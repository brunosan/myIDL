function get_nscan, dummy
;+
;
;	function:  get_nscan
;
;	purpose:  return the number of scans in the ASP file
;
;	author:  rob@ncar, 4/92
;
;==============================================================================
;
;	Check number of arguments.
;
if n_params() ne 0 then begin
	print
	print, "usage:  ret = get_nscan()"
	print
	print, "	Return the number of scans in the ASP file."
	print
	return, 0
endif
;-
;
;	Specify operation common block.
;
@op_hdr.com
;
;	Get number of scans.
;
case get_optype() of
	'Map':		nscan = nmstep
	'Cal':		nscan = cconfigs
	'Filter':	nscan = nmstep
;	'Phase':					; type "Phase" unused
	'Flat':		nscan = cconfigs
	'Tel':		nscan = nmstep
	'Ndflat':	nscan = cconfigs
	'Movie':	nscan = nfstep * nmstep
	'Gain':		nscan = nmstep			; gain corrected
	'GainXT':	nscan = nmstep			;  "  "  + XT applied 

	else:		begin
				print, 'operation_type error'
				stop
			end
endcase
;
;	Return number of scans.
;
return, nscan
end
