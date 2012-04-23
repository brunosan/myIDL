function writ_sc_data, filenum, ii, qq, uu, vv
;+
;
;	function:  writ_sc_data
;
;	purpose:  write ASP scan data into a file
;
;	author:  rob@ncar, 5/92
;
;==============================================================================
;
;	Check number of arguments.
;
if n_params() ne 5 then begin
	print
	print, "usage:  ret = writ_sc_data(filenum, i, q, u, v)"
	print
	print, "	Write ASP scan data into a file."
	print
	return, 1
endif
;-
;
;	Convert values from floating point to
;		I      - unsigned short
;		Q,U,V  - short
;	and write them out.
;	(Note that the dimensions of the raw data may have been
;	 truncated during processing.)
;
writeu, filenum, float2i(ii), fixr(qq), fixr(uu), fixr(vv)
;
;	Done.
;
return, 0
end
