/*
 * mc.h
 *
 * Description of this file:
 *    MC functions definition of the xavs2 library
 *
 * --------------------------------------------------------------------------
 *
 *    xavs2 - video encoder of AVS2/IEEE1857.4 video coding standard
 *    Copyright (C) 2018~ VCL, NELVT, Peking University
 *
 *    Authors: Falei LUO <falei.luo@gmail.com>
 *             etc.
 *
 *    Homepage1: http://vcl.idm.pku.edu.cn/xavs2
 *    Homepage2: https://github.com/pkuvcl/xavs2
 *    Homepage3: https://gitee.com/pkuvcl/xavs2
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

#ifndef XAVS2_MC_H
#define XAVS2_MC_H

/**
 * ===========================================================================
 * inline function declares
 * ===========================================================================
 */

/* ---------------------------------------------------------------------------
 * img_size: �����ؾ��ȵ�ͼ�� ��Ȼ�߶� �������ؾ��ȣ�
 * blk_size: ��ǰԤ���� ��Ȼ�߶�     �������ؾ��ȣ�
 * blk_pos:  ��ǰ����ͼ���е� x/y ����   �������ؾ��ȣ�
 * mv     :  MV �� x/y ����             ��1/4���ؾ��ȣ�
 */
static INLINE
int cu_get_mc_pos(int img_size, int blk_size, int blk_pos, int mv)
{
    int imv = mv >> 2;  // MV�������ؾ���
    int fmv = mv & 7;   // MV�ķ����ؾ��Ȳ��֣������� 1/8 ����

    if (blk_pos + imv < -blk_size - 8) {
        return ((-blk_size - 8) << 2) + (fmv);
    } else if (blk_pos + imv > img_size + 4) {
        return ((img_size + 4) << 2) + (fmv);
    } else {
        return (blk_pos << 2) + mv;
    }
}

/* ---------------------------------------------------------------------------
 */
static ALWAYS_INLINE
void get_mv_for_mc(xavs2_t *h, mv_t *mv, int pic_pix_x, int pic_pix_y, int blk_w, int blk_h)
{
    // WARNING: ��ͼ��ֱ���Ϊ 4K ������ʱ�������㹻��8K ʱ������
    mv->x = (int16_t)cu_get_mc_pos(h->i_width,  blk_w, pic_pix_x, mv->x);
    mv->y = (int16_t)cu_get_mc_pos(h->i_height, blk_h, pic_pix_y, mv->y);
}

/**
 * ===========================================================================
 * function declares
 * ===========================================================================
 */
#define interpolate_lcu_row FPFX(interpolate_lcu_row)
void interpolate_lcu_row(xavs2_t *h, xavs2_frame_t* frm, int i_lcu_y);

#define interpolate_sample_rows FPFX(interpolate_sample_rows)
void interpolate_sample_rows(xavs2_t *h, xavs2_frame_t* frm, int start_y, int height, int b_start, int b_end);

#define mc_luma FPFX(mc_luma)
void mc_luma  (pel_t *p_pred, int i_pred,
               int pic_pix_x, int pic_pix_y, int width, int height,
               const xavs2_frame_t *p_ref_frm);

#define mc_chroma FPFX(mc_chroma)
void mc_chroma(pel_t *p_pred_u, pel_t *p_pred_v, int i_pred,
               int pix_quad_x, int pix_quad_y, int width, int height,
               const xavs2_frame_t *p_ref_frm);


#endif // XAVS2_MC_H
