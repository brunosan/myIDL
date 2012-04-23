function gncorr, input, gaintbl, output, ixst
;+
;
;    purpose:  apply pixel-by-pixel gain correction to a Stokes I image
;
;      notes:  This is Rob's new version that makes one call to a C routine
;	       to do all of the interpolation (much faster!).
;
;	WARNING - 'ixst' assumes wavelengths have NOT been flipped !!!
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 4 then begin
	print
	print, "usage:  ret = gncorr(input, gaintbl, output, ixst)"
	print
	print, "	Apply pixel-by-pixel gain correction to a Stokes I"
	print, "	(0 returned on success; 1 on failure)."
	print
	print, "	Arguments"
	print, "	    input	- Stokes I image"
	print, "	    gaintbl	- pre-processed gain tbl from buildgn"
	print, "	    ixst	- index of first active X"
	print, "	    output	- gain corrected Stokes I image"
	print
	return, 0
endif
;-

;
;	Get dimensions of input array and gain table.
;
nx = sizeof(input, 1)
ny = sizeof(input, 2)
ng = sizeof(gaintbl, 1)
;
;	Initialize output array.
;
output = input
;
;	Set up subsets of arrays using active X index.
;
in = input(ixst:*, *)
out = output(ixst:*, *)
gain = gaintbl(*,*,ixst:*,*)
nx_use = nx - ixst
;
;	Invoke the C routine to do the interpolation.
;
;; pre-Solaris
;;ret = call_external('/home/hao/stokes/src/idl/gncorrc.so', '_gncorrc', $
;;	in, gain, long(nx_use), long(ny), long(ng), out)
;; Solaris
ret = call_external('/home/hao/stokes/src/idl/gncorrc.so', 'gncorrc', $
	in, gain, long(nx_use), long(ny), long(ng), out)
;
;	Store interpolated results in output image.
;
output(ixst:*, *) = out
;
;	Return success status of interpolation.
;
return, ret
end
