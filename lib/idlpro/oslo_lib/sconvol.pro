FUNCTION SCONVOL , A , KERNEL , SCALE_FACTOR = scale_factor , STD = std , FWHM = fwhm
;-
; NAME:
;	SCONVOL
;
; PURPOSE:
;	This program will smooth a 2D array, including the edges,
;	with a 2D kernel which can be separated into two symmetric,
;	one-dimensional kernels. Problems of this kind arise when,
;	e.g. an array is to be convolved with a 2D symmetric
;	gaussian, which is separable into two one-dimensional
;	convolutions.
;
; CALLING SEQUENCE:
;	Result = SCONVOL( A , KERNEL , SCALE_FACTOR = , STD = std , FWHM = fwhm )
;
; INPUTS:
;	A = a 2D array of any basic type except string.
;
;	KERNEL = a one-dimensional vector kernel. Convolution with
;		this kernel is applied along x and y directions.
;		Dimension must be odd.
;
;	SCALE_FACTOR = a scale factor for the convolution. See CONVOL.
;
;	STD = standard deviation of the 2-D gaussian.
;
;	FWHM = full width at half maximum of the 2-D gaussian.
;
; OUTPUTS:
;	Result = the convolved array, a floating point array. The
;		gaussian window is normalized to 1.
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;	Only convolves two dimensional arrays.
;
; PROCEDURE:
;	Array A is convolved separately in X and Y with the 1-D kernel.
;	If KERNEL is not given, and either STD or FWHM are input, kernel
;	will be a gaussian of standard deviation STD or full width at
;	half maximum FWHM.
;	Edges are treated by duplicating them and convolving the whole
;	array.
;	The standard deviation and the full width at half maximum of a
;	symmetric 2D gaussian are related by the formula:
;
;		fwhm = 2xSQRT(2xALOG(2))xstd
;
; MODIFICATION HISTORY:
;	R.Molowny-Horas and Z.Yi, May 1994.
;-
;
ON_ERROR,2

	s = SIZE(a)
	IF s(0) NE 2 THEN MESSAGE,'Array must be 2D'
	IF N_ELEMENTS(scale_factor) EQ 0 THEN scale_factor = 1.

	IF N_ELEMENTS(kernel) EQ 0 THEN BEGIN
		IF N_ELEMENTS(fwhm) EQ 0 AND N_ELEMENTS(std) EQ 0 THEN $
			MESSAGE,'Convolve with what?"
		IF KEYWORD_SET(fwhm) THEN std = fwhm/(2.*SQRT(2.*ALOG(2.)))
		width = FIX(std*9.)			;Wings of the gausian.
		IF NOT ODD(width) THEN width = width+1	;Only odd numbers.
		kernel = FINDGEN(width) - width/2
		kernel = EXP(-kernel*kernel/(2.*std^2))	;Kernel.
		kernel = kernel/(std*SQRT(2.*!pi))
	ENDIF ELSE BEGIN
		width = N_ELEMENTS(kernel)
		IF ODD(width) NE 1 THEN MESSAGE,'Dimension of kernel must be odd'
	ENDELSE

	big = FLTARR(s(1)+width-1,s(2)+width-1,/NOZERO)	;Big array.
	edge = width/2
	big(edge,edge) = a
	FOR i = 0,edge-1 DO BEGIN			;Duplicates rows.
		big(i,edge) = a(edge-1-i,*)
		big(s(1)+edge+i,edge) = a(s(1)-1-i,*)
	ENDFOR

	big(0) = CONVOL(big(*),kernel,scale_factor)	;Convolves in X.
	big = ROTATE(big,1)

	FOR i = 0,edge-1 DO BEGIN			;Duplicates columns.
		big(i,0) = big(2*edge-1-i,*)
		big(s(2)+edge+i,0) = big(s(2)+edge-1-i,*)
	ENDFOR

	big(0) = CONVOL(big(*),kernel,scale_factor)	;Convolves in Y.
	big = ROTATE(big,3)				;Rotates it back.
	big = big(edge:s(1)-1+edge,edge:s(2)-1+edge)	;Removes edges.

	RETURN,big

END