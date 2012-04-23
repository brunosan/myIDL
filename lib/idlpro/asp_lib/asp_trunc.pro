pro asp_trunc, ii, qq, uu, vv, xs1, ys1, xs2, ys2
;+
;
;	procedure:  asp_trunc
;
;	purpose:  truncate 4 arrays to the max/min of the given range
;
;	author:  rob@ncar, 5/92
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 8 then begin
	print
	print, "usage:  asp_trunc, ii, qq, uu, vv, xs1, ys1, xs2, ys2"
	print
	print, "	Truncate 4 arrays to the max/min of the given range."
	print
	print, "	Arguments"
	print, "		ii,qq,uu,vv	 - input arrays"
	print, "		xs1 - ys2	 - range of values at which"
	print, "			           to get the max/min for"
	print, "			           truncating"
	print
	return
endif
;-
;
;	Get ranges.
;
min_i = min(ii(xs1:xs2, ys1:ys2), max=max_i)
min_q = min(qq(xs1:xs2, ys1:ys2), max=max_q)
min_u = min(uu(xs1:xs2, ys1:ys2), max=max_u)
min_v = min(vv(xs1:xs2, ys1:ys2), max=max_v)
;
;	Scale to ranges.
;
ii = ( (ii < max_i) > min_i )
qq = ( (qq < max_q) > min_q )
uu = ( (uu < max_u) > min_u )
vv = ( (vv < max_v) > min_v )
;
;	Done.
;
end
