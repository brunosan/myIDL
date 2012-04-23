PRO DISTORTION_MAP,A,B,STD,VX,VY,BOXCAR=boxcar,ADIF=adif,CORR=corr,$
	QFIT2=qfit2,CROSSD=crossd
;+
; NAME:
;	DISTORTION_MAP
;
; PURPOSE:
;	Compute displacement map of B respect to A.
;
; CALLING SEQUENCE:
;	DISTORTION_MAP,A,B,STD,VX,VY, [BOXCAR = , ADIF = , CORR = ,
;		CROSSD = ]
;
; INPUTS:
;	A = reference image.
;
;	B = distorted image.
;
;	STD = width for smoothing window.
;
; KEYWORDS:
;	BOXCAR = if set, a boxcar window of width STD is used.
;
;	ADIF = uses absolute differences method.
;
;	CORR = uses multiplication method.
;
;	QFIT2 = fits a 2-dimensional polynomial.
;
;	CROSSD = uses cross derivative interpolation formulae.
;
; OUTPUTS:
;	VX,VY = X and Y components for the displacement map. Each vector
;		shows the shift of every point of B with respect to A.
;
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;	If using BOXCAR keyword, STD must be an odd integer number.
;
; COMMON BLOCKS:
;	None.
;
; PROCEDURE:
;	It uses November's method of shifting BOTH images. Defaults for
;	cross image, smoothing and subpixel interpolation methods are
;	absolute differences, gaussian window and 5-point interpolation
;	formulae, respectively.
;
; EXAMPLES:
;	Let B be the distorted representation of image A (for example,
;	left- and right-polarized filtergrams, taken within an interval of
;	few seconds). To compute the distortion map of B respect to A
;	one must do:
;
;		IDL> DISTORTION_MAP,a,b,45,vx,vy,/boxcar
;
;	where a boxcar smoothing window is used to speed the computation.
;
; REFERENCES:
;	November,L.J.: 1986, App. Optics, vol.25 No. 3
;	Yi,Z.: 1992, Ph.D. Thesis, University of Oslo.
;	Yi,Z and Molowny H., R.: 1992, Proceedings from LEST Mini-Workshop,
;		LEST Technical Report No. 56
;
; MODIFICATION HISTORY:
;	Written by Roberto Luis Molowny Horas, May 1992.
;	Keywords added in July 1992, RLMH
;	Defaults changed in November 1992, RLMH
;
;-
ON_ERROR,2

	IF N_PARAMS(0) LT 5 THEN MESSAGE,'Wrong number of parameters'

	s = SIZE(a)
	sb = SIZE(b)
	IF TOTAL(ABS(s(0:2)-sb(0:2))) NE 0 THEN MESSAGE,'Wrong input arrays'

	n = FLOAT(s(1)) * s(2)
	cc = FLTARR(s(1),s(2),3,3,/nozero)	;The correlation function.
	aa = a - TOTAL(a)/n			;Removes mean.
	bb = b - TOTAL(b)/n
	FOR i = -1,1 DO FOR j = -1,1 DO CASE 1 OF	;Methods.
		KEYWORD_SET(adif): cc(0,0,i+1,j+1) = $	;Absolute differences.
			ABS(SHIFT(aa,i,j) - SHIFT(bb,-i,-j))
		KEYWORD_SET(corr): cc(0,0,i+1,j+1) = $	;Cross products.
			SHIFT(aa,i,j) * SHIFT(bb,-i,-j)
		ELSE: BEGIN
			dumb = SHIFT(aa,i,j) - SHIFT(bb,-i,-j)
			cc(0,0,i+1,j+1) = dumb*dumb	;Faster than (...)^2
			dumb = 0
			END
		ENDCASE

	cc(0,0,0,0) = cc(1,*,*,*)		;Takes care of the borders.
	cc(s(1)-1,0,0,0) = cc(s(1)-2,*,*,*)
	cc(0,0,0,0) = cc(*,1,*,*)
	cc(0,s(2)-1,0,0) = cc(*,s(2)-2,*,*)

	aa = 0 & bb = 0				;No longer needed.

	FOR i = 0,2 DO FOR j = 0,2 DO IF KEYWORD_SET(boxcar) THEN $
		cc(0,0,i,j) = SMOOTHE(cc(*,*,i,j),std) ELSE $	;Boxcar...
		cc(0,0,i,j) = GCONVOL(cc(*,*,i,j),std)		;or gaussian.

	CASE 1 OF
		KEYWORD_SET(crossd): CROSSD,cc,vx,vy	;Cross derivat.
		KEYWORD_SET(qfit2): QFIT2,cc,vx,vy	;Fit polynom.
		ELSE: FIVEPOINT,cc,vx,vy		;Five points. Default.
	ENDCASE
	cc = 0
	vx = 2. * vx & vy = 2. * vy
END
