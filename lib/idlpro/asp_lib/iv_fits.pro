pro iv_fits, infile, outfile, flip=flip, few_scan=few_scan, type=type
;+
;
;	procedure:  iv_fits
;
;	purpose:  write out ASP operation I,V in FITS format
;
;	author:  rob@ncar, 4/93
;
;	notes:  - see routine 'fits_hdr' below
;
;	ex:
;	.r iv_fits
;	iv_fits, '~/xt/17/7.xt.map', '~/fits/17_07.iv.wy'
;	iv_fits, '~/xt/17/7.xt.map', '~/fits/17_07.iv.yw', /flip
;
;==============================================================================
;
;	Check number of arguments.
;
if n_params() ne 2 then begin
	print
	print, "usage:  iv_fits, infile, outfile"
	print
	print, "	Write out ASP operation I,V in FITS format."
	print
	print, "	Arguments"
	print, "		infile	   - input ASP file name"
	print, "		outfile	   - output FITS file name"
	print
	print, "	Keywords"
	print, "		flip	   - flip order of Y and wavelength"
	print, "		few_scan   - number of scans (def=all)"
	print, "		type       - type of output"
	print, "				0 = I+V and I-V (def)"
	print
	print
	print, "   ex:  iv_fits, '2.fab.cmap', '2.iv.fits'"
	print
	return
endif
;-
;
;	Set general parameters.
;
on_error, 2		; return to caller if error
true = 1
false = 0
do_flip = false
if keyword_set(flip) then do_flip = true
maxval = 0.0
minval = 0.0
if n_elements(type) eq 0 then type = 0
;
;	Set common blocks.
;
@op_hdr.com
@op_hdr.set
;
;	Open input and output units.
;
openr, in_unit, infile, /get_lun
openw, out_unit, outfile, /get_lun
;
;	Read op header.
;
if read_op_hdr(in_unit, -1, 0) eq 1 then $
	message, 'Error reading op header in "read_op_hdr".'
;
;	Get number of scans from op header common.
;
nscan = get_nscan()
if n_elements(few_scan) ne 0 then nscan = few_scan
;
;-----------------------------------------
;
;	PROCESS EACH SCAN.
;
print
for iscan = 0, nscan - 1 do begin

;	Read scan.
	print, 'scan ' + stringit(iscan)
	readscan, infile, iscan, i, q, u, v, /nohead

;	Optionally flip Y & wavelength.
	if do_flip then begin
		i = transpose(i)
		q = transpose(q)
		u = transpose(u)
		v = transpose(v)
	endif

;	Process scan.
	case type of

	  0:  begin
		temp = (i + v)/2.0		; I + V
		minval = minval < min(temp)
		maxval = maxval > max(temp)
		ipv = fixr(temp)		; (rounding fix)
		temp = (i - v)/2.0		; I - V
		minval = minval < min(temp)
		maxval = maxval > max(temp)
		imv = fixr(temp)
	      end

	  else:  begin

			message, '"type" error'

	         end

	endcase

;	Write fits header if first time thru loop.
	if iscan eq 0 then begin
		fits_header, out_unit, ipv, nscan, do_flip
	endif

;	Write scan.
	writeu, out_unit, ipv, imv

endfor
print
;
;-----------------------------------------
;
;	Print ranges of numbers.
;
print, 'minimum value:  ' + stringit(minval)
print, 'maximum value:  ' + stringit(maxval)
if (minval lt -32768.0) or (maxval gt 32767.0) then $
	message, 'numbers are too big for 2-byte integer output'
print
;
;	Close files and free unit numbers.
;
free_lun, in_unit, out_unit
;
end

;------------------------------------------------------------------------------
;------------------------------------------------------------------------------

pro fits_header, out_unit, in_image, nscan, do_flip, $
	comm1=comm_1, comm2=comm_2, comm3=comm_3, comm4=comm_4
;
;	Write FITS header.
;
; Inputs:
;	in_image	- input 2D array for size and type purposes
;	nscan		- number of scans
;
; Output:
;	out_unit	- unit for output FITS file
;		
;------------------------------------------------------------------------------

on_error, 1	; on error it returns to the main program level

escala = 1.1d9

;
;	Create the header array.
;
hdr = bytarr(80, 36)
;
;------------------------
;
;	Fill the header.
;
;------------------------
;
; 	Set general information.
;
	hdr(*, 0) = byte('SIMPLE  =                    T ' + $
		'/ Standard FITS                                  ') 
	hdr(*, 1) = byte('BITPIX  =                   16 ' + $
		'/ 16 bits integer with sign per pixel            ')
	hdr(*, 2) = byte('NAXIS   =                    3 ' + $
		'/ Images                                         ')
;
; 	Set matrix dimensions.
;
	naxis1 = sizeof(in_image, 1)
	naxis2 = sizeof(in_image, 2) * 2
	naxis3 = nscan
	if do_flip then begin
		hdr(*, 3) = byte('NAXIS1  =                      ' + $
			'/ Along slit                                     ') 
		hdr(*, 4) = byte('NAXIS2  =                      ' + $
			'/ Wavelength                                     ') 
	endif else begin
		hdr(*, 3) = byte('NAXIS1  =                      ' + $
			'/ Wavelength                                     ') 
		hdr(*, 4) = byte('NAXIS2  =                      ' + $
			'/ Along slit                                     ') 
	endelse
	hdr(*, 5) = byte('NAXIS3  =                      ' + $
		'/ Number of scans                                ') 
	n_1 = strlen(string(naxis1))
	n_2 = strlen(string(naxis2))
	n_3 = strlen(string(naxis3))
	hdr(10:9+n_1,3) = byte(string(naxis1))
	hdr(10:9+n_2,4) = byte(string(naxis2))
	hdr(10:9+n_3,5) = byte(string(naxis3))
;
; 	Set header comments.
;
	if n_elements(comm_1) gt 0 then n_1=strlen(comm_1) else n_1=0
	if n_elements(comm_2) gt 0 then n_2=strlen(comm_2) else n_2=0
	if n_elements(comm_3) gt 0 then n_3=strlen(comm_3) else n_3=0
	if n_elements(comm_4) gt 0 then n_4=strlen(comm_4) else n_4=0
	ind=0
	if n_1 gt 0 then begin
		hdr(0:11+n_1, 6) = byte('COMM    = / '+comm_1) & ind=1
	endif else if n_2 gt 0 then begin
		hdr(0:11+n_2, 7) = byte('COMM    = / '+comm_2) & ind=2
	endif else if n_3 gt 0 then begin
		hdr(0:11+n_3, 8) = byte('COMM    = / '+comm_3) & ind=3
	endif else if n_4 gt 0 then begin
		hdr(0:11+n_4, 9) = byte('COMM    = / '+comm_4) & ind=4
	endif 
;
; 	Set header end.
;
	hdr(0:2, 6+ind) = byte('END')
;
;------------------------
; 
; 	Write the header.
; 
writeu, out_unit, hdr
return
end
