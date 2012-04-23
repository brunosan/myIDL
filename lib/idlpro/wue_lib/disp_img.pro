;+
; NAME:
;       DISP_IMG
; PURPOSE:
;       Display an image from Big Bear Observatory 
; CATEGORY:
; CALLING SEQUENCE:
;       disp_img
; INPUTS:
; KEYWORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       T. Leighton, 13 Nov, 1990
;-
 
	pro disp_img, help=hlp
 
	if keyword_set(hlp) then begin
	  print,' Display an image from Big Bear Observatory' 
	  print,' disp_img'
	  return
	endif
 
rd:	
	print,' '
	file = ''
	read, 'Enter image file name: ', file
	if file eq '' then return
	on_ioerror, err
	openr,lu,file, /get_lun

	;---------  determine if header is BBSO or real FITS  -----------
	dot = "."
	dotpos = strpos(file,dot)
	ext = strmid(file,dotpos+1,3)

	;---------  read header  -----------
	if ext eq 'fts' then rd_fitshdr,lu,h else rd_bbsohdr,lu,h	; Read FITS header into string array h.
	nh = n_elements(h)
	if ext eq 'fts' then numhdr=nh/36 else numhdr=nh/7
 
	;---------  Get size of data sets -------------
	xsz = fitsnum('NAXIS1',header=h)
	ysz = fitsnum('NAXIS2',header=h)
	bits = fitsnum(header=h, 'bitpix')		; Image type: bits/pixel.

	;--------  setup to read data set ---------
	if ext eq 'fts' then off = numhdr*36*80 else off = numhdr*512  
	arr = assoc(lu,bytarr(xsz,ysz,/nozero),off) 
	print, ' '
	ch = ''

	;--------  display image  ----------
		aa = arr(0)
		if ext eq 'fts' then tvscl,aa else tvscl,aa,/order
		goto, done

err:	print,' File does not exist: ' + file
	goto, rd
done:
	free_lun,lu
	return
 
	end
