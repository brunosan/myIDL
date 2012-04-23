pro insert_wrapm, array, ix1, ix2, array2, ixmid
;+
;
;	procedure:  insert_wrapm
;
;	purpose:  insert one 1-D array into another, possibly wrapping
;
;		"MAX VERSION" - the maximum of the existing value or the
;		 new value is what gets put in 'array'
;
;	author:  rob@ncar, 1/93
;
;	notes:  - no overlapping allowed in the wrapping
;		- used in newwct.pro
;		- use SHIFT function ?
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 5 then begin
	print
	print, "usage:  insert_wrapm, array, ix1, ix2, array2, ixmid"
	print
	print, "	Insert one 1-D array into another, possibly wrapping."
	print
	print, "	Arguments"
	print, "		array	 - input array to insert into"
	print, "		ix1,ix2	 - valid indeces of array"
	print, "		array2	 - array to be inserted"
	print, "		ixmid	 - middle index for insertion"
	print
	return
endif
;-
;
;	Set up for insertion.
;
width = sizeof(array2, 1)
wd2 = width / 2
wrem = width - wd2
;
i1 = ixmid - wd2
i2 = ixmid + wrem - 1
;
;	Do the insertion.
;
if (i1 lt ix1) and (i2 gt ix2) then begin			; overlap
      print
      print, 'No overlapping allowed in "insert_wrapm".'
      print
      return

endif else if (i1 ge ix1) and (i2 le ix2) then begin		; no wrap
      array(i1:i2) = array(i1:i2) > array2(*)

endif else if (i1 lt ix1) then begin				; wrap left
      d = ix1 - i1
      array(ix2-d+1:ix2) = array(ix2-d+1:ix2) > array2(0:d-1)
      array(ix1:ix1+width-d-1) = array(ix1:ix1+width-d-1) > array2(d:width-1)

endif else begin						; wrap right
      d = i2 - ix2
      array(ix1:ix1+d-1) = array(ix1:ix1+d-1) > array2(width-d:width-1)
      array(ix2-width+d+1:ix2) = array(ix2-width+d+1:ix2) > array2(0:width-d-1)

endelse
;
;	Done.
;
end
