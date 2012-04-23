pro buildgn, ixst, iyst, ihst, ihend, ilo, ihi, $
	savefile=savefile, verbose=verbose
;+
;
;  Procedure:  buildgn
;
;  Purpose:  Build the pixel-by-pixel gain table for application to
;            ASP data.  This procedure uses the data from the neutral
;	     density filter measurements to obtain the response of each
;            pixel to varying light level.  The output gaintable should
;	     be applied only to data that is dark-subtracted and which
;	     has had the rgb gain correction applied (routine ofstcn.pro).
;	     The output of this is intended to be used with the
;	     interpolatory routine gncorr.pro.
;
;  Inputs:  ixst      = starting index for X (using 15 for 3/92 data)
;	    iyst      = starting index for Y (using 15 for 3/92 data)
;	      (to define active area of array and avoid vignetting at bottom)
;
;	    ihst      =  Y index after 1st hairline   (using 20 for 3/92 data)
;	    ihend     =  Y index before 2nd hairline  (using 215 for 3/92 data)
;	    ilo       =  lower limit spectrum index for profile shift test
;		         (using 40 for 3/25/92 6302 run, sharp telluric line)
;	    ihi       =  upper limit spectrum index for profile shift test
;			 (using 75 for 3/25/92 6302 run, sharp telluric line)
;
;  Output:  save file containing (avgprof, fitshft, gaintbl)
;
;  Note:  variables still hardwired in this code
;	  (e.g., clrnam, drknam, ndnam, etc.)  -Rob
;
;	WARNING - 'ixst' assumes wavelengths have NOT been flipped !!!
;
;==============================================================================

if n_params() ne 6 then begin
	print
	print, "usage:  buildgn, ixst, iyst, ihst, ihend, ilo, ihi"
	print
	print, "	Build the pixel-by-pixel gain table for application"
	print, "	to asp data.  This procedure uses the data from the"
	print, "	neutral density filter measurements to obtain the"
	print, "	response of each pixel to varying light level.  The"
	print, "	output gaintable should be applied only to data that"
	print, "	is dark-subtracted and which has had the rgb gain"
	print, "	correction applied (routine ofstcn.pro).  The output"
	print, "	of this is intended to be used with the interpolatory"
	print, "	routine gncorr.pro."
	print
	print, "	Arguments"
	print, "	    (see ~stokes/src/idl/buildgn.pro)"
	print
	print, "	Keywords"
	print, "	    savefile	- name of output IDL save file"
	print, "			  (def='gaintable.save')"
	print, "	    verbose	- if set, print run-time information"
	print, "			  (def=don't print it)"
	print
	return
endif
;-
;
;	Set general parameters.
;
true = 1
false = 0
do_verb = false
if keyword_set(verbose) then do_verb = true
if n_elements(savefile) eq 0 then savefile = 'gaintable.save'


;  array containing names of clear image files
clrnam = ['clear.a.19','clear.a.18','clear.a.17','clear.a.16','clear.a.15']

;  array containing names of dark image files
drknam = ['dark.a.19','dark.a.18','dark.a.17','dark.a.16','dark.a.15']

;  array containing names of nd image files
ndnam = ['a.nd.2.0','a.nd.1.8','a.nd.1.6','a.nd.1.4','a.nd.1.2',  $
         'a.nd.1.0','a.nd.8','a.nd.6','a.nd.4','a.nd.2']

;  array for storing average intensity of active area of clear images
nclear = n_elements(clrnam)
clrav=fltarr(nclear)

;  array for storing average intensity of active area of nd images
num_nd = n_elements(ndnam)
ndav=fltarr(num_nd)

;  define array for series of average intensities
series = fltarr(4,nclear)

;-------------------------------------
;
;	Loop over all sets of nd filter cycles, starting with darkest.
;
for k = 0, nclear-1 do begin

;  recover the clear, dark images
	restore,clrnam(k)
	ia=clear
	restore,drknam(k)
	da=dark

;  get dimensions of arrays
	nx = sizeof(ia, 1)
	ny = sizeof(ia, 2)
	nx1 = nx-1
	ny1 = ny-1

;  get raw averages for series
	series(0,k) = mean(ia(ixst:nx1,iyst:ny1))
	series(1,k) = mean(da(ixst:nx1,iyst:ny1))

;  subtract dark from Stokes I image
	ia = ia-da

;  array for storage of the pixel-by-pixel dependent variables
;  first point is assumed zero input, zero output, and clear
;  port is used for final input value so that there are
;  12 values for the independent variable (the first 12 positions
;  of the array), and 12 values for the dependent variable (the
;  next 12 positions of the array) at each pixel.  Curve is assumed
;  to be linear above the highest intensity
	if k eq 0 then begin
		gaintbl=fltarr(12,2,nx,ny)
	endif

;  get ideal spectral image without defects, mean image intensity
	shslit, ia, ilo, ihi, shft, shfit, avgprf, clrsp, $
		ixst, ihst, ihend, verbose=do_verb

;  correct the clear port image for residual rgb variations
	ofstcn,ia

;  determine mean of active area of image
	clrav(k) = mean(ia(ixst:nx1,iyst:ny1))
	print,' mean of clear image for set no.',k,' =',clrav(k)

;  recover images for nd scans, starting with darkest (nd=2)
	k2 = k*2
	k2p1 = k2 + 1
	restore,ndnam(k2)
	ia2=iav
	restore,ndnam(k2p1)
	ia4=iav

;  get raw averages for series
	series(2,k) = mean(ia2(ixst:nx1,iyst:ny1))
	series(3,k) = mean(ia4(ixst:nx1,iyst:ny1))
  
;  dark-correct nd images
	ia2 = ia2 - da
	ia4 = ia4 - da

;  correct the nd filter data for residual rgb variation
	ofstcn,ia2
	ofstcn,ia4

;  determine mean of active area of the nd image
	ndav(k2) = mean(ia2(ixst:nx1,iyst:ny1))
	ndav(k2p1) = mean(ia4(ixst:nx1,iyst:ny1))
	print,' mean of nd image for set no.',k,' =',ndav(k2),ndav(k2p1)

;  insert into dependent (ordinate) variable array: ideal image scaled by
;  relative average intensity 
;	gaintbl(k2+1,1,*,*) = clrsp*ndav(k2)/clrav(k)
;	gaintbl(k2p1+1,1,*,*) = clrsp*ndav(k2p1)/clrav(k)
;  leave gain table without renormalization
	gaintbl(k2+1,1,*,*) = clrsp*ndav(k2)
	gaintbl(k2p1+1,1,*,*) = clrsp*ndav(k2p1)

;  insert dark-corrected nd images into independent (abcissa) variable array
	gaintbl(k2+1,0,*,*) = ia2
	gaintbl(k2p1+1,0,*,*) = ia4
;
endfor
;  end large loop over data values
;-------------------------------------

;  insert origin point for data
gaintbl(0,0,*,*) = 0.
gaintbl(0,1,*,*) = 0.

;  insert final (clear port) data point
;  use clear avg closest to clearest nd filters
gaintbl(11,0,*,*) = ia
gaintbl(11,1,*,*) = clrsp*clrav(nclear-1)

kbad = 0
print,' start correction of gaintable for nonmonotonic stuff'
; correct gaintable abcissa to be monotonic
for j = 0,ny1 do for i = 0,nx1 do begin
  for l = 1,11 do begin
    if gaintbl(l,0,i,j) le gaintbl(l-1,0,i,j) then begin
       kbad = kbad+1
       gaintbl(l,0,i,j) = gaintbl(l-1,0,i,j)*1.00001
    endif
  endfor
endfor
print,' finished correction, # nonmonotonic pts =',kbad

;	save the average nd profile (avgprof), smoothed shifts 
;	along the slit, and gain tables
fitshft = shfit
avgprof = avgprf
print
print, 'Saving (avgprof,fitshft,gaintbl) to file ' + savefile + ' ...'
print
save,avgprof,fitshft,gaintbl,filename=savefile

end
