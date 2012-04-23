pro genibpg, im1, im2, im3, im4, range1, range, ct
;+
;
; routine to generate for publication the images for op 5 of intensity,
; field strength, field azimuth, and field inclination.  Outputs these
; respectively in im1-im4.  range1 gives the range of x,y dimensions in
; arcseconds (since the op5 is near the limb, don't use megameters here).
;
;	range(2,4) gives range of color tables, 
;	parameter ct = 0(gray),1(reverse gray),2(color),3(wrap color)
;	output of this routine will go to pltibpg.pro
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 7 then begin
	print
	print, "usage:  genibpg, im1, im2, im3, im4, range1, range, ct"
	print
	print, "	Bruce's code... (see pltibpg.pro)."
	print
	return
endif
;-

			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			;
			;Procedure to read & display a_* files
			;dumped by program bite expansions of bi-files
			;with the -x option.
			;
			;Paul Seagraves.
;  modified by b lites
			;
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			;
			;Check if user supplied directory name as argument.
			;
    directory = ''
    read, '                return or (q quit) (u usage) --> ', directory
			;
    if  directory eq 'q'  then return
			;
    if  directory eq 'u'  then begin
			;
			;Print usage information.
			;
	print
	print, "usage:  a_help, directory"
	print, "        a_help, ''        (for current working directory)"
	print, "        a_help            (for prompts)"
	print
	print, "        directory is a string variable."
	print
	print, "        directory+'/a_*' Should be files output by"
	print, "                         program bite with the -x option."
	print
			;
	return
    end
			;
			;Prompt for directory name.
			;
    read, 'Directory path with a_* files ? (return pwd) -->', directory
			;
			;
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			;
			;Append directory name with / 
			;Use null path for pwd.
			;
dir = directory+'/'
if  directory eq ''  then dir = ''
			;
			;Read header(0:127) to get y-dimension used to
			;generate raster point numbers.
			;
			;Warning, header(0:127) isn't all floating point.
			;IDL's "help, header" will look funny.
			;
a___header = read_floats( dir+'a___header' )
			;
			;Y-dimension is element 57 of a___header(0:127).
			;For ASP these are positions along the slit.
			;Inversion code gets this value from model files.
			;Default (at this time) in the inversion code is 256.
			;Recomend 256 be even if all slit positions aren't kept.
			;
nspan  = long( a___header(57)+.5 )
			;
			;Read the array of raster point numbers.
			;These may not have a corresponding stokes inversion
			;depending on polarization.
			;These are used to number the raster points
			;in a__* files (note two underscores).
			;
a__points  = long( read_floats( dir+'a__points' ) +.5 )
			;
			;Convert the raster point numbers to x & y values.
			;x corresponds to an ASP steps.
			;y corresponds to a postions along the slit.
			;y varies fastest.
			;
x = a__points/nspan
y = a__points-x*nspan
			;
			;Find ranges of x and y.
			;
x0 = min( x )
x1 = max( x )
y0 = min( y )
y1 = max( y )
			;
			;Get image dimensions.
			;
xdim = x1-x0+1
ydim = y1-y0+1
			;
			;Open window 0 large enough to display 8 images.
			;
window, title='_cct fld azm psi', xsize=4*xdim, ysize=2*ydim
			;
			;Form a subscript array for images; x varies fastest.
			;This is used to redirect data moved to images.
			;
pxy = (y-y0)*xdim + (x-x0)
			;
			;Get positions in middle away from hair lines.
			;
middle = where( (y gt 50) and (y lt 200) )
			;
			;Read the array of raster point numbers that.
			;have a corresponding stokes inversion.
			;These are used to number the raster points
			;in a_* files (note one underscore).
			;
a_solved = long( read_floats( dir+'a_solved' ) +.5 )
			;
			;Convert the raster point numbers to x & y values.
			;x corresponds to an ASP steps.
			;y corresponds to a postions along the slit.
			;y varies fastest.
			;
x = a_solved/nspan
y = a_solved-x*nspan
			;
			;Form a subscript array for images; x varies fastest.
			;This is used to redirect data moved to images.
			;
sxy = (y-y0)*xdim + (x-x0)
			;
			;Discard some arrays.
			;
a__points = 0
a_solved = 0
			;
			;Make a byte array to hold an image.
			;
biim    = bytarr( xdim*ydim, /nozero )
			;
			;Read continuum data.
			;Get middle values away from hair lines.
			;Set background to 127.
			;Scale and move the information to the byte image.
			;Discard tmpmid array.
			;Display continuum image.
			;Display the negative image.
			;
;  define output parameters for range, color table for each image
range = intarr(2,4)
ct = intarr(4)

tmp = read_floats( dir+'a__cct' )
aimage = fltarr(xdim,ydim)
aimage(pxy) = reform(tmp,ydim,xdim)
badcol,aimage
tmpmid = aimage(*,50:200)
mxtm = max(tmpmid)
aimage = aimage > min(tmpmid) < mxtm
;  store continuum image as integer array over range of intensities
im1 = intarr(xdim,ydim)
im1 = fix(aimage)
whrpen = where( (im1 gt 0.7*mxtm) and (im1 lt 0.8*mxtm) )
tvscl,im1,0*xdim,1*ydim
range(*,0) = [0,mxtm]
ct(0) = 0

;  locate outer umbral contours
ahi = .55
alo = .47
whrumb = where( (im1 gt alo*mxtm) and (im1 lt ahi*mxtm) )
;  reset intensities of penumbra
;im1(whrumb) = mxtm
;display
;tvscl,im1,0*xdim,0*ydim


;  plot error in field strength
tmp = read_floats( dir+'a_fld_er' )
aimage = fltarr(xdim*ydim,/nozero)
aimage(*) = 0.
;  locate positions where error in field strength gt 200 Gauss
whrsv = where( tmp gt 200. )
;  linearly interpolate over these positions
 terpol,tmp,whrsv
aimage(sxy) = tmp
aimage = reform(aimage,xdim,ydim)
 badcol,aimage
tmpmid = aimage(*,50:200)
fmax = max(tmpmid)
 aimage = aimage > min(tmpmid) < min([3500,fmax])
tvscl,aimage,2*xdim,0*ydim
;stop
			;
			;Read polarization data.
			;Set background to 127.
			;Scale and move the information to the byte image.
			;Display polarization image.
			;
tmp = read_floats( dir+'a__pip' )
aimage(pxy) = reform(tmp,xdim,ydim)
;whr = where ( (y ge 50) and (y le 200 ) )
;maxmid = max( aimage( whr ) )
badcol,aimage
tmpmid = aimage(*,50:200)
mxtm = max(tmpmid)
aimage = aimage > min(tmpmid) < mxtm
aimage(whrumb) = mxtm
tvscl,aimage,1*xdim,0*ydim
;stop
			;
			;Read field azimuth data.
			;Find where azimuth is -180 to 0.
			;(The inversion code puts azimuth in range -180 to 180).
			;Put in range 0 to 180.
			;Find where azimuth is in range 90 to 180.
			;For display reverse slope azimuth in range 90 to 180.
			;Set background to 127.
			;Scale and move the information to the byte image.
			;Display the azimuth image.
			;Display the negative image.
			;
tmp = read_floats( dir+'a_azm' )
;  find azimuths between -180 and 0 and correct to 0 - 180
whr = where( tmp lt 0. )
tmp( whr ) = tmp( whr )+180.
;  correct by 90 degrees
tmp(*) = tmp(*) - 90.
whr = where( tmp lt 0. )
tmp( whr ) = tmp( whr )+180.
 terpol,tmp,whrsv
aimage = fltarr(xdim*ydim,/nozero)
aimage(*) = -1.
aimage(sxy) = tmp
aimage = reform(aimage,xdim,ydim)
badcol,aimage
im3 = intarr(xdim,ydim)
im3 = fix(aimage)
im3(whrumb) = -2
tvscl,im3,2*xdim,1*ydim
range(*,2) = [0,180]
ct(2) = 3
			;
			;Read field inclination data.
			;Set background to 127.
			;Scale and move the information to the byte image.
			;Display the inclination image.
			;Display the negative image.
			;
tmp = read_floats( dir+'a_psi' )
 terpol,tmp,whrsv
aimage = fltarr(xdim*ydim,/nozero)
aimage(*) = -1.
aimage(sxy) = tmp
aimage = reform(aimage,xdim,ydim)
badcol,aimage
im4 = intarr(xdim,ydim)
im4 = fix(aimage)
im4(whrumb) = -2
tvscl,im4,3*xdim,1*ydim
range(*,3) = [0,180]
ct(3) = 2
			;
			;Read field strength data.
			;Set background to 127.
			;Scale and move the information to the byte image.
			;Display field strength image.
			;Display the negative image.
			;
tmp = read_floats( dir+'a_fld' )
aimage = fltarr(xdim*ydim,/nozero)
 terpol,tmp,whrsv
aimage(*) = -1.
aimage(sxy) = tmp
aimage = reform(aimage,xdim,ydim)
badcol,aimage
tmpmid = aimage(*,50:200)
fmax = min([3500.,max(tmpmid)])
ffmax = fix(fmax)
aimage = aimage > min(tmpmid) < fmax
; negate field strength if inclination gt 90 degrees
whr = where(im4 gt 90)
aimage(whr) = -aimage(whr) + 3500.
whr = where ( (im4 le 90) and (im4 ge 0) )
aimage(whr) = aimage(whr) + 3500.
;  store field strength image for color display, neg. values not fit
im2 = intarr(xdim,ydim)
im2 = fix(aimage)
im2(whrumb) = -2
tvscl,im2,1*xdim,1*ydim
range(*,1) = [0,7000]
ct(1) = 2

;  plot doppler velocity, 630.15 nm line
tmp = read_floats( dir+'a_cen2' )
 terpol,tmp,whrsv
aimage = fltarr(xdim*ydim,/nozero)
amean = total(tmp)/float(n_elements(tmp))
aimage(*) = amean
aimage(sxy) = tmp
aimage = reform(aimage,xdim,ydim)
badcol,aimage
tmpmid = aimage(*,50:200)
fmax = max(tmpmid)
;aimage = aimage > min(tmpmid) < fmax
aimage = aimage > 30. < 44.
aimage(whrumb) = 44.
tvscl,aimage,3*xdim,3*ydim


;----------------------------------------
; return images and their ranges

range1 = [ [0,xdim*.375], [0, ydim*.370] ]

;----------------------------------------


end

