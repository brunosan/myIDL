pro put_version, version
;+
;
;	procedure:  put_version
;
;	purpose:  change the version info in the op hdr common block
;
;	author:  rob@ncar, 5/94
;
;==============================================================================
;
;	Check number of arguments.
;
if n_params() ne 1 then begin
	print
	print, "usage:  put_version, version"
	print
	print, "	Change the version info in the op hdr common block."
	print
	print, "	Arguments"
	print, "		version	 - version number"
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
;	Put version number.
;
command = long(version)
;
end
