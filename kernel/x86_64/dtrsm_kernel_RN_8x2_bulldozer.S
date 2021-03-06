/*********************************************************************/
/* Copyright 2009, 2010 The University of Texas at Austin.           */
/* All rights reserved.                                              */
/*                                                                   */
/* Redistribution and use in source and binary forms, with or        */
/* without modification, are permitted provided that the following   */
/* conditions are met:                                               */
/*                                                                   */
/*   1. Redistributions of source code must retain the above         */
/*      copyright notice, this list of conditions and the following  */
/*      disclaimer.                                                  */
/*                                                                   */
/*   2. Redistributions in binary form must reproduce the above      */
/*      copyright notice, this list of conditions and the following  */
/*      disclaimer in the documentation and/or other materials       */
/*      provided with the distribution.                              */
/*                                                                   */
/*    THIS  SOFTWARE IS PROVIDED  BY THE  UNIVERSITY OF  TEXAS AT    */
/*    AUSTIN  ``AS IS''  AND ANY  EXPRESS OR  IMPLIED WARRANTIES,    */
/*    INCLUDING, BUT  NOT LIMITED  TO, THE IMPLIED  WARRANTIES OF    */
/*    MERCHANTABILITY  AND FITNESS FOR  A PARTICULAR  PURPOSE ARE    */
/*    DISCLAIMED.  IN  NO EVENT SHALL THE UNIVERSITY  OF TEXAS AT    */
/*    AUSTIN OR CONTRIBUTORS BE  LIABLE FOR ANY DIRECT, INDIRECT,    */
/*    INCIDENTAL,  SPECIAL, EXEMPLARY,  OR  CONSEQUENTIAL DAMAGES    */
/*    (INCLUDING, BUT  NOT LIMITED TO,  PROCUREMENT OF SUBSTITUTE    */
/*    GOODS  OR  SERVICES; LOSS  OF  USE,  DATA,  OR PROFITS;  OR    */
/*    BUSINESS INTERRUPTION) HOWEVER CAUSED  AND ON ANY THEORY OF    */
/*    LIABILITY, WHETHER  IN CONTRACT, STRICT  LIABILITY, OR TORT    */
/*    (INCLUDING NEGLIGENCE OR OTHERWISE)  ARISING IN ANY WAY OUT    */
/*    OF  THE  USE OF  THIS  SOFTWARE,  EVEN  IF ADVISED  OF  THE    */
/*    POSSIBILITY OF SUCH DAMAGE.                                    */
/*                                                                   */
/* The views and conclusions contained in the software and           */
/* documentation are those of the authors and should not be          */
/* interpreted as representing official policies, either expressed   */
/* or implied, of The University of Texas at Austin.                 */
/*********************************************************************/

#define ASSEMBLER
#include "common.h"
 
#define OLD_M	%rdi
#define OLD_N	%rsi
#define M	%r13
#define N	%r14
#define K	%rdx

#define A	%rcx
#define B	%r8
#define C	%r9
#define LDC	%r10
	
#define I	%r11
#define AO	%rdi
#define BO	%rsi
#define	CO1	%r15
#define CO2	%r12
#define BB	%rbp
#define	J	%rbx

#ifndef WINDOWS_ABI

#define STACKSIZE 96

#define OFFSET	 48(%rsp)
#define AORIG	 56(%rsp)
#define KK	 64(%rsp)
#define KKK	 72(%rsp)

#else

#define STACKSIZE 256

#define OLD_A		40 + STACKSIZE(%rsp)
#define OLD_B		48 + STACKSIZE(%rsp)
#define OLD_C		56 + STACKSIZE(%rsp)
#define OLD_LDC		64 + STACKSIZE(%rsp)
#define OLD_OFFSET	72 + STACKSIZE(%rsp)

#define OFFSET	224(%rsp)
#define AORIG	232(%rsp)
#define KK	240(%rsp)
#define KKK	248(%rsp)

#endif

#define A_PR1   384
#define B_PR1   192


.macro KERNEL8x2_SUB
	vmovddup	-16*SIZE(BO,%rax,2), %xmm1
	vmovddup	-15*SIZE(BO,%rax,2), %xmm2
	vmovups		-16*SIZE(AO,%rax,8), %xmm0
	vfmaddpd	%xmm8 , %xmm0 , %xmm1 , %xmm8
	vfmaddpd	%xmm9 , %xmm0 , %xmm2 , %xmm9
	vmovups		-14*SIZE(AO,%rax,8), %xmm4
	vfmaddpd	%xmm10, %xmm4 , %xmm1 , %xmm10
	vfmaddpd	%xmm11, %xmm4 , %xmm2 , %xmm11
	vmovups		-12*SIZE(AO,%rax,8), %xmm5
	vfmaddpd	%xmm12, %xmm5 , %xmm1 , %xmm12
	vfmaddpd	%xmm13, %xmm5 , %xmm2 , %xmm13
	vmovups		-10*SIZE(AO,%rax,8), %xmm6
	vfmaddpd	%xmm14, %xmm6 , %xmm1 , %xmm14
	vfmaddpd	%xmm15, %xmm6 , %xmm2 , %xmm15
	addq    $SIZE, %rax
.endm

.macro SOLVE_8x2

	vmovups		-16 * SIZE(AO), %xmm0
	vmovups		-14 * SIZE(AO), %xmm1
	vmovups		-12 * SIZE(AO), %xmm2
	vmovups		-10 * SIZE(AO), %xmm3
	vmovups		 -8 * SIZE(AO), %xmm4
	vmovups		 -6 * SIZE(AO), %xmm5
	vmovups		 -4 * SIZE(AO), %xmm6
	vmovups		 -2 * SIZE(AO), %xmm7

        vsubpd  	%xmm8 , %xmm0 , %xmm0
        vsubpd  	%xmm10, %xmm1 , %xmm1
        vsubpd  	%xmm12, %xmm2 , %xmm2
        vsubpd  	%xmm14, %xmm3 , %xmm3
        vsubpd  	%xmm9 , %xmm4 , %xmm4
        vsubpd  	%xmm11, %xmm5 , %xmm5
        vsubpd  	%xmm13, %xmm6 , %xmm6
        vsubpd  	%xmm15, %xmm7 , %xmm7

	vmovddup        -16 * SIZE(BO), %xmm8
        vmulpd                  %xmm0 , %xmm8 , %xmm0
        vmulpd                  %xmm1 , %xmm8 , %xmm1
        vmulpd                  %xmm2 , %xmm8 , %xmm2
        vmulpd                  %xmm3 , %xmm8 , %xmm3

        vmovddup        -15 * SIZE(BO), %xmm9
        vfnmaddpd       %xmm4 , %xmm0 , %xmm9 , %xmm4 
        vfnmaddpd       %xmm5 , %xmm1 , %xmm9 , %xmm5 
        vfnmaddpd       %xmm6 , %xmm2 , %xmm9 , %xmm6 
        vfnmaddpd       %xmm7 , %xmm3 , %xmm9 , %xmm7 

        vmovddup        -13 * SIZE(BO), %xmm10
        vmulpd                  %xmm4 , %xmm10, %xmm4
        vmulpd                  %xmm5 , %xmm10, %xmm5
        vmulpd                  %xmm6 , %xmm10, %xmm6
        vmulpd                  %xmm7 , %xmm10, %xmm7

	vmovups %xmm0 ,  0 * SIZE(CO1)
	vmovups %xmm1 ,  2 * SIZE(CO1)
	vmovups %xmm2 ,  4 * SIZE(CO1)
	vmovups %xmm3 ,  6 * SIZE(CO1)

	vmovups	%xmm4 ,  0 * SIZE(CO2)
	vmovups	%xmm5 ,  2 * SIZE(CO2)
	vmovups	%xmm6 ,  4 * SIZE(CO2)
	vmovups	%xmm7 ,  6 * SIZE(CO2)

	vmovups	%xmm0 , -16 * SIZE(AO)
	vmovups	%xmm1 , -14 * SIZE(AO)
	vmovups	%xmm2 , -12 * SIZE(AO)
	vmovups	%xmm3 , -10 * SIZE(AO)
	vmovups	%xmm4 ,  -8 * SIZE(AO)
	vmovups	%xmm5 ,  -6 * SIZE(AO)
	vmovups	%xmm6 ,  -4 * SIZE(AO)
	vmovups	%xmm7 ,  -2 * SIZE(AO)


.endm



.macro KERNEL4x2_SUB
	vmovddup	-16*SIZE(BO,%rax,2), %xmm1
	vmovddup	-15*SIZE(BO,%rax,2), %xmm2
	vmovups		-16*SIZE(AO,%rax,4), %xmm0
	vfmaddpd	%xmm8 , %xmm0 , %xmm1 , %xmm8
	vfmaddpd	%xmm9 , %xmm0 , %xmm2 , %xmm9
	vmovups		-14*SIZE(AO,%rax,4), %xmm0
	vfmaddpd	%xmm10, %xmm0 , %xmm1 , %xmm10
	vfmaddpd	%xmm11, %xmm0 , %xmm2 , %xmm11
	addq    $SIZE, %rax
.endm


.macro SOLVE_4x2

	vmovups		-16 * SIZE(AO), %xmm0
	vmovups		-14 * SIZE(AO), %xmm1
	vmovups		-12 * SIZE(AO), %xmm2
	vmovups		-10 * SIZE(AO), %xmm3

        vsubpd  	%xmm8 , %xmm0 , %xmm0
        vsubpd  	%xmm10, %xmm1 , %xmm1
        vsubpd  	%xmm9 , %xmm2 , %xmm2
        vsubpd  	%xmm11, %xmm3 , %xmm3

	vmovddup        -16 * SIZE(BO), %xmm8
        vmulpd                  %xmm0 , %xmm8 , %xmm0
        vmulpd                  %xmm1 , %xmm8 , %xmm1

        vmovddup        -15 * SIZE(BO), %xmm9
        vfnmaddpd       %xmm2 , %xmm0 , %xmm9 , %xmm2 
        vfnmaddpd       %xmm3 , %xmm1 , %xmm9 , %xmm3 

        vmovddup        -13 * SIZE(BO), %xmm10
        vmulpd                  %xmm2 , %xmm10, %xmm2
        vmulpd                  %xmm3 , %xmm10, %xmm3

	vmovups %xmm0 ,  0 * SIZE(CO1)
	vmovups %xmm1 ,  2 * SIZE(CO1)

	vmovups	%xmm2 ,  0 * SIZE(CO2)
	vmovups	%xmm3 ,  2 * SIZE(CO2)

	vmovups	%xmm0 , -16 * SIZE(AO)
	vmovups	%xmm1 , -14 * SIZE(AO)
	vmovups	%xmm2 , -12 * SIZE(AO)
	vmovups	%xmm3 , -10 * SIZE(AO)

.endm



.macro KERNEL2x2_SUB
	vmovddup	-16*SIZE(BO,%rax,2), %xmm1
	vmovddup	-15*SIZE(BO,%rax,2), %xmm2
	vmovups		-16*SIZE(AO,%rax,2), %xmm0
	vfmaddpd	%xmm8 , %xmm0 , %xmm1 , %xmm8
	vfmaddpd	%xmm9 , %xmm0 , %xmm2 , %xmm9
	addq    $SIZE, %rax
.endm


.macro SOLVE_2x2

	vmovups		-16 * SIZE(AO), %xmm0
	vmovups		-14 * SIZE(AO), %xmm2

        vsubpd  	%xmm8 , %xmm0 , %xmm0
        vsubpd  	%xmm9 , %xmm2 , %xmm2

	vmovddup        -16 * SIZE(BO), %xmm8
        vmulpd                  %xmm0 , %xmm8 , %xmm0

        vmovddup        -15 * SIZE(BO), %xmm9
        vfnmaddpd       %xmm2 , %xmm0 , %xmm9 , %xmm2 

        vmovddup        -13 * SIZE(BO), %xmm10
        vmulpd                  %xmm2 , %xmm10, %xmm2

	vmovups %xmm0 ,  0 * SIZE(CO1)

	vmovups	%xmm2 ,  0 * SIZE(CO2)

	vmovups	%xmm0 , -16 * SIZE(AO)
	vmovups	%xmm2 , -14 * SIZE(AO)
        
.endm



.macro KERNEL1x2_SUB
	vmovups 	-16*SIZE(BO,%rax,2), %xmm1
	vmovddup	-16*SIZE(AO,%rax,1), %xmm0
	vfmaddpd	%xmm8 , %xmm0 , %xmm1 , %xmm8
	addq    $SIZE, %rax
.endm

.macro SOLVE_1x2

	vmovups		-16 * SIZE(AO), %xmm2

        vsubpd  	%xmm8 , %xmm2 , %xmm2

	vmovups		%xmm2 , %xmm0
	vunpckhpd	%xmm0 , %xmm0 , %xmm0

	vmovsd          -16 * SIZE(BO), %xmm8
        vmulsd                  %xmm2 , %xmm8 , %xmm2

        vmovsd          -15 * SIZE(BO), %xmm9
        vfnmaddsd       %xmm0 , %xmm2 , %xmm9 , %xmm0 

        vmovsd          -13 * SIZE(BO), %xmm10
        vmulsd                  %xmm0 , %xmm10, %xmm0

	vmovsd  %xmm2 ,  0 * SIZE(CO1)

	vmovsd 	%xmm0 ,  0 * SIZE(CO2)

	vmovsd 	%xmm2 , -16 * SIZE(AO)
	vmovsd 	%xmm0 , -15 * SIZE(AO)

.endm


/******************************************************************************************/


.macro KERNEL8x1_SUB
	vmovddup	-16*SIZE(BO,%rax,1), %xmm1
	vmovups		-16*SIZE(AO,%rax,8), %xmm0
	vfmaddpd	%xmm8 , %xmm0 , %xmm1 , %xmm8
	vmovups		-14*SIZE(AO,%rax,8), %xmm0
	vfmaddpd	%xmm9 , %xmm0 , %xmm1 , %xmm9
	vmovups		-12*SIZE(AO,%rax,8), %xmm0
	vfmaddpd	%xmm10, %xmm0 , %xmm1 , %xmm10
	vmovups		-10*SIZE(AO,%rax,8), %xmm0
	vfmaddpd	%xmm11, %xmm0 , %xmm1 , %xmm11
	addq    $SIZE, %rax
.endm

.macro SOLVE_8x1

	vmovups		 -16 * SIZE(AO), %xmm0
	vmovups		 -14 * SIZE(AO), %xmm1
	vmovups		 -12 * SIZE(AO), %xmm2
	vmovups		 -10 * SIZE(AO), %xmm3

	vsubpd		 %xmm8 , %xmm0 , %xmm0
	vsubpd		 %xmm9 , %xmm1 , %xmm1
	vsubpd		 %xmm10, %xmm2 , %xmm2
	vsubpd		 %xmm11, %xmm3 , %xmm3

	vmovddup	 -16 * SIZE(BO), %xmm8
	vmulpd		 %xmm0 , %xmm8 , %xmm0
	vmulpd		 %xmm1 , %xmm8 , %xmm1
	vmulpd		 %xmm2 , %xmm8 , %xmm2
	vmulpd		 %xmm3 , %xmm8 , %xmm3

	vmovups	%xmm0 ,  0 * SIZE(CO1)
	vmovups	%xmm1 ,  2 * SIZE(CO1)
	vmovups	%xmm2 ,  4 * SIZE(CO1)
	vmovups	%xmm3 ,  6 * SIZE(CO1)

	vmovups	%xmm0 , -16 * SIZE(AO)
	vmovups	%xmm1 , -14 * SIZE(AO)
	vmovups	%xmm2 , -12 * SIZE(AO)
	vmovups	%xmm3 , -10 * SIZE(AO)
	
.endm



.macro KERNEL4x1_SUB
	vmovddup	-16*SIZE(BO,%rax,1), %xmm1
	vmovups		-16*SIZE(AO,%rax,4), %xmm0
	vfmaddpd	%xmm8 , %xmm0 , %xmm1 , %xmm8
	vmovups		-14*SIZE(AO,%rax,4), %xmm0
	vfmaddpd	%xmm9 , %xmm0 , %xmm1 , %xmm9
	addq    $SIZE, %rax
.endm


.macro SOLVE_4x1

	vmovups		 -16 * SIZE(AO), %xmm0
	vmovups		 -14 * SIZE(AO), %xmm1

	vsubpd		 %xmm8 , %xmm0 , %xmm0
	vsubpd		 %xmm9 , %xmm1 , %xmm1

	vmovddup	 -16 * SIZE(BO), %xmm8
	vmulpd		 %xmm0 , %xmm8 , %xmm0
	vmulpd		 %xmm1 , %xmm8 , %xmm1

	vmovups	%xmm0 ,  0 * SIZE(CO1)
	vmovups	%xmm1 ,  2 * SIZE(CO1)

	vmovups	%xmm0 , -16 * SIZE(AO)
	vmovups	%xmm1 , -14 * SIZE(AO)

.endm



.macro KERNEL2x1_SUB
	vmovddup	-16*SIZE(BO,%rax,1), %xmm1
	vmovups		-16*SIZE(AO,%rax,2), %xmm0
	vfmaddpd	%xmm8 , %xmm0 , %xmm1 , %xmm8
	addq    $SIZE, %rax
.endm


.macro SOLVE_2x1

	vmovups		 -16 * SIZE(AO), %xmm1

	vsubpd		 %xmm8 , %xmm1 , %xmm1

	vmovddup	 -16 * SIZE(BO), %xmm8
	vmulpd		 %xmm1 , %xmm8 , %xmm1

	vmovups	%xmm1 ,  0 * SIZE(CO1)

	vmovups	%xmm1 , -16 * SIZE(AO)

.endm



.macro KERNEL1x1_SUB
	vmovsd  	-16*SIZE(BO,%rax,1), %xmm1
	vmovsd 		-16*SIZE(AO,%rax,1), %xmm0
	vfmaddsd	%xmm8 , %xmm0 , %xmm1 , %xmm8
	addq    $SIZE, %rax
.endm

.macro SOLVE_1x1

	vmovsd		 -16 * SIZE(AO), %xmm1

	vsubsd		 %xmm8 , %xmm1 , %xmm1

	vmulsd		 -16 * SIZE(BO), %xmm1 , %xmm1

	vmovsd	%xmm1 ,  0 * SIZE(CO1)

	vmovsd	%xmm1 , -16 * SIZE(AO)

.endm





/***************************************************************************************************************/


	PROLOGUE
	PROFCODE
	
	subq	$STACKSIZE, %rsp
	movq	%rbx,   (%rsp)
	movq	%rbp,  8(%rsp)
	movq	%r12, 16(%rsp)
	movq	%r13, 24(%rsp)
	movq	%r14, 32(%rsp)
	movq	%r15, 40(%rsp)

#ifdef WINDOWS_ABI
	movq	%rdi,    48(%rsp)
	movq	%rsi,    56(%rsp)
	movups	%xmm6,   64(%rsp)
	movups	%xmm7,   80(%rsp)
	movups	%xmm8,   96(%rsp)
	movups	%xmm9,  112(%rsp)
	movups	%xmm10, 128(%rsp)
	movups	%xmm11, 144(%rsp)
	movups	%xmm12, 160(%rsp)
	movups	%xmm13, 176(%rsp)
	movups	%xmm14, 192(%rsp)
	movups	%xmm15, 208(%rsp)

	movq	ARG1,      OLD_M
	movq	ARG2,      OLD_N
	movq	ARG3,      K
	movq	OLD_A,     A
	movq	OLD_B,     B
	movq	OLD_C,     C
	movq	OLD_LDC,   LDC
	movsd	OLD_OFFSET, %xmm12
#else
	movq	STACKSIZE +  8(%rsp), LDC
	movsd	STACKSIZE + 16(%rsp), %xmm12
#endif

	movq	OLD_M, M
	movq	OLD_N, N

	subq	$-16 * SIZE, A
	subq	$-16 * SIZE, B

	movsd	%xmm12, OFFSET
	movsd	%xmm12, KK

        negq    KK			// for RN Kernel

	leaq	(, LDC, SIZE), LDC


	movq	N,  J
	sarq	$1, J		# j = (n >> 1)
	jle	.L80
	ALIGN_4

.L01:

	movq	A, AO

	movq	C, CO1			# coffset1 = c
	leaq	(C, LDC, 1), CO2	# coffset2 = c + ldc
	leaq    (C, LDC, 2), C

	movq	M,  I
	sarq	$3, I	# i = (m >> 3)
	jle	.L50_A
	ALIGN_4
/*********************************************************************************/
.L51:

	movq	B, BO

	vxorpd	%xmm8 , %xmm8 , %xmm8
	vxorpd	%xmm9 , %xmm9 , %xmm9
	vxorpd	%xmm10, %xmm10, %xmm10
	vxorpd	%xmm11, %xmm11, %xmm11
	vxorpd	%xmm12, %xmm12, %xmm12
	vxorpd	%xmm13, %xmm13, %xmm13
	vxorpd	%xmm14, %xmm14, %xmm14
	vxorpd	%xmm15, %xmm15, %xmm15


	movq	KK, %rax
	andq	$-4, %rax
	leaq	(, %rax, SIZE), %rax
	leaq	(AO, %rax, 8), AO
	leaq	(BO, %rax, 2), BO
	negq	%rax

	je	.L56
	ALIGN_4

.L52:
	prefetcht0      A_PR1(AO,%rax,8)
	prefetcht0      B_PR1(BO,%rax,2)
	KERNEL8x2_SUB
	prefetcht0      A_PR1(AO,%rax,8)
	KERNEL8x2_SUB
	prefetcht0      A_PR1(AO,%rax,8)
	KERNEL8x2_SUB
	prefetcht0      A_PR1(AO,%rax,8)
	KERNEL8x2_SUB

	jl	.L52
	ALIGN_4

.L56:
	movq	KK, %rax
	andq	$3, %rax		# if (k & 1)
	je .L59

	leaq	(, %rax, SIZE), %rax
	leaq	(AO, %rax, 8), AO
	leaq	(BO, %rax, 2), BO
	negq	%rax
	ALIGN_4

.L57:
	KERNEL8x2_SUB

	jl	.L57
	ALIGN_4

.L59:

	SOLVE_8x2

	addq	$8 * SIZE, CO1
	addq	$8 * SIZE, CO2

	movq	K,  %rax
	subq	KK, %rax
	leaq	(,%rax, SIZE), %rax
	leaq	(AO, %rax, 8), AO
	leaq	(BO, %rax, 2), BO

	decq	I			# i --
	jg	.L51
	ALIGN_4	

/*********************************************************************************/

.L50_A:
	testq	$4, M
	je	.L60

.L51_A:

	movq	B, BO

	vxorpd	%xmm8 , %xmm8 , %xmm8
	vxorpd	%xmm9 , %xmm9 , %xmm9
	vxorpd	%xmm10, %xmm10, %xmm10
	vxorpd	%xmm11, %xmm11, %xmm11

	movq	KK, %rax
	andq	$-4, %rax
	leaq	(, %rax, SIZE), %rax
	leaq	(AO, %rax, 4), AO
	leaq	(BO, %rax, 2), BO
	negq	%rax

	je	.L56_A
	ALIGN_4

.L52_A:

	KERNEL4x2_SUB
	KERNEL4x2_SUB
	KERNEL4x2_SUB
	KERNEL4x2_SUB

	jl	.L52_A
	ALIGN_4

.L56_A:
	movq	KK, %rax
	andq	$3, %rax		# if (k & 1)
	je .L59_A

	leaq	(, %rax, SIZE), %rax
	leaq	(AO, %rax, 4), AO
	leaq	(BO, %rax, 2), BO
	negq	%rax
	ALIGN_4

.L57_A:

	KERNEL4x2_SUB

	jl	.L57_A
	ALIGN_4

.L59_A:

	SOLVE_4x2

	addq	$4 * SIZE, CO1
	addq	$4 * SIZE, CO2

	movq	K,  %rax
	subq	KK, %rax
	leaq	(,%rax, SIZE), %rax
	leaq	(AO, %rax, 4), AO
	leaq	(BO, %rax, 2), BO

	ALIGN_4	

/*********************************************************************************/


.L60:
	testq	$2, M
	je	.L70

.L61:
	movq	B, BO

	vxorpd	%xmm8, %xmm8 , %xmm8
	vxorpd	%xmm9, %xmm9 , %xmm9

	movq	KK, %rax
	andq	$-4, %rax
	leaq	(, %rax, SIZE), %rax
	leaq	(AO, %rax, 2), AO
	leaq	(BO, %rax, 2), BO
	negq	%rax

	je	.L66
	ALIGN_4

.L62:

	KERNEL2x2_SUB
	KERNEL2x2_SUB
	KERNEL2x2_SUB
	KERNEL2x2_SUB

	jl	.L62
	ALIGN_4

.L66:
	movq	KK, %rax
	andq	$3, %rax		# if (k & 1)
	je .L69

	leaq	(, %rax, SIZE), %rax
	leaq	(AO, %rax, 2), AO
	leaq	(BO, %rax, 2), BO
	negq	%rax
	ALIGN_4

.L67:

	KERNEL2x2_SUB

	jl	.L67
	ALIGN_4

.L69:

	SOLVE_2x2

	addq	$2 * SIZE, CO1
	addq	$2 * SIZE, CO2

	movq	K,  %rax
	subq	KK, %rax
	leaq	(,%rax, SIZE), %rax
	leaq	(AO, %rax, 2), AO
	leaq	(BO, %rax, 2), BO

	ALIGN_4	
/********************************************************************************/
.L70:
	testq	$1, M
	je	.L79
	ALIGN_4

.L71:
	movq	B, BO

	vxorpd	%xmm8, %xmm8 , %xmm8

	movq	KK, %rax
	andq	$-4, %rax
	leaq	(, %rax, SIZE), %rax
	leaq	(AO, %rax, 1), AO
	leaq	(BO, %rax, 2), BO
	negq	%rax

	je	.L76
	ALIGN_4

.L72:

	KERNEL1x2_SUB
	KERNEL1x2_SUB
	KERNEL1x2_SUB
	KERNEL1x2_SUB

	jl	.L72
	ALIGN_4

.L76:
	movq	KK, %rax
	andq	$3, %rax		# if (k & 1)
	je .L78

	leaq	(, %rax, SIZE), %rax
	leaq	(AO, %rax, 1), AO
	leaq	(BO, %rax, 2), BO
	negq	%rax
	ALIGN_4

.L77:

	KERNEL1x2_SUB

	jl	.L77
	ALIGN_4

.L78:

	SOLVE_1x2

	addq	$1 * SIZE, CO1
	addq	$1 * SIZE, CO2

	movq	K,  %rax
	subq	KK, %rax
	leaq	(,%rax, SIZE), %rax
	leaq	(AO, %rax, 1), AO
	leaq	(BO, %rax, 2), BO

	ALIGN_4	
	
.L79:

        addq    $2, KK			// number of values in B # only for RN Kernel

	movq	BO, B

	decq	J			# j --
	jg	.L01
	ALIGN_4
/***************************************************************************************/
.L80:
	testq	$1, N
	je	.L999

	movq	A, AO
	movq	C, CO1			# coffset1 = c

	movq	M,  I
	sarq	$3, I	# i = (m >> 3)
	jle	.L90_A
	ALIGN_4
/*************************************************************************************/
.L91:

	movq	B, BO

	vxorpd	%xmm8, %xmm8  , %xmm8
	vxorpd	%xmm9, %xmm9  , %xmm9
	vxorpd	%xmm10, %xmm10, %xmm10
	vxorpd	%xmm11, %xmm11, %xmm11


	movq	KK, %rax
	andq	$-4, %rax
	leaq	(, %rax, SIZE), %rax
	leaq	(AO, %rax, 8), AO
	leaq	(BO, %rax, 1), BO
	negq	%rax

	je	.L96
	ALIGN_4

.L92:
	KERNEL8x1_SUB
	KERNEL8x1_SUB
	KERNEL8x1_SUB
	KERNEL8x1_SUB

	jl	.L92
	ALIGN_4

.L96:
	movq	KK, %rax
	andq	$3, %rax		# if (k & 1)
	je .L99

	leaq	(, %rax, SIZE), %rax
	leaq	(AO, %rax, 8), AO
	leaq	(BO, %rax, 1), BO
	negq	%rax
	ALIGN_4

.L97:
	KERNEL8x1_SUB

	jl	.L97
	ALIGN_4
.L99:

	SOLVE_8x1

	addq	$8 * SIZE, CO1

	movq	K,  %rax
	subq	KK, %rax
	leaq	(,%rax, SIZE), %rax
	leaq	(AO, %rax, 8), AO
	addq	%rax, BO


	decq	I			# i --
	jg	.L91
	ALIGN_4	

/*****************************************************************************/
.L90_A:
	testq	$4, M
	je	.L100

.L91_A:
	movq	B, BO

	vxorpd	%xmm8, %xmm8 , %xmm8
	vxorpd	%xmm9, %xmm9 , %xmm9

	movq	KK, %rax
	andq	$-4, %rax
	leaq	(, %rax, SIZE), %rax
	leaq	(AO, %rax, 4), AO
	leaq	(BO, %rax, 1), BO
	negq	%rax

	je	.L96_A
	ALIGN_4

.L92_A:

	KERNEL4x1_SUB
	KERNEL4x1_SUB
	KERNEL4x1_SUB
	KERNEL4x1_SUB

	jl	.L92_A
	ALIGN_4

.L96_A:
	movq	KK, %rax
	andq	$3, %rax		# if (k & 1)
	je .L99_A

	leaq	(, %rax, SIZE), %rax
	leaq	(AO, %rax, 4), AO
	leaq	(BO, %rax, 1), BO
	negq	%rax
	ALIGN_4

.L97_A:

	KERNEL4x1_SUB

	jl	.L97_A
	ALIGN_4
.L99_A:

	SOLVE_4x1

	addq	$4 * SIZE, CO1

	movq	K,  %rax
	subq	KK, %rax
	leaq	(,%rax, SIZE), %rax
	leaq	(AO, %rax, 4), AO
	addq	%rax, BO

	ALIGN_4	

/*************************************************************************************/
.L100:
	testq	$2, M
	je	.L110



	movq	B, BO

	vxorpd	%xmm8, %xmm8 , %xmm8

	movq	KK, %rax
	andq	$-4, %rax
	leaq	(, %rax, SIZE), %rax
	leaq	(AO, %rax, 2), AO
	leaq	(BO, %rax, 1), BO
	negq	%rax

	je	.L106
	ALIGN_4

.L102:

	KERNEL2x1_SUB
	KERNEL2x1_SUB
	KERNEL2x1_SUB
	KERNEL2x1_SUB

	jl	.L102
	ALIGN_4

.L106:
	movq	KK, %rax
	andq	$3, %rax		# if (k & 1)
	je .L109

	leaq	(, %rax, SIZE), %rax
	leaq	(AO, %rax, 2), AO
	leaq	(BO, %rax, 1), BO
	negq	%rax
	ALIGN_4

.L107:

	KERNEL2x1_SUB

	jl	.L107
	ALIGN_4

.L109:

	SOLVE_2x1

	addq	$2 * SIZE, CO1

	movq	K,  %rax
	subq	KK, %rax
	leaq	(,%rax, SIZE), %rax
	leaq	(AO, %rax, 2), AO
	addq	%rax, BO

	ALIGN_4	

.L110:
	testq	$1, M
	je	.L119
	ALIGN_4

.L111:
	movq	B, BO

	vxorpd	%xmm8, %xmm8 , %xmm8

	movq	KK, %rax
	andq	$-4, %rax
	leaq	(, %rax, SIZE), %rax
	leaq	(AO, %rax, 1), AO
	leaq	(BO, %rax, 1), BO
	negq	%rax

	je	.L116
	ALIGN_4

.L112:

	KERNEL1x1_SUB
	KERNEL1x1_SUB
	KERNEL1x1_SUB
	KERNEL1x1_SUB

	jl	.L112
	ALIGN_4

.L116:
	movq	KK, %rax
	andq	$3, %rax		# if (k & 1)
	je .L118

	leaq	(, %rax, SIZE), %rax
	leaq	(AO, %rax, 1), AO
	leaq	(BO, %rax, 1), BO
	negq	%rax
	ALIGN_4

.L117:

	KERNEL1x1_SUB

	jl	.L117
	ALIGN_4

.L118:

	SOLVE_1x1

	addq	$1 * SIZE, CO1

	movq	K,  %rax
	subq	KK, %rax
	leaq	(,%rax, SIZE), %rax
	addq	%rax, AO
	addq	%rax, BO

	ALIGN_4	

.L119:

        addq    $1 , KK			// number of values in B # only for RN Kernel

	movq	BO, B


	ALIGN_4

	
.L999:
	movq	   (%rsp), %rbx
	movq	  8(%rsp), %rbp
	movq	 16(%rsp), %r12
	movq	 24(%rsp), %r13
	movq	 32(%rsp), %r14
	movq	 40(%rsp), %r15

#ifdef WINDOWS_ABI
	movq	 48(%rsp), %rdi
	movq	 56(%rsp), %rsi
	movups	 64(%rsp), %xmm6
	movups	 80(%rsp), %xmm7
	movups	 96(%rsp), %xmm8
	movups	112(%rsp), %xmm9
	movups	128(%rsp), %xmm10
	movups	144(%rsp), %xmm11
	movups	160(%rsp), %xmm12
	movups	176(%rsp), %xmm13
	movups	192(%rsp), %xmm14
	movups	208(%rsp), %xmm15
#endif

	addq	$STACKSIZE, %rsp
	ret

	EPILOGUE
