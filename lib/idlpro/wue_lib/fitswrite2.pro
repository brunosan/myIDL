;+
; NAME:
;       FITSWRITE2
; PURPOSE:
;       Write out a FITS data set.
; CATEGORY:
; CALLING SEQUENCE:
;       fitswrite2, file, h, [d]
; INPUTS:
;       file = FITS file name.                  in 
;       h = FITS header in a string array.      in 
;       d = data.  Must be byte, int, or long.  in 
;	  If d is not given only the header is updated.'
;	  In this case file must exist.'
; KEYWORD PARAMETERS:
;       Keywords: 
;         ERROR=err.  0=ok, 1=data type error, 1=file not opened.'
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 9 Mar, 1990
;-
 
	pro fitswrite2, file, h, d, help=hlp, error=err
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
 	  print,' Write out a FITS data set.'
	  print,' fitswrite2, file, h, [d]'
	  print,'   file = FITS file name.                  in'
	  print,'   h = FITS header in a string array.      in'
	  print,'   d = data.  Must be byte, int, or long.  in'
	  print,'     If d is not given only the header is updated.'
	  print,'     In this case file must exist.'
	  print,' Keywords:'
	  print,'   ERROR=err.  0=ok, 1=data type error, 2=file not opened.'
	  return
	endif
 

	;-------  check if header update  --------
	if n_params(0) eq 2 then begin
	  on_ioerror, err
	  get_lun, lun
	  openu, lun, file, /block
	  on_ioerror, null
	  goto, head
	endif

	;-------  check data type  -----------
	typ = datatype(d)
	case typ of
'BYT':	  b = 2880.
'INT':	  b = 1440.
'LON':	  b = 720.
else:	  begin
	    print,' Error in fitswrite2: data type must be'
	    print,'   Byte, Integer, or Long.'
	    err = 1
	    return
	  end
	endcase
 
	;---------  open file  ----------
	on_ioerror, err
	get_lun, lun
	openw, lun, file, /block
	on_ioerror, null
 
	;--------  write out header -------------
head:	lh = (n_elements(h)-1)/36		; Last header block.
	h2 = bytarr(80,36*(lh+1))+32b		; Setup complete header array.
	h2(0,0) = byte(h)			; Put given header into it.
	hh = assoc(lun, bytarr(80,36))
	for i = 0, lh do begin			; Write out header.
	  lo = i*36
	  hi = lo + 35
	  hh(i) = h2(*,lo:hi)
	endfor
	if n_params(0) eq 2 then begin
	  print,' Header updated.'
	  goto, done
	endif
 
	;--------  write out data  --------------
	off = (1+lh)*80*36l			; Offset to data.
	case typ of
'BYT':	  begin
	    rr = assoc(lun, bytarr(2880), off)
	    n = ceil(n_elements(d)/b)*b
	    d2 = bytarr(n)
	    d2(0) = d(0:*)
	  end
'INT':	  begin
	    rr = assoc(lun, intarr(1440), off)
	    n = ceil(n_elements(d)/b)*b
	    d2 = intarr(n)
	    d2(0) = d(0:*)
	  end
'LON':	  begin
	    rr = assoc(lun, lonarr(720), off)
	    n = ceil(n_elements(d)/b)*b
	    d2 = lonarr(n)
	    d2(0) = d(0:*)
	  end
	endcase
	for i = 0, fix((n_elements(d2)/b)-1) do begin
	  lo = i*b
	  hi = lo + b - 1
	  rr(i) = d2(lo:hi)
	endfor
 
done:	close, lun
	free_lun, lun
	print,' FITS file '+file+' complete.'
	err = 0
 
	return

err:	print,' Error in fitswrite2: could not open file '+file
	err = 2
	return

	end
