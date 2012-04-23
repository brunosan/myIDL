PRO FOURIER_SUBS , SR , TR , PV
;+
; NAME:
;	FOURIER_SUBS
;
; PURPOSE:
;	Make a 3-D subsonic Fourier filter on a time series of images.
;
; CALLING SEQUENCE:
;	FOURIER_SUBS , SR , TR , PV , WD
;
; INPUTS:
;	SR = spatial resolution (kms per pixel) of the data.
;
;	TR = time interval between consecutive images (in seconds).
;
;	PV = limit phase velocity (in km/s)
;
; OUTPUTS:
;	The complex array stored in the common block IMAGES contains
;	the filtered set of images in the output. Only the real part
;	is meaningful.
;
; COMMON BLOCKS:
;	A 3D dimensional complex array, containing the time sequence
;	of images, should be stotred in a common block names IMAGES.
;	The two first dimensions should be spatial, and the third should
;	be temporal.
;
; SIDE EFFECTS:
;	The array in common block IMAGES is modified in output. Then
;	it will contain the Fourier-subsonic filtered data set.
;
; RESTRICTIONS:
;	Dimensions must be an even number. Limitations for FFT apply.
;
; PROCEDURE:
;	All Fourier components inside a cone w = v x k, where w and k are
;	temporal and angular frequencies, and v is velocity, are set to
;	zero.
;
; REFERENCES:
;	A.Title et al., 1987, in Theoretical Problems in High Resolution
;		Solar Physics II, G.Athay, D.S.Spicer (eds.), NASA Conference
;		Publication 2483, 55
;
; MODIFICATION HISTORY:
;	First implementation, Zhang Yi, June 1992
;	Minor changes, RMH, Jan. 1994
;	Renamed from FILTER_3D to FOURIER_SUBS, RMH, June 1994
;-
ON_ERROR,2

	COMMON IMAGES,a

	IF N_PARAMS(0) LT 3 THEN MESSAGE,'Wrong number of parameters'

	s = SIZE(a)
	IF s(0) NE 3 THEN MESSAGE,'Array must be 3D'

	nx = s(1)/2+1 & kx = FINDGEN(nx) & kx = [kx,REVERSE(kx(1:nx-2))]
	ny = s(2)/2+1 & ky = FINDGEN(ny) & ky = [ky,REVERSE(ky(1:ny-2))]
	nz = s(3)/2+1 & w = FINDGEN(nz) & w = [w,REVERSE(w(1:nz-2))]

	kx = 2. * !pi / s(1) / sr * kx
	ky = 2. * !pi / s(2) / sr * ky
	w = 2. * !pi / s(3) / tr * w

	k = FLTARR(s(1),s(2),/nozero)
	FOR i = 0,s(1)-1 DO FOR j = 0,s(2)-1 DO k(i,j) = kx(i)^2+ky(j)^2
	k = SQRT(k)
	k(0) = 1.			;To avoid dividing by zero

	PRINT,' 3-D FFT forward...'

	a = FFT(a,-1,/overwrite)

	PRINT,' Filtering the image...'
	a(0,0,0) = a(*,*,0)
	FOR i = 1,s(3)-1 DO BEGIN
		cone = w(i)/k LT pv
		a(0,0,i) = a(*,*,i) * cone
	ENDFOR

	PRINT,' 3-D FFT backward...'

	a = FFT(a,1,/overwrite)

END