pro displayctn, index1, index2, x1, y1, xsize, ysize, ltor=ltor, half=half
;+
;
;	procedure:  displayctn
;
;	purpose:  display a portion of the color table (normal coord. version)
;
;	author:  rob@ncar, 5/92
;
; notes: - fix this so it works in X (works for PS now with size params w/ tv)
;	 - add ltor option
;	 - index1 may be greater than index2 for reverse direction of indices
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 6 then begin
	print
	print, "usage:  displayctn, index1, index2, x1, y1, xsize, ysize"
	print
	print, "	Display a portion of the color table."
	print
	print, "	Arguments"
	print, "		index1	 - first color table index"
	print, "		index2	 - last color table index"
	print, "		x1, y1	 - lower left corner (normal coords)"
	print, "		xsize	 - width of output image"
	print, "		ysize	 - height of output image"
	print, "			     (i.e., resolution)"
	print
	print, "	Keywords"
	print, "		ltor	 - flag to have values increase left"
	print, "			   to right (def = bottom to top)"
	print, "		half	 - divide the indices into two parts,"
	print, "			   where there may be a gap in the"
	print, "			   middle, and 'half' is the size of"
	print, "			   each portion used"
	print, "			   (def = don't divide in half)"
	print
	return
endif
;-

;
;if keyword_set(ltor) then begin
;

;
;	Set up "half", for making 2 disjoint submaps.
;
num_availm1 = abs(index2 - index1)
num_avail = num_availm1 + 1
;
if n_elements(half) gt 0 then begin
	if half+half gt num_avail then begin
		print
		print, 'displayctn error - size of "half"'
		print
		return
	endif
	halfm1 = half - 1
endif else begin
	half = 0
endelse
;
;
;
nx = num_avail
ny = ysize * 100
;
;	Generate a row of the output image.
;
if index1 le index2 then begin
	if half eq 0 then begin
		row = index1 + bytscl(bindgen(nx), top=num_availm1)
	endif else begin
		nx1 = nx / 2
		nx2 = nx - nx1
		row1 = index1 + bytscl(bindgen(nx1), top=halfm1)
		row2 = index2 - halfm1 + bytscl(bindgen(nx2), top=halfm1)
		row = [row1, row2]
	endelse
endif else begin
	if half eq 0 then begin
		row = index1 - bytscl(bindgen(nx), top=num_availm1)
	endif else begin
		nx1 = nx / 2
		nx2 = nx - nx1
		row1 = index1 - bytscl(bindgen(nx1), top=halfm1)
		row2 = index2 + halfm1 - bytscl(bindgen(nx2), top=halfm1)
		row = [row1, row2]
	endelse
endelse
;
;	Generate the image array and replicate the row into it.
;
block = bytarr(nx, ny, /nozero)
for i = 0, ny-1 do block(*,i) = row
;
;	Plot the image.
;
tv, block, x1, y1, xsize=xsize, ysize=ysize, /normal
end
