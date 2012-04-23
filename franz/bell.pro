FUNCTION BELL,SIGMA,XDIM,YDIM
;+
; NAME:
;	BELL
;
; PURPOSE:
;	Create a 2-dimensional gaussian.
;
; CALLING SEQUENCE:
;	Result = BELL(SIGMA,XDIM,YDIM)
;
; INPUTS:
;	SIGMA = Standard deviation of gaussian. Same in X and Y direction.
;	XDIM & YDIM = dimensions of output array.
;
; OUTPUTS:
;	Result = floating point [XDIM,YDIM] 2-dimensional gaussian.
;
; SIDE EFFECTS:
;	None.
;
; COMMON BLOCKS:
;	None.
;
; RESTRICTIONS:
;	The standard deviations in X and Y are assumed to be equal.
;
; PROCEDURE:
;	Straightforward. The relationship between FWHM and SIGMA in a
;	2-dimensional gaussian is given by:
;
;	FWHM = 2 x SQRT (2 x ALOG(2)) x SIGMA
;
; MODIFICATION HISTORY:
;	Written by Roberto Luis Molowny Horas, October 1991.
;
;-
ON_ERROR,2

	IF N_PARAMS(0) LT 3 THEN MESSAGE,'Wrong number of parameters'

	std	= 2.*sigma*sigma
	xcol	= FINDGEN(xdim) - FIX(xdim)/2
	xcol	= EXP(-xcol*xcol/std)
	ycol	= FINDGEN(ydim) - FIX(ydim)/2
	ycol	= EXP(-ycol*ycol/std)
	wgauss	= FLTARR(xdim,ydim,/nozero)
	FOR i	= 0,ydim-1 DO wgauss(0,i) = xcol * ycol(i)
	RETURN,wgauss/(std*!pi)

END
