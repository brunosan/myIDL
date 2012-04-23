PRO DISTORTION_MAP,A,B,VX,VY, STD = std , FWHM = fwhm , BOXCAR = boxcar , $
	ADIF = adif,CORR = corr
;+
; NAME:
;	DISTORTION_MAP
;
; PURPOSE:
;	Compute displacement map of B respect to A.
;
; CALLING SEQUENCE:
;	DISTORTION_MAP,A,B,VX,VY, [ STD = , FWHM = , BOXCAR = , ADIF = , CORR = ]
;
; INPUTS:
;	A = reference image.
;
;	B = distorted image.
;
;	STD = 2D standard deviation of smoothing window.
;
;	FWHM = 2D full width at half maximum of smoothing window.
;
;       BOXCAR = width of the boxcar running window. If set, it
;               supersedes STD and FWHM.
;
; KEYWORDS:
;	ADIF = uses absolute differences method.
;
;	CORR = uses multiplication method. Default is squared differences.
;
; OUTPUTS:
;	VX,VY = X and Y components for the displacement map. Each vector
;		shows the shift of every point of B with respect to A.
;
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;	None.
;
; COMMON BLOCKS:
;	None.
;
; PROCEDURE:
;	It uses November's method of shifting BOTH images. Subpixel
;	interpolation is made with a 5 point formula.
;	When the local offsets between the images are large, artifacts
;	due to mismatching may arise.
;
; EXAMPLES:
;	Let B be the distorted representation of image A (for example,
;	left- and right-polarized filtergrams, taken within an interval of
;	few seconds). To compute the distortion map of B respect to A
;	one must do:
;
;		IDL> DISTORTION_MAP,a,b,boxcar=45,vx,vy
;
;	where a boxcar smoothing window is used to speed up the computation.
;	We may as well write:
;
;		IDL> DISTORTION_MAP,a,b,fwhm=45,vx,vy
;
;	which smoothes the correlation array with a gaussian window.
;
; REFERENCES:
;	November,L.J.: 1986, App. Optics, vol.25 No. 3
;	Yi,Z.: 1992, Ph.D. Thesis, University of Oslo.
;	Yi,Z and Molowny H., R.: 1992, Proceedings from LEST Mini-Workshop,
;		LEST Technical Report No. 56
;
; MODIFICATION HISTORY:
;	Written by Roberto Molowny-Horas, May 1992.
;	Keywords added, July 1992, RMH
;	Defaults changed, November 1992, RMH
;	Modified algorithm to allocate less memory, as well as
;		some other minor changes, Feb. 1994, RMH
;	Minor changes, MAY 1994, RMH
;
;-
ON_ERROR,2

	IF N_PARAMS(0) NE 4 THEN MESSAGE,'Wrong number of parameters'

	s = SIZE(a)
	sb = SIZE(b)
	IF TOTAL(ABS(s(0:2)-sb(0:2))) NE 0 THEN MESSAGE,'Wrong input arrays'

	n = FLOAT(s(1)) * s(2)
	IF KEYWORD_SET(corr) THEN BEGIN
		vx = a - TOTAL(a)/n
		vy = b - TOTAL(b)/n
	ENDIF ELSE numerx = a - TOTAL(a)/n + TOTAL(b)/n	;Removes mean. Dumb array.

	CASE 1 OF				;The three methods.
		KEYWORD_SET(adif): BEGIN	;Absolute differences.
			denomx = 2.*ABS(numerx-b)
			denomy = ABS(SHIFT(numerx,0,1)-SHIFT(b,0,-1))+ $
				ABS(SHIFT(numerx,0,-1)-SHIFT(b,0,1))-denomx
			numery = ABS(SHIFT(numerx,0,-1)-SHIFT(b,0,1))- $
				ABS(SHIFT(numerx,0,1)-SHIFT(b,0,-1))
			denomx = ABS(SHIFT(numerx,1,0)-SHIFT(b,-1,0))+ $
				ABS(SHIFT(numerx,-1,0)-SHIFT(b,1,0))-denomx
			numerx = ABS(SHIFT(numerx,-1,0)-SHIFT(b,1,0))- $
				ABS(SHIFT(numerx,1,0)-SHIFT(b,-1,0))
			END
		KEYWORD_SET(corr): BEGIN	;Multiplication method.
			denomx = 2.*vx*vy
			denomy = SHIFT(vx,0,1)*SHIFT(vy,0,-1)+ $
				SHIFT(vx,0,-1)*SHIFT(vy,0,1)-denomx
			numery = SHIFT(vx,0,-1)*SHIFT(vy,0,1)- $
				SHIFT(vx,0,1)*SHIFT(vy,0,-1)
			denomx = SHIFT(vx,1,0)*SHIFT(vy,-1,0)+ $
				SHIFT(vx,-1,0)*SHIFT(vy,1,0)-denomx
			numerx = SHIFT(vx,-1,0)*SHIFT(vy,1,0)- $
				SHIFT(vx,1,0)*SHIFT(vy,-1,0)
			END
		ELSE: BEGIN			;Squared differences.
			denomx = 2.*(numerx-b)^2
			denomy = (SHIFT(numerx,0,1)-SHIFT(b,0,-1))^2+ $
				(SHIFT(numerx,0,-1)-SHIFT(b,0,1))^2-denomx
			numery = (SHIFT(numerx,0,-1)-SHIFT(b,0,1))^2- $
				(SHIFT(numerx,0,1)-SHIFT(b,0,-1))^2
			denomx = (SHIFT(numerx,1,0)-SHIFT(b,-1,0))^2+ $
				(SHIFT(numerx,-1,0)-SHIFT(b,1,0))^2-denomx
			numerx = (SHIFT(numerx,-1,0)-SHIFT(b,1,0))^2- $
				(SHIFT(numerx,1,0)-SHIFT(b,-1,0))^2
			END
	ENDCASE

	denomx(0,0) = denomx(1,*)		;Takes care of the borders.
	denomx(s(1)-1,0) = denomx(s(1)-2,*)
	denomx(0,0) = denomx(*,1)
	denomx(0,s(2)-1) = denomx(*,s(2)-2)
	denomy(0,0) = denomy(1,*)
	denomy(s(1)-1,0) = denomy(s(1)-2,*)
	denomy(0,0) = denomy(*,1)
	denomy(0,s(2)-1) = denomy(*,s(2)-2)

	numerx(0,0) = numerx(1,*)
	numerx(s(1)-1,0) =  numerx(s(1)-2,*)
	numerx(0,0) = numerx(*,1)
	numerx(0,s(2)-1) = numerx(*,s(2)-2)
	numery(0,0) = numery(1,*)
	numery(s(1)-1,0) = numery(s(1)-2,*)
	numery(0,0) = numery(*,1)
	numery(0,s(2)-1) = numery(*,s(2)-2)

	IF KEYWORD_SET(boxcar) THEN BEGIN       ;Uses boxcar window,
		denomx = KCONVOL(denomx,boxcar)
		denomy = KCONVOL(denomy,boxcar)
		numerx = KCONVOL(numerx,boxcar)
		numery = KCONVOL(numery,boxcar)
	ENDIF ELSE BEGIN                        ;or a gaussian window.
		denomx = SCONVOL(denomx,std=std,fwhm=fwhm)
		denomy = SCONVOL(denomy,std=std,fwhm=fwhm)
		numerx = SCONVOL(numerx,std=std,fwhm=fwhm)
		numery = SCONVOL(numery,std=std,fwhm=fwhm)
	ENDELSE

	vx = numerx/denomx			;Final results.
	vy = numery/denomy

END