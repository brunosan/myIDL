pro displayct, index1, index2, x1, y1, xsize, ysize, ltor=ltor
;+
;
;	procedure:  displayct
;
;	purpose:  display a portion of the color table
;
;	author:  rob@ncar, 5/92
;
; notes: - fix so index1 may be greater than index2 for reverse dir. of indices
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 6 then begin
	print
	print, "usage:  displayct, index1, index2, x1, y1, xsize, ysize"
	print
	print, "	Display a portion of the color table."
	print
	print, "	Arguments"
	print, "		index1	 - first color table index"
	print, "		index2	 - last color table index"
	print, "		x1, y1	 - lower left corner (device coords)"
	print, "		xsize	 - pixel width of output image"
	print, "		ysize	 - pixel height of output image"
	print, "			     (i.e., resolution)"
	print
	print, "	Keywords"
	print, "		ltor	 - flag to have values increase left"
	print, "			   to right (def = bottom to top)"
	print
	return
endif
;-
;
num_avail1 = abs(index2 - index1)
;
;	Create the color bar.
;
if keyword_set(ltor) then begin			; left to right
;
;	Generate a row of the output image.
	row = index1 + bytscl(bindgen(xsize), top=num_avail1)
;
;	Generate the image array and replicate the row into it.
	block = bytarr(xsize, ysize, /nozero)
	for i = 0, ysize-1 do block(*,i) = row
;
endif else begin				; bottom to top
;
;	Generate a column of the output image.
	column = index1 + bytscl(bindgen(ysize), top=num_avail1)
;
;	Generate the image array and replicate the column into it.
	block = bytarr(xsize, ysize, /nozero)
	for i = 0, xsize-1 do block(i,*) = column
;
endelse
;
;	Plot the color bar.
;
tv, block, x1, y1
end
