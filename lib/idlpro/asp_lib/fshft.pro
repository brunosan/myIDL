function fshft, line, sh, nst, nend
;+
;
;	function:  fshft
;
;	purose:  shift array line by non-integer pixel shift sh by linear
;		 interpolation.  Uses wraparound for ends.  The parameter
;		 sh would be the negative of the result of corshft to shift
;		 line2 back onto line1.
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 4 then begin
	print
	print, "usage:  ret = fshft(line, sh, nst, nend)"
	print
	print, "	Shift array line by non-integer pixel shift sh by"
	print, "	linear interpolation.  Uses wraparound for ends."
	print, "	The parameter sh would be the negative of the result"
	print, "	of corshft to shift line2 back onto line1."
	print
	print, "	Arguments"
	print, "		line	- one-dimensional array"
	print, "		sh	- fractional pixel shift"
	print, "		nst	- starting index for shift"
	print, "		nend	- ending index for shift"
	print
	return, 0
endif
;-
;
;	Set general parameters.
;
nx = sizeof(line, 1)
nx1 = nx - 1
linesh = line
;;xnew = indgen(nx)
;
;	Shift the array by the *integer* pixel.
;
nsh = fix(sh)
del = sh
;
if abs(sh) ge 1.0 then begin
	linesh = shift(linesh, nsh)
	del = sh - nsh
endif
;
;	Shift the array by the *non-integer* remainder.
;
if (del ne 0.0) then begin
;
;;	Calculate the abcissae for linear interpolation.
;;	xnew = xnew - del
;
;;	Do linear interpolation.
;;	linesh = interpolate(linesh, xnew)
;
;;	Do cubic spline interpolation.
;;	xnn = xnew - del
;;	linesh = spline(xnew, linesh, xnn)
;
;	Do Fourier interpolation.
	linesh = ffterpol(linesh, del, nst, nend)
;
endif

return, linesh
end
