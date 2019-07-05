;*****************************************************************************
;* Copyright (C) 2013-2017 MulticoreWare, Inc
;* Copyright (C) 2018~ VCL, NELVT, Peking University
;*
;* Authors: Nabajit Deka <nabajit@multicorewareinc.com>
;*          Min Chen <chenm003@163.com> <min.chen@multicorewareinc.com>
;*          Li Cao <li@multicorewareinc.com>
;*          Praveen Kumar Tiwari <Praveen@multicorewareinc.com>
;*          Jiaqi Zhang <zhangjiaqi.cs@gmail.com>
;*
;* This program is free software; you can redistribute it and/or modify
;* it under the terms of the GNU General Public License as published by
;* the Free Software Foundation; either version 2 of the License, or
;* (at your option) any later version.
;*
;* This program is distributed in the hope that it will be useful,
;* but WITHOUT ANY WARRANTY; without even the implied warranty of
;* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;* GNU General Public License for more details.
;*
;* You should have received a copy of the GNU General Public License
;* along with this program; if not, write to the Free Software
;* Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02111, USA.
;*
;* This program is also available under a commercial proprietary license.
;* For more information, contact us at license @ x265.com.
;*****************************************************************************/

;TO-DO : Further optimize the routines.

%include "x86inc.asm"
%include "x86util.asm"

SECTION_RODATA 32

; ----------------------------------------------------------------------------
; dct4
tab_dct4:       times 4 dw  32,  32
                times 4 dw  42,  17
                times 4 dw  32, -32
                times 4 dw  17, -42

avx2_idct4_1:   dw  32, 32, 32, 32, 32, 32, 32, 32, 32, -32, 32, -32, 32, -32, 32, -32
                dw  42, 17, 42, 17, 42, 17, 42, 17, 17, -42, 17, -42, 17, -42, 17, -42

avx2_idct4_2:   dw  32, 32, 32,-32, 42, 17, 17,-42

idct4_shuf1:    times 2 db 0, 1, 4, 5, 2, 3, 6, 7, 8, 9, 12, 13, 10, 11, 14, 15

idct4_shuf2:    times 2 db 4, 5, 6, 7, 0, 1, 2, 3, 12, 13, 14, 15, 8 ,9 ,10, 11


; ----------------------------------------------------------------------------
; dct8
align 32

pb_idct8even:   db 0, 1, 8, 9, 4, 5, 12, 13, 0, 1,  8,  9, 4, 5, 12, 13

tab_idct8_1:    times 1 dw  32, -32,  17, -42,  32,  32,  42,  17

tab_idct8_2:    times 1 dw  44,  38,  25,   9,  38,  -9, -44, -25
                times 1 dw  25, -44,   9,  38,   9, -25,  38, -44

tab_idct8_3:    times 4 dw  44,  38
                times 4 dw  25,   9
                times 4 dw  38,  -9
                times 4 dw -44, -25
                times 4 dw  25, -44
                times 4 dw   9,  38
                times 4 dw   9, -25
                times 4 dw  38, -44

avx2_idct8_1:   times 4 dw  32,  42,  32,  17
                times 4 dw  32,  17, -32, -42
                times 4 dw  32, -17, -32,  42
                times 4 dw  32, -42,  32, -17

avx2_idct8_2:   times 4 dw  44,  38,  25,   9
                times 4 dw  38,  -9, -44, -25
                times 4 dw  25, -44,   9,  38
                times 4 dw   9, -25,  38, -44

align 32
idct8_shuf1:    dd 0, 2, 4, 6, 1, 3, 5, 7

idct8_shuf2:    times 2 db 0, 1, 2, 3, 8, 9, 10, 11, 4, 5, 6, 7, 12, 13, 14, 15

idct8_shuf3:    times 2 db 12, 13, 14, 15, 8, 9, 10, 11, 4, 5, 6, 7, 0, 1, 2, 3

pb_idct8odd:    db 2, 3, 6, 7, 10, 11, 14, 15, 2, 3, 6, 7, 10, 11, 14, 15


; ----------------------------------------------------------------------------
; dct16
align 32

dct16_shuf1:    times 2 db 14, 15, 12, 13, 10, 11, 8, 9, 6, 7, 4, 5, 2, 3, 0, 1

tab_idct16_1:   dw  45,  43,  40,  35,  29,  21,  13,   4
                dw  43,  29,   4, -21, -40, -45, -35, -13
                dw  40,   4, -35, -43, -13,  29,  45,  21
                dw  35, -21, -43,   4,  45,  13, -40, -29
                dw  29, -40, -13,  45,  -4, -43,  21,  35
                dw  21, -45,  29,  13, -43,  35,   4, -40
                dw  13, -35,  45, -40,  21,   4, -29,  43
                dw   4, -13,  21, -29,  35, -40,  43, -45

tab_idct16_2:   dw  32,  44,  42,  38,  32,  25,  17,   9
                dw  32,  38,  17,  -9, -32, -44, -42, -25
                dw  32,  25, -17, -44, -32,   9,  42,  38
                dw  32,   9, -42, -25,  32,  38, -17, -44
                dw  32,  -9, -42,  25,  32, -38, -17,  44
                dw  32, -25, -17,  44, -32,  -9,  42, -38
                dw  32, -38,  17,   9, -32,  44, -42,  25
                dw  32, -44,  42, -38,  32, -25,  17,  -9

idct16_shuff:   dd 0, 4, 2, 6, 1, 5, 3, 7

idct16_shuff1:  dd 2, 6, 0, 4, 3, 7, 1, 5


; ----------------------------------------------------------------------------
; dct32
align 32

tab_idct32_1:   dw  45,  45,  44,  43,  41,  39,  36,  34,  30,  27,  23,  19,  15,  11,   7,   2
                dw  45,  41,  34,  23,  11,  -2, -15, -27, -36, -43, -45, -44, -39, -30, -19,  -7
                dw  44,  34,  15,  -7, -27, -41, -45, -39, -23,  -2,  19,  36,  45,  43,  30,  11
                dw  43,  23,  -7, -34, -45, -36, -11,  19,  41,  44,  27,  -2, -30, -45, -39, -15
                dw  41,  11, -27, -45, -30,   7,  39,  43,  15, -23, -45, -34,   2,  36,  44,  19
                dw  39,  -2, -41, -36,   7,  43,  34, -11, -44, -30,  15,  45,  27, -19, -45, -23
                dw  36, -15, -45, -11,  39,  34, -19, -45,  -7,  41,  30, -23, -44,  -2,  43,  27
                dw  34, -27, -39,  19,  43, -11, -45,   2,  45,   7, -44, -15,  41,  23, -36, -30
                dw  30, -36, -23,  41,  15, -44,  -7,  45,  -2, -45,  11,  43, -19, -39,  27,  34
                dw  27, -43,  -2,  44, -23, -30,  41,   7, -45,  19,  34, -39, -11,  45, -15, -36
                dw  23, -45,  19,  27, -45,  15,  30, -44,  11,  34, -43,   7,  36, -41,   2,  39
                dw  19, -44,  36,  -2, -34,  45, -23, -15,  43, -39,   7,  30, -45,  27,  11, -41
                dw  15, -39,  45, -30,   2,  27, -44,  41, -19, -11,  36, -45,  34,  -7, -23,  43
                dw  11, -30,  43, -45,  36, -19,  -2,  23, -39,  45, -41,  27,  -7, -15,  34, -44
                dw   7, -19,  30, -39,  44, -45,  43, -36,  27, -15,   2,  11, -23,  34, -41,  45
                dw   2,  -7,  11, -15,  19, -23,  27, -30,  34, -36,  39, -41,  43, -44,  45, -45

tab_idct32_2:   dw  32,  44,  42,  38,  32,  25,  17,   9
                dw  32,  38,  17,  -9, -32, -44, -42, -25
                dw  32,  25, -17, -44, -32,   9,  42,  38
                dw  32,   9, -42, -25,  32,  38, -17, -44
                dw  32,  -9, -42,  25,  32, -38, -17,  44
                dw  32, -25, -17,  44, -32,  -9,  42, -38
                dw  32, -38,  17,   9, -32,  44, -42,  25
                dw  32, -44,  42, -38,  32, -25,  17,  -9

tab_idct32_3:   dw  45,  43,  40,  35,  29,  21,  13,   4
                dw  43,  29,   4, -21, -40, -45, -35, -13
                dw  40,   4, -35, -43, -13,  29,  45,  21
                dw  35, -21, -43,   4,  45,  13, -40, -29
                dw  29, -40, -13,  45,  -4, -43,  21,  35
                dw  21, -45,  29,  13, -43,  35,   4, -40
                dw  13, -35,  45, -40,  21,   4, -29,  43
                dw   4, -13,  21, -29,  35, -40,  43, -45

tab_idct32_4:   dw  32,  45,  44,  43,  42,  40,  38,  35,  32,  29,  25,  21,  17,  13,   9,   4
                dw  32,  43,  38,  29,  17,   4,  -9, -21, -32, -40, -44, -45, -42, -35, -25, -13
                dw  32,  40,  25,   4, -17, -35, -44, -43, -32, -13,   9,  29,  42,  45,  38,  21
                dw  32,  35,   9, -21, -42, -43, -25,   4,  32,  45,  38,  13, -17, -40, -44, -29
                dw  32,  29,  -9, -40, -42, -13,  25,  45,  32,  -4, -38, -43, -17,  21,  44,  35
                dw  32,  21, -25, -45, -17,  29,  44,  13, -32, -43,  -9,  35,  42,   4, -38, -40
                dw  32,  13, -38, -35,  17,  45,   9, -40, -32,  21,  44,   4, -42, -29,  25,  43
                dw  32,   4, -44, -13,  42,  21, -38, -29,  32,  35, -25, -40,  17,  43,  -9, -45
                dw  32,  -4, -44,  13,  42, -21, -38,  29,  32, -35, -25,  40,  17, -43,  -9,  45
                dw  32, -13, -38,  35,  17, -45,   9,  40, -32, -21,  44,  -4, -42,  29,  25, -43
                dw  32, -21, -25,  45, -17, -29,  44, -13, -32,  43,  -9, -35,  42,  -4, -38,  40
                dw  32, -29,  -9,  40, -42,  13,  25, -45,  32,   4, -38,  43, -17, -21,  44, -35
                dw  32, -35,   9,  21, -42,  43, -25,  -4,  32, -45,  38, -13, -17,  40, -44,  29
                dw  32, -40,  25,  -4, -17,  35, -44,  43, -32,  13,   9, -29,  42, -45,  38, -21
                dw  32, -43,  38, -29,  17,  -4,  -9,  21, -32,  40, -44,  45, -42,  35, -25,  13
                dw  32, -45,  44, -43,  42, -40,  38, -35,  32, -29,  25, -21,  17, -13,   9,  -4


; ----------------------------------------------------------------------------
SECTION .text

cextern pd_11
cextern pd_12
cextern pd_16
cextern pd_512
cextern pd_2048


; ============================================================================
; void idct_4x4(const coeff_t *src, coeff_t *dst, int i_dst)
; ============================================================================

; ------------------------------------------------------------------
; idct_4x4_sse2
INIT_XMM sse2
cglobal idct_4x4, 3, 4, 7
%define IDCT4_SHIFT1        5                   ; shift1 = 5
%define IDCT4_OFFSET1       [pd_16]             ; add1   = 16
%if BIT_DEPTH == 10                             ;
    %define IDCT4_SHIFT2    10                  ;
    %define IDCT4_OFFSET2   [pd_512]            ;
%elif BIT_DEPTH == 8                            ; for BIT_DEPTH: 8
    %define IDCT4_SHIFT2    12                  ; shift2 = 12
    %define IDCT4_OFFSET2   [pd_2048]           ; add2   = 2048
%else                                           ;
    %error Unsupported BIT_DEPTH!               ;
%endif                                          ;
    add            r2d, r2d                     ; r2 <-- i_dst
    lea             r3, [tab_dct4]              ;
                                                ;
    mova            m6, IDCT4_OFFSET1           ;
                                                ;
    movu            m0, [r0 + 0 * 16]           ; mova???
    movu            m1, [r0 + 1 * 16]           ;
                                                ;
    punpcklwd       m2, m0, m1                  ;
    pmaddwd         m3, m2, [r3 + 0 * 16]       ; m3 = E1
    paddd           m3, m6                      ;
                                                ;
    pmaddwd         m2, [r3 + 2 * 16]           ; m2 = E2
    paddd           m2, m6                      ;
                                                ;
    punpckhwd       m0, m1                      ;
    pmaddwd         m1, m0, [r3 + 1 * 16]       ; m1 = O1
    pmaddwd         m0, [r3 + 3 * 16]           ; m0 = O2
                                                ;
    paddd           m4, m3, m1                  ;
    psrad           m4, IDCT4_SHIFT1            ; m4 = m128iA
    paddd           m5, m2, m0                  ;
    psrad           m5, IDCT4_SHIFT1            ;
    packssdw        m4, m5                      ; m4 = m128iA
                                                ;
    psubd           m2, m0                      ;
    psrad           m2, IDCT4_SHIFT1            ;
    psubd           m3, m1                      ;
    psrad           m3, IDCT4_SHIFT1            ;
    packssdw        m2, m3                      ; m2 = m128iD
                                                ;
    punpcklwd       m1, m4, m2                  ; m1 = S0
    punpckhwd       m4, m2                      ; m4 = S8
                                                ;
    punpcklwd       m0, m1, m4                  ; m0 = m128iA
    punpckhwd       m1, m4                      ; m1 = m128iD
                                                ;
    mova            m6, IDCT4_OFFSET2           ;
                                                ;
    punpcklwd       m2, m0, m1                  ;
    pmaddwd         m3, m2, [r3 + 0 * 16]       ;
    paddd           m3, m6                      ; m3 = E1
                                                ;
    pmaddwd         m2, [r3 + 2 * 16]           ;
    paddd           m2, m6                      ; m2 = E2
                                                ;
    punpckhwd       m0, m1                      ;
    pmaddwd         m1, m0, [r3 + 1 * 16]       ; m1 = O1
    pmaddwd         m0, [r3 + 3 * 16]           ; m0 = O2
                                                ;
    paddd           m4, m3, m1                  ;
    psrad           m4, IDCT4_SHIFT2            ; m4 = m128iA
    paddd           m5, m2, m0                  ;
    psrad           m5, IDCT4_SHIFT2            ;
    packssdw        m4, m5                      ; m4 = m128iA
                                                ;
    psubd           m2, m0                      ;
    psrad           m2, IDCT4_SHIFT2            ;
    psubd           m3, m1                      ;
    psrad           m3, IDCT4_SHIFT2            ;
    packssdw        m2, m3                      ; m2 = m128iD
                                                ;
    punpcklwd       m1, m4, m2                  ;
    punpckhwd       m4, m2                      ;
                                                ;
    punpcklwd       m0, m1, m4                  ;
    movlps         [r1 + 0 * r2], m0            ; store dst, line 0
    movhps         [r1 + 1 * r2], m0            ;            line 1
                                                ;
    punpckhwd       m1, m4                      ;
    movlps         [r1 + 2*r2], m1              ; store dst, line 2
    lea             r1, [r1 + 2*r2]             ;
    movhps         [r1 + r2], m1                ;            line 3
                                                ;
    RET                                         ;
%undef IDCT4_SHIFT1
%undef IDCT4_OFFSET1
%undef IDCT4_SHIFT2
%undef IDCT4_OFFSET2


; ----------------------------------------------------------------------------
; void idct_8x8(const coeff_t *src, coeff_t *dst, int i_dst)
; ----------------------------------------------------------------------------
INIT_XMM ssse3

cglobal patial_butterfly_inverse_internal_pass1
    %define IDCT8_SHIFT1    5                   ; shift1 = 5
    %define IDCT8_ADD1      [pd_16]             ; add1   = 16
                                                ;
    movh            m0, [r0         ]           ;
    movhps          m0, [r0 + 2 * 16]           ;
    movh            m1, [r0 + 4 * 16]           ;
    movhps          m1, [r0 + 6 * 16]           ;
                                                ;
    punpckhwd       m2, m0, m1                  ; [2 6]
    punpcklwd       m0, m1                      ; [0 4]
    pmaddwd         m1, m0, [r6     ]           ; EE[0]
    pmaddwd         m0,     [r6 + 32]           ; EE[1]
    pmaddwd         m3, m2, [r6 + 16]           ; EO[0]
    pmaddwd         m2,     [r6 + 48]           ; EO[1]
                                                ;
    paddd           m4, m1, m3                  ; E[0]
    psubd           m1, m3                      ; E[3]
    paddd           m3, m0, m2                  ; E[1]
    psubd           m0, m2                      ; E[2]
                                                ;
    ; E[K] = E[k] + add                         ;
    mova            m5, IDCT8_ADD1              ; add1   = 16
    paddd           m0, m5                      ;
    paddd           m1, m5                      ;
    paddd           m3, m5                      ;
    paddd           m4, m5                      ;
                                                ;
    movh            m2, [r0 +     16]           ;
    movhps          m2, [r0 + 5 * 16]           ;
    movh            m5, [r0 + 3 * 16]           ;
    movhps          m5, [r0 + 7 * 16]           ;
    punpcklwd       m6, m2, m5                  ; [1 3]
    punpckhwd       m2, m5                      ; [5 7]
                                                ;
    pmaddwd         m5, m6, [r4     ]           ;
    pmaddwd         m7, m2, [r4 + 16]           ;
    paddd           m5, m7                      ; O[0]
                                                ;
    paddd           m7, m4, m5                  ;
    psrad           m7, IDCT8_SHIFT1            ; shift1 = 5
                                                ;
    psubd           m4, m5                      ;
    psrad           m4, IDCT8_SHIFT1            ; shift1 = 5
                                                ;
    packssdw        m7, m4                      ;
    movh           [r5 + 0 * 16], m7            ;
    movhps         [r5 + 7 * 16], m7            ;
                                                ;
    pmaddwd         m5, m6, [r4 + 32]           ;
    pmaddwd         m4, m2, [r4 + 48]           ;
    paddd           m5, m4                      ; O[1]
                                                ;
    paddd           m4, m3, m5                  ;
    psrad           m4, IDCT8_SHIFT1            ; shift1 = 5
                                                ;
    psubd           m3, m5                      ;
    psrad           m3, IDCT8_SHIFT1            ; shift1 = 5
                                                ;
    packssdw        m4, m3                      ;
    movh           [r5 + 1 * 16], m4            ;
    movhps         [r5 + 6 * 16], m4            ;
                                                ;
    pmaddwd         m5, m6, [r4 + 64]           ;
    pmaddwd         m4, m2, [r4 + 80]           ;
    paddd           m5, m4                      ; O[2]
                                                ;
    paddd           m4, m0, m5                  ;
    psrad           m4, IDCT8_SHIFT1            ; shift1 = 5
                                                ;
    psubd           m0, m5                      ;
    psrad           m0, IDCT8_SHIFT1            ; shift1 = 5
                                                ;
    packssdw        m4, m0                      ;
    movh           [r5 + 2 * 16], m4            ;
    movhps         [r5 + 5 * 16], m4            ;
                                                ;
    pmaddwd         m5, m6, [r4 +  96]          ;
    pmaddwd         m4, m2, [r4 + 112]          ;
    paddd           m5, m4                      ; O[3]
                                                ;
    paddd           m4, m1, m5                  ;
    psrad           m4, IDCT8_SHIFT1            ; shift1 = 5
                                                ;
    psubd           m1, m5                      ;
    psrad           m1, IDCT8_SHIFT1            ; shift1 = 5
                                                ;
    packssdw        m4, m1                      ;
    movh           [r5 + 3 * 16], m4            ;
    movhps         [r5 + 4 * 16], m4            ;
                                                ;
    %undef IDCT8_SHIFT1                         ;
    %undef IDCT8_ADD1                           ;
    ret                                         ;

%macro PARTIAL_BUTTERFLY_PROCESS_ROW 1
%if BIT_DEPTH == 10                             ;
    %define IDCT8_SHIFT2  10                    ;
%elif BIT_DEPTH == 8                            ; for BIT_DEPTH: 8
    %define IDCT8_SHIFT2  12                    ; shift2 = 12
%else                                           ;
    %error Unsupported BIT_DEPTH!               ;
%endif                                          ;
    pshufb          m4, %1, [pb_idct8even]      ;
    pmaddwd         m4, [tab_idct8_1]           ;
    phsubd          m5, m4                      ;
    pshufd          m4, m4, 0x4E                ;
    phaddd          m4, m4                      ;
    punpckhqdq      m4, m5                      ; m4 = dd e[ 0 1 2 3]
    paddd           m4, m6                      ;
                                                ;
    pshufb          %1, %1, [r6]                ;
    pmaddwd         m5, %1, [r4]                ;
    pmaddwd         %1, [r4 + 16]               ;
    phaddd          m5, %1                      ; m5 = dd O[0, 1, 2, 3]
                                                ;
    paddd           %1, m4, m5                  ;
    psrad           %1, IDCT8_SHIFT2            ;
                                                ;
    psubd           m4, m5                      ;
    psrad           m4, IDCT8_SHIFT2            ;
    pshufd          m4, m4, 0x1B                ;
                                                ;
    packssdw        %1, m4                      ;
%undef IDCT8_SHIFT2                             ;
%endmacro

cglobal patial_butterfly_inverse_internal_pass2
    mova            m0, [r5     ]               ;
    PARTIAL_BUTTERFLY_PROCESS_ROW m0            ;
    movu   [r1       ], m0                      ;
                                                ;
    mova            m2, [r5 + 16]               ;
    PARTIAL_BUTTERFLY_PROCESS_ROW m2            ;
    movu   [r1 +   r2], m2                      ;
                                                ;
    mova            m1, [r5 + 32]               ;
    PARTIAL_BUTTERFLY_PROCESS_ROW m1            ;
    movu   [r1 + 2*r2], m1                      ;
                                                ;
    mova            m3, [r5 + 48]               ;
    PARTIAL_BUTTERFLY_PROCESS_ROW m3            ;
    movu   [r1 +   r3], m3                      ;
                                                ;
    ret                                         ;

; ------------------------------------------------------------------
; idct_8x8_ssse3
cglobal idct_8x8, 3,7,8 ;,0-16*mmsize
    ; alignment stack to 64-bytes               ;
    mov             r5, rsp                     ;
    sub            rsp, 16*mmsize + gprsize     ;
    and            rsp, ~(64-1)                 ;
    mov           [rsp + 16*mmsize], r5         ;
    mov             r5, rsp                     ;
                                                ;
    lea             r4, [tab_idct8_3]           ;
    lea             r6, [tab_dct4]              ;
                                                ;
    call    patial_butterfly_inverse_internal_pass1
                                                ;
    add             r0, 8                       ;
    add             r5, 8                       ;
                                                ;
    call    patial_butterfly_inverse_internal_pass1
                                                ;
%if BIT_DEPTH == 10                             ;
    mova            m6, [pd_512]                ;
%elif BIT_DEPTH == 8                            ;
    mova            m6, [pd_2048]               ;
%else                                           ;
  %error Unsupported BIT_DEPTH!                 ;
%endif                                          ;
    add             r2, r2                      ;
    lea             r3, [r2 * 3]                ;
    lea             r4, [tab_idct8_2]           ;
    lea             r6, [pb_idct8odd]           ;
    sub             r5, 8                       ;
                                                ;
    call    patial_butterfly_inverse_internal_pass2
                                                ;
    lea             r1, [r1 + 4 * r2]           ;
    add             r5, 64                      ;
                                                ;
    call    patial_butterfly_inverse_internal_pass2
                                                ;
    ; restore origin stack pointer              ;
    mov            rsp, [rsp + 16*mmsize]       ;
    RET                                         ;


; ============================================================================
; ARCH_X86_64 ONLY
; ============================================================================

%if ARCH_X86_64 == 1

; ----------------------------------------------------------------------------
; void idct_4x4(const coeff_t *src, coeff_t *dst, int i_dst)
; ----------------------------------------------------------------------------
INIT_YMM avx2
cglobal idct_4x4, 3, 4, 6
%define IDCT4_SHIFT1    5                       ; shift1 = 5
    vbroadcasti128  m4, [pd_16]                 ; add1   = 16
%if BIT_DEPTH == 10                             ;
    %define IDCT4_SHIFT2 10                     ;
    vpbroadcastd    m5, [pd_512]                ;
%elif BIT_DEPTH == 8                            ; for BIT_DEPTH: 8
    %define IDCT4_SHIFT2 12                     ; shift2 = 12
    vpbroadcastd    m5, [pd_2048]               ; add2   = 2048
%else                                           ;
    %error Unsupported BIT_DEPTH!               ;
%endif                                          ;
                                                ;
    add             r2, r2                      ; r2 <-- i_src (src is 16bit data)
    lea             r3, [r2 * 3]                ; r3 <-- 3 * i_src
                                                ;
    movu            m0, [r0]                    ; [00 01 02 03 10 11 12 13 20 21 22 23 30 31 32 33]
                                                ;
    pshufb          m0, [idct4_shuf1]           ; [00 02 01 03 10 12 11 13 20 22 21 23 30 32 31 33]
    vextracti128   xm1, m0, 1                   ; [20 22 21 23 30 32 31 33]
    punpcklwd      xm2, xm0, xm1                ; [00 20 02 22 01 21 03 23]
    punpckhwd      xm0, xm1                     ; [10 30 12 32 11 31 13 33]
    vinserti128     m2, m2, xm2, 1              ; [00 20 02 22 01 21 03 23 00 20 02 22 01 21 03 23]
    vinserti128     m0, m0, xm0, 1              ; [10 30 12 32 11 31 13 33 10 30 12 32 11 31 13 33]
                                                ;
    mova            m1, [avx2_idct4_1     ]     ;
    mova            m3, [avx2_idct4_1 + 32]     ;
    pmaddwd         m1, m2                      ;
    pmaddwd         m3, m0                      ;
                                                ;
    paddd           m0, m1, m3                  ;
    paddd           m0, m4                      ;
    psrad           m0, IDCT4_SHIFT1            ; [00 20 10 30 01 21 11 31]
                                                ;
    psubd           m1, m3                      ;
    paddd           m1, m4                      ;
    psrad           m1, IDCT4_SHIFT1            ; [03 23 13 33 02 22 12 32]
                                                ;
    packssdw        m0, m1                      ; [00 20 10 30 03 23 13 33 01 21 11 31 02 22 12 32]
    vmovshdup       m1, m0                      ; [10 30 10 30 13 33 13 33 11 31 11 31 12 32 12 32]
    vmovsldup       m0, m0                      ; [00 20 00 20 03 23 03 23 01 21 01 21 02 22 02 22]
                                                ;
    vpbroadcastq    m2, [avx2_idct4_2    ]      ;
    vpbroadcastq    m3, [avx2_idct4_2 + 8]      ;
    pmaddwd         m0, m2                      ;
    pmaddwd         m1, m3                      ;
                                                ;
    paddd           m2, m0, m1                  ;
    paddd           m2, m5                      ;
    psrad           m2, IDCT4_SHIFT2            ; [00 01 10 11 30 31 20 21]
                                                ;
    psubd           m0, m1                      ;
    paddd           m0, m5                      ;
    psrad           m0, IDCT4_SHIFT2            ; [03 02 13 12 33 32 23 22]
                                                ;
    pshufb          m0, [idct4_shuf2]           ; [02 03 12 13 32 33 22 23]
    punpcklqdq      m1, m2, m0                  ; [00 01 02 03 10 11 12 13]
    punpckhqdq      m2, m0                      ; [30 31 32 33 20 21 22 23]
    packssdw        m1, m2                      ; [00 01 02 03 30 31 32 33 10 11 12 13 20 21 22 23]
    vextracti128   xm0, m1, 1                   ;
                                                ;
    movq   [r1       ], xm1                     ; store result, line 0
    movq   [r1 +   r2], xm0                     ; store result, line 1
    movhps [r1 + 2*r2], xm0                     ; store result, line 2
    movhps [r1 +   r3], xm1                     ; store result, line 3
    RET                                         ;
%undef IDCT4_SHIFT1
%undef IDCT4_SHIFT2


%macro IDCT8_PASS_1 1
    vpbroadcastd    m7, [r5 + %1    ]           ;
    vpbroadcastd   m10, [r5 + %1 + 4]           ;
    pmaddwd         m5, m4, m7                  ;
    pmaddwd         m6, m0, m10                 ;
    paddd           m5, m6                      ;
                                                ;
    vpbroadcastd    m7, [r6 + %1    ]           ;
    vpbroadcastd   m10, [r6 + %1 + 4]           ;
    pmaddwd         m6, m1, m7                  ;
    pmaddwd         m3, m2, m10                 ;
    paddd           m6, m3                      ;
                                                ;
    paddd           m3, m5, m6                  ;
    paddd           m3, m11                     ;
    psrad           m3, IDCT8_SHIFT1            ;
                                                ;
    psubd           m5, m6                      ;
    paddd           m5, m11                     ;
    psrad           m5, IDCT8_SHIFT1            ;
                                                ;
    vpbroadcastd    m7, [r5 + %1 + 32]          ;
    vpbroadcastd   m10, [r5 + %1 + 36]          ;
    pmaddwd         m6, m4, m7                  ;
    pmaddwd         m8, m0, m10                 ;
    paddd           m6, m8                      ;
                                                ;
    vpbroadcastd    m7, [r6 + %1 + 32]          ;
    vpbroadcastd   m10, [r6 + %1 + 36]          ;
    pmaddwd         m8, m1, m7                  ;
    pmaddwd         m9, m2, m10                 ;
    paddd           m8, m9                      ;
                                                ;
    paddd           m9, m6, m8                  ;
    paddd           m9, m11                     ;
    psrad           m9, IDCT8_SHIFT1            ;
                                                ;
    psubd           m6, m8                      ;
    paddd           m6, m11                     ;
    psrad           m6, IDCT8_SHIFT1            ;
                                                ;
    packssdw        m3, m9                      ;
    vpermq          m3, m3, 0xD8                ;
                                                ;
    packssdw        m6, m5                      ;
    vpermq          m6, m6, 0xD8                ;
%endmacro

%macro IDCT8_PASS_2 0
    punpcklqdq      m2, m0, m1                  ;
    punpckhqdq      m0, m1                      ;
                                                ;
    pmaddwd         m3, m2, [r5     ]           ;
    pmaddwd         m5, m2, [r5 + 32]           ;
    pmaddwd         m6, m2, [r5 + 64]           ;
    pmaddwd         m7, m2, [r5 + 96]           ;
    phaddd          m3, m5                      ;
    phaddd          m6, m7                      ;
    pshufb          m3, [idct8_shuf2]           ;
    pshufb          m6, [idct8_shuf2]           ;
    punpcklqdq      m7, m3, m6                  ;
    punpckhqdq      m3, m6                      ;
                                                ;
    pmaddwd         m5, m0, [r6     ]           ;
    pmaddwd         m6, m0, [r6 + 32]           ;
    pmaddwd         m8, m0, [r6 + 64]           ;
    pmaddwd         m9, m0, [r6 + 96]           ;
    phaddd          m5, m6                      ;
    phaddd          m8, m9                      ;
    pshufb          m5, [idct8_shuf2]           ;
    pshufb          m8, [idct8_shuf2]           ;
    punpcklqdq      m6, m5, m8                  ;
    punpckhqdq      m5, m8                      ;
                                                ;
    paddd           m8, m7, m6                  ;
    paddd           m8, m12                     ;
    psrad           m8, IDCT8_SHIFT2            ;
                                                ;
    psubd           m7, m6                      ;
    paddd           m7, m12                     ;
    psrad           m7, IDCT8_SHIFT2            ;
                                                ;
    pshufb          m7, [idct8_shuf3]           ;
    packssdw        m8, m7                      ;
                                                ;
    paddd           m9, m3, m5                  ;
    paddd           m9, m12                     ;
    psrad           m9, IDCT8_SHIFT2            ;
                                                ;
    psubd           m3, m5                      ;
    paddd           m3, m12                     ;
    psrad           m3, IDCT8_SHIFT2            ;
                                                ;
    pshufb          m3, [idct8_shuf3]           ;
    packssdw        m9, m3                      ;
%endmacro


; ----------------------------------------------------------------------------
; void idct_8x8(const coeff_t *src, coeff_t *dst, int i_dst)
; ----------------------------------------------------------------------------

; ------------------------------------------------------------------
; idct_8x8_sse2
INIT_XMM sse2

    %define IDCT8_SHIFT1    5                   ; shift1 = 5
    %define IDCT8_ADD1      [pd_16]             ; add1   = 16
%if BIT_DEPTH == 10                             ;
    %define IDCT8_SHIFT2    10                  ;
    %define IDCT8_ADD2      [pd_512]            ;
%elif BIT_DEPTH == 8                            ; for BIT_DEPTH: 8
    %define IDCT8_SHIFT2    12                  ; shift2 = 12
    %define IDCT8_ADD2      [pd_2048]           ; add2   = 2048
%else                                           ;
    %error Unsupported BIT_DEPTH!               ;
%endif                                          ;

cglobal idct_8x8, 3, 6, 16, 0-5*mmsize
    mova            m9, [r0 + 1*mmsize]         ;
    mova            m1, [r0 + 3*mmsize]         ;
    mova            m7, m9                      ;
    punpcklwd       m7, m1                      ;
    punpckhwd       m9, m1                      ;
    mova           m14, [tab_idct8_3]           ;
    mova            m3, m14                     ;
    pmaddwd        m14, m7                      ;
    pmaddwd         m3, m9                      ;
    mova            m0, [r0 + 5*mmsize]         ;
    mova           m10, [r0 + 7*mmsize]         ;
    mova            m2, m0                      ;
    punpcklwd       m2, m10                     ;
    punpckhwd       m0, m10                     ;
    mova           m15, [tab_idct8_3+1*mmsize]  ;
    mova           m11, [tab_idct8_3+1*mmsize]  ;
    pmaddwd        m15, m2                      ;
    mova            m4, [tab_idct8_3+2*mmsize]  ;
    pmaddwd        m11, m0                      ;
    mova            m1, [tab_idct8_3+2*mmsize]  ;
    paddd          m15, m14                     ;
    mova            m5, [tab_idct8_3+4*mmsize]  ;
    mova           m12, [tab_idct8_3+4*mmsize]  ;
    paddd          m11, m3                      ;
    mova          [rsp + 0*mmsize], m11         ;
    mova          [rsp + 1*mmsize], m15         ;
    pmaddwd         m4, m7                      ;
    pmaddwd         m1, m9                      ;
    mova           m14, [tab_idct8_3+3*mmsize]  ;
    mova            m3, [tab_idct8_3+3*mmsize]  ;
    pmaddwd        m14, m2                      ;
    pmaddwd         m3, m0                      ;
    paddd          m14, m4                      ;
    paddd           m3, m1                      ;
    mova          [rsp + 2*mmsize], m3          ;
    pmaddwd         m5, m9                      ;
    pmaddwd         m9, [tab_idct8_3+6*mmsize]  ;
    mova            m6, [tab_idct8_3+5*mmsize]  ;
    pmaddwd        m12, m7                      ;
    pmaddwd         m7, [tab_idct8_3+6*mmsize]  ;
    mova            m4, [tab_idct8_3+5*mmsize]  ;
    pmaddwd         m6, m2                      ;
    paddd           m6, m12                     ;
    pmaddwd         m2, [tab_idct8_3+7*mmsize]  ;
    paddd           m7, m2                      ;
    mova          [rsp + 3*mmsize], m6          ;
    pmaddwd         m4, m0                      ;
    pmaddwd         m0, [tab_idct8_3+7*mmsize]  ;
    paddd           m9, m0                      ;
    paddd           m5, m4                      ;
    mova            m6, [r0 + 0*mmsize]         ;
    mova            m0, [r0 + 4*mmsize]         ;
    mova            m4, m6                      ;
    punpcklwd       m4, m0                      ;
    punpckhwd       m6, m0                      ;
    mova           m12, [r0 + 2*mmsize]         ;
    mova            m0, [r0 + 6*mmsize]         ;
    mova           m13, m12                     ;
    mova            m8, [tab_dct4]              ;
    punpcklwd      m13, m0                      ;
    mova           m10, [tab_dct4]              ;
    punpckhwd      m12, m0                      ;
    pmaddwd         m8, m4                      ;
    mova            m3, m8                      ;
    pmaddwd         m4, [tab_dct4 + 2*mmsize]   ;
    pmaddwd        m10, m6                      ;
    mova            m2, [tab_dct4 + 1*mmsize]   ;
    mova            m1, m10                     ;
    pmaddwd         m6, [tab_dct4 + 2*mmsize]   ;
    mova            m0, [tab_dct4 + 1*mmsize]   ;
    pmaddwd         m2, m13                     ;
    paddd           m3, m2                      ;
    psubd           m8, m2                      ;
    mova            m2, m6                      ;
    pmaddwd        m13, [tab_dct4 + 3*mmsize]   ;
    pmaddwd         m0, m12                     ;
    paddd           m1, m0                      ;
    psubd          m10, m0                      ;
    mova            m0, m4                      ;
    pmaddwd        m12, [tab_dct4 + 3*mmsize]   ;
    paddd           m3, IDCT8_ADD1              ; add1   = 16
    paddd           m1, IDCT8_ADD1              ; add1   = 16
    paddd           m8, IDCT8_ADD1              ; add1   = 16
    paddd          m10, IDCT8_ADD1              ; add1   = 16
    paddd           m0, m13                     ;
    paddd           m2, m12                     ;
    paddd           m0, IDCT8_ADD1              ; add1   = 16
    paddd           m2, IDCT8_ADD1              ; add1   = 16
    psubd           m4, m13                     ;
    psubd           m6, m12                     ;
    paddd           m4, IDCT8_ADD1              ; add1   = 16
    paddd           m6, IDCT8_ADD1              ; add1   = 16
    mova           m12, m8                      ;
    psubd           m8, m7                      ;
    psrad           m8, IDCT8_SHIFT1            ; shift1 = 5
    paddd          m15, m3                      ;
    psubd           m3, [rsp + 1*mmsize]        ;
    psrad          m15, IDCT8_SHIFT1            ; shift1 = 5
    paddd          m12, m7                      ;
    psrad          m12, IDCT8_SHIFT1            ; shift1 = 5
    paddd          m11, m1                      ;
    mova           m13, m14                     ;
    psrad          m11, IDCT8_SHIFT1            ; shift1 = 5
    packssdw       m15, m11                     ;
    psubd           m1, [rsp + 0*mmsize]        ;
    psrad           m1, IDCT8_SHIFT1            ; shift1 = 5
    mova           m11, [rsp + 2*mmsize]        ;
    paddd          m14, m0                      ;
    psrad          m14, IDCT8_SHIFT1            ; shift1 = 5
    psubd           m0, m13                     ;
    psrad           m0, IDCT8_SHIFT1            ; shift1 = 5
    paddd          m11, m2                      ;
    mova           m13, [rsp + 3*mmsize]        ;
    psrad          m11, IDCT8_SHIFT1            ; shift1 = 5
    packssdw       m14, m11                     ;
    mova           m11, m6                      ;
    psubd           m6, m5                      ;
    paddd          m13, m4                      ;
    psrad          m13, IDCT8_SHIFT1            ; shift1 = 5
    psrad           m6, IDCT8_SHIFT1            ; shift1 = 5
    paddd          m11, m5                      ;
    psrad          m11, IDCT8_SHIFT1            ; shift1 = 5
    packssdw       m13, m11                     ;
    mova           m11, m10                     ;
    psubd           m4, [rsp + 3*mmsize]        ;
    psubd          m10, m9                      ;
    psrad           m4, IDCT8_SHIFT1            ; shift1 = 5
    psrad          m10, IDCT8_SHIFT1            ; shift1 = 5
    packssdw        m4, m6                      ;
    packssdw        m8, m10                     ;
    paddd          m11, m9                      ;
    psrad          m11, IDCT8_SHIFT1            ; shift1 = 5
    packssdw       m12, m11                     ;
    psubd           m2, [rsp + 2*mmsize]        ;
    mova            m5, m15                     ;
    psrad           m2, IDCT8_SHIFT1            ; shift1 = 5
    packssdw        m0, m2                      ;
    mova            m2, m14                     ;
    psrad           m3, IDCT8_SHIFT1            ; shift1 = 5
    packssdw        m3, m1                      ;
    mova            m6, m13                     ;
    punpcklwd       m5, m8                      ;
    punpcklwd       m2, m4                      ;
    mova            m1, m12                     ;
    punpcklwd       m6, m0                      ;
    punpcklwd       m1, m3                      ;
    mova            m9, m5                      ;
    punpckhwd      m13, m0                      ;
    mova            m0, m2                      ;
    punpcklwd       m9, m6                      ;
    punpckhwd       m5, m6                      ;
    punpcklwd       m0, m1                      ;
    punpckhwd       m2, m1                      ;
    punpckhwd      m15, m8                      ;
    mova            m1, m5                      ;
    punpckhwd      m14, m4                      ;
    punpckhwd      m12, m3                      ;
    mova            m6, m9                      ;
    punpckhwd       m9, m0                      ;
    punpcklwd       m1, m2                      ;
    mova            m4, [tab_idct8_3+0*mmsize]  ;
    punpckhwd       m5, m2                      ;
    punpcklwd       m6, m0                      ;
    mova            m2, m15                     ;
    mova            m0, m14                     ;
    mova            m7, m9                      ;
    punpcklwd       m2, m13                     ;
    punpcklwd       m0, m12                     ;
    punpcklwd       m7, m5                      ;
    punpckhwd      m14, m12                     ;
    mova           m10, m2                      ;
    punpckhwd      m15, m13                     ;
    punpckhwd       m9, m5                      ;
    pmaddwd         m4, m7                      ;
    mova           m13, m1                      ;
    punpckhwd       m2, m0                      ;
    punpcklwd      m10, m0                      ;
    mova            m0, m15                     ;
    punpckhwd      m15, m14                     ;
    mova           m12, m1                      ;
    mova            m3, [tab_idct8_3+0*mmsize]  ;
    punpcklwd       m0, m14                     ;
    pmaddwd         m3, m9                      ;
    mova           m11, m2                      ;
    punpckhwd       m2, m15                     ;
    punpcklwd      m11, m15                     ;
    mova            m8, [tab_idct8_3+1*mmsize]  ;
    punpcklwd      m13, m0                      ;
    punpckhwd      m12, m0                      ;
    pmaddwd         m8, m11                     ;
    paddd           m8, m4                      ;
    mova          [rsp + 4*mmsize], m8          ;
    mova            m4, [tab_idct8_3+2*mmsize]  ;
    pmaddwd         m4, m7                      ;
    mova           m15, [tab_idct8_3+2*mmsize]  ;
    mova            m5, [tab_idct8_3+1*mmsize]  ;
    pmaddwd        m15, m9                      ;
    pmaddwd         m5, m2                      ;
    paddd           m5, m3                      ;
    mova           [rsp + 3*mmsize], m5         ;
    mova           m14, [tab_idct8_3+3*mmsize]  ;
    mova            m5, [tab_idct8_3+3*mmsize]  ;
    pmaddwd        m14, m11                     ;
    paddd          m14, m4                      ;
    mova          [rsp + 2*mmsize], m14         ;
    pmaddwd         m5, m2                      ;
    paddd           m5, m15                     ;
    mova          [rsp + 1*mmsize], m5          ;
    mova           m15, [tab_idct8_3+4*mmsize]  ;
    mova            m5, [tab_idct8_3+4*mmsize]  ;
    pmaddwd        m15, m7                      ;
    pmaddwd         m7, [tab_idct8_3+6*mmsize]  ;
    pmaddwd         m5, m9                      ;
    pmaddwd         m9, [tab_idct8_3+6*mmsize]  ;
    mova            m4, [tab_idct8_3+5*mmsize]  ;
    pmaddwd         m4, m2                      ;
    paddd           m5, m4                      ;
    mova            m4, m6                      ;
    mova            m8, [tab_idct8_3+5*mmsize]  ;
    punpckhwd       m6, m10                     ;
    pmaddwd         m2, [tab_idct8_3+7*mmsize]  ;
    punpcklwd       m4, m10                     ;
    paddd           m9, m2                      ;
    pmaddwd         m8, m11                     ;
    mova           m10, [tab_dct4]              ;
    paddd           m8, m15                     ;
    pmaddwd        m11, [tab_idct8_3+7*mmsize]  ;
    paddd           m7, m11                     ;
    mova          [rsp + 0*mmsize], m8          ;
    pmaddwd        m10, m6                      ;
    pmaddwd         m6, [tab_dct4 + 2*mmsize]   ;
    mova            m1, m10                     ;
    mova            m8, [tab_dct4]              ;
    mova            m3, [tab_dct4 + 1*mmsize]   ;
    pmaddwd         m8, m4                      ;
    pmaddwd         m4, [tab_dct4 + 2*mmsize]   ;
    mova            m0, m8                      ;
    mova            m2, [tab_dct4 + 1*mmsize]   ;
    pmaddwd         m3, m13                     ;
    psubd           m8, m3                      ;
    paddd           m0, m3                      ;
    mova            m3, m6                      ;
    pmaddwd        m13, [tab_dct4 + 3*mmsize]   ;
    pmaddwd         m2, m12                     ;
    paddd           m1, m2                      ;
    psubd          m10, m2                      ;
    mova            m2, m4                      ;
    pmaddwd        m12, [tab_dct4 + 3*mmsize]   ;
    paddd           m0, IDCT8_ADD2              ; add2   = 2048
    paddd           m1, IDCT8_ADD2              ; add2   = 2048
    paddd           m8, IDCT8_ADD2              ; add2   = 2048
    paddd          m10, IDCT8_ADD2              ; add2   = 2048
    paddd           m2, m13                     ;
    paddd           m3, m12                     ;
    paddd           m2, IDCT8_ADD2              ; add2   = 2048
    paddd           m3, IDCT8_ADD2              ; add2   = 2048
    psubd           m4, m13                     ;
    psubd           m6, m12                     ;
    paddd           m4, IDCT8_ADD2              ; add2   = 2048
    paddd           m6, IDCT8_ADD2              ; add2   = 2048
    mova           m15, [rsp + 4*mmsize]        ;
    mova           m12, m8                      ;
    psubd           m8, m7                      ;
    psrad           m8, IDCT8_SHIFT2            ; shift2 = 12
    mova           m11, [rsp + 3*mmsize]        ;
    paddd          m15, m0                      ;
    psrad          m15, IDCT8_SHIFT2            ; shift2 = 12
    psubd           m0, [rsp + 4*mmsize]        ;
    psrad           m0, IDCT8_SHIFT2            ; shift2 = 12
    paddd          m12, m7                      ;
    paddd          m11, m1                      ;
    mova           m14, [rsp + 2*mmsize]        ;
    psrad          m11, IDCT8_SHIFT2            ; shift2 = 12
    packssdw       m15, m11                     ;
    psubd           m1, [rsp + 3*mmsize]        ;
    psrad           m1, IDCT8_SHIFT2            ; shift2 = 12
    mova           m11, [rsp + 1*mmsize]        ;
    paddd          m14, m2                      ;
    psrad          m14, IDCT8_SHIFT2            ; shift2 = 12
    packssdw        m0, m1                      ;
    psrad          m12, IDCT8_SHIFT2            ; shift2 = 12
    psubd           m2, [rsp + 2*mmsize]        ;
    paddd          m11, m3                      ;
    mova           m13, [rsp + 0*mmsize]        ;
    psrad          m11, IDCT8_SHIFT2            ; shift2 = 12
    packssdw       m14, m11                     ;
    mova           m11, m6                      ;
    psubd           m6, m5                      ;
    paddd          m13, m4                      ;
    psrad          m13, IDCT8_SHIFT2            ; shift2 = 12
    mova            m1, m15                     ;
    paddd          m11, m5                      ;
    psrad          m11, IDCT8_SHIFT2            ; shift2 = 12
    packssdw       m13, m11                     ;
    mova           m11, m10                     ;
    psubd          m10, m9                      ;
    psrad          m10, IDCT8_SHIFT2            ; shift2 = 12
    packssdw        m8, m10                     ;
    psrad           m6, IDCT8_SHIFT2            ; shift2 = 12
    psubd           m4, [rsp + 0*mmsize]        ;
    paddd          m11, m9                      ;
    psrad          m11, IDCT8_SHIFT2            ; shift2 = 12
    packssdw       m12, m11                     ;
    punpcklwd       m1, m14                     ;
    mova            m5, m13                     ;
    psrad           m4, IDCT8_SHIFT2            ; shift2 = 12
    packssdw        m4, m6                      ;
    psubd           m3, [rsp + 1*mmsize]        ;
    psrad           m2, IDCT8_SHIFT2            ; shift2 = 12
    mova            m6, m8                      ;
    psrad           m3, IDCT8_SHIFT2            ; shift2 = 12
    punpcklwd       m5, m12                     ;
    packssdw        m2, m3                      ;
    punpcklwd       m6, m4                      ;
    punpckhwd       m8, m4                      ;
    mova            m4, m1                      ;
    mova            m3, m2                      ;
    punpckhdq       m1, m5                      ;
    punpckldq       m4, m5                      ;
    punpcklwd       m3, m0                      ;
    punpckhwd       m2, m0                      ;
    mova            m0, m6                      ;
    lea             r2, [r2 +   r2]             ;
    lea             r4, [r2 +   r2]             ;
    lea             r3, [r4 +   r2]             ;
    lea             r4, [r4 +   r3]             ;
    lea             r0, [r4 + 2*r2]             ;
    movq          [r1], m4                      ;
    punpckhwd      m15, m14                     ;
    movhps [r1 +   r2], m4                      ;
    punpckhdq       m0, m3                      ;
    movq   [r1 + 2*r2], m1                      ;
    punpckhwd      m13, m12                     ;
    movhps [r1 +   r3], m1                      ;
    mova            m1, m6                      ;
    punpckldq       m1, m3                      ;
    movq           [r1        + 8], m1          ;
    movhps         [r1 +   r2 + 8], m1          ;
    movq           [r1 + 2*r2 + 8], m0          ;
    movhps         [r1 +   r3 + 8], m0          ;
    mova            m0, m15                     ;
    punpckhdq      m15, m13                     ;
    punpckldq       m0, m13                     ;
    movq           [r1 + 4*r2], m0              ;
    movhps         [r1 +   r4], m0              ;
    mova            m0, m8                      ;
    punpckhdq       m8, m2                      ;
    movq           [r1 + 2*r3], m15             ;
    punpckldq       m0, m2                      ;
    movhps         [r1 +   r0    ], m15         ;
    movq           [r1 + 4*r2 + 8], m0          ;
    movhps         [r1 +   r4 + 8], m0          ;
    movq           [r1 + 2*r3 + 8], m8          ;
    movhps         [r1 +   r0 + 8], m8          ;
    RET                                         ;
%undef IDCT8_SHIFT1
%undef IDCT8_SHIFT2
%undef IDCT8_ADD1
%undef IDCT8_ADD2


; ----------------------------------------------------------------------------
; void idct_8x8(const coeff_t *src, coeff_t *dst, int i_dst)
; ----------------------------------------------------------------------------

; ------------------------------------------------------------------
; idct_8x8_avx2
INIT_YMM avx2
cglobal idct_8x8, 3, 7, 13, 0-8*16
    %define IDCT8_SHIFT1    5                   ; shift1 = 5
    %define IDCT8_ADD1      [pd_16]             ; add1   = 16
%if BIT_DEPTH == 10                             ;
    %define IDCT8_SHIFT2    10                  ;
    vpbroadcastd   m12,     [pd_512]            ;
%elif BIT_DEPTH == 8                            ; for BIT_DEPTH: 8
    %define IDCT8_SHIFT2    12                  ; shift2 = 12
    vpbroadcastd   m12,     [pd_2048]           ; add1   = 2048
%else                                           ;
    %error Unsupported BIT_DEPTH!               ;
%endif                                          ;
                                                ;
    vbroadcasti128 m11, IDCT8_ADD1              ; add1   = 16
                                                ;
    mov             r4, rsp                     ;
    lea             r5, [avx2_idct8_1]          ;
    lea             r6, [avx2_idct8_2]          ;
                                                ;
    ;pass1                                      ;
    movu            m1, [r0 + 0 * 32]           ; [0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1]
    movu            m0, [r0 + 1 * 32]           ; [2 2 2 2 2 2 2 2 3 3 3 3 3 3 3 3]
    vpunpcklwd      m5, m1, m0                  ; [0 2 0 2 0 2 0 2 1 3 1 3 1 3 1 3]
    vpunpckhwd      m1, m0                      ; [0 2 0 2 0 2 0 2 1 3 1 3 1 3 1 3]
    vinserti128     m4, m5, xm1, 1              ; [0 2 0 2 0 2 0 2 0 2 0 2 0 2 0 2]
    vextracti128   xm2, m5, 1                   ; [1 3 1 3 1 3 1 3]
    vinserti128     m1, m1, xm2, 0              ; [1 3 1 3 1 3 1 3 1 3 1 3 1 3 1 3]
                                                ;
    movu            m2, [r0 + 2 * 32]           ; [4 4 4 4 4 4 4 4 5 5 5 5 5 5 5 5]
    movu            m0, [r0 + 3 * 32]           ; [6 6 6 6 6 6 6 6 7 7 7 7 7 7 7 7]
    vpunpcklwd      m5, m2, m0                  ; [4 6 4 6 4 6 4 6 5 7 5 7 5 7 5 7]
    vpunpckhwd      m2, m0                      ; [4 6 4 6 4 6 4 6 5 7 5 7 5 7 5 7]
    vinserti128     m0, m5, xm2, 1              ; [4 6 4 6 4 6 4 6 4 6 4 6 4 6 4 6]
    vextracti128   xm5, m5, 1                   ; [5 7 5 7 5 7 5 7]
    vinserti128     m2, m2, xm5, 0              ; [5 7 5 7 5 7 5 7 5 7 5 7 5 7 5 7]
                                                ;
    mova            m5, [idct8_shuf1]           ;
    vpermd          m4, m5, m4                  ;
    vpermd          m0, m5, m0                  ;
    vpermd          m1, m5, m1                  ;
    vpermd          m2, m5, m2                  ;
                                                ;
    IDCT8_PASS_1    0                           ;
    mova            [r4     ], m3               ;
    mova            [r4 + 96], m6               ;
                                                ;
    IDCT8_PASS_1    64                          ;
    mova            [r4 + 32], m3               ;
    mova            [r4 + 64], m6               ;
                                                ;
    ;pass2                                      ;
    add            r2d, r2d                     ;
    lea             r3, [r2 * 3]                ;
                                                ;
    mova            m0, [r4     ]               ;
    mova            m1, [r4 + 32]               ;
    IDCT8_PASS_2                                ;
                                                ;
    vextracti128   xm3, m8, 1                   ;
    movu           [r1       ], xm8             ;
    movu           [r1 +   r2], xm3             ;
    vextracti128   xm3, m9, 1                   ;
    movu           [r1 + 2*r2], xm9             ;
    movu           [r1 +   r3], xm3             ;
                                                ;
    lea             r1, [r1 + r2 * 4]           ;
    mova            m0, [r4 + 64]               ;
    mova            m1, [r4 + 96]               ;
    IDCT8_PASS_2                                ;
                                                ;
    vextracti128   xm3, m8, 1                   ;
    movu           [r1       ], xm8             ;
    movu           [r1 +   r2], xm3             ;
    vextracti128   xm3, m9, 1                   ;
    movu           [r1 + 2*r2], xm9             ;
    movu           [r1 +   r3], xm3             ;
    RET                                         ;
%undef IDCT8_SHIFT1
%undef IDCT8_SHIFT2
%undef IDCT8_ADD1
%undef IDCT8_ADD2


%macro IDCT16_PASS1 2
    vbroadcasti128  m5, [tab_idct16_2 + %1 * 16]

    pmaddwd         m9, m0, m5                  ;
    pmaddwd        m10, m7, m5                  ;
    phaddd          m9, m10                     ;
                                                ;
    pmaddwd        m10, m6, m5                  ;
    pmaddwd        m11, m8, m5                  ;
    phaddd         m10, m11                     ;
                                                ;
    phaddd          m9, m10                     ;
    vbroadcasti128  m5, [tab_idct16_1 + %1*16]  ;
                                                ;
    pmaddwd        m10, m1, m5                  ;
    pmaddwd        m11, m3, m5                  ;
    phaddd         m10, m11                     ;
                                                ;
    pmaddwd        m11, m4, m5                  ;
    pmaddwd        m12, m2, m5                  ;
    phaddd         m11, m12                     ;
                                                ;
    phaddd         m10, m11                     ;
                                                ;
    paddd          m11, m9, m10                 ;
    paddd          m11, m14                     ;
    psrad          m11, IDCT16_SHIFT1           ;
                                                ;
    psubd           m9, m10                     ;
    paddd           m9, m14                     ;
    psrad           m9, IDCT16_SHIFT1           ;
                                                ;
    vbroadcasti128  m5, [tab_idct16_2 + %1*16 + 16]
                                                ;
    pmaddwd        m10, m0, m5                  ;
    pmaddwd        m12, m7, m5                  ;
    phaddd         m10, m12                     ;
                                                ;
    pmaddwd        m12, m6, m5                  ;
    pmaddwd        m13, m8, m5                  ;
    phaddd         m12, m13                     ;
                                                ;
    phaddd         m10, m12                     ;
    vbroadcasti128  m5, [tab_idct16_1 + %1 * 16  + 16]
                                                ;
    pmaddwd        m12, m1, m5                  ;
    pmaddwd        m13, m3, m5                  ;
    phaddd         m12, m13                     ;
                                                ;
    pmaddwd        m13, m4, m5                  ;
    pmaddwd         m5, m2                      ;
    phaddd         m13, m5                      ;
                                                ;
    phaddd         m12, m13                     ;
                                                ;
    paddd           m5, m10, m12                ;
    paddd           m5, m14                     ;
    psrad           m5, IDCT16_SHIFT1           ;
                                                ;
    psubd          m10, m12                     ;
    paddd          m10, m14                     ;
    psrad          m10, IDCT16_SHIFT1           ;
                                                ;
    packssdw       m11, m5                      ;
    packssdw        m9, m10                     ;
                                                ;
    mova           m10, [idct16_shuff]          ;
    mova            m5, [idct16_shuff1]         ;
                                                ;
    vpermd         m12, m10, m11                ;
    vpermd         m13, m5, m9                  ;
    mova           [r3 + %1*16*2     ], xm12    ;
    mova           [r3 + %2*16*2     ], xm13    ;
    vextracti128   [r3 + %2*16*2 + 32], m13, 1  ;
    vextracti128   [r3 + %1*16*2 + 32], m12, 1  ;
%endmacro


; ----------------------------------------------------------------------------
; void idct_16x16(const coeff_t *src, coeff_t *dst, int i_dst)
; ----------------------------------------------------------------------------

; ------------------------------------------------------------------
; idct_16x16_avx2
INIT_YMM avx2
cglobal idct_16x16, 3, 7, 16, 0-16*mmsize
%define IDCT16_SHIFT1       5                   ; shift1 = 5
%define IDCT16_ADD1         [pd_16]             ; add1   = 16
%if BIT_DEPTH == 10                             ;
    %define IDCT16_SHIFT2   10                  ;
    vpbroadcastd  m15,      [pd_512]            ;
%elif BIT_DEPTH == 8                            ; for BIT_DEPTH: 8
    %define IDCT16_SHIFT2   12                  ; shift2 = 12
    vpbroadcastd  m15,      [pd_2048]           ; add2   = 2048
%else                                           ;
    %error Unsupported BIT_DEPTH!               ;
%endif                                          ;
                                                ;
    vbroadcasti128 m14, IDCT16_ADD1             ; add1   = 16
                                                ;
    add            r2d, r2d                     ;
    mov             r3, rsp                     ;
    mov            r4d, 2                       ;
                                                ;
.pass1:                                         ;
    movu           xm0, [r0 +  0 * 32]          ;
    movu           xm1, [r0 +  8 * 32]          ;
    punpckhqdq     xm2, xm0, xm1                ;
    punpcklqdq     xm0, xm1                     ;
    vinserti128     m0, m0, xm2, 1              ;
                                                ;
    movu           xm1, [r0 +  1 * 32]          ;
    movu           xm2, [r0 +  9 * 32]          ;
    punpckhqdq     xm3, xm1, xm2                ;
    punpcklqdq     xm1, xm2                     ;
    vinserti128     m1, m1, xm3, 1              ;
                                                ;
    movu           xm2, [r0 + 2  * 32]          ;
    movu           xm3, [r0 + 10 * 32]          ;
    punpckhqdq     xm4, xm2, xm3                ;
    punpcklqdq     xm2, xm3                     ;
    vinserti128     m2, m2, xm4, 1              ;
                                                ;
    movu           xm3, [r0 + 3  * 32]          ;
    movu           xm4, [r0 + 11 * 32]          ;
    punpckhqdq     xm5, xm3, xm4                ;
    punpcklqdq     xm3, xm4                     ;
    vinserti128     m3, m3, xm5, 1              ;
                                                ;
    movu           xm4, [r0 + 4  * 32]          ;
    movu           xm5, [r0 + 12 * 32]          ;
    punpckhqdq     xm6, xm4, xm5                ;
    punpcklqdq     xm4, xm5                     ;
    vinserti128     m4, m4, xm6, 1              ;
                                                ;
    movu           xm5, [r0 + 5  * 32]          ;
    movu           xm6, [r0 + 13 * 32]          ;
    punpckhqdq     xm7, xm5, xm6                ;
    punpcklqdq     xm5, xm6                     ;
    vinserti128     m5, m5, xm7, 1              ;
                                                ;
    movu           xm6, [r0 + 6  * 32]          ;
    movu           xm7, [r0 + 14 * 32]          ;
    punpckhqdq     xm8, xm6, xm7                ;
    punpcklqdq     xm6, xm7                     ;
    vinserti128     m6, m6, xm8, 1              ;
                                                ;
    movu           xm7, [r0 + 7  * 32]          ;
    movu           xm8, [r0 + 15 * 32]          ;
    punpckhqdq     xm9, xm7, xm8                ;
    punpcklqdq     xm7, xm8                     ;
    vinserti128     m7, m7, xm9, 1              ;
                                                ;
    punpckhwd       m8, m0, m2                  ; [8 10]
    punpcklwd       m0, m2                      ; [0 2]
                                                ;
    punpckhwd       m2, m1, m3                  ; [9 11]
    punpcklwd       m1, m3                      ; [1 3]
                                                ;
    punpckhwd       m3, m4, m6                  ; [12 14]
    punpcklwd       m4, m6                      ; [4 6]
                                                ;
    punpckhwd       m6, m5, m7                  ; [13 15]
    punpcklwd       m5, m7                      ; [5 7]
                                                ;
    punpckhdq       m7, m0, m4                  ; [02 22 42 62 03 23 43 63 06 26 46 66 07 27 47 67]
    punpckldq       m0, m4                      ; [00 20 40 60 01 21 41 61 04 24 44 64 05 25 45 65]
                                                ;
    punpckhdq       m4, m8, m3                  ; [82 102 122 142 83 103 123 143 86 106 126 146 87 107 127 147]
    punpckldq       m8, m3                      ; [80 100 120 140 81 101 121 141 84 104 124 144 85 105 125 145]
                                                ;
    punpckhdq       m3, m1, m5                  ; [12 32 52 72 13 33 53 73 16 36 56 76 17 37 57 77]
    punpckldq       m1, m5                      ; [10 30 50 70 11 31 51 71 14 34 54 74 15 35 55 75]
                                                ;
    punpckhdq       m5, m2, m6                  ; [92 112 132 152 93 113 133 153 96 116 136 156 97 117 137 157]
    punpckldq       m2, m6                      ; [90 110 130 150 91 111 131 151 94 114 134 154 95 115 135 155]
                                                ;
    punpckhqdq      m6, m0, m8                  ; [01 21 41 61 81 101 121 141 05 25 45 65 85 105 125 145]
    punpcklqdq      m0, m8                      ; [00 20 40 60 80 100 120 140 04 24 44 64 84 104 124 144]
                                                ;
    punpckhqdq      m8, m7, m4                  ; [03 23 43 63 43 103 123 143 07 27 47 67 87 107 127 147]
    punpcklqdq      m7, m4                      ; [02 22 42 62 82 102 122 142 06 26 46 66 86 106 126 146]
                                                ;
    punpckhqdq      m4, m1, m2                  ; [11 31 51 71 91 111 131 151 15 35 55 75 95 115 135 155]
    punpcklqdq      m1, m2                      ; [10 30 50 70 90 110 130 150 14 34 54 74 94 114 134 154]
                                                ;
    punpckhqdq      m2, m3, m5                  ; [13 33 53 73 93 113 133 153 17 37 57 77 97 117 137 157]
    punpcklqdq      m3, m5                      ; [12 32 52 72 92 112 132 152 16 36 56 76 96 116 136 156]
                                                ;
    IDCT16_PASS1    0, 14                       ;
    IDCT16_PASS1    2, 12                       ;
    IDCT16_PASS1    4, 10                       ;
    IDCT16_PASS1    6, 8                        ;
                                                ;
    add             r0, 16                      ;
    add             r3, 16                      ;
    dec            r4d                          ;
    jnz            .pass1                       ;
                                                ;
    mov             r3, rsp                     ;
    mov            r4d, 8                       ;
    lea             r5, [tab_idct16_2]          ;
    lea             r6, [tab_idct16_1]          ;
                                                ;
    vbroadcasti128  m7, [r5     ]               ;
    vbroadcasti128  m8, [r5 + 16]               ;
    vbroadcasti128  m9, [r5 + 32]               ;
    vbroadcasti128 m10, [r5 + 48]               ;
    vbroadcasti128 m11, [r5 + 64]               ;
    vbroadcasti128 m12, [r5 + 80]               ;
    vbroadcasti128 m13, [r5 + 96]               ;
                                                ;
.pass2:                                         ;
    movu            m1, [r3]                    ;
    vpermq          m0, m1, 0xD8                ;
                                                ;
    pmaddwd         m1, m0, m7                  ;
    pmaddwd         m2, m0, m8                  ;
    phaddd          m1, m2                      ;
                                                ;
    pmaddwd         m2, m0, m9                  ;
    pmaddwd         m3, m0, m10                 ;
    phaddd          m2, m3                      ;
                                                ;
    phaddd          m1, m2                      ;
                                                ;
    pmaddwd         m2, m0, m11                 ;
    pmaddwd         m3, m0, m12                 ;
    phaddd          m2, m3                      ;
                                                ;
    vbroadcasti128 m14, [r5 + 112]              ;
    pmaddwd         m3, m0, m13                 ;
    pmaddwd         m4, m0, m14                 ;
    phaddd          m3, m4                      ;
                                                ;
    phaddd          m2, m3                      ;
                                                ;
    movu            m3, [r3 + 32]               ;
    vpermq          m0, m3, 0xD8                ;
                                                ;
    vbroadcasti128 m14, [r6]                    ;
    pmaddwd         m3, m0, m14                 ;
    vbroadcasti128 m14, [r6 + 16]               ;
    pmaddwd         m4, m0, m14                 ;
    phaddd          m3, m4                      ;
                                                ;
    vbroadcasti128 m14, [r6 + 32]               ;
    pmaddwd         m4, m0, m14                 ;
    vbroadcasti128 m14, [r6 + 48]               ;
    pmaddwd         m5, m0, m14                 ;
    phaddd          m4, m5                      ;
                                                ;
    phaddd          m3, m4                      ;
                                                ;
    vbroadcasti128 m14, [r6 + 64]               ;
    pmaddwd         m4, m0, m14                 ;
    vbroadcasti128 m14, [r6 + 80]               ;
    pmaddwd         m5, m0, m14                 ;
    phaddd          m4, m5                      ;
                                                ;
    vbroadcasti128 m14, [r6 + 96]               ;
    pmaddwd         m6, m0, m14                 ;
    vbroadcasti128 m14, [r6 + 112]              ;
    pmaddwd         m0, m14                     ;
    phaddd          m6, m0                      ;
                                                ;
    phaddd          m4, m6                      ;
                                                ;
    paddd           m5, m1, m3                  ;
    paddd           m5, m15                     ;
    psrad           m5, IDCT16_SHIFT2           ;
                                                ;
    psubd           m1, m3                      ;
    paddd           m1, m15                     ;
    psrad           m1, IDCT16_SHIFT2           ;
                                                ;
    paddd           m6, m2, m4                  ;
    paddd           m6, m15                     ;
    psrad           m6, IDCT16_SHIFT2           ;
                                                ;
    psubd           m2, m4                      ;
    paddd           m2, m15                     ;
    psrad           m2, IDCT16_SHIFT2           ;
                                                ;
    packssdw        m5, m6                      ;
    packssdw        m1, m2                      ;
    pshufb          m2, m1, [dct16_shuf1]       ;
                                                ;
    mova           [r1          ], xm5          ;
    mova           [r1      + 16], xm2          ;
    vextracti128   [r1 + r2     ], m5, 1        ;
    vextracti128   [r1 + r2 + 16], m2, 1        ;
                                                ;
    lea             r1, [r1 + 2 * r2]           ;
    add             r3, 64                      ;
    dec            r4d                          ;
    jnz            .pass2                       ;
    RET                                         ;
%undef IDCT16_SHIFT1
%undef IDCT16_SHIFT2
%undef IDCT16_ADD1
%undef IDCT16_ADD2


%macro IDCT32_PASS1 1
    vbroadcasti128  m3, [tab_idct32_1+%1*32   ] ;
    vbroadcasti128 m13, [tab_idct32_1+%1*32+16] ;
    pmaddwd         m9, m4, m3                  ;
    pmaddwd        m10, m8, m13                 ;
    phaddd          m9, m10                     ;
                                                ;
    pmaddwd        m10, m2, m3                  ;
    pmaddwd        m11, m1, m13                 ;
    phaddd         m10, m11                     ;
                                                ;
    phaddd          m9, m10                     ;
                                                ;
    vbroadcasti128  m3, [tab_idct32_1+(15 - %1)*32   ]
    vbroadcasti128 m13, [tab_idct32_1+(15 - %1)*32+16]
    pmaddwd        m10, m4, m3                  ;
    pmaddwd        m11, m8, m13                 ;
    phaddd         m10, m11                     ;
                                                ;
    pmaddwd        m11, m2, m3                  ;
    pmaddwd        m12, m1, m13                 ;
    phaddd         m11, m12                     ;
                                                ;
    phaddd         m10, m11                     ;
    phaddd          m9, m10                     ; [row0s0 row2s0 row0s15 row2s15 row1s0 row3s0 row1s15 row3s15]
                                                ;
    vbroadcasti128  m3, [tab_idct32_2 + %1*16]  ;
    pmaddwd        m10, m0, m3                  ;
    pmaddwd        m11, m7, m3                  ;
    phaddd         m10, m11                     ;
    phaddd         m10, m10                     ;
                                                ;
    vbroadcasti128  m3, [tab_idct32_3 + %1*16]  ;
    pmaddwd        m11, m5, m3                  ;
    pmaddwd        m12, m6, m3                  ;
    phaddd         m11, m12                     ;
    phaddd         m11, m11                     ;
                                                ;
    paddd          m12, m10, m11                ; [row0a0 row2a0 NIL NIL row1sa0 row3a0 NIL NIL]
    psubd          m10, m11                     ; [row0a15 row2a15 NIL NIL row1a15 row3a15 NIL NIL]
                                                ;
    punpcklqdq     m12, m10                     ; [row0a0 row2a0 row0a15 row2a15 row1a0 row3a0 row1a15 row3a15]
    paddd          m10, m9, m12                 ;
    paddd          m10, m15                     ;
    psrad          m10, IDCT32_SHIFT1           ;
                                                ;
    psubd          m12, m9                      ;
    paddd          m12, m15                     ;
    psrad          m12, IDCT32_SHIFT1           ;
                                                ;
    packssdw       m10, m12                     ;
    vextracti128  xm12, m10, 1                  ;
    movd    [r3              + %1*64], xm10     ;
    movd    [r3 + 32         + %1*64], xm12     ;
    pextrd  [r4              - %1*64], xm10, 1  ;
    pextrd  [r4 + 32         - %1*64], xm12, 1  ;
    pextrd  [r3 + 16*64      + %1*64], xm10, 3  ;
    pextrd  [r3 + 16*64 + 32 + %1*64], xm12, 3  ;
    pextrd  [r4 + 16*64      - %1*64], xm10, 2  ;
    pextrd  [r4 + 16*64 + 32 - %1*64], xm12, 2  ;
%endmacro


; ----------------------------------------------------------------------------
; void idct_32x32(const coeff_t *src, coeff_t *dst, int i_dst)
; ----------------------------------------------------------------------------

; TODO: Reduce PHADDD instruction by PADDD

; ------------------------------------------------------------------
; idct_32x32_avx2
INIT_YMM avx2
cglobal idct_32x32, 3, 6, 16, 0-32*64
    %define IDCT32_SHIFT1    5                  ; shift1 = 5
    %define IDCT32_ADD1      [pd_16]            ; add1   = 16
                                                ;
    vbroadcasti128 m15, IDCT32_ADD1             ; add1   = 16
                                                ;
    mov             r3, rsp                     ;
    lea             r4, [r3 + 15 * 64]          ;
    mov            r5d, 8                       ;
                                                ;
.pass1:                                         ;
    movq           xm0, [r0 +  2 * 64]          ;
    movq           xm1, [r0 + 18 * 64]          ;
    punpcklqdq     xm0, xm0, xm1                ;
    movq           xm1, [r0 +  0 * 64]          ;
    movq           xm2, [r0 + 16 * 64]          ;
    punpcklqdq     xm1, xm1, xm2                ;
    vinserti128     m0,  m0, xm1, 1             ; [2 18 0 16]
                                                ;
    movq           xm1, [r0 +  1 * 64]          ;
    movq           xm2, [r0 +  9 * 64]          ;
    punpcklqdq     xm1, xm1, xm2                ;
    movq           xm2, [r0 + 17 * 64]          ;
    movq           xm3, [r0 + 25 * 64]          ;
    punpcklqdq     xm2, xm2, xm3                ;
    vinserti128     m1,  m1, xm2, 1             ; [1 9 17 25]
                                                ;
    movq           xm2, [r0 +  6 * 64]          ;
    movq           xm3, [r0 + 22 * 64]          ;
    punpcklqdq     xm2, xm2, xm3                ;
    movq           xm3, [r0 + 4 * 64]           ;
    movq           xm4, [r0 + 20 * 64]          ;
    punpcklqdq     xm3, xm3, xm4                ;
    vinserti128     m2,  m2, xm3, 1             ; [6 22 4 20]
                                                ;
    movq           xm3, [r0 +  3 * 64]          ;
    movq           xm4, [r0 + 11 * 64]          ;
    punpcklqdq     xm3, xm3, xm4                ;
    movq           xm4, [r0 + 19 * 64]          ;
    movq           xm5, [r0 + 27 * 64]          ;
    punpcklqdq     xm4, xm4, xm5                ;
    vinserti128     m3,  m3, xm4, 1             ; [3 11 17 25]
                                                ;
    movq           xm4, [r0 + 10 * 64]          ;
    movq           xm5, [r0 + 26 * 64]          ;
    punpcklqdq     xm4, xm4, xm5                ;
    movq           xm5, [r0 +  8 * 64]          ;
    movq           xm6, [r0 + 24 * 64]          ;
    punpcklqdq     xm5, xm5, xm6                ;
    vinserti128     m4,  m4, xm5, 1             ; [10 26 8 24]
                                                ;
    movq           xm5, [r0 +  5 * 64]          ;
    movq           xm6, [r0 + 13 * 64]          ;
    punpcklqdq     xm5, xm5, xm6                ;
    movq           xm6, [r0 + 21 * 64]          ;
    movq           xm7, [r0 + 29 * 64]          ;
    punpcklqdq     xm6, xm6, xm7                ;
    vinserti128     m5,  m5, xm6, 1             ; [5 13 21 9]
                                                ;
    movq           xm6, [r0 + 14 * 64]          ;
    movq           xm7, [r0 + 30 * 64]          ;
    punpcklqdq     xm6, xm6, xm7                ;
    movq           xm7, [r0 + 12 * 64]          ;
    movq           xm8, [r0 + 28 * 64]          ;
    punpcklqdq     xm7, xm7, xm8                ;
    vinserti128     m6,  m6, xm7, 1             ; [14 30 12 28]
                                                ;
    movq           xm7, [r0 +  7 * 64]          ;
    movq           xm8, [r0 + 15 * 64]          ;
    punpcklqdq     xm7, xm7, xm8                ;
    movq           xm8, [r0 + 23 * 64]          ;
    movq           xm9, [r0 + 31 * 64]          ;
    punpcklqdq     xm8, xm8, xm9                ;
    vinserti128     m7,  m7, xm8, 1             ; [7 15 23 31]
                                                ;
    punpckhwd       m8, m0, m2                  ; [18 22 16 20]
    punpcklwd       m0, m2                      ; [2 6 0 4]
                                                ;
    punpckhwd       m2, m1, m3                  ; [9 11 25 27]
    punpcklwd       m1, m3                      ; [1 3 17 19]
                                                ;
    punpckhwd       m3, m4, m6                  ; [26 30 24 28]
    punpcklwd       m4, m6                      ; [10 14 8 12]
                                                ;
    punpckhwd       m6, m5, m7                  ; [13 15 29 31]
    punpcklwd       m5, m7                      ; [5 7 21 23]
                                                ;
    punpckhdq       m7, m0, m4                  ; [22 62 102 142 23 63 103 143 02 42 82 122 03 43 83 123]
    punpckldq       m0, m4                      ; [20 60 100 140 21 61 101 141 00 40 80 120 01 41 81 121]
                                                ;
    punpckhdq       m4, m8, m3                  ; [182 222 262 302 183 223 263 303 162 202 242 282 163 203 243 283]
    punpckldq       m8, m3                      ; [180 220 260 300 181 221 261 301 160 200 240 280 161 201 241 281]
                                                ;
    punpckhdq       m3, m1, m5                  ; [12 32 52 72 13 33 53 73 172 192 212 232 173 193 213 233]
    punpckldq       m1, m5                      ; [10 30 50 70 11 31 51 71 170 190 210 230 171 191 211 231]
                                                ;
    punpckhdq       m5, m2, m6                  ; [92 112 132 152 93 113 133 153 252 272 292 312 253 273 293 313]
    punpckldq       m2, m6                      ; [90 110 130 150 91 111 131 151 250 270 290 310 251 271 291 311]
                                                ;
    punpckhqdq      m6, m0, m8                  ; [21 61 101 141 181 221 261 301 01 41 81 121 161 201 241 281]
    punpcklqdq      m0, m8                      ; [20 60 100 140 180 220 260 300 00 40 80 120 160 200 240 280]
                                                ;
    punpckhqdq      m8, m7, m4                  ; [23 63 103 143 183 223 263 303 03 43 83 123 163 203 243 283]
    punpcklqdq      m7, m4                      ; [22 62 102 142 182 222 262 302 02 42 82 122 162 202 242 282]
                                                ;
    punpckhqdq      m4, m1, m2                  ; [11 31 51 71 91 111 131 151 171 191 211 231 251 271 291 311]
    punpcklqdq      m1, m2                      ; [10 30 50 70 90 110 130 150 170 190 210 230 250 270 290 310]
                                                ;
    punpckhqdq      m2, m3, m5                  ; [13 33 53 73 93 113 133 153 173 193 213 233 253 273 293 313]
    punpcklqdq      m3, m5                      ; [12 32 52 72 92 112 132 152 172 192 212 232 252 272 292 312]
                                                ;
    vperm2i128      m5, m0, m6, 0x20            ; [20 60 100 140 180 220 260 300 21 61 101 141 181 221 261 301]
    vperm2i128      m0, m0, m6, 0x31            ; [00 40 80 120 160 200 240 280 01 41 81 121 161 201 241 281]
                                                ;
    vperm2i128      m6, m7, m8, 0x20            ; [22 62 102 142 182 222 262 302 23 63 103 143 183 223 263 303]
    vperm2i128      m7, m7, m8, 0x31            ; [02 42 82 122 162 202 242 282 03 43 83 123 163 203 243 283]
                                                ;
    vperm2i128      m8, m1, m4, 0x31            ; [170 190 210 230 250 270 290 310 171 191 211 231 251 271 291 311]
    vperm2i128      m4, m1, m4, 0x20            ; [10 30 50 70 90 110 130 150 11 31 51 71 91 111 131 151]
                                                ;
    vperm2i128      m1, m3, m2, 0x31            ; [172 192 212 232 252 272 292 312 173 193 213 233 253 273 293 313]
    vperm2i128      m2, m3, m2, 0x20            ; [12 32 52 72 92 112 132 152 13 33 53 73 93 113 133 153]
                                                ;
    IDCT32_PASS1    0                           ;
    IDCT32_PASS1    1                           ;
    IDCT32_PASS1    2                           ;
    IDCT32_PASS1    3                           ;
    IDCT32_PASS1    4                           ;
    IDCT32_PASS1    5                           ;
    IDCT32_PASS1    6                           ;
    IDCT32_PASS1    7                           ;
                                                ;
    add             r0, 8                       ;
    add             r3, 4                       ;
    add             r4, 4                       ;
    dec            r5d                          ;
    jnz            .pass1                       ;
                                                ;
%if BIT_DEPTH == 10                             ;
    %define IDCT_SHIFT2 10                      ;
    vpbroadcastd   m15, [pd_512 ]               ;
%elif BIT_DEPTH == 8                            ; for BIT_DEPTH: 8
    test            r2, 0x01                    ; test flag?
    jz             .b32x32                      ;
    lea             r5, [pd_11  ]               ; shift2 = 11
    vpbroadcastq   m15, [pd_2048]               ; add2   = 1024
    and             r2, 0xFE                    ; clear the flag
    jmp            .normal_start                ;
.b32x32:                                        ;
    lea             r5, [pd_12  ]               ; shift2 = 12
    vpbroadcastq   m15, [pd_2048]               ; add2   = 2048
.normal_start:                                  ;
%else                                           ;
    %error Unsupported BIT_DEPTH!               ;
%endif                                          ;
                                                ;
    mov             r3, rsp                     ;
    add            r2d, r2d                     ;
    mov            r4d, 32                      ;
                                                ;
    mova            m7, [tab_idct32_4    ]      ;
    mova            m8, [tab_idct32_4+ 32]      ;
    mova            m9, [tab_idct32_4+ 64]      ;
    mova           m10, [tab_idct32_4+ 96]      ;
    mova           m11, [tab_idct32_4+128]      ;
    mova           m12, [tab_idct32_4+160]      ;
    mova           m13, [tab_idct32_4+192]      ;
    mova           m14, [tab_idct32_4+224]      ;
.pass2:                                         ;
    movu            m0, [r3]                    ;
    movu            m1, [r3 + 32]               ;
                                                ;
    pmaddwd         m2, m0, m7                  ;
    pmaddwd         m3, m0, m8                  ;
    phaddd          m2, m3                      ;
                                                ;
    pmaddwd         m3, m0, m9                  ;
    pmaddwd         m4, m0, m10                 ;
    phaddd          m3, m4                      ;
                                                ;
    phaddd          m2, m3                      ;
                                                ;
    pmaddwd         m3, m0, m11                 ;
    pmaddwd         m4, m0, m12                 ;
    phaddd          m3, m4                      ;
                                                ;
    pmaddwd         m4, m0, m13                 ;
    pmaddwd         m5, m0, m14                 ;
    phaddd          m4, m5                      ;
                                                ;
    phaddd          m3, m4                      ;
                                                ;
    vperm2i128      m4, m2, m3, 0x31            ;
    vperm2i128      m2, m2, m3, 0x20            ;
    paddd           m2, m4                      ;
                                                ;
    pmaddwd         m3, m0, [tab_idct32_4+256]  ;
    pmaddwd         m4, m0, [tab_idct32_4+288]  ;
    phaddd          m3, m4                      ;
                                                ;
    pmaddwd         m4, m0, [tab_idct32_4+320]  ;
    pmaddwd         m5, m0, [tab_idct32_4+352]  ;
    phaddd          m4, m5                      ;
                                                ;
    phaddd          m3, m4                      ;
                                                ;
    pmaddwd         m4, m0, [tab_idct32_4+384]  ;
    pmaddwd         m5, m0, [tab_idct32_4+416]  ;
    phaddd          m4, m5                      ;
                                                ;
    pmaddwd         m5, m0, [tab_idct32_4+448]  ;
    pmaddwd         m0,     [tab_idct32_4+480]  ;
    phaddd          m5, m0                      ;
                                                ;
    phaddd          m4, m5                      ;
                                                ;
    vperm2i128      m0, m3, m4, 0x31            ;
    vperm2i128      m3, m3, m4, 0x20            ;
    paddd           m3, m0                      ;
                                                ;
    pmaddwd         m4, m1, [tab_idct32_1]      ;
    pmaddwd         m0, m1, [tab_idct32_1+32]   ;
    phaddd          m4, m0                      ;
                                                ;
    pmaddwd         m5, m1, [tab_idct32_1+ 64]  ;
    pmaddwd         m0, m1, [tab_idct32_1+ 96]  ;
    phaddd          m5, m0                      ;
                                                ;
    phaddd          m4, m5                      ;
                                                ;
    pmaddwd         m5, m1, [tab_idct32_1+128]  ;
    pmaddwd         m0, m1, [tab_idct32_1+160]  ;
    phaddd          m5, m0                      ;
                                                ;
    pmaddwd         m6, m1, [tab_idct32_1+192]  ;
    pmaddwd         m0, m1, [tab_idct32_1+224]  ;
    phaddd          m6, m0                      ;
                                                ;
    phaddd          m5, m6                      ;
                                                ;
    vperm2i128      m0, m4, m5, 0x31            ;
    vperm2i128      m4, m4, m5, 0x20            ;
    paddd           m4, m0                      ;
                                                ;
    pmaddwd         m5, m1, [tab_idct32_1+256]  ;
    pmaddwd         m0, m1, [tab_idct32_1+288]  ;
    phaddd          m5, m0                      ;
                                                ;
    pmaddwd         m6, m1, [tab_idct32_1+320]  ;
    pmaddwd         m0, m1, [tab_idct32_1+352]  ;
    phaddd          m6, m0                      ;
                                                ;
    phaddd          m5, m6                      ;
                                                ;
    pmaddwd         m6, m1, [tab_idct32_1+384]  ;
    pmaddwd         m0, m1, [tab_idct32_1+416]  ;
    phaddd          m6, m0                      ;
                                                ;
    pmaddwd         m0, m1, [tab_idct32_1+448]  ;
    pmaddwd         m1,     [tab_idct32_1+480]  ;
    phaddd          m0, m1                      ;
                                                ;
    phaddd          m6, m0                      ;
                                                ;
    vperm2i128      m0, m5, m6, 0x31            ;
    vperm2i128      m5, m5, m6, 0x20            ;
    paddd           m5, m0                      ;
                                                ;
    paddd           m6, m2, m4                  ;
    paddd           m6, m15                     ;
    psrad           m6, [r5]                    ; shift2
                                                ;
    psubd           m2, m4                      ;
    paddd           m2, m15                     ;
    psrad           m2, [r5]                    ; shift2
                                                ;
    paddd           m4, m3, m5                  ;
    paddd           m4, m15                     ;
    psrad           m4, [r5]                    ; shift2
                                                ;
    psubd           m3, m5                      ;
    paddd           m3, m15                     ;
    psrad           m3, [r5]                    ; shift2
                                                ;
    packssdw        m6, m4                      ;
    packssdw        m2, m3                      ;
                                                ;
    vpermq          m6, m6, 0xD8                ;
    vpermq          m2, m2, 0x8D                ;
    pshufb          m2, [dct16_shuf1]           ;
                                                ;
    movu     [r1     ], m6                      ;
    movu     [r1 + 32], m2                      ;
                                                ;
    add             r1, r2                      ;
    add             r3, 64                      ;
    dec             r4d                         ;
    jnz            .pass2                       ;
    RET                                         ;
%undef IDCT32_SHIFT1
%undef IDCT32_SHIFT2
%undef IDCT32_ADD1
%undef IDCT32_ADD2

%endif                                          ; if ARCH_X86_64 == 1
