pro put_nmap, nmap
;+
;
;	procedure:  put_nmap
;
;	purpose:  change the #_of_maps info in the op hdr common block
;
;	author:  rob@ncar, 5/94
;
;==============================================================================
;
;	Check number of arguments.
;
if n_params() ne 1 then begin
	print
	print, "usage:  put_nmap, nmap"
	print
	print, "	Change the #_of_maps info in the op hdr common block."
	print
	print, "	Arguments"
	print, "		nmap	 - number_of_maps value to insert"
	print
	print, "	Keywords"
	print, "		(none)"
	print
	return
endif
;-
;
;	Specify operation common block.
;
@op_hdr.com
;
;	Put number of maps.
;
nfstep = long(nmap)
;
end
