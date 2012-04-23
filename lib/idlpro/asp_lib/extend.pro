function extend, dat, nst, nend
;+
;
;	function:  extend
;
;	purpose:  smoothly extend data to make it periodic over its
;		  dimensioned extent
;
;	history:  lites@ncar - written.
;		  8/94 rob@ncar - replaced loops with array operations for
;			speed; various commenting/cleanup/etc.
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 3 then begin
	print
	print, "usage:  ret = extend(dat, nst, nend)"
	print
	print, "	Smoothly extend data to make it periodic over its"
	print, "	dimensioned extent."
	print
	print, "	Arguments"
	print, "		dat	- one-dimensional float array"
	print, "		nst	- starting index for unaltered data"
	print, "		nend	- ending index for unaltered data"
	print
	return, 0
endif
;-
;
;	Initialize array to return.
;
ret = dat
;
;	Get dimensions of array.
;
nx = sizeof(dat, 1)
nx1 = nx - 1
;
;	Get length of function for smoothed extension.
;
nmask = (nx1 - nend + 1) + nst
;
;	Check to see that mask length is long enough.
;
if nmask lt 15 then begin
	print, ' CAUTION:  in extend.pro, total number of points '
	print, ' in extension (' + stringit(nmask) + ') is small!'
	print, ' Normally it should be 15 pts or longer.'
	print, ' nx1, nst, nend ', nx1, nst, nend
	stop
endif

amul = !pi / float(nmask)

;
;	Extend the array so that there is smooth transition.
;
;;----------------------
;;OLD
;;----------------------
;;for i = nend+1,nx1 do begin
;;	arg = 0.5 * (1. - cos(float(i - nend) * amul))
;;	ret(i) = arg*dat(nst) + (1.-arg)*dat(nend)
;;endfor
;;
;;ist = nx - nend
;;
;;for i = 0,nst-1 do begin
;;	arg = 0.5 * (1. - cos(float(i + ist) * amul))
;;	ret(i) = arg*dat(nst) + (1.-arg)*dat(nend)
;;endfor
;;----------------------
;;NEW
;;----------------------
n = nx - nend
if n gt 1 then begin
	arg = 0.5 * (1.0 - cos( (findgen(n-1)+1.0) * amul))
	ret(nend+1:nx1) = arg*dat(nst) + (1.0 - arg)*dat(nend)
endif

if nst gt 0 then begin
	arg = 0.5 * (1.0 - cos( (findgen(nst)+n) * amul))
	ret(0:nst-1) = arg*dat(nst) + (1.0 - arg)*dat(nend)
endif
;;----------------------

return,ret
end
