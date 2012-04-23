PRO FLOW_SAVE , SAVE_NAME , NAMESA , NAMESB , VX = vx , VY = vy , STD = std , $
	FWHM = fwhm , BOXCAR = boxcar , ADIF = adif , CORR = corr
;+
; NAME:
;	FLOW_SAVE
;
; PURPOSE:
;	Compute time averaged local offsets map between two data sets.
;
; CALLING SEQUENCE:
;	FLOW_SAVE,SAVE_NAME , [ NAMESA , NAMESB , VX = , VY = , STD = , FWHM = ,
;	BOXCAR = , ADIF = , CORR =  SILENT = ]
;
; INPUTS:
;	SAVE_NAME = string containing the name to save the correlation
;		function array, or to restore it if it had been saved
;		previously.
;
; OPTIONAL INPUTS:
;	NAMESA = string array containing the names for the first image
;		in every correlating pair.
;
;	NAMESB = string array containing the names for the second image
;		in every correlating pair.
;
;		If NAMESA and NAMESB are given, the routine assumes that
;		the correlation function is to be calculated. Otherwise,
;		the program will try to restore a file called SAVE_NAME,
;		and convolve it with a gaussian or a boxcar window.
;
;	STD = standard deviation of a 2-D gaussian.
;
;	FWHM = full width at half maximum of the 2-D gaussian. For further
;		information, see the header of SCONVOL.
;
;	BOXCAR = width of a boxcar running window. This keyword supersedes
;		STD and FWHM.
;
; KEYWORDS:
;	ADIF = uses absolute differences method.
;
;	CORR = uses multiplication method. Default is squared differences.
;
; OPTIONAL OUTPUTS:
;	VX,VY = X and Y components for the displacement map. Each vector
;		shows the shift of every point of B with respect to A.
;
; SIDE EFFECTS:
;	If NAMESA and NAMESB are given, a file called SAVE_NAME will be
;	saved on disk. It will contain a floating array, of size four times
;	that of the images.
;
; RESTRICTIONS:
;	Images are assumed to be stored in FITS format.
;
; COMMON BLOCKS:
;	None.
;
; PROCEDURE:
;	It differs from FLOW_MAKER in a number of things. The most
;	important is that FLOW_SAVE calculates the correlation
;	function, and saves it. Then, we may investigate the effect
;	of different sampling windows of varying size without going
;	through the cumbersome task of computing the correlation
;	function again. This idea goes all the way back to L.J.November's
;	implementation of his algorithm (see references below).
;	FLOW_SAVE uses a 5 point interpolation formula to find the
;	extrem location of the correlation function. This saves time
;	and memory space.
;
; EXAMPLES:
;	Let's have a time series of 100 images, stored in FITS format,
;	labelled image1.bin,...,image100.bin. They have been obtained
;	with a time interval of 10 s between consecutive frames. To
;	make a correlation function, with a time lag between correlated
;	images of 60 s, we'll do:
;
;	IDL> namesa = 'image'+STRTRIM(STRING(INDGEN(94)+1),2)+'.bin'
;	IDL> namesb = 'image'+STRTRIM(STRING(INDGEN(94)+7),2)+'.bin'
;	IDL> FLOW_SAVE,'corfunc',namesa,namesb
;
;	which saves it on disk. In the example above, a squared differences
;	algorithm has been chosen by default. To calculate a vector field with
;	a gaussian smoothing window of fwhm = 25 pixels, we'll do:
;
;	IDL> FLOW_SAVE,'corfunc',vx=vx,vy=vy,fwhm=25.
;
;	which we may compare with the same field, but smoothed by a boxcar
;	running window of width 25 pixels:
;
;	IDL> FLOW_SAVE,'corfunc',vx=vx,vy=vy,boxcar=25
;
;	This takes much less time than computing the whole correlation
;	array again.
;
; REFERENCES:
;	The user should be acquainted with the following papers:
;	* November, L.J., 1986, Applied Optics, Vol.25, No.3, 392
;	* November, L.J., Simon, G.W., 1988, Ap.J., 333, 427
;
; MODIFICATION HISTORY:
;	R. Molowny-Horas, May 1994.
;-
ON_ERROR,2

	IF N_ELEMENTS(save_name) EQ 0 THEN MESSAGE,'Missing SAVE_NAME input'

	na = N_ELEMENTS(namesa)
	nb = N_ELEMENTS(namesb)
	IF na NE nb THEN $
		MESSAGE,'Arrays NAMEA and NAMEB should have same dimensions'

	IF na NE 0 THEN BEGIN
		s = SIZE(READFITS(namesa(0),/silent))	;Gets size of images.
		numerx = 0. & numery = 0 & denomx = 0. & denomy = 0.
		FOR i = 0,na-1 DO BEGIN
;
; If the images are not in FITS format, edit the next two lines (and the one
; above which contains READFITS) and add your own routine.

			PRINT,' Reading ' + namesa(i) + '...'
			a = READFITS(namesa(i),/silent)
			PRINT,' Reading ' + namesb(i) + '...'
			b = READFITS(namesb(i),/silent)

			a = a - TOTAL(a)/s(4)		;Removes mean.
			IF KEYWORD_SET(corr) THEN b = b - TOTAL(b)/s(4) ELSE $
				a = a + TOTAL(b)/s(4)	;Removes mean of image.

			CASE 1 OF				;The three methods.
			KEYWORD_SET(adif): BEGIN	;Absolute differences.
				denomx = denomx + ABS(SHIFT(a,1,0)-SHIFT(b,-1,0))+ $
					ABS(SHIFT(a,-1,0)-SHIFT(b,1,0))-2.*ABS(a-b)
				numerx = numerx + ABS(SHIFT(a,-1,0)-SHIFT(b,1,0))- $
					ABS(SHIFT(a,1,0)-SHIFT(b,-1,0))
				denomy = denomy + ABS(SHIFT(a,0,1)-SHIFT(b,0,-1))+ $
					ABS(SHIFT(a,0,-1)-SHIFT(b,0,1))-2.*ABS(a-b)
				numery = numery + ABS(SHIFT(a,0,-1)-SHIFT(b,0,1))- $
					ABS(SHIFT(a,0,1)-SHIFT(b,0,-1))
				END
			KEYWORD_SET(corr): BEGIN	;Multiplication method.
				denomx = denomx + SHIFT(a,1,0)*SHIFT(b,-1,0)+ $
					SHIFT(a,-1,0)*SHIFT(b,1,0)-2.*a*b
				numerx = numerx + SHIFT(a,-1,0)*SHIFT(b,1,0)- $
					SHIFT(a,1,0)*SHIFT(b,-1,0)
				denomy = denomy + SHIFT(a,0,1)*SHIFT(b,0,-1)+ $
					SHIFT(a,0,-1)*SHIFT(b,0,1)-2.*a*b
				numery = numery + SHIFT(a,0,-1)*SHIFT(b,0,1)- $
					SHIFT(a,0,1)*SHIFT(b,0,-1)
				END
			ELSE: BEGIN			;Squared differences. Default.
				denomx = denomx + (SHIFT(a,1,0)-SHIFT(b,-1,0))^2+ $
					(SHIFT(a,-1,0)-SHIFT(b,1,0))^2-2.*(a-b)^2
				numerx = numerx + (SHIFT(a,-1,0)-SHIFT(b,1,0))^2- $
					(SHIFT(a,1,0)-SHIFT(b,-1,0))^2
				denomy = denomy + (SHIFT(a,0,1)-SHIFT(b,0,-1))^2+ $
					(SHIFT(a,0,-1)-SHIFT(b,0,1))^2-2.*(a-b)^2
				numery = numery + (SHIFT(a,0,-1)-SHIFT(b,0,1))^2- $
					(SHIFT(a,0,1)-SHIFT(b,0,-1))^2
				ENDELSE
			ENDCASE
		ENDFOR

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

		SAVE,denomx,denomy,numerx,numery,filename=save_name	;Saves it.

	ENDIF ELSE BEGIN

		RESTORE,save_name			;Restores it.

		IF KEYWORD_SET(boxcar) THEN BEGIN	;Uses boxcar window,
			denomx = KCONVOL(denomx,boxcar)
			denomy = KCONVOL(denomy,boxcar)
			numerx = KCONVOL(numerx,boxcar)
			numery = KCONVOL(numery,boxcar)
		ENDIF ELSE BEGIN			;or a gaussian window.
			denomx = SCONVOL(denomx,std=std,fwhm=fwhm)
			denomy = SCONVOL(denomy,std=std,fwhm=fwhm)
			numerx = SCONVOL(numerx,std=std,fwhm=fwhm)
			numery = SCONVOL(numery,std=std,fwhm=fwhm)
		ENDELSE
		vx = numerx/denomx			;Final results.
		vy = numery/denomy

	ENDELSE

END