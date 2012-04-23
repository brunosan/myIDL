pro ofstcn,imag
;+
;
;	function:  ofstcn
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
;	input:   array imag
;	output:  array imag
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 1 then begin
	print
	print, "usage:  ofstcn, imag"
	print
	print, "	Arguments"
	print, "		imag	- image  (I/P and O/P)"
	print
	return
endif
;-

;  get dimensions of arrays
nx = sizeof(imag, 1)
ny = sizeof(imag, 2)
print,'input array size:', nx, ny
imgout = fltarr(nx,ny)

;  starting value for correcting the gain variation after correcting
;  for the offset.  Normally the offset sample ends at idl column 15.
;  We have eliminated the first column from the extracted average images
;  because that column contains bad values.  So the actual active image
;  data starts in idl column 15, and the last offset sample is idl column 13.

ist2 = 15

;  get averages of 3 recursive columns in the middle of the
;  offset sample area ( which is defined by columns
;  0-13)
avgc = fltarr(3)

imgout=imag

;  find average of r-g-b columns for the active region of the array
for i = 0,2 do begin
    avgc(i) = 0.
endfor

numb = 0

  for i = ist2,nx-6,3 do begin
numb = numb + 1
    for ii = 0,2 do begin
      avgc(ii) = avgc(ii) +  total(imgout(ii+i,*))/float(ny)
    endfor
  endfor

print,' number of columns averaged =',numb,(nx-3)/3
  avgc = avgc/numb
  avgf = total(avgc)/3

;  renormalization factor for columns
  avgc = avgf/avgc
print,' renormalization factors for r-g-b:',avgc


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

;  load back into input array
imag=imgout

end
