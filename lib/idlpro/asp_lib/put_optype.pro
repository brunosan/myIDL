pro put_optype, type
;+
;
;	procedure:  put_optype
;
;	purpose:  put new operation type in op header common
;
;	author:  rob@ncar, 4/93
;
;==============================================================================
;
;	Check number of arguments.
;
if n_params() ne 1 then begin
	print
	print, "usage:  put_optype, type"
	print
	print, "	Put new operation type in op header common."
	print
	print, "	Arguments"
	print, "		type	- operation type (string)"
	print, "			    'Gain'   - gain corrected"
	print, "				       (e.g., in gainit.pro)"
	print, "			    'GainXT' - gain corrected and"
	print, "				       XT applied"
	print, "				       (e.g., in gain_xt*.pro"
	print, "				        and calibrate.pro)"
	print, "	Keywords"
	print, "		(none)"
	print
	print
	print, "   ex:  put_optype, 'GainXT'"
	print
	return
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
case type of
	'Map':		optype = 1L
	'Cal':		optype = 2L
	'Filter':	optype = 4L
	'Phase':	optype = 8L
	'Flat':		optype = 16L
	'Tel':		optype = 32L

	'Ndflat':	optype = 64L		; new types added by David
	'Movie':	optype = 128L

	'Gain':		optype = 256L		; new types added by Rob
	'GainXT':	optype = 512L

	else:		message, 'bad "type"'
endcase
end
