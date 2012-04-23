function wrap_scale, array, type, reverseit=reverseit
;+
;
;	function:  wrap_scale
;
;	purpose:  scale an array to be used with the 'newwct' colormap
;
;	author:  rob@ncar, 8/92
;
;	example:  @wrap.com			<-- define common block
;		  newwct, 1			<-- set color table
;		  ...
;		  tv, wrap_scale(arr1, 2), ...	<-- use tv, not tvscl !
;		  tv, wrap_scale(arr2, 3), ...
;
;
;	notes: fix 'reverse' possibilities
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 2 then begin
	print
	print, "usage:  ret = wrap_scale(array, type)"
	print
	print, "		[ret is a byte array]"
	print
	print, "	Scale an array to be used with the 'newwct' colormap."
	print
	print, "	Arguments"
	print, "	    array	- input array to be scaled"
	print, "	    type	- type of scaling to be done"
	print, "		            0 = black-and-white"
	print, "		            1 = grayscale"
	print, "		            2 = reverse grayscale"
	print, "		            3 = colorscale"
	print, "		            4 = wrapped color (or Red,Blue)"
	print, "		            5 = disjoint color"
	print
	print, "	Keywords"
	print, "	    reverseit	- if set, reverse for type 4 (now)"
	print
	return, 0
endif
;-
;
;	Specify common block.
;
@wrap.com
;
;	Set general parameters.
;
true = 1
false = 0
reverse = false
;
;	Create byte array to hold image (note it can be 1D or 2D).
;
ndim = sizeof(array, 0)
case ndim of
	1: im = bytarr(sizeof(array, 1), /nozero)
	2: im = bytarr(sizeof(array, 1), sizeof(array, 2), /nozero)
     else: begin
		print
		print, 'Dimension error to wrap_scale'
		print
		return, 0
	   endif
endcase
;
;	Set index variables.
;
ixnodat = where(array eq -1)				; no data
ixcont1 = where(array eq -2)				; 1st contours
ixcont2 = where(array eq -3)				; 2nd contours
ixpos = where(array ge 0.0)				; data
;
;	Set type-specific variables.
;
case type of
;
  0: begin						; BLACK-AND-WHITE
	print
	print, 'Value "type" not currently supported.'
	print
	return, 0
     end
;
  1: begin						; GRAYSCALE
	offset = ix_gray
	top = num_gray - 1
	if sizeof(ixnodat, 0) gt 0 then $	; no data
		im(ixnodat) = ix_nodat2
	if sizeof(ixpos, 0) gt 0 then $		; data exists
		im(ixpos) = bytscl(array(ixpos), top=top) + offset
     end
;
  2: begin						; REVERSE GRAYSCALE
	offset = ix_gray
	top = num_gray - 1
	reverse = true
	if sizeof(ixnodat, 0) gt 0 then $	; no data
		im(ixnodat) = ix_nodat2
	if sizeof(ixpos, 0) gt 0 then $		; data exists
		im(ixpos) = bytscl(array(ixpos), top=top) + offset
     end
;
  3: begin						; COLORSCALE
	offset = ix_color2
	top = num_color2 - 1
	if sizeof(ixnodat, 0) gt 0 then $	; no data
		im(ixnodat) = ix_nodat
	if sizeof(ixpos, 0) gt 0 then $		; data exists
		im(ixpos) = bytscl(array(ixpos), top=top) + offset
     end
;
  4: begin						; WRAPPED COLOR
	offset = ix_color
	top = num_color - 1
	if sizeof(ixnodat, 0) gt 0 then $	; no data
		im(ixnodat) = ix_nodat
	if sizeof(ixpos, 0) gt 0 then $		; data exists
		im(ixpos) = bytscl(array(ixpos), top=top) + offset

	if keyword_set(reverseit) then $
		if sizeof(ixpos, 0) gt 0 then $
			im(ixpos) = top - (im(ixpos) - offset) + offset
     end
;
  5: begin						; DISJOINT COLORSCALE
	minv = min(array(ixpos), max=maxv)
	midv = minv + 0.5 * (maxv - minv)
	ixlow = where(array le midv)
	ixhigh = where(array gt midv)
	top = num_color3h - 1
	if sizeof(ixlow, 0) gt 0 then $
		im(ixlow) = bytscl(array(ixlow), top=top) + ix_color3a
	if sizeof(ixhigh, 0) gt 0 then $
		im(ixhigh) = bytscl(array(ixhigh), top=top) + ix_color3b
;
	if sizeof(ixnodat, 0) gt 0 then $	; no data (must follow)
		im(ixnodat) = ix_nodat
     end
;
  else: begin						; ERROR
	print
	print, 'Value "type" must be in range 0 - 5.'
	print
	return, 0
	end
endcase
;
;	Do the remaining scaling.
;
;	(Check for scalar value, indicating no returned indices from 'where'.)
;
	if sizeof(ixcont1, 0) gt 0 then $	; 1st contours
		im(ixcont1) = ix_cont1
	if sizeof(ixcont2, 0) gt 0 then $	; 2nd contours
		im(ixcont2) = ix_cont2
;
;	Do reversing if necessary.
;
	if reverse then $
		if sizeof(ixpos, 0) gt 0 then $
			im(ixpos) = top - (im(ixpos) - offset) + offset
;
;	Return the array.
;
return, im
end
