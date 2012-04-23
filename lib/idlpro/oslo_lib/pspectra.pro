FUNCTION PSPECTRA , A , FREQ
;+
; NAME:
;	PSPECTRA
;
; PURPOSE:
;	Compute the average radial power spectrum of A.
;
; CALLING SEQUENCE:
;	Result = PSPECTRA(A , [ FREQ ] )
;
; INPUTS:
;	A = 2-dimensional square image.
;
; OUTPUT:
;	Result = average radial power spectrum.
;
; OPTIONAL OUTPUTS:
;	FREQ = vector of spatial frequencies, assuming the resolution
;		is 1. Frequencies in 1/Megametres can be calculated
;		by doing FREQ/resolution, where "resolution"
;		is Megam. per pixel.
;
; RESTRICTIONS:
;	Image must be square.
;
; SIDE EFFECTS:
;	Slow. The algorithm is not very "sofisticated".
;
; PROCEDURE:
;	Azimuthal integration is made by rounding to the nearest
;	integer an appropriate array of coordinates.
;
; MODIFICATION HISTORY:
;	Written by Roberto Luis Molowny Horas, February 1992.
;	Modified in October 1992, RMH
;	Minor modifications, July 1994, RMH
;-
;
ON_ERROR,2

	s = SIZE(a)
	IF s(0) NE 2 THEN MESSAGE,'Input array must be 2-D' ELSE $
		IF s(1) NE s(2) THEN MESSAGE,'Input must be a square array'

	p = FFT(a,-1)
	p = FLOAT(p*CONJ(p))			;2-D power spectrum.

	x = RFIX(DIST(s(1)))			;Frequency array rounded.
	mx = MAX(x)				;Maximum frequency.
	radial = FLTARR(mx+1)
	radial(0) = p(0)

	FOR i = 1,mx DO BEGIN
		n = WHERE(x EQ i,noz)		;Points at this frequency...
		IF noz NE 0 THEN radial(i) = $	;are averaged.
			TOTAL(p(n))
	ENDFOR

	IF N_PARAMS(0) GT 1 THEN freq = 2.*!pi/s(1)*FINDGEN(mx+1)

	RETURN,radial

END
