function sizeof, array, index
;+
;
;	function:  sizeof
;
;	purpose:  return information from the SIZE function
;
;	author:  rob@ncar, 5/92
;
;==============================================================================
;
;	Check number of parameters.
;
on_error, 2
if n_params() lt 1 then begin
	print
	print, "usage:  ret = sizeof(array [,flag])"
	print
	print, "	Return information from the SIZE function."
	print
	print, "	Arguments"
	print, "	    array	- input array"
	print, "	    flag	- information to return"
	print
	print, "		          0 = # of dimensions"
	print, "		     1 to n = size of the dimension"
	print, "		         -1 = type code (see SIZE function)"
	print, "		         -2 = number of elements"
	print, "		         -3 = type in ASCII"
	print
	print, "		          (def = 1)"
	print
	return, -1
endif
;-
;
;	Return size information.
;
if n_elements(index) eq 0 then index = 1
s = size(array)

if index ge 0 then begin			; 0 - n
	return, s(index)
endif else if index eq -3 then begin		; -3
	ndim = s(0)
	case (s(ndim + 1)) of
		0:  return, 'Undefined'
		1:  return, 'Byte'
		2:  return, 'Integer'
		3:  return, 'Longword integer'
		4:  return, 'Floating point'
		5:  return, 'Double precision floating'
		6:  return, 'Complex floating'
		7:  return, 'String'
		8:  return, 'Structure'
		else:  return, 'Error'
	endcase
endif else if index lt -2 then begin		; error
	print
	print, 'sizeof - index error'
	print
	return, -1
endif else begin				; -1 or -2
	ndim = s(0)
	return, s(ndim - index)
endelse

end
