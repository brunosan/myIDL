function is_raw, dummy
;+
;
;	function:  is_raw
;
;	purpose:  return 1 if 'raw' ASP data, else return 0 (uses op header)
;
;		  	NOT-'raw' = Gain, GainXT
;		  	    'raw' = Map, Cal, Filter, ...
;
;	author:  rob@ncar, 4/93
;
;	note:  - assumes valid operation type in op header
;
;==============================================================================
;
;	Check number of arguments.
;
if n_params() ne 0 then begin
	print
	print, "usage:  ret = is_raw()"
	print
	print, "	Return 1 if 'raw' ASP data, else return 0"
	print, "	(uses op header)."
	print
	print, "	Arguments"
	print, "		(none)"
	print
	print, "	Keywords"
	print, "		(none)"
	print
	print
	print, "   ex:  ... read_op_hdr ...	; read operation header"
	print, "	if is_raw() then .....	; operate on raw data"
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
;	Get operation type.
;
type = get_optype()
;
;	Return 'raw' status.
;
case type of
	'Gain':		return, 0		; not raw
	'GainXT':	return, 0		; not raw

	else:		return, 1		; raw
endcase
end
