pro iquv_fits, infile, outfile
;+
;
;	procedure:  iquv_fits
;
;	purpose:  write out ASP operation I,Q,U,V in FITS format
;
;	author:  rob@ncar, 4/93
;
;	notes:  - routine 'fits_hdr' is below
;
;==============================================================================
;
;	Check number of arguments.
;
if n_params() ne 2 then begin
	print
	print, "usage:  iquv_fits, infile, outfile"
	print
	print, "	Write out ASP operation I,Q,U,V in FITS format."
	print
	print, "	Arguments"
	print, "		infile	   - name of input ASP file"
	print, "		outfile	   - name of output FITS file"
	print
	print, "	Keywords"
	print, "		(none)"
	print
	print
	print, "   ex:  ; Note you must '.run' the program first."
	print, "	.r iquv_fits"
	print, "	iquv_fits, '2.fab.cmap', '2.iquv.fits'"
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
maxval = 0.0
minval = 0.0
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

;	Process scan.
	ii = i / 2.0
	minval = minval < min(ii)
	maxval = maxval > max(ii)
	ii = fixr(ii)			; (rounding fix)

	qq = q / 2.0
	minval = minval < min(qq)
	maxval = maxval > max(qq)
	qq = fixr(qq)

	uu = u / 2.0
	minval = minval < min(uu)
	maxval = maxval > max(uu)
	uu = fixr(uu)

	vv = v / 2.0
	minval = minval < min(vv)
	maxval = maxval > max(vv)
	vv = fixr(vv)

;	Write fits header if first time thru loop.
	if iscan eq 0 then  fits_header, out_unit, ii, nscan

;	Write scan.
	writeu, out_unit, ii, qq, uu, vv

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

pro fits_header, out_unit, in_image, nscan, $
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
	hdr(*, 2) = byte('NAXIS   =                    4 ' + $
		'/ Images                                         ')
;
; 	Set matrix dimensions.
;
	naxis1 = sizeof(in_image, 1)
	naxis2 = sizeof(in_image, 2)
	naxis3 = 4
	naxis4 = nscan

	hdr(*, 3) = byte('NAXIS1  =                      ' + $
		'/ Wavelength                                     ') 

	hdr(*, 4) = byte('NAXIS2  =                      ' + $
		'/ Along slit                                     ') 

	hdr(*, 5) = byte('NAXIS3  =                      ' + $
		'/ I, Q, U, V                                     ') 

	hdr(*, 6) = byte('NAXIS4  =                      ' + $
		'/ Number of scans                                ') 

	n_1 = strlen(string(naxis1))
	n_2 = strlen(string(naxis2))
	n_3 = strlen(string(naxis3))
	n_4 = strlen(string(naxis4))
	hdr(10:9+n_1, 3) = byte(string(naxis1))
	hdr(10:9+n_2, 4) = byte(string(naxis2))
	hdr(10:9+n_3, 5) = byte(string(naxis3))
	hdr(10:9+n_4, 6) = byte(string(naxis4))
;
; 	Set header comments.
;
	if n_elements(comm_1) gt 0 then n_1=strlen(comm_1) else n_1=0
	if n_elements(comm_2) gt 0 then n_2=strlen(comm_2) else n_2=0
	if n_elements(comm_3) gt 0 then n_3=strlen(comm_3) else n_3=0
	if n_elements(comm_4) gt 0 then n_4=strlen(comm_4) else n_4=0
	ind=0
	if n_1 gt 0 then begin
		hdr(0:11+n_1,  7) = byte('COMM    = / '+ comm_1)  & ind=1
	endif else if n_2 gt 0 then begin
		hdr(0:11+n_2,  8) = byte('COMM    = / '+ comm_2)  & ind=2
	endif else if n_3 gt 0 then begin
		hdr(0:11+n_3,  9) = byte('COMM    = / '+ comm_3)  & ind=3
	endif else if n_4 gt 0 then begin
		hdr(0:11+n_4, 10) = byte('COMM    = / '+ comm_4)  & ind=4
	endif 
;
; 	Set header end.
;
	hdr(0:2, 7+ind) = byte('END')
;
;------------------------
; 
; 	Write the header.
; 
writeu, out_unit, hdr
return
end
