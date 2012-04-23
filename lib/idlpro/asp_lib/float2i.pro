function float2i, array
;+
;
;	function:  float2i
;
;	purpose:  convert an I array from float to unsigned int
;
;	author:  rob@ncar, 5/92
;
;	notes:  THIS NEEDS TO BE UPDATED TO USE ALL BITS, LIKE i2float.pro !!
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 1 then begin
	print
	print, "usage:  ret = float2i(array)"
	print
	print, "	Convert an I array from float to unsigned int."
	print
	return, 0
endif
;-

;;
;;	Shift up to positive values and fix the array (rounding).
;;
;;minv = min(array)
;;
;;if minv lt 0.0 then begin
;;	return, fix(array - minv + 0.5)
;;endif else begin
;;	return, fix(array + 0.5)
;;endelse

;
;	Fix the array (rounding).
;
return, fix( ( array > 0.0 ) + 0.5 )
end
