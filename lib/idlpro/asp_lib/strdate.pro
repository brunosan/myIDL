function strdate, dummy
;+
;
;	function:  strdate
;
;	purpose:  return date string given ASP op header common block
;
;	author:  rob@ncar, 12/92
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 0 then begin
	print
	print, "usage:  ret = strdate()"
	print
	print, "	Return date string given ASP op header common block."
	print
	return, 0
endif
;-

;
;	Specify operation common block.
;
@op_hdr.com
;
;	Make and return the date string.
;
return, stringit(month) + '/' + stringit(day) + '/' + stringit(year)
end
