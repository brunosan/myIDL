FUNCTION SINC_SQUARE,X,XC,FWHM
;+
; NAME:
;	SINC_SQUARE
;
; PURPOSE:
;	Calculate the sinc square function.
;
; CALLING SEQUENCE:
;	Result = SINC_SQUARE(X,XC,FWHM)
;
; INPUT:
;	X = the abscissa value.
;
;	XC = centre of sinc square function.
;
;	FWHM = full width at half maximum of sinc square function.
;
; OUTPUT:
;	Result = the sinc square function evaluated in every X. The 
;		singularity at X = 0 is treated so that SINC_SQUARE(0) = 1.
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
;	Straightforward. Computations are performed in double precision.
;
; MODIFICATION HISTORY:
;	Written by Roberto Luis Molowny Horas, December 1993.
;
;-
ON_ERROR,2

;	t = 2d		;This is the way the parameter t has been computed.
;	t = t - (SIN(t)^2/t^2-.5d)/(SIN(2d*t)/t^2-2d*SIN(t)^2/t^3)
;	t = t - (SIN(t)^2/t^2-.5d)/(SIN(2d*t)/t^2-2d*SIN(t)^2/t^3)
;	t = t - (SIN(t)^2/t^2-.5d)/(SIN(2d*t)/t^2-2d*SIN(t)^2/t^3);Enough!

	t = 1.3915574D
	t = t*2d	;Because t above is half width at half maximum.

	xx = t/fwhm * (x-xc)		;Rescales the abscissa.

	n = WHERE(xx EQ 0.,noz)		;Checks for singularity at x = 0

	IF noz EQ 0 THEN RETURN,SIN(xx)^2/xx^2 ELSE BEGIN
		xx(n) = 1d
		y = SIN(xx)^2/xx^2
		y(n) = 1d
		RETURN,y
	ENDELSE

END
