function get_version, dummy
;+
;
;	function:  get_version
;
;	purpose:  return the version number of the ASP file
;		  (from op header common)
;
;	author:  rob@ncar, 4/93
;
;==============================================================================
;
;	Check number of arguments.
;
if n_params() ne 0 then begin
	print
	print, "usage:  version = get_version()"
	print
	print, "	Return the version number of the ASP file"
	print, "	(from op header common)."
	print
	return, 0
endif
;-
;
;	Specify operation common block.
;
@op_hdr.com
;
;	Return the version number.
;
return, command > 100		; (if "command" is < 100, version is 100)
end
