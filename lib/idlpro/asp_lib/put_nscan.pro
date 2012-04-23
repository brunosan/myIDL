pro put_nscan, nscan
;+
;
;	procedure:  put_nscan
;
;	purpose:  change the #_of_scans info in the op hdr common block
;
;	author:  rob@ncar, 6/92
;
;==============================================================================
;
;	Check number of arguments.
;
if n_params() ne 1 then begin
	print
	print, "usage:  put_nscan, nscan"
	print
	print, "	Change the #_of_scans info in the op hdr common block."
	print
	print, "	Arguments"
	print, "		nscan	 - number_of_scans value to insert"
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
;	Put number of scans.
;
case get_optype() of
	'Map':		nmstep   = long(nscan)
	'Cal':		cconfigs = long(nscan)
	'Filter':	nmstep   = long(nscan)
;	'Phase':					; type "Phase" unused
	'Flat':		cconfigs = long(nscan)
	'Tel':		nmstep   = long(nscan)
	'Ndflat':	cconfigs = long(nscan)

;			(NOTE: nfstep is # of frames)
	'Movie':	nmstep   = long(nscan)

	'Gain':		nmstep   = long(nscan)		; gain corrected
	'GainXT':	nmstep   = long(nscan)		;  "  "  + XT applied

	else:		begin
				print, 'operation_type error'
				stop
			end
endcase
;
end
