function strcam, dummy
;+
;
;	function:  strcam
;
;	purpose:  return camera string given ASP op header common block
;
;	author:  rob@ncar, 12/92
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 0 then begin
	print
	print, "usage:  ret = strcam()"
	print
	print, "	Return camera string given ASP op header common block."
	print
	return, 0
endif
;-

;
;	Specify operation common block.
;
@op_hdr.com
;
;	Make and return the camera string.
;
case det of
	0:	return, 'Camera A'
	1:	return, 'Camera B'
	else:	return, 'Camera ?'
endcase
end
