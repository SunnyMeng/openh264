;*!
;* \copy
;*     Copyright (c)  2009-2013, Cisco Systems
;*     All rights reserved.
;*
;*     Redistribution and use in source and binary forms, with or without
;*     modification, are permitted provided that the following conditions
;*     are met:
;*
;*        * Redistributions of source code must retain the above copyright
;*          notice, this list of conditions and the following disclaimer.
;*
;*        * Redistributions in binary form must reproduce the above copyright
;*          notice, this list of conditions and the following disclaimer in
;*          the documentation and/or other materials provided with the
;*          distribution.
;*
;*     THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
;*     "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
;*     LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
;*     FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
;*     COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
;*     INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
;*     BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
;*     LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
;*     CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
;*     LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
;*     ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
;*     POSSIBILITY OF SUCH DAMAGE.
;*
;*
;*  quant.asm
;*
;*  Abstract
;*      sse2 quantize inter-block
;*
;*  History
;*      7/6/2009 Created
;*
;*
;*************************************************************************/

%include "asm_inc.asm"

BITS 32

SECTION .text
;************************************************
;NEW_QUANT
;************************************************

%macro SSE2_Quant8  5
		MOVDQ	%1, %5
		pxor	%2, %2
		pcmpgtw	%2, %1
		pxor	%1, %2
		psubw	%1, %2
		paddusw	%1, %3
		pmulhuw	%1, %4
		pxor	%1, %2
		psubw	%1, %2
		MOVDQ	%5, %1
%endmacro

%macro SSE2_QuantMax8  6
		MOVDQ	%1, %5
		pxor	%2, %2
		pcmpgtw	%2, %1
		pxor	%1, %2
		psubw	%1, %2
		paddusw	%1, %3
		pmulhuw	%1, %4
		pmaxsw	%6, %1
		pxor	%1, %2
		psubw	%1, %2
		MOVDQ	%5, %1
%endmacro

%define pDct				esp + 4
%define ff					esp + 8
%define mf					esp + 12
%define max					esp + 16
;***********************************************************************
;	void WelsQuant4x4_sse2(int16_t *pDct, int16_t* ff,  int16_t *mf);
;***********************************************************************
WELS_EXTERN WelsQuant4x4_sse2
align 16
WelsQuant4x4_sse2:
		mov		eax,  [ff]
		mov		ecx,  [mf]
		MOVDQ	xmm2, [eax]
		MOVDQ	xmm3, [ecx]

		mov		edx,  [pDct]
		SSE2_Quant8	xmm0, xmm1, xmm2, xmm3, [edx]
		SSE2_Quant8	xmm0, xmm1, xmm2, xmm3, [edx + 0x10]

		ret

;***********************************************************************
;void WelsQuant4x4Dc_sse2(int16_t *pDct, const int16_t ff, int16_t mf);
;***********************************************************************
WELS_EXTERN WelsQuant4x4Dc_sse2
align 16
WelsQuant4x4Dc_sse2:
		mov		ax,		[mf]
		SSE2_Copy8Times xmm3, eax

		mov		cx, [ff]
		SSE2_Copy8Times xmm2, ecx

		mov		edx,  [pDct]
		SSE2_Quant8	xmm0, xmm1, xmm2, xmm3, [edx]
		SSE2_Quant8	xmm0, xmm1, xmm2, xmm3, [edx + 0x10]

		ret

;***********************************************************************
;	void WelsQuantFour4x4_sse2(int16_t *pDct, int16_t* ff,  int16_t *mf);
;***********************************************************************
WELS_EXTERN WelsQuantFour4x4_sse2
align 16
WelsQuantFour4x4_sse2:
		mov		eax,  [ff]
		mov		ecx,  [mf]
		MOVDQ	xmm2, [eax]
		MOVDQ	xmm3, [ecx]

		mov		edx,  [pDct]
		SSE2_Quant8	xmm0, xmm1, xmm2, xmm3, [edx]
		SSE2_Quant8	xmm0, xmm1, xmm2, xmm3, [edx + 0x10]
		SSE2_Quant8	xmm0, xmm1, xmm2, xmm3, [edx + 0x20]
		SSE2_Quant8	xmm0, xmm1, xmm2, xmm3, [edx + 0x30]
		SSE2_Quant8	xmm0, xmm1, xmm2, xmm3, [edx + 0x40]
		SSE2_Quant8	xmm0, xmm1, xmm2, xmm3, [edx + 0x50]
		SSE2_Quant8	xmm0, xmm1, xmm2, xmm3, [edx + 0x60]
		SSE2_Quant8	xmm0, xmm1, xmm2, xmm3, [edx + 0x70]

		ret

;***********************************************************************
;	void WelsQuantFour4x4Max_sse2(int16_t *pDct, int32_t* f,  int16_t *mf, int16_t *max);
;***********************************************************************
WELS_EXTERN WelsQuantFour4x4Max_sse2
align 16
WelsQuantFour4x4Max_sse2:
		mov		eax,  [ff]
		mov		ecx,  [mf]
		MOVDQ	xmm2, [eax]
		MOVDQ	xmm3, [ecx]

		mov		edx,  [pDct]
		pxor	xmm4, xmm4
		pxor	xmm5, xmm5
		pxor	xmm6, xmm6
		pxor	xmm7, xmm7
		SSE2_QuantMax8	xmm0, xmm1, xmm2, xmm3, [edx	   ], xmm4
		SSE2_QuantMax8	xmm0, xmm1, xmm2, xmm3, [edx + 0x10], xmm4
		SSE2_QuantMax8	xmm0, xmm1, xmm2, xmm3, [edx + 0x20], xmm5
		SSE2_QuantMax8	xmm0, xmm1, xmm2, xmm3, [edx + 0x30], xmm5
		SSE2_QuantMax8	xmm0, xmm1, xmm2, xmm3, [edx + 0x40], xmm6
		SSE2_QuantMax8	xmm0, xmm1, xmm2, xmm3, [edx + 0x50], xmm6
		SSE2_QuantMax8	xmm0, xmm1, xmm2, xmm3, [edx + 0x60], xmm7
		SSE2_QuantMax8	xmm0, xmm1, xmm2, xmm3, [edx + 0x70], xmm7

		SSE2_TransTwo4x4W xmm4, xmm5, xmm6, xmm7, xmm0
		pmaxsw  xmm0,  xmm4
		pmaxsw  xmm0,  xmm5
		pmaxsw  xmm0,  xmm7
		movdqa	xmm1,  xmm0
		punpckhqdq	xmm0, xmm1
		pmaxsw	xmm0, xmm1

		mov		edx,  [max]
		movq	[edx], xmm0

		ret

%macro  MMX_Copy4Times 2
		movd		%1, %2
		punpcklwd	%1, %1
		punpckldq	%1,	%1
%endmacro

SECTION .text

%macro MMX_Quant4  4
		pxor	%2, %2
		pcmpgtw	%2, %1
		pxor	%1, %2
		psubw	%1, %2
		paddusw	%1, %3
		pmulhuw	%1, %4
		pxor	%1, %2
		psubw	%1, %2
%endmacro

%define dct2x2				esp + 16
%define iChromaDc			esp + 20
;***********************************************************************
;int32_t WelsHadamardQuant2x2_mmx(int16_t *rs, const int16_t ff, int16_t mf, int16_t * pDct, int16_t * block);
;***********************************************************************
WELS_EXTERN WelsHadamardQuant2x2_mmx
align 16
WelsHadamardQuant2x2_mmx:

		mov			eax,			[pDct]
		movd		mm0,			[eax]
		movd		mm1,			[eax + 0x20]
		punpcklwd	mm0,			mm1
		movd		mm3,			[eax + 0x40]
		movd		mm1,			[eax + 0x60]
		punpcklwd	mm3,			mm1

		mov			cx,				0
		mov			[eax],			cx
		mov			[eax + 0x20],	cx
		mov			[eax + 0x40],	cx
		mov			[eax + 0x60],	cx

		;hdm_2x2,	mm0 = dct0 dct1, mm3 = dct2 dct3
		movq		mm5,			mm3
		paddw		mm3,			mm0
		psubw		mm0,			mm5
		punpcklwd	mm3,			mm0
		movq		mm1,			mm3
		psrlq		mm1,			32
		movq		mm5,			mm1
		paddw		mm1,			mm3
		psubw		mm3,			mm5
		punpcklwd	mm1,			mm3

		;quant_2x2_dc
		mov			ax,				[mf]
		MMX_Copy4Times	mm3,		eax
		mov			cx,				[ff]
		MMX_Copy4Times	mm2,		ecx
		MMX_Quant4		mm1,	mm0,	mm2,	mm3

		; store dct_2x2
		mov			edx,			[dct2x2]
		movq		[edx],			mm1
		mov			ecx,			[iChromaDc]
		movq		[ecx],			mm1

		; pNonZeroCount of dct_2x2
		pcmpeqb		mm2,			mm2		; mm2 = FF
		pxor		mm3,			mm3
		packsswb	mm1,			mm3
		pcmpeqb		mm1,			mm3		; set FF if equal, 0 if not equal
		psubsb		mm1,			mm2		; set 0 if equal, 1 if not equal
		psadbw		mm1,			mm3		;
		movd		eax,			mm1

		WELSEMMS
		ret

;***********************************************************************
;int32_t WelsHadamardQuant2x2Skip_mmx(int16_t *pDct, int16_t ff,  int16_t mf);
;***********************************************************************
WELS_EXTERN WelsHadamardQuant2x2Skip_mmx
align 16
WelsHadamardQuant2x2Skip_mmx:

		mov			eax,			[pDct]
		movd		mm0,			[eax]
		movd		mm1,			[eax + 0x20]
		punpcklwd	mm0,			mm1
		movd		mm3,			[eax + 0x40]
		movd		mm1,			[eax + 0x60]
		punpcklwd	mm3,			mm1

		;hdm_2x2,	mm0 = dct0 dct1, mm3 = dct2 dct3
		movq		mm5,			mm3
		paddw		mm3,			mm0
		psubw		mm0,			mm5
		punpcklwd	mm3,			mm0
		movq		mm1,			mm3
		psrlq		mm1,			32
		movq		mm5,			mm1
		paddw		mm1,			mm3
		psubw		mm3,			mm5
		punpcklwd	mm1,			mm3

		;quant_2x2_dc
		mov			ax,				[mf]
		MMX_Copy4Times	mm3,		eax
		mov			cx,				[ff]
		MMX_Copy4Times	mm2,		ecx
		MMX_Quant4		mm1,	mm0,	mm2,	mm3

		; pNonZeroCount of dct_2x2
		pcmpeqb		mm2,			mm2		; mm2 = FF
		pxor		mm3,			mm3
		packsswb	mm1,			mm3
		pcmpeqb		mm1,			mm3		; set FF if equal, 0 if not equal
		psubsb		mm1,			mm2		; set 0 if equal, 1 if not equal
		psadbw		mm1,			mm3		;
		movd		eax,			mm1

		WELSEMMS
		ret


%macro SSE2_DeQuant8 3
    MOVDQ  %2, %1
    pmullw %2, %3
    MOVDQ  %1, %2
%endmacro


ALIGN  16
;***********************************************************************
; void WelsDequant4x4_sse2(int16_t *pDct, const uint16_t* mf);
;***********************************************************************
align 16
WELS_EXTERN WelsDequant4x4_sse2
WelsDequant4x4_sse2:
	;ecx = dequant_mf[qp], edx = pDct
	mov		ecx,  [esp + 8]
	mov		edx,  [esp + 4]

	movdqa  xmm1, [ecx]
	SSE2_DeQuant8 [edx		],  xmm0, xmm1
	SSE2_DeQuant8 [edx+0x10	],  xmm0, xmm1

    ret

;***********************************************************************====
;void WelsDequantFour4x4_sse2(int16_t *pDct, const uint16_t* mf);
;***********************************************************************====

align 16

WELS_EXTERN WelsDequantFour4x4_sse2
WelsDequantFour4x4_sse2:
    ;ecx = dequant_mf[qp], edx = pDct
	mov		ecx,  [esp + 8]
	mov		edx,  [esp + 4]

	movdqa  xmm1, [ecx]
	SSE2_DeQuant8 [edx		],  xmm0, xmm1
	SSE2_DeQuant8 [edx+0x10	],  xmm0, xmm1
	SSE2_DeQuant8 [edx+0x20	],  xmm0, xmm1
	SSE2_DeQuant8 [edx+0x30	],  xmm0, xmm1
	SSE2_DeQuant8 [edx+0x40	],  xmm0, xmm1
	SSE2_DeQuant8 [edx+0x50	],  xmm0, xmm1
	SSE2_DeQuant8 [edx+0x60	],  xmm0, xmm1
	SSE2_DeQuant8 [edx+0x70	],  xmm0, xmm1

    ret

;***********************************************************************
;void WelsDequantIHadamard4x4_sse2(int16_t *rs, const uint16_t mf);
;***********************************************************************
WELS_EXTERN WelsDequantIHadamard4x4_sse2
align 16
WelsDequantIHadamard4x4_sse2:
		mov			eax,			[esp + 4]
		mov			cx,				[esp + 8]

		; WelsDequantLumaDc4x4
		SSE2_Copy8Times	xmm1,		ecx
		;psrlw		xmm1,		2		; for the (>>2) in ihdm
		MOVDQ		xmm0,		[eax]
		MOVDQ		xmm2,		[eax+0x10]
		pmullw		xmm0,		xmm1
		pmullw		xmm2,		xmm1

		; ihdm_4x4
		movdqa		xmm1,		xmm0
		psrldq		xmm1,		8
		movdqa		xmm3,		xmm2
		psrldq		xmm3,		8

		SSE2_SumSub		xmm0, xmm3,	xmm5					; xmm0 = xmm0 - xmm3, xmm3 = xmm0 + xmm3
		SSE2_SumSub		xmm1, xmm2, xmm5					; xmm1 = xmm1 - xmm2, xmm2 = xmm1 + xmm2
		SSE2_SumSub		xmm3, xmm2, xmm5					; xmm3 = xmm3 - xmm2, xmm2 = xmm3 + xmm2
		SSE2_SumSub		xmm0, xmm1, xmm5               		; xmm0 = xmm0 - xmm1, xmm1 = xmm0 + xmm1

		SSE2_TransTwo4x4W	xmm2, xmm1, xmm3, xmm0, xmm4
		SSE2_SumSub		xmm2, xmm4,	xmm5
		SSE2_SumSub		xmm1, xmm0, xmm5
		SSE2_SumSub		xmm4, xmm0, xmm5
		SSE2_SumSub		xmm2, xmm1, xmm5
		SSE2_TransTwo4x4W	xmm0, xmm1, xmm4, xmm2, xmm3

		punpcklqdq	xmm0,		xmm1
		MOVDQ		[eax],		xmm0

		punpcklqdq	xmm2,		xmm3
		MOVDQ		[eax+16],	xmm2
		ret
