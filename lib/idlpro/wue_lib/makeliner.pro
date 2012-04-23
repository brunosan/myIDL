;+
; NAME:
;       MAKELINER
; PURPOSE: 
;       Generating new idlv2.one file
; CALLING SEQUENCE;
;       makeliner, q
; INPUTS:
; KEYWIORD PARAMETERS:
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
: MODIFICATION HISTORY:
;       R. Sterner, 20 Jul, 1990
;- 

	pro makeliner, q

	timer, /start

	print,' Generating new idlv2.one file'
	print,' Finding file names . . .'
	name = filename('IDLUSR','*.pro')
	f = findfile(name)
	n = n_elements(f)
	print,' Number of files = '+strtrim(n,2)

	print,' Making idlv2.one file . . .'

	if !version.os eq 'vms' then begin
	  spawn,'delete idlv2.one;*'
	endif

	for i = 0, n-1 do extracthlp,'idlv2.one',f(i), /liner, /listfile

	bell
	timer,/stop,/print

	return
	end
