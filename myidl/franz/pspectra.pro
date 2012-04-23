FUNCTION PSPECTRA,A,FREQ,FNYQ,RESOLUTION=resolution
;+
; NAME:
;	PSPECTRA
;
; PURPOSE:
;	Compute the average radial power spectrum of A.
;
; CALLING SEQUENCE:
;	Result = PSPECTRA(A,FREQ)
;
; INPUTS:
;	A = 2-dimensional squared image.
;
; OPTIONAL INPUTS:
;	RESOLUTION = resolution in arcsec. per pixel. If given, 
;		FREQ and FNYQ outputs will be accordingly scaled. 
;		If not provided, it is assumed to be = 1.
;
; OUTPUT:
;	Result = average radial power spectrum.
;
; OPTIONAL OUTPUTS:
;	FREQ = a vector containing the frequency values, ranging from
;		zero to the Nyquist frequency (in 1/Megameters).
;
;	FNYQ = the Nyquist frequency for the given resolution (in 1/Mm).
;
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;	Image must be square.
;
; SIDE EFFECTS:
;	It may be time consuming.
;
; PROCEDURE:
;	The 2-dimensional power spectrum of A is spatially averaged.
;	Units are such that SQRT(TOTAL(p(1:*))) is equal to the standard
;	deviation of the array A.
;
; MODIFICATION HISTORY:
;	Written by Roberto Luis Molowny Horas, February 1992.
;	Modified in October 1992.
;
;-
ON_ERROR,2

	s = SIZE(a)
	IF s(0) NE 2 THEN MESSAGE,'Input array must be 2-D' ELSE $
		IF s(1) NE s(2) THEN MESSAGE,'Input must be a square array'
	IF NOT KEYWORD_SET(resolution) LT 2 THEN resolution = 1.

	p = FFT(a,-1)
	p = DOUBLE(p*CONJ(p))			;2-D power spectrum.

	x = RFIX(DIST(s(1)))			;Frequency array rounded.
	mx = MAX(x)				;Maximum frequency.
	radial = DBLARR(mx+1)
	radial(0) = p(0)

	FOR i = 1,mx DO BEGIN
		n = WHERE(x EQ i,noz)		;Points at this frequency...
		IF noz NE 0 THEN radial(i) = $	;are summed.
			TOTAL(p(n))
	ENDFOR

	mma = .725				;Megameters per arcsecond.
	freq = DINDGEN(mx+1)
	freq = freq*2*!pi/(s(1)*resolution*mma)	;Frequency in megameters^(-1)
	fnyq = 1. /resolution * !pi / mma	;Nyquist frequency in megamts.

	RETURN,radial

END