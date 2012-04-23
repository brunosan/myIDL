FUNCTION GCONVOL,A,STD
;+
; NAME:
;	GCONVOL
;
; PURPOSE:
;	This program will smooth an array, including the edges,
;	with a two dimensional gausian, using the IDL function CONVOL,
;	by surrounding the array with duplicates of itself
;	and then convolving the large array.
;
; CATEGORY:
;	IMAGE PROCESSING
;
; CALLING SEQUENCE:
;	Result = GCONVOL(A,STD)
;
; INPUTS:
;	A = an array of any basic type except string.
;
;	STD = standard deviation of the 2-D gausian.
;
; OUTPUTS:
;	Result = the convolved array, floating point array.
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
;	Array A is convolved separately in X and Y with a 1-D gausian.
;	Edges are treated by duplicating them and convolving the whole
;	array.
;
; MODIFICATION HISTORY:
;	Written by Roberto Luis Molowny Horas, July 1992.
;
;-
ON_ERROR,2

	s = SIZE(a)
	IF s(0) EQ 0 OR s(0) GT 2 THEN MESSAGE,'Wrong dimensions'

	width = FIX(std*9.)				;Wings of the gausian.
	IF NOT ODD(width) THEN width = width + 1	;Only odd numbers.
	kernel = FINDGEN(width) - width/2
	kernel = EXP(-kernel*kernel/(2.*std*std))	;Kernel.

	big = FLTARR(s(1)+width-1,s(2)+width-1,/NOZERO)	;Big array.
	edge = width/2
	big(edge,edge) = a
	FOR i = 0,edge-1 DO BEGIN			;Duplicates rows.
		big(i,edge) = a(edge-1-i,*)
		big(s(1)+edge+i,edge) = a(s(1)-1-i,*)
	ENDFOR

	big(0) = CONVOL(big(*),kernel)			;Convolves in X.
	big = ROTATE(big,1)

	FOR i = 0,edge-1 DO BEGIN			;Duplicates columns.
		big(i,0) = big(2*edge-1-i,*)
		big(s(2)+edge+i,0) = big(s(2)+edge-1-i,*)
	ENDFOR

	big(0) = CONVOL(big(*),kernel)			;Convolves in Y.
	big = ROTATE(big,3)				;Rotates it back.
	big = big(edge:s(1)-1+edge,edge:s(2)-1+edge)	;Removes edges.

	RETURN,big/(2.*std*std*!pi)			;Normalization factor.
	END