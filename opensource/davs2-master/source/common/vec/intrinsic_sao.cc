/*
 * intrinsic_sao.cc
 *
 * Description of this file:
 *    SSE assembly functions of SAO module of the davs2 library
 *
 * --------------------------------------------------------------------------
 *
 *    davs2 - video decoder of AVS2/IEEE1857.4 video coding standard
 *    Copyright (C) 2018~ VCL, NELVT, Peking University
 *
 *    Authors: Falei LUO <falei.luo@gmail.com>
 *             etc.
 *
 *    This program is free software; you can redistribute it and/or modify
 *    it under the terms of the GNU General Public License as published by
 *    the Free Software Foundation; either version 2 of the License, or
 *    (at your option) any later version.
 *
 *    This program is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    GNU General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License
 *    along with this program; if not, write to the Free Software
 *    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02111, USA.
 *
 *    This program is also available under a commercial proprietary license.
 *    For more information, contact us at sswang @ pku.edu.cn.
 */

#include "../common.h"


#include "intrinsic.h"

#include <mmintrin.h>
#include <emmintrin.h>
#include <tmmintrin.h>
#include <smmintrin.h>

#ifdef _MSC_VER
#pragma warning(disable:4244)  // TODO: ��������warning
#endif

#if !HIGH_BIT_DEPTH
/* ---------------------------------------------------------------------------
 * lcu neighbor
 */
enum lcu_neighbor_e {
    SAO_T = 0,     /* top        */
    SAO_D = 1,     /* down       */
    SAO_L = 2,     /* left       */
    SAO_R = 3,     /* right      */
    SAO_TL = 4,    /* top-left   */
    SAO_TR = 5,    /* top-right  */
    SAO_DL = 6,    /* down-left  */
    SAO_DR = 7     /* down-right */
};

/* ---------------------------------------------------------------------------
 */
void SAO_on_block_eo_0_sse128(pel_t *p_dst, int i_dst, const pel_t *p_src,int i_src, int i_block_w, int i_block_h,
                              int bit_depth, const int *lcu_avail, const int *sao_offset)
{
    __m128i off0, off1, off2, off3, off4;
    __m128i s0, s1, s2;
    __m128i t0, t1, t2, t3, t4, etype;
    __m128i c0, c1, c2, c3, c4;
    __m128i mask;
    int x, y;

    UNUSED_PARAMETER(bit_depth);

    __m128i clipMin = _mm_setzero_si128();
    int end_x_16;

    c0 = _mm_set1_epi8(-2);
    c1 = _mm_set1_epi8(-1);
    c2 = _mm_set1_epi8(0);
    c3 = _mm_set1_epi8(1);
    c4 = _mm_set1_epi8(2);

    off0 = _mm_set1_epi8((int8_t)sao_offset[0]);
    off1 = _mm_set1_epi8((int8_t)sao_offset[1]);
    off2 = _mm_set1_epi8((int8_t)sao_offset[2]);
    off3 = _mm_set1_epi8((int8_t)sao_offset[3]);
    off4 = _mm_set1_epi8((int8_t)sao_offset[4]);

    int start_x = lcu_avail[SAO_L] ? 0 : 1;
    int end_x = lcu_avail[SAO_R] ? i_block_w : (i_block_w - 1);
    end_x_16 = end_x - ((end_x - start_x) & 0x0f);

    for (y = 0; y < i_block_h; y++) {
        for (x = start_x; x < end_x; x += 16) {
            s0 = _mm_loadu_si128((__m128i*)&p_src[x - 1]);
            s1 = _mm_loadu_si128((__m128i*)&p_src[x]);
            s2 = _mm_loadu_si128((__m128i*)&p_src[x + 1]);

            t3 = _mm_min_epu8(s0, s1);
            t1 = _mm_cmpeq_epi8(t3, s0);
            t2 = _mm_cmpeq_epi8(t3, s1);
            t0 = _mm_subs_epi8(t2, t1);

            t3 = _mm_min_epu8(s1, s2);
            t1 = _mm_cmpeq_epi8(t3, s1);
            t2 = _mm_cmpeq_epi8(t3, s2);
            t3 = _mm_subs_epi8(t1, t2);    //rightsign

            etype = _mm_adds_epi8(t0, t3); //edgetype=leftsign+rightsign

            t0 = _mm_cmpeq_epi8(etype, c0);
            t1 = _mm_cmpeq_epi8(etype, c1);
            t2 = _mm_cmpeq_epi8(etype, c2);
            t3 = _mm_cmpeq_epi8(etype, c3);
            t4 = _mm_cmpeq_epi8(etype, c4);

            t0 = _mm_and_si128(t0, off0);
            t1 = _mm_and_si128(t1, off1);
            t2 = _mm_and_si128(t2, off2);
            t3 = _mm_and_si128(t3, off3);
            t4 = _mm_and_si128(t4, off4);

            t0 = _mm_adds_epi8(t0, t1);
            t2 = _mm_adds_epi8(t2, t3);
            t0 = _mm_adds_epi8(t0, t4);
            t0 = _mm_adds_epi8(t0, t2);//get offset

            //add 8 nums once for possible overflow
            t1 = _mm_cvtepi8_epi16(t0);
            t0 = _mm_srli_si128(t0, 8);
            t2 = _mm_cvtepi8_epi16(t0);
            t3 = _mm_unpacklo_epi8(s1, clipMin);
            t4 = _mm_unpackhi_epi8(s1, clipMin);

            t1 = _mm_adds_epi16(t1, t3);
            t2 = _mm_adds_epi16(t2, t4);
            t0 = _mm_packus_epi16(t1, t2);

            if (x != end_x_16) {
                _mm_storeu_si128((__m128i*)(p_dst + x), t0);
            } else {
                mask = _mm_load_si128((__m128i*)(intrinsic_mask[end_x - end_x_16 - 1]));
                _mm_maskmoveu_si128(t0, mask, (char*)(p_dst + x));
                break;
            }
        }
        p_dst += i_dst;
        p_src += i_src;
    }
}

/* ---------------------------------------------------------------------------
*/
void SAO_on_block_eo_90_sse128(pel_t *p_dst, int i_dst, const pel_t *p_src, int i_src, int i_block_w, int i_block_h,
                               int bit_depth, const int *lcu_avail, const int *sao_offset)
{
    __m128i off0, off1, off2, off3, off4;
    __m128i s0, s1, s2;
    __m128i t0, t1, t2, t3, t4, etype;
    __m128i c0, c1, c2, c3, c4;
    __m128i mask;
    int x, y;

    UNUSED_PARAMETER(bit_depth);

    __m128i clipMin = _mm_setzero_si128();
    int end_x_16 = i_block_w - 15;

    c0 = _mm_set1_epi8(-2);
    c1 = _mm_set1_epi8(-1);
    c2 = _mm_set1_epi8(0);
    c3 = _mm_set1_epi8(1);
    c4 = _mm_set1_epi8(2);

    off0 = _mm_set1_epi8((int8_t)sao_offset[0]);
    off1 = _mm_set1_epi8((int8_t)sao_offset[1]);
    off2 = _mm_set1_epi8((int8_t)sao_offset[2]);
    off3 = _mm_set1_epi8((int8_t)sao_offset[3]);
    off4 = _mm_set1_epi8((int8_t)sao_offset[4]);

    int start_y = lcu_avail[SAO_T] ? 0 : 1;
    int end_y = lcu_avail[SAO_D] ? i_block_h : (i_block_h - 1);

    p_dst += start_y * i_dst;
    p_src += start_y * i_src;

    for (y = start_y; y < end_y; y++) {
        for (x = 0; x < i_block_w; x += 16) {
            s0 = _mm_loadu_si128((__m128i*)&p_src[x - i_src]);
            s1 = _mm_loadu_si128((__m128i*)&p_src[x]);
            s2 = _mm_loadu_si128((__m128i*)&p_src[x + i_src]);

            t3 = _mm_min_epu8(s0, s1);
            t1 = _mm_cmpeq_epi8(t3, s0);
            t2 = _mm_cmpeq_epi8(t3, s1);
            t0 = _mm_subs_epi8(t2, t1); //upsign

            t3 = _mm_min_epu8(s1, s2);
            t1 = _mm_cmpeq_epi8(t3, s1);
            t2 = _mm_cmpeq_epi8(t3, s2);
            t3 = _mm_subs_epi8(t1, t2); //downsign

            etype = _mm_adds_epi8(t0, t3); //edgetype

            t0 = _mm_cmpeq_epi8(etype, c0);
            t1 = _mm_cmpeq_epi8(etype, c1);
            t2 = _mm_cmpeq_epi8(etype, c2);
            t3 = _mm_cmpeq_epi8(etype, c3);
            t4 = _mm_cmpeq_epi8(etype, c4);

            t0 = _mm_and_si128(t0, off0);
            t1 = _mm_and_si128(t1, off1);
            t2 = _mm_and_si128(t2, off2);
            t3 = _mm_and_si128(t3, off3);
            t4 = _mm_and_si128(t4, off4);

            t0 = _mm_adds_epi8(t0, t1);
            t2 = _mm_adds_epi8(t2, t3);
            t0 = _mm_adds_epi8(t0, t4);
            t0 = _mm_adds_epi8(t0, t2);//get offset

            //add 8 nums once for possible overflow
            t1 = _mm_cvtepi8_epi16(t0);
            t0 = _mm_srli_si128(t0, 8);
            t2 = _mm_cvtepi8_epi16(t0);
            t3 = _mm_unpacklo_epi8(s1, clipMin);
            t4 = _mm_unpackhi_epi8(s1, clipMin);

            t1 = _mm_adds_epi16(t1, t3);
            t2 = _mm_adds_epi16(t2, t4);
            t0 = _mm_packus_epi16(t1, t2); //saturated

            if (x < end_x_16) {
                _mm_storeu_si128((__m128i*)(p_dst + x), t0);
            } else {
                mask = _mm_loadu_si128((__m128i*)(intrinsic_mask[(i_block_w & 15) - 1]));
                _mm_maskmoveu_si128(t0, mask, (char*)(p_dst + x));
                break;
            }
        }
        p_dst += i_dst;
        p_src += i_src;
    }
}

/* ---------------------------------------------------------------------------
*/
void SAO_on_block_eo_135_sse128(pel_t *p_dst, int i_dst, const pel_t *p_src, int i_src, int i_block_w, int i_block_h,
                                int bit_depth, const int *lcu_avail, const int *sao_offset)
{
    __m128i off0, off1, off2, off3, off4;
    __m128i s0, s1, s2;
    __m128i t0, t1, t2, t3, t4, etype;
    __m128i c0, c1, c2, c3, c4;
    __m128i mask_r0, mask_r, mask_rn;
    int x, y;

    __m128i clipMin = _mm_setzero_si128();
    int end_x_r0_16, end_x_r_16, end_x_rn_16;
    UNUSED_PARAMETER(bit_depth);

    c0 = _mm_set1_epi8(-2);
    c1 = _mm_set1_epi8(-1);
    c2 = _mm_set1_epi8(0);
    c3 = _mm_set1_epi8(1);
    c4 = _mm_set1_epi8(2);

    off0 = _mm_set1_epi8((int8_t)sao_offset[0]);
    off1 = _mm_set1_epi8((int8_t)sao_offset[1]);
    off2 = _mm_set1_epi8((int8_t)sao_offset[2]);
    off3 = _mm_set1_epi8((int8_t)sao_offset[3]);
    off4 = _mm_set1_epi8((int8_t)sao_offset[4]);

    //first row
    int start_x_r0 = lcu_avail[SAO_TL] ? 0 : 1;
    int end_x_r0 = lcu_avail[SAO_T] ? (lcu_avail[SAO_R] ? i_block_w : (i_block_w - 1)) : 1;
    end_x_r0_16 = end_x_r0 - ((end_x_r0 - start_x_r0) & 0x0f);
    for (x = start_x_r0; x < end_x_r0; x += 16) {
        s0 = _mm_loadu_si128((__m128i*)&p_src[x - i_src - 1]);
        s1 = _mm_loadu_si128((__m128i*)&p_src[x]);
        s2 = _mm_loadu_si128((__m128i*)&p_src[x + i_src + 1]);

        t3 = _mm_min_epu8(s0, s1);
        t1 = _mm_cmpeq_epi8(t3, s0);
        t2 = _mm_cmpeq_epi8(t3, s1);
        t0 = _mm_subs_epi8(t2, t1); //upsign

        t3 = _mm_min_epu8(s1, s2);
        t1 = _mm_cmpeq_epi8(t3, s1);
        t2 = _mm_cmpeq_epi8(t3, s2);
        t3 = _mm_subs_epi8(t1, t2); //downsign

        etype = _mm_adds_epi8(t0, t3); //edgetype

        t0 = _mm_cmpeq_epi8(etype, c0);
        t1 = _mm_cmpeq_epi8(etype, c1);
        t2 = _mm_cmpeq_epi8(etype, c2);
        t3 = _mm_cmpeq_epi8(etype, c3);
        t4 = _mm_cmpeq_epi8(etype, c4);

        t0 = _mm_and_si128(t0, off0);
        t1 = _mm_and_si128(t1, off1);
        t2 = _mm_and_si128(t2, off2);
        t3 = _mm_and_si128(t3, off3);
        t4 = _mm_and_si128(t4, off4);

        t0 = _mm_adds_epi8(t0, t1);
        t2 = _mm_adds_epi8(t2, t3);
        t0 = _mm_adds_epi8(t0, t4);
        t0 = _mm_adds_epi8(t0, t2);//get offset

        //add 8 nums once for possible overflow
        t1 = _mm_cvtepi8_epi16(t0);
        t0 = _mm_srli_si128(t0, 8);
        t2 = _mm_cvtepi8_epi16(t0);
        t3 = _mm_unpacklo_epi8(s1, clipMin);
        t4 = _mm_unpackhi_epi8(s1, clipMin);

        t1 = _mm_adds_epi16(t1, t3);
        t2 = _mm_adds_epi16(t2, t4);
        t0 = _mm_packus_epi16(t1, t2); //saturated

        if (x != end_x_r0_16) {
            _mm_storeu_si128((__m128i*)(p_dst + x), t0);
        } else {
            mask_r0 = _mm_load_si128((__m128i*)(intrinsic_mask[end_x_r0 - end_x_r0_16 - 1]));
            _mm_maskmoveu_si128(t0, mask_r0, (char*)(p_dst + x));
            break;
        }
    }
    p_dst += i_dst;
    p_src += i_src;

    //middle rows
    int start_x_r = lcu_avail[SAO_L] ? 0 : 1;
    int end_x_r = lcu_avail[SAO_R] ? i_block_w : (i_block_w - 1);
    end_x_r_16 = end_x_r - ((end_x_r - start_x_r) & 0x0f);

    for (y = 1; y < i_block_h - 1; y++) {
        for (x = start_x_r; x < end_x_r; x += 16) {
            s0 = _mm_loadu_si128((__m128i*)&p_src[x - i_src - 1]);
            s1 = _mm_loadu_si128((__m128i*)&p_src[x]);
            s2 = _mm_loadu_si128((__m128i*)&p_src[x + i_src + 1]);

            t3 = _mm_min_epu8(s0, s1);
            t1 = _mm_cmpeq_epi8(t3, s0);
            t2 = _mm_cmpeq_epi8(t3, s1);
            t0 = _mm_subs_epi8(t2, t1); //upsign

            t3 = _mm_min_epu8(s1, s2);
            t1 = _mm_cmpeq_epi8(t3, s1);
            t2 = _mm_cmpeq_epi8(t3, s2);
            t3 = _mm_subs_epi8(t1, t2); //downsign

            etype = _mm_adds_epi8(t0, t3); //edgetype

            t0 = _mm_cmpeq_epi8(etype, c0);
            t1 = _mm_cmpeq_epi8(etype, c1);
            t2 = _mm_cmpeq_epi8(etype, c2);
            t3 = _mm_cmpeq_epi8(etype, c3);
            t4 = _mm_cmpeq_epi8(etype, c4);

            t0 = _mm_and_si128(t0, off0);
            t1 = _mm_and_si128(t1, off1);
            t2 = _mm_and_si128(t2, off2);
            t3 = _mm_and_si128(t3, off3);
            t4 = _mm_and_si128(t4, off4);

            t0 = _mm_adds_epi8(t0, t1);
            t2 = _mm_adds_epi8(t2, t3);
            t0 = _mm_adds_epi8(t0, t4);
            t0 = _mm_adds_epi8(t0, t2);//get offset

            //add 8 nums once for possible overflow
            t1 = _mm_cvtepi8_epi16(t0);
            t0 = _mm_srli_si128(t0, 8);
            t2 = _mm_cvtepi8_epi16(t0);
            t3 = _mm_unpacklo_epi8(s1, clipMin);
            t4 = _mm_unpackhi_epi8(s1, clipMin);

            t1 = _mm_adds_epi16(t1, t3);
            t2 = _mm_adds_epi16(t2, t4);
            t0 = _mm_packus_epi16(t1, t2); //saturated

            if (x != end_x_r_16) {
                _mm_storeu_si128((__m128i*)(p_dst + x), t0);
            } else {
                mask_r = _mm_load_si128((__m128i*)(intrinsic_mask[end_x_r - end_x_r_16 - 1]));
                _mm_maskmoveu_si128(t0, mask_r, (char*)(p_dst + x));
                break;
            }
        }
        p_dst += i_dst;
        p_src += i_src;
    }
    //last row
    int start_x_rn = lcu_avail[SAO_D] ? (lcu_avail[SAO_L] ? 0 : 1) : (i_block_w - 1);
    int end_x_rn = lcu_avail[SAO_DR] ? i_block_w : (i_block_w - 1);
    end_x_rn_16 = end_x_rn - ((end_x_rn - start_x_rn) & 0x0f);
    for (x = start_x_rn; x < end_x_rn; x += 16) {
        s0 = _mm_loadu_si128((__m128i*)&p_src[x - i_src - 1]);
        s1 = _mm_loadu_si128((__m128i*)&p_src[x]);
        s2 = _mm_loadu_si128((__m128i*)&p_src[x + i_src + 1]);

        t3 = _mm_min_epu8(s0, s1);
        t1 = _mm_cmpeq_epi8(t3, s0);
        t2 = _mm_cmpeq_epi8(t3, s1);
        t0 = _mm_subs_epi8(t2, t1); //upsign

        t3 = _mm_min_epu8(s1, s2);
        t1 = _mm_cmpeq_epi8(t3, s1);
        t2 = _mm_cmpeq_epi8(t3, s2);
        t3 = _mm_subs_epi8(t1, t2); //downsign

        etype = _mm_adds_epi8(t0, t3); //edgetype

        t0 = _mm_cmpeq_epi8(etype, c0);
        t1 = _mm_cmpeq_epi8(etype, c1);
        t2 = _mm_cmpeq_epi8(etype, c2);
        t3 = _mm_cmpeq_epi8(etype, c3);
        t4 = _mm_cmpeq_epi8(etype, c4);

        t0 = _mm_and_si128(t0, off0);
        t1 = _mm_and_si128(t1, off1);
        t2 = _mm_and_si128(t2, off2);
        t3 = _mm_and_si128(t3, off3);
        t4 = _mm_and_si128(t4, off4);

        t0 = _mm_adds_epi8(t0, t1);
        t2 = _mm_adds_epi8(t2, t3);
        t0 = _mm_adds_epi8(t0, t4);
        t0 = _mm_adds_epi8(t0, t2);//get offset

        //add 8 nums once for possible overflow
        t1 = _mm_cvtepi8_epi16(t0);
        t0 = _mm_srli_si128(t0, 8);
        t2 = _mm_cvtepi8_epi16(t0);
        t3 = _mm_unpacklo_epi8(s1, clipMin);
        t4 = _mm_unpackhi_epi8(s1, clipMin);

        t1 = _mm_adds_epi16(t1, t3);
        t2 = _mm_adds_epi16(t2, t4);
        t0 = _mm_packus_epi16(t1, t2); //saturated

        if (x != end_x_rn_16) {
            _mm_storeu_si128((__m128i*)(p_dst + x), t0);
        } else {
            mask_rn = _mm_load_si128((__m128i*)(intrinsic_mask[end_x_rn - end_x_rn_16 - 1]));
            _mm_maskmoveu_si128(t0, mask_rn, (char*)(p_dst + x));
            break;
        }
    }
}

/* ---------------------------------------------------------------------------
*/
void SAO_on_block_eo_45_sse128(pel_t *p_dst, int i_dst, const pel_t *p_src, int i_src, int i_block_w, int i_block_h,
                               int bit_depth, const int *lcu_avail, const int *sao_offset)
{
    __m128i off0, off1, off2, off3, off4;
    __m128i s0, s1, s2;
    __m128i t0, t1, t2, t3, t4, etype;
    __m128i c0, c1, c2, c3, c4;
    __m128i mask_r0, mask_r, mask_rn;
    int x, y;

    __m128i clipMin = _mm_setzero_si128();
    int end_x_r0_16, end_x_r_16, end_x_rn_16;
    UNUSED_PARAMETER(bit_depth);

    c0 = _mm_set1_epi8(-2);
    c1 = _mm_set1_epi8(-1);
    c2 = _mm_set1_epi8(0);
    c3 = _mm_set1_epi8(1);
    c4 = _mm_set1_epi8(2);

    off0 = _mm_set1_epi8((int8_t)sao_offset[0]);
    off1 = _mm_set1_epi8((int8_t)sao_offset[1]);
    off2 = _mm_set1_epi8((int8_t)sao_offset[2]);
    off3 = _mm_set1_epi8((int8_t)sao_offset[3]);
    off4 = _mm_set1_epi8((int8_t)sao_offset[4]);

    //first row
    int start_x_r0 = lcu_avail[SAO_T] ? (lcu_avail[SAO_L] ? 0 : 1) : (i_block_w - 1);
    int end_x_r0 = lcu_avail[SAO_TR] ? i_block_w : (i_block_w - 1);
    end_x_r0_16 = end_x_r0 - ((end_x_r0 - start_x_r0) & 0x0f);
    for (x = start_x_r0; x < end_x_r0; x += 16) {
        s0 = _mm_loadu_si128((__m128i*)&p_src[x - i_src + 1]);
        s1 = _mm_loadu_si128((__m128i*)&p_src[x]);
        s2 = _mm_loadu_si128((__m128i*)&p_src[x + i_src - 1]);

        t3 = _mm_min_epu8(s0, s1);
        t1 = _mm_cmpeq_epi8(t3, s0);
        t2 = _mm_cmpeq_epi8(t3, s1);
        t0 = _mm_subs_epi8(t2, t1); //upsign

        t3 = _mm_min_epu8(s1, s2);
        t1 = _mm_cmpeq_epi8(t3, s1);
        t2 = _mm_cmpeq_epi8(t3, s2);
        t3 = _mm_subs_epi8(t1, t2); //downsign

        etype = _mm_adds_epi8(t0, t3); //edgetype

        t0 = _mm_cmpeq_epi8(etype, c0);
        t1 = _mm_cmpeq_epi8(etype, c1);
        t2 = _mm_cmpeq_epi8(etype, c2);
        t3 = _mm_cmpeq_epi8(etype, c3);
        t4 = _mm_cmpeq_epi8(etype, c4);

        t0 = _mm_and_si128(t0, off0);
        t1 = _mm_and_si128(t1, off1);
        t2 = _mm_and_si128(t2, off2);
        t3 = _mm_and_si128(t3, off3);
        t4 = _mm_and_si128(t4, off4);

        t0 = _mm_adds_epi8(t0, t1);
        t2 = _mm_adds_epi8(t2, t3);
        t0 = _mm_adds_epi8(t0, t4);
        t0 = _mm_adds_epi8(t0, t2);//get offset

        //add 8 nums once for possible overflow
        t1 = _mm_cvtepi8_epi16(t0);
        t0 = _mm_srli_si128(t0, 8);
        t2 = _mm_cvtepi8_epi16(t0);
        t3 = _mm_unpacklo_epi8(s1, clipMin);
        t4 = _mm_unpackhi_epi8(s1, clipMin);

        t1 = _mm_adds_epi16(t1, t3);
        t2 = _mm_adds_epi16(t2, t4);
        t0 = _mm_packus_epi16(t1, t2); //saturated

        if (x != end_x_r0_16) {
            _mm_storeu_si128((__m128i*)(p_dst + x), t0);
        } else {
            mask_r0 = _mm_load_si128((__m128i*)(intrinsic_mask[end_x_r0 - end_x_r0_16 - 1]));
            _mm_maskmoveu_si128(t0, mask_r0, (char*)(p_dst + x));
            break;
        }
    }
    p_dst += i_dst;
    p_src += i_src;
    //middle rows
    int start_x_r = lcu_avail[SAO_L] ? 0 : 1;
    int end_x_r = lcu_avail[SAO_R] ? i_block_w : (i_block_w - 1);
    end_x_r_16 = end_x_r - ((end_x_r - start_x_r) & 0x0f);
    for (y = 1; y < i_block_h - 1; y++) {
        for (x = start_x_r; x < end_x_r; x += 16) {
            s0 = _mm_loadu_si128((__m128i*)&p_src[x - i_src + 1]);
            s1 = _mm_loadu_si128((__m128i*)&p_src[x]);
            s2 = _mm_loadu_si128((__m128i*)&p_src[x + i_src - 1]);

            t3 = _mm_min_epu8(s0, s1);
            t1 = _mm_cmpeq_epi8(t3, s0);
            t2 = _mm_cmpeq_epi8(t3, s1);
            t0 = _mm_subs_epi8(t2, t1); //upsign

            t3 = _mm_min_epu8(s1, s2);
            t1 = _mm_cmpeq_epi8(t3, s1);
            t2 = _mm_cmpeq_epi8(t3, s2);
            t3 = _mm_subs_epi8(t1, t2); //downsign

            etype = _mm_adds_epi8(t0, t3); //edgetype

            t0 = _mm_cmpeq_epi8(etype, c0);
            t1 = _mm_cmpeq_epi8(etype, c1);
            t2 = _mm_cmpeq_epi8(etype, c2);
            t3 = _mm_cmpeq_epi8(etype, c3);
            t4 = _mm_cmpeq_epi8(etype, c4);

            t0 = _mm_and_si128(t0, off0);
            t1 = _mm_and_si128(t1, off1);
            t2 = _mm_and_si128(t2, off2);
            t3 = _mm_and_si128(t3, off3);
            t4 = _mm_and_si128(t4, off4);

            t0 = _mm_adds_epi8(t0, t1);
            t2 = _mm_adds_epi8(t2, t3);
            t0 = _mm_adds_epi8(t0, t4);
            t0 = _mm_adds_epi8(t0, t2);//get offset

            //add 8 nums once for possible overflow
            t1 = _mm_cvtepi8_epi16(t0);
            t0 = _mm_srli_si128(t0, 8);
            t2 = _mm_cvtepi8_epi16(t0);
            t3 = _mm_unpacklo_epi8(s1, clipMin);
            t4 = _mm_unpackhi_epi8(s1, clipMin);

            t1 = _mm_adds_epi16(t1, t3);
            t2 = _mm_adds_epi16(t2, t4);
            t0 = _mm_packus_epi16(t1, t2); //saturated

            if (x != end_x_r_16) {
                _mm_storeu_si128((__m128i*)(p_dst + x), t0);
            } else {
                mask_r = _mm_load_si128((__m128i*)(intrinsic_mask[end_x_r - end_x_r_16 - 1]));
                _mm_maskmoveu_si128(t0, mask_r, (char*)(p_dst + x));
                break;
            }
        }
        p_dst += i_dst;
        p_src += i_src;
    }
    //last row
    int start_x_rn = lcu_avail[SAO_DL] ? 0 : 1;
    int end_x_rn = lcu_avail[SAO_D] ? (lcu_avail[SAO_R] ? i_block_w : (i_block_w - 1)) : 1;
    end_x_rn_16 = end_x_rn - ((end_x_rn - start_x_rn) & 0x0f);
    for (x = start_x_rn; x < end_x_rn; x += 16) {
        s0 = _mm_loadu_si128((__m128i*)&p_src[x - i_src + 1]);
        s1 = _mm_loadu_si128((__m128i*)&p_src[x]);
        s2 = _mm_loadu_si128((__m128i*)&p_src[x + i_src - 1]);

        t3 = _mm_min_epu8(s0, s1);
        t1 = _mm_cmpeq_epi8(t3, s0);
        t2 = _mm_cmpeq_epi8(t3, s1);
        t0 = _mm_subs_epi8(t2, t1); //upsign

        t3 = _mm_min_epu8(s1, s2);
        t1 = _mm_cmpeq_epi8(t3, s1);
        t2 = _mm_cmpeq_epi8(t3, s2);
        t3 = _mm_subs_epi8(t1, t2); //downsign

        etype = _mm_adds_epi8(t0, t3); //edgetype

        t0 = _mm_cmpeq_epi8(etype, c0);
        t1 = _mm_cmpeq_epi8(etype, c1);
        t2 = _mm_cmpeq_epi8(etype, c2);
        t3 = _mm_cmpeq_epi8(etype, c3);
        t4 = _mm_cmpeq_epi8(etype, c4);

        t0 = _mm_and_si128(t0, off0);
        t1 = _mm_and_si128(t1, off1);
        t2 = _mm_and_si128(t2, off2);
        t3 = _mm_and_si128(t3, off3);
        t4 = _mm_and_si128(t4, off4);

        t0 = _mm_adds_epi8(t0, t1);
        t2 = _mm_adds_epi8(t2, t3);
        t0 = _mm_adds_epi8(t0, t4);
        t0 = _mm_adds_epi8(t0, t2);//get offset

        //add 8 nums once for possible overflow
        t1 = _mm_cvtepi8_epi16(t0);
        t0 = _mm_srli_si128(t0, 8);
        t2 = _mm_cvtepi8_epi16(t0);
        t3 = _mm_unpacklo_epi8(s1, clipMin);
        t4 = _mm_unpackhi_epi8(s1, clipMin);

        t1 = _mm_adds_epi16(t1, t3);
        t2 = _mm_adds_epi16(t2, t4);
        t0 = _mm_packus_epi16(t1, t2); //saturated

        if (x != end_x_rn_16) {
            _mm_storeu_si128((__m128i*)(p_dst + x), t0);
        } else {
            mask_rn = _mm_load_si128((__m128i*)(intrinsic_mask[end_x_rn - end_x_rn_16 - 1]));
            _mm_maskmoveu_si128(t0, mask_rn, (char*)(p_dst + x));
            break;
        }
    }
}

/* ---------------------------------------------------------------------------
*/
void SAO_on_block_bo_sse128(pel_t *p_dst, int i_dst,
                            const pel_t *p_src, int i_src,
                            int i_block_w, int i_block_h,
                            int bit_depth, const sao_param_t *sao_param)
{
    __m128i r0, r1, r2, r3, off0, off1, off2, off3;
    __m128i t0, t1, t2, t3;
    __m128i mask;
    int shift_bo = g_bit_depth - NUM_SAO_BO_CLASSES_IN_BIT;
    int x, y;

    __m128i src0, src1;
    __m128i shift_mask = _mm_set1_epi8(31);
    __m128i clipMin = _mm_setzero_si128();
    int end_x_16 = i_block_w - 15;

    UNUSED_PARAMETER(bit_depth);

    r0 = _mm_set1_epi8((int8_t)(sao_param->startBand));
    r1 = _mm_set1_epi8((int8_t)((sao_param->startBand + 1) & 31));
    r2 = _mm_set1_epi8((int8_t)(sao_param->startBand2));
    r3 = _mm_set1_epi8((int8_t)((sao_param->startBand2 + 1) & 31));

    off0 = _mm_set1_epi8((int8_t)sao_param->offset[sao_param->startBand]);
    off1 = _mm_set1_epi8((int8_t)sao_param->offset[(sao_param->startBand + 1) & 31]);
    off2 = _mm_set1_epi8((int8_t)sao_param->offset[sao_param->startBand2]);
    off3 = _mm_set1_epi8((int8_t)sao_param->offset[(sao_param->startBand2 + 1) & 31]);

    for (y = 0; y < i_block_h; y++) {
        for (x = 0; x < i_block_w; x += 16) {
            __m128i t4;
            src0 = _mm_loadu_si128((__m128i*)&p_src[x]);
            src1 = _mm_and_si128(_mm_srai_epi16(src0, shift_bo), shift_mask);

            t0 = _mm_cmpeq_epi8(src1, r0);
            t1 = _mm_cmpeq_epi8(src1, r1);
            t2 = _mm_cmpeq_epi8(src1, r2);
            t3 = _mm_cmpeq_epi8(src1, r3);

            t0 = _mm_and_si128(t0, off0);
            t1 = _mm_and_si128(t1, off1);
            t2 = _mm_and_si128(t2, off2);
            t3 = _mm_and_si128(t3, off3);

            t0 = _mm_or_si128(t0, t1);
            t2 = _mm_or_si128(t2, t3);
            t0 = _mm_or_si128(t0, t2);//get offset

            //add 8 nums once for possible overflow
            t1 = _mm_cvtepi8_epi16(t0);
            t0 = _mm_srli_si128(t0, 8);
            t2 = _mm_cvtepi8_epi16(t0);
            t3 = _mm_unpacklo_epi8(src0, clipMin);
            t4 = _mm_unpackhi_epi8(src0, clipMin);

            t1 = _mm_adds_epi16(t1, t3);
            t2 = _mm_adds_epi16(t2, t4);
            src0 = _mm_packus_epi16(t1, t2); //saturated

            if (x < end_x_16) {
                _mm_storeu_si128((__m128i*)&p_dst[x], src0);
            } else {
                mask = _mm_load_si128((const __m128i*)intrinsic_mask[(i_block_w & 15) - 1]);
                _mm_maskmoveu_si128(src0, mask, (char*)(p_dst + x));
            }
        }
        p_dst += i_dst;
        p_src += i_src;
    }
}

#endif // !HIGH_BIT_DEPTH
