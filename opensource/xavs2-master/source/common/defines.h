/*
 * defines.h
 *
 * Description of this file:
 *    const variable definition of the xavs2 library
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


#ifndef XAVS2_DEFINES_H
#define XAVS2_DEFINES_H


/**
 * ===========================================================================
 * build switch
 * ===========================================================================
 */
/* ---------------------------------------------------------------------------
 * debug */
#define XAVS2_DUMP_REC        1     /* dump reconstruction frames, 1: ON, 0: OFF */
#define XAVS2_TRACE           0     /* write trace file,    1: ON, 0: OFF */
#define XAVS2_STAT            1     /* stat encoder info,   1: On, 0: OFF */


/**
 * ===========================================================================
 * optimization
 * ===========================================================================
 */

/* ����㷨�Ƿ��� */
#define IS_ALG_ENABLE(alg)  ((h->i_fast_algs >> alg) & 1)

/* ---------------------------------------------------------------------------
 * mask for fast algorithms
 */
enum xavs2_fast_algorithms_e {
    /* fast inter */
    OPT_EARLY_SKIP           ,        /* ����ʱ������ԵĿ���SKIP���� */
    OPT_PSC_MD               ,        /* ����ʱ������ԵĿ���ģʽ���� (prediction size correlation based mode decision) */
    OPT_FAST_CBF_MODE        ,        /* �������Ż���ģʽ��CBF��������ʣ��Ļ���ģʽ */
    OPT_FAST_PU_SEL          ,        /* OPT_FAST_CBF_MODE�ļ��㷨��cbf=0ʱ����2Nx2N������SKIP��������ʣ��֡��ģʽ��֡��ģʽ */
    OPT_BYPASS_AMP           ,        /* ���PRED_2NxNδ������ţ�ֱ��������ͬ���ַ����PRED_2NxnU/PRED_2NxnD; PRED_Nx2Nͬ�� */
    OPT_DMH_CANDIDATE        ,        /* ���ھ���DMHģʽ�µ�RDO���� */
    OPT_BYPASS_MODE_FPIC     ,        /* F֡�е�֡��ģʽ��DMHģʽ���� */
    OPT_ADVANCE_CHROMA_AEC   ,        /* ��ǰɫ�ȿ�ı任ϵ��������� */
    OPT_ROUGH_MODE_SKIP      ,        /* */
    OPT_CMS_ETMD             ,        /* ��������֡�ڻ��ַ�ʽ��
                                       * ��1����I_2Nx2N������֡��Ԥ��ģʽ���򲻱���֡���������֣�
                                       * ��2��֡������ģʽ��CBPΪ��ʱ����֡�ڻ��ַ�ʽ��*/
    OPT_ROUGH_PU_SEL         ,        /* ���Ե�PU����ģʽ���� */
    OPT_CBP_DIRECT           ,        /* ����directģʽ�²в��Ƿ�Ϊȫ��飬����PU���ֺ�CU�ݹ黮�� */
    OPT_SKIP_DMH_THRES       ,        /* ͨ��Distortion����ֵ��������DMHģʽ�ı��� */
    OPT_ROUGH_SKIP_SEL       ,        /* ͨ��distortion�Ա�ֻ�Ը���skip/directģʽ��RDO */

    /* fast intra */
    OPT_BYPASS_SDIP          ,        /* ���PRED_I_2Nxn�ѻ����ţ�ֱ������PRED_I_nx2N */
    OPT_FAST_INTRA_MODE      ,        /* ֡��ģʽ���پ��� */
    OPT_FAST_RDO_INTRA_C     ,        /* ����֡��ChromaԤ��ģʽ�Ż�������ɫ�ȷ����������� */
    OPT_ET_RDO_INTRA_L       ,        /* Luma RDO������ǰ�˳����� */
    OPT_ET_INTRA_DEPTH       ,        /* ����MADֵ��I֡depth������ǰ��ֹ */
    OPT_BYPASS_INTRA_BPIC    ,        /* B֡����֡��Ԥ��ģʽ��CBPΪ�㣬������֡��Ԥ��ģʽ���� */
    OPT_FAST_INTRA_IN_INTER  ,        /* ������CU������ģʽ�Ƿ�֡�ڼ���ǰCU��֡��ģʽRDCost����֡���֡��ģʽ */

    /* fast CU depth */
    OPT_ECU                  ,        /* HM��ȫ��SKIPģʽ��ֹ�²㻮�� */
    OPT_ET_HOMO_MV           ,        /* */
    OPT_CU_CSET              ,        /* CSET of uAVS2, Only for inter frames that are not referenced by others */
    OPT_CU_DEPTH_CTRL        ,        /* ����ʱ������Ե�Depth���ƣ������ϡ������ϡ����Ϻ�ʱ��ο���level����DEPTH��Χ��ȫI֡Ҳ���� */
    OPT_CU_QSFD              ,        /* CU splitting termination based on RD-Cost:
                                         Z. Wang, R. Wang, K. Fan, H. Sun, and W. Gao,
                                         ��uAVS2��Fast encoder for the 2nd generation IEEE 1857 video coding standard,��
                                         Signal Process. Image Commun., vol. 53, no. October 2016, pp. 13�C23, 2017. */

    /* fast transform and Quant */
    OPT_BYPASS_INTRA_RDOQ    ,        /* ����B֡֡������е�֡��ģʽ��RDOQ */
    OPT_RDOQ_AZPC            ,        /* ͨ���Ա任ϵ������ֵ�жϼ��ȫ������RDOQԤ��������ɫ�ȷ�����RDOQ����*/

    /* others */
    OPT_FAST_ZBLOCK          ,        /* ���������� */
    OPT_TR_KEY_FRAME_MD      ,        /* �Ը�����������ǹؼ�֡�Ĳ���ģʽ���ܽ�ʡ5%����ʱ�� */
    OPT_CODE_OPTIMZATION     ,        /* OPT_CU_SUBCU_COST: �ȱ����CU���ٱ���СCUʱ��ǰ����СCU��RDCost������CU��һ����������������CU
                                       * OPT_RDOQ_SKIP:     ͨ����RDOQ֮ǰ�Ա任ϵ������ֵ�жϼ��ȫ��飬����RDOQ����
                                       */
    OPT_BIT_EST_PSZT         ,        /* ����TU���ع��ƣ���33x32������TU�ٶ�ֻ�е�Ƶ��16x16�����з���ϵ�� */
    OPT_TU_LEVEL_DEC         ,        /* TU���㻮�־��ߣ��Ե�һ��TU����ѡ�����ţ����������ڶ���TU���֣������Ƿ���Ҫ����TU���� */
    OPT_FAST_ALF             ,        /* ALF�����㷨���ڶ���B֡����������֡�ο�������ALF��������ALF��Э����������ʱ������step=2���²��� */
    OPT_FAST_SAO             ,        /* SAO�����㷨���ڶ���B֡����������֡�ο�������SAO */
    OPT_SUBCU_SPLIT          ,        /* ���ݻ����ӿ����Ŀ���߸����Ƿ�Է�SKIPģʽ��RDO */
    OPT_PU_RMS               ,        /* �ر�С�飨8x8,16x16)���ֵ�Ԥ�ⵥԪ��������2Nx2N��֡�ڣ�֡���Լ�SKIPģʽ*/
    NUM_FAST_ALGS                     /* �ܵĿ����㷨���� */
};


/* ---------------------------------------------------------------------------
 * const defines related with fast algorithms
 */
#define SAVE_CU_INFO            1     /* ����ο�֡�������ÿһ֡��cu type��cu bitsize�����ڻ�ȡʱ���cuģʽ��cu�ߴ� */
#define NUM_INTRA_C_FULL_RD     4

/* ---------------------------------------------------------------------------
 * switches for modules to be removed
 */
/* remove code for Weighted Quant */
#define ENABLE_WQUANT           0     /* 1: enable, 0: disable */

/* frame level interpolation */
#define ENABLE_FRAME_SUBPEL_INTPL         1

/* Entropy coding optimization for context update */
#define CTRL_OPT_AEC            1

/* ---------------------------------------------------------------------------
 * Rate Control
 */
#define ENABLE_RATE_CONTROL_CU  0     /* Enable Rate-Control on CU level: 1: enable, 0: disable */

#define ENABLE_AUTO_INIT_QP     1     /* ����Ŀ�������Զ����ó�ʼQPֵ */


/**
 * ===========================================================================
 * const defines
 * ===========================================================================
 */

/* ---------------------------------------------------------------------------
 * const for bool type
 */
#ifndef FALSE
#define FALSE                   0
#endif
#ifndef TRUE
#define TRUE                    1
#endif


/* ---------------------------------------------------------------------------
 * profiles
 */
#define MAIN_PICTURE_PROFILE    0x12  /* profile: MAIN_PICTURE */
#define MAIN_PROFILE            0x20  /* profile: MAIN */
#define MAIN10_PROFILE          0x22  /* profile: MAIN10 */


/* ---------------------------------------------------------------------------
* chroma formats
*/
#define CHROMA_400              0
#define CHROMA_420              1
#define CHROMA_422              2
#define CHROMA_444              3

#define CHROMA_V_SHIFT          (h->i_chroma_v_shift)

/* ---------------------------------------------------------------------------
 * quantization parameter range
 */
#define MIN_QP                  0     /* min QP */
#define MAX_QP                  63    /* max QP */
#define SHIFT_QP                11    /* shift QP */


/* ---------------------------------------------------------------------------
 * cu size
 */
#define MAX_CU_SIZE             64    /* max CU size */
#define MAX_CU_SIZE_IN_BIT      6
#define MIN_CU_SIZE             8     /* min CU size */
#define MIN_CU_SIZE_IN_BIT      3
#define MIN_PU_SIZE             4     /* min PU size */
#define MIN_PU_SIZE_IN_BIT      2
#define BLOCK_MULTIPLE          (MIN_CU_SIZE / MIN_PU_SIZE)
#define CTU_DEPTH               (MAX_CU_SIZE_IN_BIT - MIN_CU_SIZE_IN_BIT + 1)

#define B4X4_IN_BIT             2     /* unit level: 2 */
#define B8X8_IN_BIT             3     /* unit level: 3 */
#define B16X16_IN_BIT           4     /* unit level: 4 */
#define B32X32_IN_BIT           5     /* unit level: 5 */
#define B64X64_IN_BIT           6     /* unit level: 6 */


/* ---------------------------------------------------------------------------
 * parameters for scale mv
 */
#define MULTIx2                 32768
#define MULTI                   16384
#define HALF_MULTI              8192
#define OFFSET                  14


/* ---------------------------------------------------------------------------
 * prediction techniques
 */
#define LAM_2Level_TU           0.8
#define DMH_MODE_NUM            5     /* number of DMH mode */
#define WPM_NUM                 3     /* number of WPM */
#define TH_PMVR                 2     /* PMVR���ķ�֮һ���ؾ���MV�Ŀ��÷�Χ */


/* ---------------------------------------------------------------------------
 * coefficient coding
 */
#define MAX_TU_SIZE             32    /* ���任���С���ر���ʱ��ϵ������ */
#define MAX_TU_SIZE_IN_BIT      5     /* ���任���С���ر���ʱ��ϵ������ */
#define SIZE_CG                 4     /* CG ��С 4x4 */
#define SIZE_CG_IN_BIT          2     /* CG ��С 4x4 */
#define MAX_CG_NUM_IN_TU        (1 << ((MAX_TU_SIZE_IN_BIT - SIZE_CG_IN_BIT) << 1))

/* ---------------------------------------------------------------------------
 * temporal level (layer)
 */
#define TEMPORAL_MAXLEVEL       8     /* max number of temporal levels */
#define TEMPORAL_MAXLEVEL_BIT   3     /* bits of temporal level */



/* ---------------------------------------------------------------------------
 * SAO (Sample Adaptive Offset)
 */
#define NUM_BO_OFFSET                 32                            /*BOģʽ��offset�������������4������*/
#define MAX_NUM_SAO_CLASSES           32                            /*���offset����*/
#define NUM_SAO_BO_CLASSES_LOG2       5                             /**/
#define NUM_SAO_BO_CLASSES_IN_BIT     5                             /**/
#define NUM_SAO_BO_CLASSES           (1 << NUM_SAO_BO_CLASSES_LOG2) /*BOģʽ��startband��Ŀ*/
#define SAO_RATE_THR                  1.0                          /*���ȷ���������RDO����*/
#define SAO_RATE_CHROMA_THR           1.0                          /*ɫ�ȷ���������RDO����*/
#define SAO_SHIFT_PIX_NUM             4                             /*SAO������ƫ�Ƶ����ص���*/


#define MAX_DOUBLE              1.7e+308



/* ---------------------------------------------------------------------------
 * ALF (Adaptive Loop Filter)
 */
#define ALF_MAX_NUM_COEF        9
#define NO_VAR_BINS             16
#define LOG2_VAR_SIZE_H         2
#define LOG2_VAR_SIZE_W         2
#define ALF_FOOTPRINT_SIZE      7
#define DF_CHANGED_SIZE         3
#define ALF_NUM_BIT_SHIFT       6

#define LAMBDA_SCALE_LUMA   (1.0)     /* scale for luma */
#define LAMBDA_SCALE_CHROMA (1.0)     /* scale for chroma */



/* ---------------------------------------------------------------------------
 * threshold values to zero out quantized transform coefficients
 */
#define LUMA_COEFF_COST         1     /* threshold for luma coefficients */
#define MAX_COEFF_QUASI_ZERO    8     /* threshold for quasi zero block detection with luma coefficients */


/* ---------------------------------------------------------------------------
 * number of luma intra modes for full RDO
 */
#define INTRA_MODE_NUM_FOR_RDO  9     /* number of luma intra modes for full RDO */

/* ---------------------------------------------------------------------------
 * max values
 */
#define MAX_DISTORTION     (1 << 30)  /* maximum distortion (1 << bitdepth)^2 * (MAX_CU_SIZE)^2 */
#define XAVS2_THREAD_MAX        128   /* max number of threads */
#define XAVS2_BS_HEAD_LEN       256   /* length of bitstream buffer for headers */
#define XAVS2_PAD          (64 + 16)  /* number of pixels padded around the reference frame */
#define MAX_COST         (1LL << 50)  /* used for start value for cost variables */
#define MAX_FRAME_INDEX  0x3FFFFF00   /* max frame index */
#define MAX_REFS     XAVS2_MAX_REFS   /* max number of reference frames */
#define MAX_SLICES                8   /* max number of slices in one picture */
#define MAX_PARALLEL_FRAMES       8   /* max number of parallel encoding frames */
#define MAX_COI_VALUE   ((1<<8) - 1)  /* max COI value (unsigned char) */
#define PIXEL_MAX ((1<<BIT_DEPTH)-1)  /* max value of a pixel */


/* ---------------------------------------------------------------------------
 * reference picture management
 */
#define XAVS2_INPUT_NUM      (4 * MAX_PARALLEL_FRAMES + 4)    /* number of buffered input frames */
#define FREF_BUF_SIZE (MAX_REFS + MAX_PARALLEL_FRAMES * 4)    /* number of reference + decoding frames to buffer */


/* ---------------------------------------------------------------------------
 * reserved memory space for check pseudo code */
#define PSEUDO_CODE_SIZE        1024  /* size of reserved memory space */

/* ---------------------------------------------------------------------------
 * transform
 */
#define SEC_TR_SIZE             4
#define SEC_TR_MIN_BITSIZE      3     /* apply secT to greater than or equal to 8x8 block */

#define LIMIT_BIT               16
#define FACTO_BIT               5


/* ---------------------------------------------------------------------------
 * frame list type
 */
enum frame_alloc_type_e {
    FT_ENC              =  0,       /* encoding frame */
    FT_DEC              =  1,       /* decoding frame */
    FT_TEMP             =  2,       /* temporary frame for SAO/ALF/TDRDO decision or other modules */
};

/* ---------------------------------------------------------------------------
 * variable section delimiter
 */
#define SYNC_VARS_1(delimiter)  int delimiter
#define SYNC_VARS_2(delimiter)  int delimiter


/* ---------------------------------------------------------------------------
 * all assembly and related C functions are prefixed with 'xavs2_' default
 */
#define PFXB(prefix, name)  prefix ## _ ## name
#define PFXA(prefix, name)  PFXB(prefix, name)
#define FPFX(name)          PFXA(xavs2,  name)


/* ---------------------------------------------------------------------------
 * flag
 */
#define XAVS2_EXIT_THREAD     (-1)  /* flag to terminate thread */



/* ---------------------------------------------------------------------------
 * others
 */
/* reference management */
#define XAVS2_MAX_REFS         4     /* max number of reference frames */
#define XAVS2_MAX_GOPS        16     /* max number of GOPs */
#define XAVS2_MAX_GOP_SIZE    16     /* max length of GOP */

/* adapt layer */
#define XAVS2_ADAPT_LAYER      1     /* output adapt layer? */
#define XAVS2_MAX_NAL_NUM     16     /* max number of NAL in bitstream of one frame */

/* weight quant */
#define WQMODEL_PARAM_SIZE    64     /* size of weight quant model param */

/* qp */
#define XAVS2_QP_AUTO          0     /* get qp automatically */

#endif /* #if XAVS2_DEFINES_H */
