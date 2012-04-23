pro set_iquv, dummy
;+
;
;	function:  set_iquv
;
;	purpose:  Set lengths of I,Q,U,V arrays for common block 'iquv'.
;
;	author:  rob@ncar, 1/92
;
;	notes:  dnumx and dnumy come from common block 'op_hdr'
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 0 then begin
	print
	print, "usage:  set_iquv"
	print
	print, "	Set lengths of I,Q,U,V arrays for common block iquv."
	print
	print, "	[Set 'dnumx' and 'dnumy' in 'op_hdr' first.]"
	print
	return
endif
;-
;
;	Specify common blocks.
;
@op_hdr.com
@iquv.com
;
;	Set int and float arrays.
;
i_int = intarr(dnumx, dnumy, /nozero)
q_int = intarr(dnumx, dnumy, /nozero)
u_int = intarr(dnumx, dnumy, /nozero)
v_int = intarr(dnumx, dnumy, /nozero)
i = fltarr(dnumx, dnumy, /nozero)
q = fltarr(dnumx, dnumy, /nozero)
u = fltarr(dnumx, dnumy, /nozero)
v = fltarr(dnumx, dnumy, /nozero)
;
;	Done.
;
end
