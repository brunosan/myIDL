;+
; NAME:
;       FITSDATA
; PURPOSE:
;       Return a data set from a FITS file.
; CATEGORY:
; CALLING SEQUENCE:
;       fitsdata, file, data
; INPUTS:
;       file = Name of FITS file.        in 
; KEYWORD PARAMETERS:
;       Keywords: 
;         SET=s  data set number to return (def=1). 
;         NUMBER=n  data sets to read (def=1). 
;         /ONE_D interpret an image as multiple 1-d data sets. 
;	  /BBSOQD read a Big Bear Solar Observatory FITS image.
;	    Quantex and Datacube images.
;	  /BBSOEY read a Big Bear Solar Observatory FITS image.
;	    Eyecom images.
;         ERROR=e error flag.  0=ok, 1=file not found, 
;           2=data set number out of range, 3=other. 
; OUTPUTS:
;       data = returned data.            out 
; COMMON BLOCKS:
; NOTES:
;       Notes: If BSCALE and/or BZERO appear in the 
;         header they are applied to data. 
; MODIFICATION HISTORY:
;       R. Sterner, 4 Mar, 1990
;	R. Sterner, 6 Dec, 1990 --- added /BBSO
;-
 
	pro fitsdata, file, data, set=set, number=num, one_d=one_d, $
	   error=err, help=hlp, bbsoqd=bbsoqd, bbsoey=bbsoey
 
	if (n_params() lt 2) or keyword_set(hlp) then begin
	  print,' Return a data set from a FITS file.'
	  print,' fitsdata, file, data'
	  print,'   file = Name of FITS file.        in'
	  print,'   data = returned data.            out'
	  print,' Keywords:'
	  print,'   SET=s  data set number to return (def=1).'
	  print,'   NUMBER=n  data sets to read (def=1).'
	  print,'   /ONE_D interpret an image as multiple 1-d data sets.'
	  print,'   /BBSOQD read a Big Bear Solar Observatory FITS image.
	  print,'     Quantex and Datacube images.
	  print,'   /BBSOEY read a Big Bear Solar Observatory FITS image.
	  print,'     Eyecom images.
	  print,'   ERROR=e error flag.  0=ok, 1=file not found,'
	  print,'     2=data set number out of range, 3=other.'
	  print,' Notes: If BSCALE and/or BZERO appear in the'
	  print,'   header they are applied to data.'
	  return
	endif
 
	;---------  read header  -----------
	fitshdr, file, h, err=err	; Read FITS header into string array h.
	if err gt 0 then return		; File not opened error.
	nh = n_elements(h)/36		; Number of header blocks of 80 char.
 
	;---------  Get number, size, and type of data sets -------------
	nx = fitsnum(header=h, 'naxis1')	     ; Image x size.
	ny = fitsnum(header=h, 'naxis2', error=err)  ; Image y size.
	if err eq 1 then ny = 1			     ; No y axis, assume 1.
	nz = fitsnum(header=h, 'naxis3', error=err)  ; Number of images.
	if err eq 1 then nz = 1			     ; No z axis, assume 1.
	bits = fitsnum(header=h, 'bitpix')	     ; Image type: bits/pixel.
 
	;---------  1-d interpretation  -----------
	if keyword_set(one_d) then begin
	  nz = ny
	  ny = 1
	endif
 
	;---------  Which data set?  ------------------
	if n_elements(set) eq 0 then set=1	; If data set not given use 1.
	if (set lt 1) or (set gt nz) then begin	; Set number in range?
	  print,' Data set number out of range, must be from 1 to '+$
	    strtrim(fix(nz),2)
	  err=2					;   Set out of range error.
	  return
	endif
 
	;---------  How many data sets?  ------------------
	if n_elements(num) eq 0 then num=1	; If number not given use 1.
	if (num lt 1) or (num gt (nz+1-set)) then begin   ; In range?
	  print,' Number of data sets out of range, must be from 1 to '+$
	    strtrim(fix(nz+1-set),2)
	  err=2					;   Number out of range error.
	  return
	endif
 
	;---------  Set up array of correct type and shape  ----------
	if bits eq  8 then img = bytarr(nx, ny, num)	; Setup image type.
	if bits eq 16 then img = intarr(nx, ny, num)
	if bits eq 32 then img = lonarr(nx, ny, num)
 
	;--------  setup to read data set ---------
	openr, lun, file, /get_lun, /block	; Open FITS file to read.
	offset = nh*36*80			; For standard FITS.
	if keyword_set(bbsoqd) then begin	; BBSO FITS (Quantex/Datacube).
	  w = where(strtrim(h,2) eq 'END')	;  Find END in header.
	  nh = w(0)+1				;  Header line number with END.
	  offset = fix(ceil((nh*80)/512.))*512	;  Offset: bytes (512 b recs).
	endif
	if keyword_set(bbsoey) then begin	; Handle BBSO FITS (Eyecom).
	  w = where(strtrim(h,2) eq 'END')	;  Find END in header.
	  nh = w(0)				;  Header line number with END.
	  offset = fix(ceil((nh*80+4)/512.))*512   ;Offset: bytes (512 b recs).
	endif
	aa = assoc(lun, img, offset)		; Set up to read data.
 
	;--------  read data  ---------------------
	data = aa(set-1)			; Read data.
	close, lun
	free_lun, lun
 
	;-------  try to scale data  --------------
	bscale = fitsnum('bscale', error=err)
	if err eq 1 then bscale = 1.
	bzero = fitsnum('bzero', error=err)
	if err eq 1 then bzero = 0.
	if bscale ne 1. then data = data*bscale
	if bzero ne 0. then data = data + bzero
 
	err = 0
	return
	end
