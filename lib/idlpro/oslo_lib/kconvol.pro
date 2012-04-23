FUNCTION KCONVOL , A , KERNEL , SCALE_FACTOR , CENTER = center
;+
; NAME:
;	KCONVOL
;
; PURPOSE:
;	This program will smooth an array, including the edges,
;	using IDL's SMOOTH or CONVOL functions, by surrounding the array
;	with duplicates of itself and then convolving the larger
;	array.
;
; CALLING SEQUENCE:
;	Result = KCONVOL(A , KERNEL , SCALE_FACTOR , CENTER =)
;
; INPUTS:
;	A = the array you wish to smooth. It may be of any type.
;		May have one or two dimensions.
;
;	KERNEL = a 1D or 2D kernel, depending whether A is 1D or 2D.
;		IF KERNEL is a number, it is assumed to be the width of
;		the boxcar window of SMOOTH.
;
; OPTIONAL INPUTS:
;	SCALE_FACTOR = a scale factor for the convolution. See CONVOL.
;
; KEYWORDS:
;	CENTER = center the kernel over each array point. See CONVOL.
;
; KEYWORD PARAMETERS:
;	None.
;
; OUTPUTS:
;	Result = the smoothed array. Type is floating.
;
; COMMON BLOCKS:
;	None.
;
; PROCEDURE:
;	Straightforward. It is based on program SMOOTHE included in
;	H.Cohl's IDL library.
;	Unlike SCONVOL, KCONVOL does not assume any symmetry of the
;	kernel.
;
; MODIFICATION HISTORY:
;	H. Cohl, 23 Sep, 1991      --- Generalization (SMOOTHE)
;	K. Reardon, 19 Jun, 1991   --- Initial programming (SMOOTHE)
;	R. Molowny-Horas, Jan 1994 --- Modified to use less memory (SMOOTHE)
;	R. Molowny-Horas and Z. Yi, May 1994 --- Accepts any kind of kernel.
;-
;
ON_ERROR,2

	IF N_PARAMS(0) LT 2 THEN MESSAGE,'Wrong input'

	sk = SIZE(kernel)
	s = SIZE(a)
	IF sk(0) NE 0 THEN IF s(0) NE sk(0) THEN $
		MESSAGE,'Kernel and array must have some number of dimensions'

	IF N_ELEMENTS(scale_factor) EQ 0 THEN scale_factor = 1.
	IF N_ELEMENTS(center) EQ 0 THEN center = 1

	CASE 1 OF
		s(0) EQ 0: MESSAGE,' Input is not an array'
		s(0) EQ 1: GOTO,ONED
		s(0) EQ 2: GOTO,TWOD
		ELSE: MESSAGE,'Input array has more than two dimensions'
	ENDCASE

ONED:			;One dimensional array.

	IF sk(0) EQ 0 THEN wx = kernel ELSE wx = sk(1)
	border = wx*2
	eg1 = s(1)+wx-1
	sa = FLTARR(border+s(1),/nozero)
	sa(wx:eg1) = a
	a = ROTATE(a,5)
	sa(0:wx-1) = a(s(1)-wx:s(1)-1)
	sa(s(1)+wx:s(1)+2*wx-1) = a(0:wx-1)
	a = ROTATE(a,5)
	IF N_ELEMENTS(kernel) EQ 0 THEN sa = SMOOTH(sa,kernel) ELSE $
		sa = CONVOL(sa,kernel,scale_factor,center=center)
	sa = sa(wx:eg1)
	GOTO,finishup

TWOD:			;Two dimensional array.

	IF s(1) EQ 1 THEN BEGIN
		a = a(*)
		GOTO,oned
	ENDIF

	IF sk(0) EQ 0 THEN BEGIN
		wx = kernel
		wy = kernel
	ENDIF ELSE BEGIN
		wx = sk(1)
		wy = sk(2)
	ENDELSE

	borderx = wx*2
	bordery = wy*2
	eg1 = s(1) + (wx-1)
	eg2 = s(2) + (wy-1)
	max1 = s(1) + borderx - 1
	max2 = s(2) + bordery - 1

	sa = FLTARR(borderx+s(1),bordery+s(2),/nozero)
	sa(wx:eg1,wy:eg2) = a
	a = ROTATE(a,5)
	sa(0:wx-1,wy:eg2) = a(s(1)-wx:s(1)-1,*)
	sa(s(1)+wx:max1,wy:eg2) = a(0:wx-1,*)
	a = ROTATE(ROTATE(a,5),7)
	sa(wx:eg1,0:wy-1) = a(*,s(2)-wy:s(2)-1)
	sa(wx:eg1,s(2)+wy:max2) = a(*,0:wy-1)
	a = ROTATE(ROTATE(a,7),2)
	sa(0:wx-1,0:wy-1) = a(s(1)-wx:s(1)-1,s(2)-wy:s(2)-1)
	sa(s(1)+wx:max1,s(2)+wy:max2) = a(0:wx-1,0:wy-1)
	sa(0:wx-1,s(2)+wy:max2) = a(s(1)-wx:s(1)-1,0:wy-1)
	sa(s(1)+wx:max1,0:wy-1) = a(0:wx-1,s(2)-wy:s(2)-1)
	a = ROTATE(a,2)
	IF sk(0) EQ 0 THEN sa = SMOOTH(sa,kernel) ELSE $
		sa = CONVOL(sa,kernel,scale_factor,center=center)
	sa = sa(wx:eg1,wy:eg2)

	finishup:

	RETURN,sa

END