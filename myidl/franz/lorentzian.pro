FUNCTION LORENTZIAN,SIGMA,XDIM,YDIM
;+
; NAME:
;	LORENTZIAN
;
; PURPOSE:
;	Make a normalized lorentzian window.
;
; CALLING SEQUENCE:
;	Result = LORENTZIAN(SIGMA,XDIM,YDIM)
;
; INPUTS:
;	SIGMA = Standard deviation .Same in X and Y direction.
;
;	XDIM & YDIM = dimension of output array.
;
; OUTPUTS:
;	Result = floating array [XDIM,YDIM] with lorentzian window.
;
; RESTRICTIONS:
;	The standard deviations in X and Y are assumed to be equal.
;
; PROCEDURE:
;	Straightforward.
;
; MODIFICATION HISTORY:
;	Written by Roberto Luis Molowny Horas, October 1991.
;
;-
ON_ERROR,2

	IF N_PARAMS(0) LT 3 THEN MESSAGE,'Wrong number of parameters'

	xcol	= (FINDGEN(xdim) - (xdim-1)/2.) / sigma
	xcol	= 1. + .5 * xcol * xcol
	xcol	= 1. / xcol
	ycol	= (FINDGEN(ydim) - (ydim-1)/2.) / sigma
	ycol	= 1. + .5 * ycol * ycol
	ycol	= 1. / ycol
	lorent	= FLTARR(xdim,ydim,/nozero)
	FOR i	= 0,ydim-1 DO lorent(0,i) = xcol * ycol(i)

	RETURN,lorent/MEAN(lorent)

END