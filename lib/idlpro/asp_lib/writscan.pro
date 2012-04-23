pro writscan, ounit, ii, qq, uu, vv, v101=v101
;+
;
;	procedure:  writscan
;
;	purpose:  write ASP scan (header and data) out to file
;
;	author:  rob@ncar, 1/93
;
;	notes:  - header is in common block from readscan or read_sc_hdr
;		- note that outfile *unit* is specified, not the file *name*
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 5 then begin
	print
	print, "usage:  writscan, ounit, ii, qq, uu, vv"
	print
	print, "	Write ASP scan (header and data) out to file."
	print
	print, "	Arguments"
	print, "	    ounit	- unit # of output file"
	print, "	    ii,qq,uu,vv	- floating point data"
	print
	print, "	Keywords"
	print, "	    v101	- set to force version 101"
	print, "		          (def=use version # in op hdr)"
	print
	return
endif
;-
;
;	Specify common blocks.
;
@op_hdr.com
@scan_hdr.com
;
;	Set version number ('get_version' uses operation header).
;
if keyword_set(v101) then version = 101  else  version = get_version()
;
;	Write scan header.
;
if writ_sc_hdr(ounit, version=version) eq 1 then begin
	print
	print, 'Error writing scan header in "writ_sc_hdr"'
	print
	return
endif
;
;	Write scan data.
;
if writ_sc_data(ounit, ii, qq, uu, vv) eq 1 then begin
	print
	print, 'Error writing scan data in "writ_sc_data"'
	print
	return
endif
;
end
