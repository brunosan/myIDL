function wrap_scalew, array, type, minv, maxv, reverseit=reverseit
;+
;
;	function:  wrap_scalew
;
;	purpose:  scale an array to be used with the "newwct" colormap;
;		  this is "wrap_scale" with a wrapper around it
;
;	author:  rob@ncar, 8/92
;
;	notes:  - this is a wrapper for wrap_scale
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 4 then begin
	print
	print, "usage:  ret = wrap_scalew(array, type, minv, maxv)"
	print
	print, "	     [ret is a byte array]"
	print
	print, "	Scale an array to be used with the 'newwct' colormap."
	print
	print, "	Arguments"
	print, "	    array	- input array to be scaled"
	print, "	    type	- (see wrap_scale.pro)"
	print, "	    minv,maxv	- min and max values for range"
	print
	print, "	Keywords"
	print, "	    reverseit	- if set, reverse for type 4 (now)"
	print
	return, 0
endif
;-
;
;	Get the dimensions of the image.
;
xsize = sizeof(array, 1)
ysize = sizeof(array, 2)
;
;	Reformat the image to 1D.
;
size_1d = long(xsize) * long(ysize)
temp = reform(array, size_1d)
;
;	Truncate the image in case there are numbers outside the range.
;
maxit, temp, maxv		; can simply truncate at top
;
;;ixpos = where(temp ge 0)	; have to avoid special values at bottom
;;t1 = temp(ixpos)
;;t1(where(t1 lt minv)) = minv
;;temp(ixpos) = t1
;
;	Add the max and min values to the image, so that bytscl will use
;	that range.
;
temp = [temp, minv, maxv]
;
;	Do the scaling.
;
if keyword_set(reverseit) then begin
	temp = wrap_scale(temp, type, /reverseit)
endif else begin
	temp = wrap_scale(temp, type)
endelse
;
;	Remove the extra values.
;
temp = temp(0:size_1d - 1)
;
;	Reformat back to 2D.
;
temp = reform(temp, xsize, ysize)
;
;	Return the scaled image.
;
return, temp
end
