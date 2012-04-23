PRO FLOW_MAKER,REFERENCE,LIFE,STD,VX,VY,BOXCAR=boxcar,ADIF=adif,CORR=corr, $
	QFIT2=qfit2,CROSSD=crossd,SILENT=silent
;+
; NAME:
;	FLOW_MAKER
;
; PURPOSE:
;	Compute flow maps.
;
; INPUTS:
;	REFERENCE = string array containing the names for the so-called
;		"reference" images.
;
;	LIFE = string array containing the names for the "life" images.
;
;	STD = width for smoothing window.
;
; KEYWORDS:
;	BOXCAR = if set, a boxcar window of width STD is used. Hence,
;		STD must be an odd number.
;
;	ADIF = uses an absolute differences algorithm.
;
;	CORR = uses a multiplicative algorithm. Default is the sum of
;		square of the local differences.
;
;	QFIT2 = uses 9 points fitting procedure.
;
;	CROSSD = uses cross derivative interpolation formulae.
;
;	SILENT = if set, suppresses displaying the size of the array at
;		the terminal.
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
;	for reference and life images, respectively. For an image resolution
;	of 0".2 per pixel, we want to compute a flow map using a FWHM of
;	4" for the smoothing gaussian window. Therefore, the call will be
;
;	IDL> FLOW_MAKER,name1,name2,8.5,vx,vy,/silent
;
;	Array sizes are not display at the screen as READIFTS reads them.
;	FWHM of gaussian window is 8.5 * .2 * 2.355 = 4 arcsec.
;
; REFERENCES:
;	November,L.J. and Simon,G.W.: 1988, Ap.J., 333, 427
;	Darvann,T.: 1991, Master's Thesis, University of Oslo.
;
; MODIFICATION HISTORY:
;	Written by Roberto Luis Molowny Horas, May 1992.
;	Keywords added in July 1992.
;	FITS routines added in November 1992.
;
;-
ON_ERROR,2

	n = N_ELEMENTS(reference)
	IF N_ELEMENTS(life) NE n THEN MESSAGE,'Wrong string arrays'

	s = SIZE(READFITS(reference(0),/silent));Acquiring array dimensions.

	IF KEYWORD_SET(silent) THEN silent = 0	;Does not display information.

	cc = FLTARR(s(1),s(2),3,3)		;The cum. correlation function.

	FOR k = 0,n-1 DO BEGIN
		a = READFITS(reference(k),silent=silent)
		b = READFITS(life(k),silent=silent)
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
				dumb = 0	;This is faster than (...)^2
				END
			ENDCASE
		a = 0 & b = 0
	ENDFOR

	cc(0,0,0,0) = cc(1,*,*,*)		;Takes care of the edges.
	cc(0,0,0,0) = cc(*,1,*,*)
	cc(s(1),0,0,0) = cc(s(1)-1,*,*,*)
	cc(0,s(2),0,0) = cc(*,s(2)-1,*,*)

	FOR i = 0,2 DO FOR j = 0,2 DO IF KEYWORD_SET(boxcar) THEN $
		cc(0,0,i,j) = SMOOTHE(cc(*,*,i,j),std) ELSE $	;Boxcar...
		cc(0,0,i,j) = GCONVOL(cc(*,*,i,j),std)		;or gausian.

	CASE 1 OF
		KEYWORD_SET(qfit2): QFIT2,cc,vx,vy		;9-p. fitting,
		KEYWORD_SET(crossd): CROSSD,cc,vx,vy		;cross derivat.
		ELSE: FIVEPOINT,cc,vx,vy			;or default.
	ENDCASE
	cc = 0

	vx = 2. * vx & vy = 2. * vy		;Scales the result.

END