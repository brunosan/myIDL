;+
; NAME:
;       FITSMINHDR
; PURPOSE:
;       Make a minimal FITS header for given data set.
; CATEGORY:
; CALLING SEQUENCE:
;       h = fitsminhdr(d)
; INPUTS:
;       d = data set.            in 
;         Floating arrays are converted to long, 
;         and BSCALE and BZERO are added to header. 
; KEYWORD PARAMETERS:
;       Keywords: 
;         /QUIET suppresses warning message for floating arrays. 
;         ERROR=err.  Error flag. 0=ok, 1=invalid data type,$
;           2=not array. 
; OUTPUTS:
;       h = resulting header.    out 
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 9 Mar, 1990
;-
 
	function fitsminhdr, d, help=hlp, error=err, quiet=q
 
	if (n_params() lt 1) or keyword_set(hlp) then begin
	  print,' Make a minimal FITS header for given data set.'
	  print,' h = fitsminhdr(d)'
	  print,'   d = data set.            in'
	  print,'     Floating arrays are converted to long,'
	  print,'     and BSCALE and BZERO are added to header.'
	  print,'   h = resulting header.    out'
	  print,' Keywords:'
	  print,'   /QUIET suppresses warning message for floating arrays.'
	  print,'   ERROR=err.  Error flag. 0=ok, 1=invalid data type,$
	  print,'     2=not array.'
	  return, -1
	endif
 
	bflag = 0		; Assume no bscale or bzero.
 
	typ = datatype(d)
	if not isarray(d) then d = array(d)
	case 1 of
(typ eq 'BYT'):	bitpix = 8
(typ eq 'INT'):	bitpix = 16
(typ eq 'LON'):	bitpix = 32
(typ eq 'FLO') or (typ eq 'DOU'):  begin
	  if not keyword_set(q) then $
	     print,' Warning in fitsminhdr: converting data to long.'
	  if max(abs(d)) eq 0. then begin
	    bscale = 1.
	    bzero = 0.	
	    d = [0l]
	    bitpix = 32
	    bflag = 1
	  endif else begin
	    p = 10.^fix(alog10(1e9/max(abs(d))))
	    d = long(p*d)
	    bscale = 1./p
	    bzero = 0.
	  endelse
	  bitpix = 32	; Now 32 bits (long).
	  bflag = 1
	end
else:	begin
	  print,' Error in fitsminhdr: invalid data type.'
	  print,'   Must be byte, integer, long, float, or double.'
	  err = 1
	  return, -1
	end
	endcase
 
	err = 0
	sz = size(d)
	naxis = sz(0)
	if naxis eq 0 then begin
	  print,' Error in fitsminhdr: data must be an array.'
	  err = 2
	  return, -1
	endif
 
	h = ['END']
	fitsputl, h, 'simple', 't'
	fitsputi, h, 'bitpix', bitpix
	fitsputi, h, 'naxis', naxis
	for i = 1, naxis do fitsputi, h, numname('naxis#',i), sz(i)
	if bflag eq 1 then begin
	  fitsputr, h, 'bscale', bscale, 'REAL = TAPE*BSCALE + BZERO'
	  fitsputr, h, 'bzero', bzero
	endif
 
;	h = string(bytarr(80,36)+32b)
;	h(0) = fitstxtl('simple','t')
;	h(1) = fitstxti('bitpix',bitpix)
;	h(2) = fitstxti('naxis',naxis)
;	for i = 1, naxis do h(2+i) = fitstxti(numname('naxis#',i),sz(i))
;	offset = naxis
;	if bflag eq 1 then begin
;	  h(3+naxis) = fitstxtr('bscale',bscale,'REAL = TAPE*BSCALE + BZERO')
;	  h(4+naxis) = fitstxtr('bzero',bzero)
;	  offset = offset + 2
;	endif
;	h(3+offset) = 'END'
 
	return, h
	end
