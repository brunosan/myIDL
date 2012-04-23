function get_nmap, dummy
;+
;
;	function:  get_nmap
;
;	purpose:  return the number of maps in the ASP file
;
;	author:  rob@ncar, 5/94
;
;==============================================================================
;
;	Check number of arguments.
;
if n_params() ne 0 then begin
	print
	print, "usage:  ret = get_nmap()"
	print
	print, "	Return the number of maps in the ASP file."
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
	'Map':		nmap = nfstep > 1
	'Cal':		nmap = 1
	'Filter':	nmap = 1
;	'Phase':					; type "Phase" unused
	'Flat':		nmap = 1
	'Tel':		nmap = 1

	'Ndflat':	nmap = 1			; types added by David
	'Movie':	nmap = nfstep > 1

	'Gain':		nmap = nfstep > 1		; gain corrected
	'GainXT':	nmap = nfstep > 1		;  "  "  + XT applied

	else:		begin
				print, 'operation_type error'
				stop
			end
endcase
;
;	Return number of scans.
;
return, nmap
end
