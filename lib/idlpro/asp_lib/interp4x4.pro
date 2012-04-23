function interp4x4, mats, oplist, op
;+
;
;	function:  interp4x4
;
;	purpose:  linearly interpolate a 4x4 matrix from a set of matrices
;
;	author:  rob@ncar, 10/92
;
;	notes:  1) This is a general routine, but currently used in get_st2 to
;		   calculate average X matrices.
;		2) If op is out of the oplist range, extrapolation will occur.
;		3) If there is only one input matrix, it will be returned.
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 3 then begin
	print
	print, "usage:  mat = interp4x4(mats, oplist, op)"
	print
	print, "	Interpolate a 4x4 matrix from a set of matrices;"
	print, "	extrapolate if necessary."
	print
	print, "	Arguments"
	print, "		mats	 - array of matrices, dim. (n, 4, 4)"
	print, "		oplist	 - array of operation numbers"
	print, "			   corresponding to matrices 0 to n-1"
	print, "			   (monotonic)"
	print, "		op	 - operation number at which to"
	print, "			   interpolate a new 4x4"
	print
	print
	print, "   ex:  xnew = interp4x4(xmats, xlist, opnum)"
	print
	return, 0
endif
;-
;
;	Get number of input matrices.
;
nmat = sizeof(mats, 1)
nmat1 = nmat - 1
if nmat lt 1 then begin
	print
	print, 'No input matrices.'
	print
	return, 0
endif
if nmat ne sizeof(oplist) then begin
	print
	print, '# matrices in "mats" not equal to # values in "oplist".'
	print
	return, 0
endif
;
;	Only one input matrix, so return it (no interp/extrap needed).
;
if nmat eq 1 then return, reform(mats(0, *, *), 4, 4)
;
;	Find which two matrices to interpolate with.
;
if (op lt oplist(0)) then begin
	ix1 = 0
	ix2 = 1
endif else if (op gt oplist(nmat1)) then begin
	ix1 = nmat1 - 1
	ix2 = nmat1
endif else begin
	ix2 = 0
	repeat ix2 = ix2 + 1 until op le oplist(ix2)
	ix1 = ix2 - 1
endelse
;
;	Set values for interpolation.
;
m1 = mats(ix1, *, *)
m2 = mats(ix2, *, *)
op1 = oplist(ix1)
op2 = oplist(ix2)
;
;	Return interpolated matrix.
;
m = m1(*) + float(op - op1)/(op2 - op1) * (m2(*) - m1(*))
return, reform(m, 4, 4)
;
end
