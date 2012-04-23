FUNCTION ALIGN_CROSS,A,B,WX,WY,CCMAX=ccmax
;+
; NAME:
;	ALIGN_CROSS
;
; PURPOSE:
;	Compute misalignment between A and B.
;
; CALLING SEQUENCE:
;	Result = ALIGN_CROSS(A,B, [ WX , WY ] )
;
; INPUTS:
;	A = reference image.
;
;	B = misaligned image.
;
; OPTIONAL INPUTS:
;	WX = size of subimage of B, in x-direction.
;
;	WY = 	"	"	"      y-direction.
;
;	Defaults are size of B minus 10 pixels.
;
; OUTPUTS:
;	Result = displacement to give B to match A.
;
; OPTIONAL OUTPUTS:
;	CCMAX = value of the correlation coefficient at the
;		location closest to the maximum.
;
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;	Slow when the number of pixels in images A and B is not a power
;	of two.
;
; PROCEDURE:
;	Image A is taken as the reference frame. The linear correlation 
;	coefficient between a subimage of B and image A is computed.
;	The algorithm makes use of the properties of Fourier transforms,
;	fastest when the number of pixels in A and B is a power of two.
;	Let sA and sB be subimage of A and B, respectively. Then the 
;	algorithm works like:
;
;	TOTAL(sA*sB)/n - TOTAL(sA)/n * TOTAL(sB)/n
;	------------------------------------------
;	stand.deviat.A * stand.deviat.B
;
;	The linear correlation coefficient is relatively robust
;	against linear trends in the data.
;
; MODIFICATION HISTORY:
;	Written by Roberto Luis Molowny Horas, October 1992.
;
;-
ON_ERROR,2

	s = SIZE(a)
	IF N_PARAMS(0) LT 4 THEN IF N_PARAMS(0) LT 3 THEN BEGIN
		wx = s(1) - 10
		wy = s(2) - 10
	ENDIF ELSE wy = wx

	n = FLOAT(s(1))*s(2) / (FLOAT(wx)*wy)	;Constant to multiply by.

	nx = s(1) - wx				;Magic numbers.
	nx = nx / 2
	ny = s(2) - wy
	ny = ny / 2

	window = FLTARR(s(1),s(2))
	window(nx,ny) = REPLICATE(1.,wx,wy)	;Subimage in B.
	window = CONJ(FFT(window,-1))

	fa = FFT(a,-1)
	ma = FLOAT(FFT(fa*window,1))		;Computing the mean of A.
	ma = SHIFT(ma,s(1)/2,s(2)/2)
	ma = ma(s(1)/2-nx:s(1)/2+nx,s(2)/2-ny:s(2)/2+ny) * n

	maa = FLOAT(FFT(FFT(FLOAT(a)*a,-1)*window,1))	;Mean of A^2
	maa = SHIFT(maa,s(1)/2,s(2)/2)
	maa = maa(s(1)/2-nx:s(1)/2+nx,s(2)/2-ny:s(2)/2+ny) * n

	mb = MEAN(b(nx:nx+wx-1,ny:ny+wy-1))	;Mean of subimage in B.
	stb = SQRT(MEAN(FLOAT(b(nx:nx+wx-1,ny:ny+wy-1))^2)-mb*mb)

	sta = SQRT(maa-ma*ma)		;Standard deviations in A.
	mab = ma * mb			;Product of means.

	window = FLTARR(s(1),s(2))
	window(nx,ny) = REPLICATE(1.,wx,wy)
	fb = CONJ(FFT(b*window,-1))			;Subimage in B.
	cc = FLOAT(FFT(fa*fb,1))			;Correlation.
	fa = 0 & fb = 0
	cc = SHIFT(cc,s(1)/2,s(2)/2)
	cc = cc(s(1)/2-nx:s(1)/2+nx,s(2)/2-ny:s(2)/2+ny) * n

	cc = (cc-mab)/sta/stb		;Linear correlation coefficient.
	xy = MAXLOC(cc)			;Finds position of maximum.

	IF xy(0) EQ 0 OR xy(0) EQ 2*nx OR xy(1) EQ 0 OR xy(1) EQ 2*ny $
	THEN BEGIN
		PRINT,' >>>> SHIFT too large!'		;Too bad.
		x = 0 & y = 0
	ENDIF ELSE BEGIN			;Subpixel interpolation.
		IF KEYWORD_SET(ccmax) THEN ccmax = cc(xy(0),xy(1))
		cc = cc(xy(0)-1:xy(0)+1,xy(1)-1:xy(1)+1)
		FIVEPOINT,cc,x,y
		x = xy(0) - nx + x
		y = xy(1) - ny + y
	ENDELSE		

	RETURN,[x,y]				;Voila!
END