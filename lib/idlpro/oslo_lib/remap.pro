FUNCTION REMAP,A,B, STD = std , FWHM = fwhm , BOXCAR=boxcar , $
	ADIF=adif , CORR=corr ,	INTERP=interp , MISSING=missing
;+
; NAME:
;	REMAP
;
; PURPOSE:
;	Correct image B for distortions and match to image A.
;
; CALLING SEQUENCE:
;	Result = REMAP(A,B,[ STD = , FWHM = , BOXCAR = , ADIF = , CORR = , 
;		INTERP = , MISSING = missing ])
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
;	BOXCAR = width of the running boxcar window. If set, it
;		supersedes STD and FWHM.
;
; OPTIONAL INPUTS:
;	MISSING = The value to return for elements outside the
;		bounds of B.
;
; KEYWORDS:
;	ADIF = uses an absolute differences algorithm.
;
;	CORR = uses a multiplicative algorithm. Default is local
;		squared differences.
;
;	INTERP = If set, bicubic interpolation is chosen. Otherwise,
;		bilinear interpolation is performed.
;
; OUTPUTS:
;	Result = distortion corrected image. Same type as B.
;
; OPTIONAL OUTPUTS:
;	VX, VY = local displacements map.
;
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;	If BOXCAR keyword is selected, the program assumes that STD or FWHM
;	is the width of the boxcar window, and that they are an
;	odd integer number.
;
; PROCEDURE:
;	The distortion map is computed with DISTORTION_MAP.
;
; EXAMPLE:
;	Let B be the distorted image, and A the reference one. To compute
;	a distortion-free image called "result", do:
;
;	IDL> result = REMAP(a,b,boxcar=45)
;
;	where bilinear interpolation is carried out, and the smoothing
;	window is a boxcar of width 45 pixels.
;
; REFERENCES:
;	Yi,Z. and Molowny H.R.: 1992, Proceedings from Lest Mini-Workshop,
;		LEST Technical Report No.56
;
; MODIFICATION HISTORY:
;	Written by Roberto Molowny-Horas, November 1992.
;	Modified Feb 1992, RMH
;
;-
ON_ERROR,2

	DISTORTION_MAP,A,B,VX,VY,STD=std,FWHM=fwhm,BOXCAR=boxcar,$
		ADIF=adif,CORR=corr

	s = SIZE(a)
	x = LINDGEN(s(1),s(2))		;Grids.
	y = x / s(1)
	x = x MOD s(1)

	IF NOT KEYWORD_SET(interp) THEN interp = 0

	IF N_ELEMENTS(missing) NE 0 THEN $
		RETURN,INTERPOLATE(b,x+vx,y+vy,cubic=interp,missing=missing) $
		ELSE RETURN,INTERPOLATE(b,x+vx,y+vy,cubic=interp)

END