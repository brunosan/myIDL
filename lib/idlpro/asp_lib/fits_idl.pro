function fits_idl, infile, swap=swap, nohead=nohead
;+
;
;	function:  fits_idl
;
;	purpose:  read a FITS file into an IDL array
;
;	author:  Jorge Sanchez (IAC, 1/92), and Rob Montgomery (HAO)
;
;	mods:  - code simplified and comments added
;	       - reads until 'END' header line
;	         (used to always read 36 lines of "header")
;
;==============================================================================
;
;       Check number of parameters.
;
if n_params() eq 0 then begin
	print
	print, "usage:  out_image = fits_idl(infile)"
	print
	print, "	Arguments"
	print, "		infile	- name of input FITS file"
	print
	print, "	Keywords"
	print, "		swap	- if set, byte swap (def=don't swap)"
	print, "		nohead	- if set, don't print header"
	print
	print
	print, "   ex:  im = fits_idl('file.fits', /nohead)"
	print
	return, 0
endif
;-
;
;	Set general parameters.
;
true = 1
false = 0
bscale = 1.0		; default
bzero = 0.0		; default
lines_rec = 36		; 2880 byte records / 80 chars = 36 lines/record
print_head = true
if keyword_set(nohead) then print_head = false
;
;	Open the input file
;
openr, unit, infile, /get_lun
;
;	Read first header record.
;
hdr = bytarr(80, lines_rec)
readu, unit, hdr
;
;	Read additional header records if present;
;	optionally print header.
;
final = 0

again:
  j = 0
  more = true
  end_found = false

  while (not end_found) and (more) do begin 
;
;	Get and optionally print line.
	line = hdr(*, j + final)
	if print_head then print, string(line)
;
;	Check if END record | increment counter.
	if (string(line(0:2)) eq 'END') then end_found = true $
					else j = j + 1
;	See if checked all lines.
	if j eq lines_rec then more = false
;
  endwhile

  if not end_found then begin
	hdr2 = bytarr(80, lines_rec)
	readu, unit, hdr2
	hdr = [ [hdr], [hdr2] ]
	final = final + lines_rec
	goto, again
  endif else begin
	final = final + j
  endelse
;
;	Read the basic parameters that define the image from the header.
;
print
print, 'input = ' + infile
for j = 0, final do begin
;
	case (string(hdr(0:5,j))) of
;
;	   Standard FITS ?
	   'SIMPLE': $
		begin
		pos = strpos(string(hdr(*, j)), '/')
		std = strtrim(hdr(10:pos-1, j), 2) 
		if (std ne 'T') then print, 'format = non-standard FITS' $
				else print, 'format = standard FITS'
		end
;
;	   Number of bytes per pixel.
	   'BITPIX': $
		begin
		pos = strpos(string(hdr(*, j)), '/')
		bitpix = fix(string(hdr(10:pos-1, j))) 
		end
;
;	   Scales of the format.
	   'BSCALE': $
		begin
		pos = strpos(string(hdr(*, j)), '/')
		bscale = float(string(hdr(10:pos-1, j))) 
		end
;
	   'BZERO': $
		begin
		pos = strpos(string(hdr(*, j)), '/')
		bzero = float(string(hdr(10:pos-1, j))) 
		end
;
;	   Dimensions of the image.
	   'NAXIS1': $
		begin
		pos = strpos(string(hdr(*, j)), '/')
		naxis1 = float(string(hdr(10:pos-1, j))) 
		end
;
	   'NAXIS2': $
		begin
		pos = strpos(string(hdr(*,j)), '/')
		naxis2 = float(string(hdr(10:pos-1, j))) 
		end
;
	   else: $
		begin
		end
	endcase
endfor
;
;	Print variables.
;
print, 'header lines = ' + stringit(final + 1)
print, 'bits/pixel = ' + stringit(bitpix)
print, 'bscale = ' + stringit(bscale)
print, 'bzero = ' + stringit(bzero)
print, 'naxis1 = ' + stringit(naxis1)
print, 'naxis2 = ' + stringit(naxis2)
print
;
;	Set up the image array.
;
if (bitpix eq 16) then begin 
	data = intarr(naxis1, naxis2)

endif else if(bitpix eq 32) then begin 
	data = lonarr(naxis1, naxis2)

endif else begin
	stop, stringit(bitpix) + ' bits/pixel is not supported' 

endelse
;
;	Read the image;
;	close input file and free unit number.
;
readu, unit, data
free_lun, unit
;
;	Optionally swap bytes;
;	scale the data to floating point.
;
if keyword_set(swap) then byteorder, data
data = float(data) * bscale + bzero
;
;	Return the array.
;
return, data
end
