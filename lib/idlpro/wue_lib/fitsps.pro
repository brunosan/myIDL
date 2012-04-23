;+
; NAME:
;       FITSPS
; PURPOSE:
;       Display a FITS data set and its header on a Postscript printer.
; CATEGORY:
; CALLING SEQUENCE:
;       fitsps, file
; INPUTS:
;       file = FITS file to display.       in 
; KEYWORD PARAMETERS:
;       Keywords: 
;         SET=n  data set number in FITS file. 
;         PRINTER=p  select postscript printer number (0=def). 
;         /ONE_D forces multiple 1-d data sets to be interpreted 
;           as 1-d data instead of an image. 
;         XFACTOR=xf  for images, factor to increase x size by. 
;         YFACTOR=yf  for images, factor to increase y size by. 
;         ERROR=err  error flag: 0=ok, 1=not FITS file, 2=file not found, 
;           3=data set number out of range. 
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: 1-d or 2-d data may be displayed.  Multiple 1-d data 
;         sets will be displayed as an image.  
;         XFACTOR and YFACTOR do nearest neighbor interpolation. 
;         Only one factor is needed. 
; MODIFICATION HISTORY:
;       R. Sterner, 28 Aug, 1989.
;       R. Sterner, 7 Mar, 1990 --- generalized.
;	R. Sterner, 7 Jun, 1990 --- fixed printer number.
;-
 
	pro fitsps, file, help=hlp, set=set0, printer=pr, one_d=one_d,$
	  xfactor=xfactor, yfactor=yfactor, error=errps
 
	if (n_params(0) lt 1) or keyword_set(hlp) then begin
	  print,' Display a FITS data set and header on a Postscript printer.'
	  print,' fitsps, file'
	  print,'   file = FITS file to display.       in'
	  print,' Keywords:'
	  print,'   SET=n  data set number in FITS file.'
	  print,'   PRINTER=p  select postscript printer number (0=def).'
	  print,'   /ONE_D forces multiple 1-d data sets to be interpreted'
	  print,'     as 1-d data instead of an image.'
	  print,'   XFACTOR=xf  for images, factor to increase x size by.'
	  print,'   YFACTOR=yf  for images, factor to increase y size by.'
	  print,'   ERROR=err  error flag: 0=ok, 1=not FITS, 2=not found,'
	  print,'     3=data set number out of range.'
	  print,' Notes: 1-d or 2-d data may be displayed.  Multiple 1-d data'
	  print,'   sets will be displayed as an image.' 
	  print,'   XFACTOR and YFACTOR do nearest neighbor interpolation.'
	  print,'   Only one factor is needed.'
	  return
	endif
 
	if n_elements(pr) eq 0 then pr = 0
 
	set = 1
	if n_elements(set0) ne 0 then set = set0	; Which data set?
	nax = fitsnum(file=file, 'naxis', error=err)	; Data set dimension.
	
	;---------  check for errors  -------------
	if err eq 1 then begin
	  print,' Error: file is not a FITS file.'
	  errps = 1
	  return
	endif
	if err eq 3 then begin
	  print,' Error: file not found.'
	  errps = 2
	  return
	endif
	if err ne 0 then begin
	  print,' Error: file is not a FITS file.'
	  errps = 1
	  return
	endif
 
	;-----------  images  ----------------------
	if nax gt 1 then begin
	  if keyword_set(one_d) then goto, oned
	  nz = fitsnum(file=file,'naxis3', error=err)	; # images.
	  if err eq 1 then nz = 1
	  if err gt 1 then begin
	    bell
	    print,' Unknown error in fitsps.'
	    return
	  endif
	  if set gt nz then begin
	    print,' Error in fitsps: requested image number is greater'
	    print,'   then last image number (= '+strtrim(fix(nz),2)+').'
	    print,'   FITS display aborted.'
	    errps = 3
	    return
	  endif
	  set = fix(set)
	  txt = 'FITS file = '+file+'.  Image number '+strtrim(set,2)
	  fitshdr, file, hdr				; Read FITS header.
	  print,' Reading image . . .'
	  fitsdata, file, img, set=set			; Read FITS image.
	  sz = size(img)
	  ;-----  check if image too big  ---------
	  if sz(1) gt 512 then begin
	    print,' Image too big, shrinking . . .'
	    img = congrid(img, 512, sz(2)*512./sz(1))
	  endif
	  sz = size(img)
	  if sz(2) gt 512 then begin
	    print,' Image too big, shrinking . . .'
	    img = congrid(img, sz(1)*512./sz(2), 512)
	  endif
	  xf = 1.				; Setup for size change.
	  if n_elements(xfactor) gt 0 then begin
	    xf = xfactor
	    txt = txt + '.  X size multiplied by '+strtrim(xf,2)
	  endif
	  yf = 1.
	  if n_elements(yfactor) gt 0 then begin
	    yf = yfactor
	    txt = txt + '.  Y size multiplied by '+strtrim(yf,2)
	  endif
	  sz = size(img)
          img = congrid(img, xf*sz(1), yf*sz(2))
	  print,' Display on Postscript printer '+txt+'.'
	  print,' Displaying image . . .'
	  imagesize, 16., 10.667, img, xout, yout
	  psinit, pr, /full, /quiet	; Redirect to postscript printer.
	  tv, ls(img,0.5,0.5,lo,hi), /cent, 1, 14, xsize=xout, ysize=yout
	  xyouts, .05, .53, txt+'.  Image scaled from '+$
	    strtrim(lo,2)+' to '+strtrim(hi,2), /normal, size=.6 ; Label image.
	;------------  1-d data  -------------------
	endif else begin
oned:	  ny = fitsnum(header=hdr,'naxis2')
	  if set gt ny then begin
	    print,' Error in fitsps: requested data set number is greater'
	    print,'   then last data set number (= '+strtrim(fix(ny),2)+').'
	    print,'   FITS display aborted.'
	    errps = 3
	    return
	  endif
	  set = fix(set)
	  txt = 'FITS file = '+file+'.  Data set number '+strtrim(set,2)
	  fitshdr, file, hdr				; Read FITS header.
	  fitsdata, file, data, /one_d, set=set, error=err  ; Read FITS data.
	  print,' Display on Postscript printer '+txt+'.'
	  print,' Displaying data . . .'
	  psinit, pr, /full 	; Redirect to postscript printer.
	  plot, data, position=[.1,.6,.9,.94]
	  xyouts, .05, .53, txt+'.', /normal, size=.6
	endelse
 
	;-----------  list header  -------------------
	print,' Listing header . . .'
	x = 0.05 & y = 0.498  & dy = .014 & i = 0 & l = 0
loop:	t = strtrim(hdr(i),2)			; FITS header record # i.
	if t ne '' then begin			; Only list non-null lines.
	  t = strcompress(t)			;   Eliminate excess space.
	  xyouts, x, y, t, /normal, size=.6	;   List line.
	  y = y - dy				;   Move down one line.
	  l = l + 1				; Count listed line.
	endif
	i = i + 1				; Inc header rec number.
	if l eq 34 then begin			; First column of text full?
	  x = .55				;   Yes, move to second column.
	  y = .498				;   Move to top of column.
	endif
	if l ge 68 then begin			; Out of space?
	  xyouts, x, y, ' . . .', /normal, size=.6 ; Yes, indicate missing txt.
	  goto, skip
	endif
	if strupcase(strmid(t,0,3)) ne 'END' then goto, loop ; Look for END.
 
skip:	xyouts, .05, 0.0, systime(), /normal, size=.6	; Label display time.
 
	psterm					; Send image to printer.
 
	errps = 0
	return
	end
