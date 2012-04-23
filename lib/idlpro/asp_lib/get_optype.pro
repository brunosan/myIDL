function get_optype, dummy
;+
;
;	function:  get_optype
;
;	purpose:  return a string containing the ASP operation type from
;		  op header common
;
;	author:  rob@ncar, 4/93
;
;==============================================================================
;
;	Check number of arguments.
;
if n_params() ne 0 then begin
	print
	print, "usage:  type = get_optype()"
	print
	print, "	Return a string containing the ASP operation type"
	print, "	from op header common."
	print
	print, "	Arguments"
	print, "		(none)"
	print
	print, "	Keywords"
	print, "		(none)"
	print
	print
	print, "   ex:  type = get_optype()"
	print
	return, ''
endif
;-
;
;	Return to caller if error.
;
on_error, 2
;
;	Set common blocks.
;
@op_hdr.com
;
;	Return operation type.
;
case optype of
	1:	return, 'Map'
	2:	return, 'Cal' 
	4:	return, 'Filter'
	8:	return, 'Phase'
	16:	return, 'Flat'
	32:	return, 'Tel'

	64:	return, 'Ndflat'	; new types added by David
	128:	return, 'Movie'

	256:	return, 'Gain'		; new types added by Rob
	512:	return, 'GainXT'

	else:	return, '(error)'
endcase
end
