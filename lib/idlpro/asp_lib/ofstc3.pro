pro ofstc3, imag, qqq, uuu, vvv
;+
;
;	procedure:  ofstc3
;
;	purpose:   correct the input image for offset variations by
;   subtracting the average of dark columns at first of image.
;   Averages computed separately for red, green, blue channels of
;   each CCD by averaging columns 3+6, 4+7, and 5+8 of the
;   dark region at left of each image, then subtracting these values
;   from the corresponding following r,g,b columns of the image.
;
;   next, it calculates the residual 3-column variation from dark
;   image and corrects for it by a multiplicative factor.  This corrects
;   accurately for the residual r-g-b gain errors.
;
;   FOR NOW, THE ROUTINE ONLY CORRECTS FOR RESIDUAL 3-COLUMN VARIATION
;   BECAUSE DARK SUBTRACTION SEEMS TO TAKE CARE OF DARK OFFSETS.  THE
;   CORRECTIONS ARE MULTIPLICATIVE, BUT SINCE THEY ARE SMALL, IT WOULD NOT
;   MAKE MUCH DIFFERENCE IF THEY WERE SUBTRACTIVE
;
;	author:  lites@ncar, 4/92
;
;	inputs:  imag	   - I
;		 qqq       - Q
;		 uuu       - U
;		 vvv       - V
;
;      outputs:  imag	   - corrected I
;		 qqq       - corrected Q
;		 uuu       - corrected U
;		 vvv       - corrected V
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 4 then begin
	print
	print, "usage:  ofstc3, imag, qqq, uuu, vvv"
	print
	print, "	Arguments"
	print, "		imag	- I  (I/P and O/P)"
	print, "		qqq	- Q  (I/P and O/P)"
	print, "		uuu	- U  (I/P and O/P)"
	print, "		vvv	- V  (I/P and O/P)"
	print
	return
endif
;-

;  get dimensions of arrays
nx = sizeof(imag, 1)
ny = sizeof(imag, 2)
;;print,'input array size', nx, ny
imgout = fltarr(nx,ny)
  nrgb = fltarr(3)	; zero'ed

;  starting index is hardwired to idl column 3, in order to
;  average columns 3-8.  It starts on this column both to avoid
;  spurious values near left and right edges of darkened area,
;  and to be able to easily correct whole field.  ist must be
;  a multiple of 3

ist = 3

;  starting value for correcting the gain variation after correcting
;  for the offset.  Normally the offset sample ends at idl column 15.
;  We have eliminated the first column from the extracted average images
;  because that column contains bad values.  So the actual active image
;  data starts in idl column 15, and the last offset sample is idl column 14.

ist2 = 15


;  get averages of 3 recursive columns in the middle of the
;  offset sample area ( which is defined by columns
;  0-13)
avgc = fltarr(3)
;for i = 0,2 do begin
;  avgc(i) = 0.
;  avgc(i) = (  total(imag(ist+i,*))+total(imag(ist+i+3,*))  $
;		    )/float(ny*2)
;endfor
;print,'average of columns:',avgc

;  subtract offsets from image
;for i = 0,nx-3,3 do begin
;  print,'index=',i
;  for ii = 0,2 do imgout(i+ii,*) = imag(i+ii,*) - avgc(ii)
;endfor
;ksum=3*fix((nx-3)/3)+2
;if ksum ne (nx-1) then begin
;  for i = ksum+1,(nx-1) do begin
;	imgout(i,*) = imag(i,*) - avgc(i-ksum-1)
;  endfor
;endif
;read,'type to continue',ans


;  load back into input array
;  imag=imgout


imgout=imag

;  first get average spectral profile for array
  avgprf=fltarr(nx)
  for i=0,nx-1 do avgprf(i) = total(imgout(i,0:ny-1))/float(ny)
;  determine maximum of this average profile
  avgpmx = max(avgprf)
;  set limit for summing profiles to get rgb variation
  avgpmx = 0.9*avgpmx

;  find average of r-g-b columns for the active region of the array
    avgc(*) = 0.
  for i = ist2,nx-6,3 do begin
    for ii = 0,2 do begin
      if avgprf(ii+i) gt avgpmx  then begin
        nrgb(ii) = nrgb(ii) + 1.
        avgc(ii) = avgc(ii) +  avgprf(ii+i)
      endif
    endfor
  endfor

;;print,' numbers of rgb columns averaged =',nrgb
  avgc = avgc/nrgb
  avgf = total(avgc)/3.
;  renormalization factor for columns
  avgc = avgf/avgc
;;print,' renormalization factors for r-g-b:',avgc


;  renormalize columns of image
for i = ist2,nx-3,3 do begin
  for ii = 0,2 do imgout(i+ii,*) = imgout(i+ii,*) * avgc(ii)
endfor
ksum=3*fix((nx-3)/3)+2
if ksum ne (nx-1) then begin
  for i = ksum+1,(nx-1) do begin
	imgout(i,*) = imgout(i,*) * avgc(i-ksum-1)
  endfor
endif

;  renormalize columns of image Q
for i = ist2,nx-3,3 do begin
  for ii = 0,2 do qqq(i+ii,*) = qqq(i+ii,*) * avgc(ii)
endfor
ksum=3*fix((nx-3)/3)+2
if ksum ne (nx-1) then begin
  for i = ksum+1,(nx-1) do begin
	qqq(i,*) = qqq(i,*) * avgc(i-ksum-1)
  endfor
endif

;  renormalize columns of image U
for i = ist2,nx-3,3 do begin
  for ii = 0,2 do uuu(i+ii,*) = uuu(i+ii,*) * avgc(ii)
endfor
ksum=3*fix((nx-3)/3)+2
if ksum ne (nx-1) then begin
  for i = ksum+1,(nx-1) do begin
	uuu(i,*) = uuu(i,*) * avgc(i-ksum-1)
  endfor
endif

;  renormalize columns of image V
for i = ist2,nx-3,3 do begin
  for ii = 0,2 do vvv(i+ii,*) = vvv(i+ii,*) * avgc(ii)
endfor
ksum=3*fix((nx-3)/3)+2
if ksum ne (nx-1) then begin
  for i = ksum+1,(nx-1) do begin
	vvv(i,*) = vvv(i,*) * avgc(i-ksum-1)
  endfor
endif

;  load back into input array
imag=imgout

return
end
