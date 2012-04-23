FUNCTION REMAP,A,B,STD,BOXCAR=boxcar,ADIF=adif,CORR=corr,QFIT2=qfit2,$
	CROSSD=crossd,INTERP=interp
;+
; NAME:
;	REMAP
;
; PURPOSE:
;	Correct image B for distortions and match to image A.
;
; CALLING SEQUENCE:
;	Result = REMAP(A,B,STD,[ BOXCAR = , ADIF = , CORR = ,
;			QFIT2 = , CROSSD = , INTERP = interp ] )
;
; INPUTS:
;	A = reference image.
;
;	B = distorted image.
;
;	STD = width for smoothing window. If smoothing is carried out
;		with a boxcar window, STD must be an odd number.
;
; KEYWORDS:
;	BOXCAR = if set, a boxcar window of width STD is used.
;
;	ADIF = uses an absolute differences algorithm.
;
;	CORR = uses a multiplicative algorithm. Default is the sum of
;		squares of the local differences.
;
;	QFIT2 = uses 9 points fitting procedure.
;
;	CROSSD = uses cross derivative interpolation formulae.
;
;	INTERP = If set to 1, bicubic interpolation. If set to 2, the so-
;		called cross derivative interpolation is used. If set to
;		3, spline interpolation will be chosen. If not present,
;		set to 0 or any other number, bilinear interpolation is
;		performed.
;
; OUTPUTS:
;	Result = distortion corrected image.
;
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;	None.
;
; PROCEDURE:
;	The distortion map is computed with DISTORTION_MAP.
;
; EXAMPLE:
;	Let B be the distorted image, and A the reference one. To compute
;	a distortion-free image called "result", do:
;
;	IDL> result = REMAP(A,B,45,/boxcar)
;
;	where bilinear interpolation is carried out, and the smoothing
;	window is a boxcar of width 45 pixels.
;
; REFERENCES:
;	Yi,Z. and Molowny H.R.: 1992, Proceedings from Lest Mini-Workshop,
;		LEST Technical Report No.56
;
; MODIFICATION HISTORY:
;	Written by Roberto Luis Molowny Horas, November 1992.
;
;-
ON_ERROR,2

	DISTORTION_MAP,A,B,STD,VX,VY , BOXCAR=boxcar , ADIF=adif , CORR=corr,$
		QFIT2=qfit2 , CROSSD=crossd

	s = SIZE(a)
	x = LINDGEN(s(1),s(2))		;Grids.
	y = x / s(1))
	x = x MOD s(1)

	IF N_ELEMENTS(interp) EQ 0 THEN interp = 0	;INTERP not set.

	CASE 1 OF					;Matching image A.
		interp EQ 1: RETURN,RINTER(b,x+vx,y+vy)
		interp EQ 2: RETURN,GRID_CROSSD(b,x+vx,y+vy)
		interp EQ 3: RETURN,GRID_SPLINE(b,x+vx,y+vy)
		ELSE: RETURN,INTERPOLATE(b,x+vx,y+vy)
	ENDCASE
END
