FUNCTION COSIN_APOD,N,P
;+
; NAME:
;	COSIN_APOD
;
; PURPOSE:
;	Apodize a 1-D data set with a cosine apodizing function.
;
; CALLING SEQUENCE:
;	Result = COSIN_APOD(N,P)
;
; INPUTS:
;	N = number of points of the data set.
;
; OPTIONAL INPUTS:
;	P = dimension of the cosine function, in percentage of N.
;		Default is 10 %.
;
; OUTPUT:
;	Result = a cosine window function.
;
; KEYWORDS:
;	None.
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;	None.
;
; PROCEDURE:
;	The two edges of the output array are multiplied by a cosine
;	function.
;
; MODIFICATION HISTORY:
;	Written by Roberto Luis Molowny Horas, January 1994.
;
;-
;
ON_ERROR,2

	IF N_PARAMS(0) LT 2 THEN p = 10.	;Deafult is a 10% cosine win.

	y = REPLICATE(1.,n)			;Output array.

	np = FIX(n/100.*p)			;Percentage of cosine points.
	x = !pi/2./np*FINDGEN(np)
	x = SIN(x)
	y(0) = x				;Left edge.
	y(n-np) = REVERSE(x)			;Right edge.

	RETURN,y>0.				;In case of roundoff errors.
END