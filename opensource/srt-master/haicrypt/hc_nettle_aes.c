/*
 * SRT - Secure, Reliable, Transport
 * Copyright (c) 2018 Haivision Systems Inc.
 * 
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 * 
 */

/*
 * Author(s):
 *     Justin Kim <justin.kim@collabora.com>
 */ 

#include "hcrypt.h"

#include <stdlib.h>
#include <string.h>

typedef struct tag_hcNettle_AES_data
{
  AES_KEY aes_key[2];           /* even/odd SEK */

#define	HCRYPT_OPENSSL_OUTMSGMAX		6
  uint8_t *outbuf;              /* output circle buffer */
  size_t outbuf_ofs;            /* write offset in circle buffer */
  size_t outbuf_siz;            /* circle buffer size */
} hcNettle_AES_data;

static const unsigned char default_iv[] = {
  0xA6, 0xA6, 0xA6, 0xA6, 0xA6, 0xA6, 0xA6, 0xA6,
};

int
hcrypt_WrapKey (AES_KEY * key, unsigned char *out,
    const unsigned char *in, unsigned int inlen)
{
  unsigned char *A, B[16], *R;
  unsigned int i, j, t;
  if ((inlen & 0x7) || (inlen < 8))
    return -1;
  A = B;
  t = 1;
  memcpy (out + 8, in, inlen);
  memcpy (A, default_iv, 8);

  for (j = 0; j < 6; j++) {
    R = out + 8;
    for (i = 0; i < inlen; i += 8, t++, R += 8) {
      memcpy (B + 8, R, 8);
      aes_encrypt(key, sizeof(B), B, B);
      A[7] ^= (unsigned char) (t & 0xff);
      if (t > 0xff) {
        A[6] ^= (unsigned char) ((t >> 8) & 0xff);
        A[5] ^= (unsigned char) ((t >> 16) & 0xff);
        A[4] ^= (unsigned char) ((t >> 24) & 0xff);
      }
      memcpy (R, B + 8, 8);
    }
  }
  memcpy (out, A, 8);
  return inlen + 8;
}

int
hcrypt_UnwrapKey (AES_KEY * key, unsigned char *out,
    const unsigned char *in, unsigned int inlen)
{
  unsigned char *A, B[16], *R;
  unsigned int i, j, t;
  inlen -= 8;
  if (inlen & 0x7)
    return -1;
  if (inlen < 8)
    return -1;
  A = B;
  t = 6 * (inlen >> 3);
  memcpy (A, in, 8);
  memcpy (out, in + 8, inlen);
  for (j = 0; j < 6; j++) {
    R = out + inlen - 8;
    for (i = 0; i < inlen; i += 8, t--, R -= 8) {
      A[7] ^= (unsigned char) (t & 0xff);
      if (t > 0xff) {
        A[6] ^= (unsigned char) ((t >> 8) & 0xff);
        A[5] ^= (unsigned char) ((t >> 16) & 0xff);
        A[4] ^= (unsigned char) ((t >> 24) & 0xff);
      }
      memcpy (B + 8, R, 8);
      aes_decrypt(key, sizeof(B), B, B);
      memcpy (R, B + 8, 8);
    }
  }
  if (memcmp (A, default_iv, 8) != 0) {
    memset (out, 0, inlen);
    return 0;
  }
  return inlen;
}

static unsigned char *
hcNettle_AES_GetOutbuf (hcNettle_AES_data * aes_data, size_t pfx_len,
    size_t out_len)
{
  unsigned char *out_buf;

  if ((pfx_len + out_len) > (aes_data->outbuf_siz - aes_data->outbuf_ofs)) {
    /* Not enough room left, circle buffers */
    aes_data->outbuf_ofs = 0;
  }
  out_buf = &aes_data->outbuf[aes_data->outbuf_ofs];
  aes_data->outbuf_ofs += (pfx_len + out_len);
  return (out_buf);
}

static hcrypt_CipherData *
hcNettle_AES_Open (size_t max_len)
{
  hcNettle_AES_data *aes_data;
  unsigned char *membuf;
  size_t memsiz, padded_len = hcryptMsg_PaddedLen (max_len, 128 / 8);

  HCRYPT_LOG (LOG_DEBUG, "%s", "Using Nettle AES\n");

  memsiz = sizeof (*aes_data) + (HCRYPT_OPENSSL_OUTMSGMAX * padded_len);
  aes_data = malloc (memsiz);
  if (NULL == aes_data) {
    HCRYPT_LOG (LOG_ERR, "malloc(%zd) failed\n", memsiz);
    return (NULL);
  }
  membuf = (unsigned char *) aes_data;
  membuf += sizeof (*aes_data);

  aes_data->outbuf = membuf;
  aes_data->outbuf_siz = HCRYPT_OPENSSL_OUTMSGMAX * padded_len;
  aes_data->outbuf_ofs = 0;
//      membuf += aes_data->outbuf_siz;

  return ((hcrypt_CipherData *) aes_data);
}

static int
hcNettle_AES_Close (hcrypt_CipherData * cipher_data)
{
  if (NULL != cipher_data) {
    free (cipher_data);
  }
  return (0);
}

static int
hcNettle_AES_SetKey (hcrypt_CipherData * cipher_data, hcrypt_Ctx * ctx,
    unsigned char *key, size_t key_len)
{
  hcNettle_AES_data *aes_data = (hcNettle_AES_data *) cipher_data;
  AES_KEY *aes_key = &aes_data->aes_key[hcryptCtx_GetKeyIndex (ctx)];   /* Ctx tells if it's for odd or even key */

  if ((ctx->flags & HCRYPT_CTX_F_ENCRYPT)       /* Encrypt key */
      ||(ctx->mode == HCRYPT_CTX_MODE_AESCTR)) {        /* CTR mode decrypts using encryption methods */
    if (hcrypt_aes_set_encrypt_key (key, key_len * 8, aes_key)) {
      HCRYPT_LOG (LOG_ERR, "%s", "AES_set_encrypt_key(sek) failed\n");
      return (-1);
    }
  } else {                      /* Decrypt key */
    if (hcrypt_aes_set_decrypt_key (key, key_len * 8, aes_key)) {
      HCRYPT_LOG (LOG_ERR, "%s", "AES_set_decrypt_key(sek) failed\n");
      return (-1);
    }
  }
  return (0);
}

static int
hcNettle_AES_Encrypt (hcrypt_CipherData * cipher_data,
    hcrypt_Ctx * ctx,
    hcrypt_DataDesc * in_data, int nbin,
    void *out_p[], size_t out_len_p[], int *nbout_p)
{
  hcNettle_AES_data *aes_data = (hcNettle_AES_data *) cipher_data;
  unsigned char *out_msg;
  int out_len = 0;              //payload size
  int pfx_len;

  ASSERT (NULL != ctx);
  ASSERT (NULL != aes_data);
  ASSERT ((NULL != in_data) || (1 == nbin));    //Only one in_data[] supported

  /* 
   * Get message prefix length
   * to reserve room for unencrypted message header in output buffer
   */
  pfx_len = ctx->msg_info->pfx_len;

  /* Get buffer room from the internal circular output buffer */
  out_msg = hcNettle_AES_GetOutbuf (aes_data, pfx_len, in_data[0].len);

  if (NULL != out_msg) {
    switch (ctx->mode) {
      case HCRYPT_CTX_MODE_AESCTR:     /* Counter mode */
      {
        /* Get current key (odd|even) from context */
        AES_KEY *aes_key = &aes_data->aes_key[hcryptCtx_GetKeyIndex (ctx)];
        unsigned char ctr[AES_BLOCK_SIZE];
        unsigned char iv[AES_BLOCK_SIZE];

        /* Get input packet index (in network order) */
        hcrypt_Pki pki = hcryptMsg_GetPki (ctx->msg_info, in_data[0].pfx, 1);

        /*
         * Compute the Initial Vector
         * IV (128-bit):
         *    0   1   2   3   4   5  6   7   8   9   10  11  12  13  14  15
         * +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
         * |                   0s                  |      pki      |  ctr  |
         * +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
         *                            XOR                         
         * +---+---+---+---+---+---+---+---+---+---+---+---+---+---+
         * |                         nonce                         +
         * +---+---+---+---+---+---+---+---+---+---+---+---+---+---+
         *
         * pki    (32-bit): packet index
         * ctr    (16-bit): block counter
         * nonce (112-bit): number used once (salt)
         */
        memset (&ctr[0], 0, sizeof (ctr));
        hcrypt_SetCtrIV ((unsigned char *) &pki, ctx->salt, iv);

        /* Encrypt packet payload in output message buffer */
        ctr_crypt (aes_key,        /* ctx */
                   (nettle_crypt_func*)aes_encrypt, /* nettle_cipher_func */
                   AES_BLOCK_SIZE, /* cipher blocksize */
                   iv,             /* iv */
                   in_data[0].len, /* length */
                   &out_msg[pfx_len],   /* dest */
                   in_data[0].payload   /* src */);

        /* Prepend packet prefix (clear text) in output buffer */
        memcpy (out_msg, in_data[0].pfx, pfx_len);
        /* CTR mode output length is same as input, no padding */
        out_len = in_data[0].len;

        break;
      }
      case HCRYPT_CTX_MODE_AESECB:     /* Electronic Codebook mode (VF-AES) */
      {
        int i;
        int nb = in_data[0].len / AES_BLOCK_SIZE;
        int nmore = in_data[0].len % AES_BLOCK_SIZE;
        AES_KEY *aes_key = &aes_data->aes_key[hcryptCtx_GetKeyIndex (ctx)];

        /* Encrypt packet payload, block by block, in output buffer */
        for (i = 0; i < nb; i++) {
          aes_encrypt (aes_key, AES_BLOCK_SIZE, 
                          &out_msg[pfx_len + (i*AES_BLOCK_SIZE)],
                          &in_data[0].payload[(i*AES_BLOCK_SIZE)]);
        }
        /* Encrypt last incomplete block */
        if (0 < nmore) {
          unsigned char intxt[AES_BLOCK_SIZE];
          memcpy (intxt, &in_data[0].payload[(nb * AES_BLOCK_SIZE)], nmore);
          memset (intxt + nmore, 0, AES_BLOCK_SIZE - nmore);
          aes_encrypt (aes_key, AES_BLOCK_SIZE, 
                          &out_msg[pfx_len + (nb*AES_BLOCK_SIZE)],
                          intxt);
          nb++;
          //VF patch: pass padding size in pki
          ctx->msg_info->setPki (out_msg, 16 - nmore);
        }
        /* Prepend packet prefix (clear text) in output message buffer */
        memcpy (out_msg, in_data[0].pfx, pfx_len);
        /* ECB mode output length is on AES block (128 bits) boundary */
        out_len = nb * AES_BLOCK_SIZE;
        break;
      }
      case HCRYPT_CTX_MODE_CLRTXT:     /* Clear text mode (transparent mode for tests) */
        memcpy (&out_msg[pfx_len], in_data[0].payload, in_data[0].len);
        memcpy (out_msg, in_data[0].pfx, pfx_len);
        out_len = in_data[0].len;
        break;
      default:
        /* Unsupported cipher mode */
        return (-1);
    }
  } else {
    /* input data too big */
    return (-1);
  }

  if (out_len > 0) {
    /* Encrypted messages have been produced */
    if (NULL == out_p) {
      /* 
       * Application did not provided output buffer, 
       * so copy encrypted message back in input buffer
       */
      memcpy (in_data[0].pfx, out_msg, pfx_len);
      memcpy (in_data[0].payload, &out_msg[pfx_len], out_len);
      in_data[0].len = out_len;
    } else {
      /*
       * Set output buffer array to internal circular buffers
       */
      out_p[0] = out_msg;
      out_len_p[0] = pfx_len + out_len;
      *nbout_p = 1;
    }
  } else {
    /*
     * Nothing out
     * This is not an error for implementations using deferred/async processing
     * with co-processor, DSP, crypto hardware, etc.
     * Submitted input data could be returned encrypted in a next call.
     */
    if (nbout_p != NULL)
      *nbout_p = 0;
    return (-1);
  }
  return (0);
}



static int
hcNettle_AES_Decrypt (hcrypt_CipherData * cipher_data, hcrypt_Ctx * ctx,
    hcrypt_DataDesc * in_data, int nbin, void *out_p[], size_t out_len_p[],
    int *nbout_p)
{
  hcNettle_AES_data *aes_data = (hcNettle_AES_data *) cipher_data;
  unsigned char *out_txt;
  int out_len;
  int iret = 0;

  ASSERT (NULL != aes_data);
  ASSERT (NULL != ctx);
  ASSERT ((NULL != in_data) || (1 == nbin));    //Only one in_data[] supported

  /* Reserve output buffer (w/no header) */
  out_txt = hcNettle_AES_GetOutbuf (aes_data, 0, in_data[0].len);

  if (NULL != out_txt) {
    switch (ctx->mode) {
      case HCRYPT_CTX_MODE_AESCTR:
      {
        /* Get current key (odd|even) from context */
        AES_KEY *aes_key = &aes_data->aes_key[hcryptCtx_GetKeyIndex (ctx)];
        unsigned char ctr[AES_BLOCK_SIZE];
        unsigned char iv[AES_BLOCK_SIZE];

        /* Get input message index (in network order) */
        hcrypt_Pki pki = hcryptMsg_GetPki (ctx->msg_info, in_data[0].pfx, 1);

        /*
         * Compute the Initial Vector
         * IV (128-bit):
         *    0   1   2   3   4   5  6   7   8   9   10  11  12  13  14  15
         * +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
         * |                   0s                  |      pki      |  ctr  |
         * +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
         *                            XOR                         
         * +---+---+---+---+---+---+---+---+---+---+---+---+---+---+
         * |                         nonce                         +
         * +---+---+---+---+---+---+---+---+---+---+---+---+---+---+
         *
         * pki    (32-bit): packet index
         * ctr    (16-bit): block counter
         * nonce (112-bit): number used once (salt)
         */
        memset (&ctr[0], 0, sizeof (ctr));
        hcrypt_SetCtrIV ((unsigned char *) &pki, ctx->salt, iv);

        /* Decrypt message (same as encrypt for CTR mode) */
        ctr_crypt (aes_key,        /* ctx */
                   (nettle_crypt_func*)aes_encrypt, /* nettle_cipher_func */
                   AES_BLOCK_SIZE, /* cipher blocksize */
                   iv,             /* iv */
                   in_data[0].len, /* length */
                   out_txt,             /* dest */
                   in_data[0].payload   /* src */);

        out_len = in_data[0].len;
        break;
      }
      case HCRYPT_CTX_MODE_AESECB:
      {
        int i;
        int nb = in_data[0].len / AES_BLOCK_SIZE;
        unsigned nbpad = ctx->msg_info->getPki (in_data[0].pfx, 0);     //Patch
        AES_KEY *aes_key = &aes_data->aes_key[hcryptCtx_GetKeyIndex (ctx)];

        /* Decrypt message (same as encrypt for CTR mode) */
        for (i = 0; i < nb; i++) {
          aes_encrypt (aes_key, AES_BLOCK_SIZE, 
                          &out_txt[i*AES_BLOCK_SIZE],
                          &in_data[0].payload[(i*AES_BLOCK_SIZE)]);
        }
        out_len = in_data[0].len - nbpad;
        break;
      }
      case HCRYPT_CTX_MODE_CLRTXT:
        memcpy (out_txt, in_data[0].payload, in_data[0].len);
        out_len = in_data[0].len;
        break;
      default:
        return (-1);
    }
  } else {
    return (-1);
  }

  if (out_len > 0) {
    if (NULL == out_p) {
      /* Decrypt in-place (in input buffer) */
      memcpy (in_data[0].payload, out_txt, out_len);
      in_data[0].len = out_len;
    } else {
      out_p[0] = out_txt;
      out_len_p[0] = out_len;
      *nbout_p = 1;
    }
    iret = 0;
  } else {
    if (NULL != nbout_p)
      *nbout_p = 0;
    iret = -1;
  }

  return (iret);
}


static hcrypt_Cipher hcNettle_AES_cipher;

HaiCrypt_Cipher
HaiCryptCipher_Get_Instance (void)
{
  hcNettle_AES_cipher.open = hcNettle_AES_Open;
  hcNettle_AES_cipher.close = hcNettle_AES_Close;
  hcNettle_AES_cipher.setkey = hcNettle_AES_SetKey;
  hcNettle_AES_cipher.encrypt = hcNettle_AES_Encrypt;
  hcNettle_AES_cipher.decrypt = hcNettle_AES_Decrypt;

  return ((HaiCrypt_Cipher) & hcNettle_AES_cipher);
}
