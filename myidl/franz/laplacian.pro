FUNCTION LAPLACIAN,SIGMA,XDIM,YDIM
;+
; NAME:
;	LAPLACIAN
;
; PURPOSE:
;	Makes a normalized laplacian window.
;
; CALLING SEQUENCE:
;	Result = LAPLACIAN(SIGMA,XDIM,YDIM)
;
; INPUTS:
;	SIGMA = Standard deviation. Same in X and Y direction.
;
;	XDIM & YDIM = dimensions of output array.
;
; OUTPUT:
;	Result = floating array [XDIM,YDIM] with lorentzian window.
;
; RESTRICTIONS:
;	The standard deviations in X and Y are assumed to be equal.
;
; PROCEDURE:
;	Straightforward.
;
; MODIFICATION HISTORY:
;	Written by Roberto Luis Molowny Horas, November 1991.
;
;-
ON_ERROR,2
	IF N_PARAMS(0) LT 3 THEN MESSAGE,'Wrong number of parameters'

	xcol = LINDGEN(xdim,ydim) MOD xdim
	xcol = FLOAT(xcol) - (xdim-1.)/2.
	ycol = LINDGEN(xdim,ydim) / xdim
	ycol = FLOAT(ycol) - (ydim-1.)/2.
	lapla = BELL(sigma,xdim,ydim)

	RETURN,lapla*(xcol*xcol+ycol*ycol-2.*sigma^2)/(sigma^2)

END
