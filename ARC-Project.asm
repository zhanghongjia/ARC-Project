	.begin
!********************************************************!
.macro in A
in_wait:
	sethi	0x3fffc0, %r29
	ldub	[%r29+0xc], %r30
	andcc	%r30, 0x80, %r0
	be	in_wait
	sethi	0x3fffc0, %r29
	ldub	[%r29+0x8], A
.endmacro

.macro out A
out_wait:
	sethi	0x3fffc0, %r29
	ldub	[%r29+0x4], %r30
	andcc	%r30, 0x80, %r0
	be	out_wait
	sethi	0x3fffc0, %r29
	stb	A, [%r29+0x0]
.endmacro

.macro	push	A
	sub	%r14, 4, %r14
	st	A, %r14
.endmacro

.macro	pop	A
	ld	%r14, A
	add	%r14, 4, %r14
.endmacro

.macro	push_all
	push	%r2
	push	%r3
	push	%r4
	push	%r15
.endmacro

.macro	pop_all
	pop	%r15
	pop	%r4
	pop	%r3
	pop	%r2
.endmacro

.macro	return
	jmpl	%r15 + 4, %r0
.endmacro

!********************************************************!
	.org 2048
Main:		
	call	In_arr			! Input Array
	ba	Menu

!--------------------------------------------------------!
Menu:
	sethi	12, %r1
	push	%r1
	call	Out_str
	add	%r14, 4, %r14

	in	%r1

	cmp	%r1, 0x61		! a. Sort
	be	Sort				
	cmp	%r1, 0x62		! b. Case Convert
	be	Case_convert
	cmp	%r1, 0x63		! c. Sum
	be	Sum

!--------------------------------------------------------!
In_arr:
	push	%r15			! Reserved return address
	
	sethi	11, %r1
	push	%r1
	call	Out_str
	add	%r14, 4, %r14

	sethi	10, %r1			! Array's Start

In_arr_loop:
	in	%r2
	cmp	%r2, 0x0A		! 0x0A is NewLine
	be	In_arr_ret

	stb	%r2, %r1
	out	%r2
	inc	%r1			! Next element of Array
	inc	%r11			! Array's Length
	ba	In_arr_loop

In_arr_ret:
	pop	%r15
	return

!--------------------------------------------------------!
Out_arr:
	sethi	10, %r1			! Array's Start

Out_arr_loop:
	ldub	%r1, %r2
	cmp	%r2, 0x00		! 0x00 is Null
	be	Out_arr_ret
	
	out	%r2
	inc	%r1			! Next element of Array
	ba	Out_arr_loop

Out_arr_ret:
	return

!--------------------------------------------------------!
Out_str:
	mov	%r14, %r31
	ld	[%r31], %r1		! String's Start

Out_str_loop:
	ld	[%r1], %r2
	cmp	%r2, 0x00		! 0x00 is Null
	be	Out_str_ret

	out	%r2
	add	%r1, 4, %r1		! Next character of String
	ba	Out_str_loop

Out_str_ret:
	return
!--------------------------------------------------------!
Sort:
	sethi	13, %r1
	push	%r1
	call	Out_str
	add	%r14, 4, %r14

	in	%r1

	cmp	%r1, 0x61		! a. Bubble Sort
	be	Bubble_sort
	cmp	%r1, 0x62		! b. Quick_Sort
	be	Quick_sort

!--------------------------------------------------------!
! Bubble Sort:
! r1:Array's Length
! r2:Number of Outer Loops
! r3:Number of Inner Loops
! r4:i
! r5:j
! r6:Swap_A
! r7:Swap_B
! r10:The start address of the array

Bubble_sort:
	mov	%r11, %r1		! Array's Length
	clr	%r4
	clr	%r5
	sub	%r1, 1, %r2		! Outer Loops = Length - 1

Bubble_sort_loop1:
	cmp	%r4, %r2		! if (i >= Outer Loops), Break Outer Loops
	bge	Bubble_sort_end

	sethi	10, %r10		! Array's Start
	clr	%r5
	sub	%r2, %r4, %r3		! Inner Loops = Outer Loops - i
	inc	%r4			! i++
	ba	Bubble_sort_loop2

Bubble_sort_loop2:	
	cmp	%r5, %r3		! if (j >= Inner Loops), Break Inner Loops
	bge	Bubble_sort_loop1

	ldub	%r10, %r6
	ldub	%r10+1, %r7

	cmp	%r6, %r7		! if (A > B), Swap
	bpos	Bubble_sort_swap

	inc	%r5 			! j++
	inc	%r10
	ba	Bubble_sort_loop2

Bubble_sort_swap:
	stb	%r6, %r10+1
	stb	%r7, %r10

	inc	%r5			! j++
	inc	%r10
	ba	Bubble_sort_loop2

Bubble_sort_end:
	sethi	14, %r1
	push	%r1
	call	Out_str
	add	%r14, 4, %r14
	
	call	Out_arr
	ba	Sub_end

!--------------------------------------------------------!
!Quick_sort:
! r1:Array's Start
! r2:Left Border
! r3:Right Border
! r4:i
! r5:j
! r6:key
! r7:temp

Quick_sort:
	push	%r11			! R

	clr	%r10
	mov	0, %r10
	push	%r10			! L

	clr	%r10
	sethi	10, %r10
	sub	%r10, 1, %r10
	push	%r10			! arr

	call	Quick_sort_start

	sethi	14, %r1
	push	%r1
	call	Out_str
	add	%r14, 4, %r14

	call	Out_arr
	ba	Sub_end
	
Quick_sort_start:
	mov	%r14, %r31
	push_all

	ld	[%r31], %r1		! arr
	ld	[%r31+4], %r2		! L
	ld	[%r31+8], %r3		! R

	cmp	%r2, %r3		! if (L >= R), Return
	bge	Quick_sort_ret

	mov	%r2, %r4		! i = L
	mov	%r3, %r5		! j = R
	ldub	[%r1+%r2], %r6		! key = arr[L]

Quick_sort_loop:
	cmp	%r4, %r5		! while (i < j)
	bge	Quick_sort_loop_end
	
Quick_sort_loop1:
	cmp	%r4, %r5		! while (i < j)
	bge	Quick_sort_loop1_end

	ldub	[%r1+%r5], %r7
	cmp	%r6, %r7		! while (key <= a[j])
	bg	Quick_sort_loop1_end

	sub	%r5, 1, %r5		! j--

	ba	Quick_sort_loop1

Quick_sort_loop1_end:
	ldub	[%r1+%r5], %r7	
	stb	%r7, [%r1+%r4]		! a[i] = a[j]
	
Quick_sort_loop2:
	cmp	%r4, %r5		! while(i < j) 
	bge	Quick_sort_loop2_end

	ldub	[%r1+%r4], %r7
	cmp	%r6, %r7		! while(key >= a[i])
	bl	Quick_sort_loop2_end

	inc	%r4			! i++

	ba	Quick_sort_loop2

Quick_sort_loop2_end:
	ldub	[%r1+%r4], %r7
	stb	%r7, [%r1+%r5]		! a[j] = a[i]

	ba	Quick_sort_loop

Quick_sort_loop_end:
	stb	%r6, [%r1+%r4]		! a[i] = key

	sub	%r4, 1,	%r4
	push	%r4
	push	%r2
	push	%r1

	call	Quick_sort_start	! Qsort (arr, L, i-1)
	add	%r14, 12, %r14

	add	%r4, 2, %r4
	push	%r3
	push	%r4
	push	%r1
	call	Quick_sort_start	! Qsort (arr, i+1, R)
	add	%r14, 12, %r14

Quick_sort_ret:
	pop_all
	return

!--------------------------------------------------------!
Case_convert:
	sethi	10,%r1

Case_convert_loop:
	ldub	%r1, %r2
	cmp	%r2, 0x00		! 0x00 is Null
	be	Case_convert_output

	cmp	%r2, 0x41		! if ( char < 'A' ), No convert
	bl	Store

	cmp	%r2, 0x5A		! if ( 'A' < char < 'Z' ), Convert
	ble	Convert			

	cmp	%r2, 0x61		! if ( char < 'a' ), No convert
	bl	Store
	cmp	%r2, 0x7A		! if ( char > 'z' ), No convert
	bg	Store
	
	ba	Convert			! else ( 'a' < char < 'z' ), Convert

Convert:
	xor	%r2, 0x20, %r2		! Convert the case

Store:
	stb	%r2, %r1		! Store the character
	inc	%r1
	ba	Case_convert_loop

Case_convert_output:
	sethi	15, %r1
	push	%r1
	call	Out_str
	add	%r14, 4, %r14

	call Out_arr
	ba Sub_end
	
!--------------------------------------------------------!
Sum:
	clr	%r1			! arr
	clr	%r2			! i
	clr	%r4			! sum
	sethi	10, %r1

SumLoop:
	cmp	%r2, %r11		! while(i < Length)
	bge	Radix

	ldub	%r1, %r3
	add	%r4, %r3, %r4		! sum=sum+arr[i]

	inc	%r1
	inc	%r2			! i++
	ba	SumLoop

Radix:
	sethi	16, %r1
	push	%r1
	call	Out_str
	add	%r14, 4, %r14

	in %r1

	cmp	%r1, 0x61		! a. Octal
	be	Octal
	cmp	%r1, 0x62		! b. Hex
	be	Hex

Octal:
	clr	%r1
	sethi	17, %r1
	push	%r1
	call	Out_str
	add	%r14, 4, %r14
	
	clr	%r2
	mov	21, %r2

Octal_loop:
	cmp	%r2, -3
	be	Octal_end

	srl	%r4, %r2, %r3
	and	%r3, 0x07, %r3

Octal_out:
	add	%r3, 0x30, %r3
	out	%r3

	sub	%r2, 3, %r2
	ba	Octal_loop

Octal_end:
	ba	Sub_end

Hex:
	clr	%r1
	sethi	17, %r1
	push	%r1
	call	Out_str
	add	%r14, 4, %r14

	clr	%r2
	mov	28, %r2

Hex_loop:
	cmp	%r2, -4
	be	Hex_end

	srl	%r4, %r2, %r3
	and	%r3, 0x0F, %r3
	
	cmp	%r3, 0x0A
	bge	Hex_letter

Hex_digit:
	add	%r3, 0x30, %r3
	ba	Hex_out

Hex_letter:
	add	%r3, 0x57, %r3
	ba	Hex_out

Hex_out:
	out	%r3

	sub	%r2, 4, %r2
	ba	Hex_loop

Hex_end:
	ba	Sub_end

!--------------------------------------------------------!
Sub_end:
	sethi	18, %r1
	push	%r1
	call	Out_str
	add	%r14, 4, %r14
	
	in	%r1

	cmp	%r1, 0x61		! a. Menu
	be	Menu				
	cmp	%r1, 0x62		! b. End
	be	End

!--------------------------------------------------------!
End:	
	sethi	19, %r1
	push	%r1
	call	Out_str
	add	%r14, 4, %r14

	halt
!********************************************************!
	.org	10240
arr:	.dwb	1000


	.org	11264
str1:	0x50, 0x6C, 0x65, 0x61, 0x73, 0x65, 0x20, 0x65, 0x6E, 0x74
	0x65, 0x72, 0x20, 0x61, 0x6E, 0x20, 0x61, 0x72, 0x72, 0x61
	0x79, 0x3A, 0x20, 0x28, 0x65, 0x6E, 0x64, 0x73, 0x20, 0x77
	0x69, 0x74, 0x68, 0x20, 0x61, 0x20, 0x4E, 0x65, 0x77, 0x6C
	0x69, 0x6E, 0x65, 0x29, 0x0A, 0x00

	.org	12288
str2:	0x0A, 0x50, 0x6C, 0x65, 0x61, 0x73, 0x65, 0x20, 0x73, 0x65
	0x6C, 0x65, 0x63, 0x74, 0x20, 0x74, 0x68, 0x65, 0x20, 0x73
	0x75, 0x62, 0x72, 0x6F, 0x75, 0x74, 0x69, 0x6E, 0x65, 0x20
	0x74, 0x6F, 0x20, 0x65, 0x78, 0x65, 0x63, 0x75, 0x74, 0x65
	0x3A, 0x0A, 0x61, 0x2E, 0x20, 0x53, 0x6F, 0x72, 0x74, 0x0A
	0x62, 0x2E, 0x20, 0x43, 0x61, 0x73, 0x65, 0x20, 0x63, 0x6F
	0x6E, 0x76, 0x65, 0x72, 0x73, 0x69, 0x6F, 0x6E, 0x0A, 0x63
	0x2E, 0x20, 0x53, 0x75, 0x6D, 0x6D, 0x61, 0x74, 0x69, 0x6F
	0x6E, 0x0A, 0x00

	.org	13312
str3:	0x50, 0x6c, 0x65, 0x61, 0x73, 0x65, 0x20, 0x73, 0x65, 0x6c
	0x65, 0x63, 0x74, 0x20, 0x61, 0x20, 0x73, 0x6f, 0x72, 0x74
	0x69, 0x6e, 0x67, 0x20, 0x61, 0x6c, 0x67, 0x6f, 0x72, 0x69
	0x74, 0x68, 0x6d, 0x3a, 0x0a, 0x61, 0x2e, 0x20, 0x42, 0x75
	0x62, 0x62, 0x6c, 0x65, 0x20, 0x73, 0x6f, 0x72, 0x74, 0x0a
	0x62, 0x2e, 0x20, 0x51, 0x75, 0x69, 0x63, 0x6b, 0x20, 0x73
	0x6f, 0x72, 0x74, 0x0A, 0x00

	.org	14336
str4:	0x54, 0x68, 0x65, 0x20, 0x73, 0x6f, 0x72, 0x74, 0x65, 0x64
	0x20, 0x61, 0x72, 0x72, 0x61, 0x79, 0x20, 0x69, 0x73, 0x3a
	0x0a, 0x00

	.org	15360
str5:	0x54, 0x68, 0x65, 0x20, 0x72, 0x65, 0x73, 0x75, 0x6c, 0x74
	0x20, 0x6f, 0x66, 0x20, 0x74, 0x68, 0x65, 0x20, 0x63, 0x61
	0x73, 0x65, 0x20, 0x63, 0x6f, 0x6e, 0x76, 0x65, 0x72, 0x73
	0x69, 0x6f, 0x6e, 0x20, 0x69, 0x73, 0x3a, 0x0a, 0x00

	.org	16384
str6:	0x50, 0x6C, 0x65, 0x61, 0x73, 0x65, 0x20, 0x73, 0x65, 0x6C
	0x65, 0x63, 0x74, 0x20, 0x74, 0x68, 0x65, 0x20, 0x6F, 0x75
	0x74, 0x70, 0x75, 0x74, 0x20, 0x66, 0x6F, 0x72, 0x6D, 0x61
	0x74, 0x3A, 0x0A, 0x61, 0x2E, 0x20, 0x4F, 0x63, 0x74, 0x61
	0x6C, 0x0A, 0x62, 0x2E, 0x20, 0x48, 0x65, 0x78, 0x0A, 0x00

	.org	17408
str7:	0x54, 0x68, 0x65, 0x20, 0x73, 0x75, 0x6d, 0x20, 0x6f, 0x66
	0x20, 0x74, 0x68, 0x65, 0x20, 0x41, 0x53, 0x43, 0x49, 0x49
	0x20, 0x76, 0x61, 0x6c, 0x75, 0x65, 0x73, 0x20, 0x69, 0x73
	0x3a, 0x0a, 0x00

	.org	18432
str8:	0x0a, 0x50, 0x6c, 0x65, 0x61, 0x73, 0x65, 0x20, 0x63, 0x68
	0x6f, 0x6f, 0x73, 0x65, 0x20, 0x74, 0x68, 0x65, 0x20, 0x6e
	0x65, 0x78, 0x74, 0x20, 0x61, 0x63, 0x74, 0x69, 0x6f, 0x6e
	0x3a, 0x0a, 0x61, 0x2e, 0x20, 0x52, 0x65, 0x74, 0x75, 0x72
	0x6e, 0x20, 0x74, 0x6f, 0x20, 0x74, 0x68, 0x65, 0x20, 0x6d
	0x65, 0x6e, 0x75, 0x0a, 0x62, 0x2e, 0x20, 0x45, 0x6e, 0x64
	0x20, 0x74, 0x68, 0x65, 0x20, 0x70, 0x72, 0x6f, 0x67, 0x72
	0x61, 0x6d, 0x0a, 0x00

	.org	19456
str9:	0x54, 0x68, 0x65, 0x20, 0x70, 0x72, 0x6f, 0x67, 0x72, 0x61
	0x6d, 0x20, 0x68, 0x61, 0x73, 0x20, 0x66, 0x69, 0x6e, 0x69
	0x73, 0x68, 0x65, 0x64, 0x20, 0x72, 0x75, 0x6e, 0x6e, 0x69
	0x6e, 0x67, 0x2e, 0x0a, 0x00

!********************************************************!
	.end
