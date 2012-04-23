PRO FLOW_MAKER,NAMESA,NAMESB,VX,VY, STD = std , FWHM = fwhm , $
	BOXCAR = boxcar , ADIF = adif , CORR = corr , QFIT2 = qfit2 , $
	CROSSD = crossd
;+
; NAME:
;	FLOW_MAKER
;
; PURPOSE:
;	Compute flow maps.
;
; INPUTS:
;	NAMESA = string array containing the names for the first image
;		in every correlating pair.
;
;	NAMESB = string array containing the names for the second image
;		in every correlating pair.
;
;	STD = standard deviation of a 2-D gaussian.
;
;	FWHM = full width at half maximum of the 2-D gaussian. For further
;               information, see the header of SCONVOL.
;
;	BOXCAR = width of a boxcar running window. This keyword supersedes
;               STD and FWHM.
;
; KEYWORDS:
;	ADIF = uses an absolute differences algorithm.
;
;	CORR = uses a multiplicative algorithm. Default is the sum of
;		square of the local differences.
;
;	QFIT2 = uses 9 points fitting procedure.
;
;	CROSSD = uses cross derivative interpolation formulae.
;
; OUTPUTS:
;	VX,VY = X and Y components for the proper motion map.
;
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;	The images are read inside this procedure. Should the routines for
;	the reading be different, change it.
;
; COMMON BLOCKS:
;	None.
;
; PROCEDURE:
;	It uses November's method of shifting BOTH images. The defaults for
;	the different methods are square differences for the matching, 
;	gaussian window for the smoothing and FIVEPOINT for the subpixel
;	extrem finding procedure. Images must be in FITS format.
;
; EXAMPLE:
;	Let name1 and name2 be two string arrays containing the names
;	for first and second images of every pair, respectively. For an
;	image resolution of 0".2 per pixel, we want to compute a flow map
;	using a FWHM of 4" for the smoothing gaussian window. Therefore,
;	the call will be:
;
;	IDL> FLOW_MAKER,name1,name2,vx,vy,fwhm=8.5
;
; REFERENCES:
;	* November, L.J., 1986, Applied Optics, Vol.25, No.3, 392
;	* November,L.J. and Simon,G.W.: 1988, Ap.J., 333, 427
;
; MODIFICATION HISTORY:
;	R. Molowny Horas, May 1992.
;	Keywords added in July 1992, RMH
;	FITS routines added in November 1992, RMH
;	Supressed keyword SILENT, May 1994, RMH
;-
ON_ERROR,2

	n = N_ELEMENTS(namesa)
	IF N_ELEMENTS(namesb) NE n THEN MESSAGE,'Wrong string arrays'

	s = SIZE(READFITS(namesa(0)))		;Acquiring array dimensions.

	cc = FLTARR(s(1),s(2),3,3)		;The cum. correlation function.

	FOR k = 0,n-1 DO BEGIN
		a = READFITS(namesa(k))
		b = READFITS(namesb(k))
		a = a - TOTAL(a)/s(4)		;Remove mean.
		b = b - TOTAL(b)/s(4)
		FOR i = -1,1 DO FOR j = -1,1 DO CASE 1 OF	;Methods.
			KEYWORD_SET(adif): BEGIN	;Absolute differences.
				cc(0,0,i+1,j+1) = cc(*,*,i+1,j+1)+$
					ABS(SHIFT(a,i,j)-SHIFT(b,-i,-j))
				END
			KEYWORD_SET(corr): BEGIN	;Cross products.
				cc(0,0,i+1,j+1) = cc(*,*,i+1,j+1)+$
					SHIFT(a,i,j) * SHIFT(b,-i,-j)
				END
			ELSE: BEGIN			;Square differences.
				dumb = SHIFT(a,i,j) - SHIFT(b,-i,-j)
				cc(0,0,i+1,j+1) = cc(*,*,i+1,j+1) + dumb*dumb
				dumb = 0	;This should be faster than (...)^2
				END
			ENDCASE
		a = 0 & b = 0
	ENDFOR

	cc(0,0,0,0) = cc(1,*,*,*)		;Takes care of the edges.
	cc(0,0,0,0) = cc(*,1,*,*)
	cc(s(1)-1,0,0,0) = cc(s(1)-2,*,*,*)
	cc(0,s(2)-1,0,0) = cc(*,s(2)-2,*,*)

	FOR i = 0,2 DO FOR j = 0,2 DO IF N_ELEMENTS(boxcar) NE 0 THEN $
		cc(0,0,i,j) = KCONVOL(cc(*,*,i,j),boxcar) ELSE $	;Boxcar...
		cc(0,0,i,j) = SCONVOL(cc(*,*,i,j),std=std,fwhm=fwhm)	;or gausian.

	CASE 1 OF
		KEYWORD_SET(qfit2): QFIT2,cc,vx,vy		;9-p. fitting,
		KEYWORD_SET(crossd): CROSSD,cc,vx,vy		;cross derivat.
		ELSE: FIVEPOINT,cc,vx,vy			;or default.
	ENDCASE

	vx = 2. * vx & vy = 2. * vy		;Scales the result.

END