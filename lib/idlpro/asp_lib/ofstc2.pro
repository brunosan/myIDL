pro ofstc2, imag, verbose=verbose
;+
;
;	procedure:  ofstc2
;
;	purpose:   Correct the input image for offset variations by
;		   subtracting the average of dark columns at first of image.
;		   Averages computed separately for red, green, blue channels
;		   of each CCD by averaging columns 3+6, 4+7, and 5+8 of the
;		   dark region at left of each image, then subtracting these
;		   values from the corresponding following RGB columns of
;		   the image.
;		   Next, calculate the residual 3-column variation from
;		   dark image and correct for it by a multiplicative factor.
;		   This corrects accurately for the residual RGB gain errors.
;
;	author:  lites@ncar, 4/92	[various mod's by rob@ncar]
;
;	notes:  - FOR NOW, THE ROUTINE ONLY CORRECTS FOR RESIDUAL 3-COLUMN
;		  VARIATION BECAUSE DARK SUBTRACTION SEEMS TO TAKE CARE OF
;		  DARK OFFSETS.  THE CORRECTIONS ARE MULTIPLICATIVE, BUT
;		  SINCE THEY ARE SMALL, IT WOULD NOT MAKE MUCH DIFFERENCE
;		  IF THEY WERE SUBTRACTIVE
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 1 then begin
	print
	print, "usage:  ofstc2, imag"
	print
	print, "	Arguments"
	print, "		imag	- image  (I/P and O/P)"
	print
	print, "	Keywords"
	print, "		verbose	- if set, print run-time information"
	print, "			  (def=don't print it)"
	print
	return
endif
;-
;
;	Set general parameters.
;
do_verb = keyword_set(verbose)
;
;	Get dimensions of arrays.
;
nx = sizeof(imag, 1)
ny = sizeof(imag, 2)
if do_verb then print, format='(/A)', $
	'ofstc2:  input array size = ' + stringit(nx) + ' x ' + stringit(ny)
;
;	Set arrays.
;
avgprf = fltarr(nx)		; arrays are zero'ed
nrgb = fltarr(3)
avgc = fltarr(3)
imgout = imag

;  Starting value for correcting the gain variation after correcting
;  for the offset.  Normally the offset sample ends at IDL column 15.
;  We have eliminated the first column from the extracted average images
;  because that column contains bad values.  So the actual active image
;  data starts in IDL column 15, and the last offset sample is IDL column 14.
ist2 = 15

;  Get averages of 3 recursive columns in the middle of the
;  offset sample area (which is defined by columns 0-13).

;
;	Get average spectral profile for array.
;
for i=0,nx-1 do avgprf(i) = total(imgout(i,0:ny-1))/float(ny)
;
;	Determine maximum of this average profile.
;
avgpmx = max(avgprf)
;
;	Set limit for summing profiles to get RGB variation.
;
avgpmx = 0.9*avgpmx
;
;	Find average of RGB columns for the active region of the array.
;
for i = ist2,nx-6, 3 do $
	for ii = 0, 2 do $
		if avgprf(ii+i) gt avgpmx  then begin
			nrgb(ii) = nrgb(ii) + 1.0
			avgc(ii) = avgc(ii) + avgprf(ii+i)
		endif

if do_verb then print, 'ofstc2:  number of RGB columns averaged = ', $
	stringit(nrgb(0)), ', ', stringit(nrgb(1)), ', ', stringit(nrgb(2))

;
;	Calc average R, G, and B.
avgc = avgc/nrgb
;
;	Calc average R, G, and B.
;
avgf = total(avgc)/3.0
;
;	Renormalization factor for columns.
;
avgc = avgf/avgc

if do_verb then print, 'ofstc2:  renormalization factors for RGB = ', $
	stringit(avgc(0)), ', ', stringit(avgc(1)), ', ', stringit(avgc(2))

;
;	Renormalize columns of image.
;
for i = ist2, nx-3, 3 do $
	for ii = 0,2 do imgout(i+ii,*) = imgout(i+ii,*) * avgc(ii)
;
;	Handle remaining columns, if not normalized yet.
;
ksum = 3 * fix( (nx-3)/3 ) + 2
;
if ksum ne (nx-1) then $
	for i = ksum+1,(nx-1) do imgout(i,*) = imgout(i,*) * avgc(i-ksum-1)
;
;	Load back into input array.
;
imag = imgout

end
