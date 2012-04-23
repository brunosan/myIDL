FUNCTION SINC,X,XC,FWHM
;+
; NAME:
;	SINC
;
; PURPOSE:
;	Calculate the sinc function.
;
; CALLING SEQUENCE:
;	Result = SINC(X,XC,FWHM)
;
; INPUT:
;	X = the abscissa value.
;
;	XC = centre of sinc function.
;
;	FWHM = full width at half maximum of sinc function.
;
; OUTPUT:
;	Result = the sinc function evaluated in every X. The singularity
;		at X = 0 is treated so that SINC(0) = 1.
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
;	Straightforward.
;
; MODIFICATION HISTORY:
;	Written by Roberto Luis Molowny Horas, December 1993.
;
;-
ON_ERROR,2

;	t = 2d		;This is the way the parameter t has been computed.
;	t = t - (SIN(t)/t-.5d)/(COS(t)/t-SIN(t)/t^2)	;This is a Newton-
;	t = t - (SIN(t)/t-.5d)/(COS(t)/t-SIN(t)/t^2)	;Raphson algorithm.

	t = 1.8954943D
	t = t*2D

	xx = t/fwhm * (x-xc)		;Rescales the abscissa.

	n = WHERE(xx EQ 0.,noz)		;Checks for singularity at x = 0

	IF noz EQ 0 THEN RETURN,SIN(xx)/xx ELSE BEGIN
		xx(n) = 1.
		y = SIN(xx)/xx
		y(n) = 1.
		RETURN,y
	ENDELSE

END
