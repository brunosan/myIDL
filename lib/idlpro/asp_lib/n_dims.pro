function n_dims, array, D1, D2, D3, D4, D5 $
, size=sz, type=type, n_elements=n_el
;+
;
;	function:  n_dims
;
;	purpose:  return number dimensions of 1st argument;
;		  -1 returned for undefined argument
;
;	author:  paul@ncar, 11/94
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() eq 0 then begin
	print
	print, "usage:  ndim = n_dims(array[,D1[,D2[,D3[,D4[,D5]]]]])"
	print
	print, "	Return number dimensions of 1st argument;"
	print, "	-1 returned for undefined argument is undefined."
	print
	print, "	Arguments:"
	print, "		array	- input array"
	print, "		D1	- 1th dimension (1 if missing)"
	print, "		D2	- 2nd dimension (1 if missing)"
	print, "		D3	- 3rd dimension (1 if missing)"
	print, "		D4	- 4th dimension (1 if missing)"
	print, "		D5	- 5th dimension (1 if missing)"
	print
	print, "	Keywords:"
	print, "		size	- result of size() on array"
	print, "		type	- type of 1st argument in ascii"
	print, "	  n_elements	- number of elements"
	print
	return, -1L
endif
;-
				    ;Get result of size function.
sz = size(array)
				    ;Get number of dimensions.
ndim = sz(0)
				    ;Set number of elements.
n_el = sz(ndim+2)
				    ;Set sequence of 5 or more dimensions.
Dn=[sz(0:ndim),1L,1L,1L,1L,1L]
				    ;Set returned dimension argument sequence.
D1 = Dn(1)
D2 = Dn(2)
D3 = Dn(3)
D4 = Dn(4)
D5 = Dn(5)
				    ;Set type in ascii.
case sz(ndim+1) of
	0:	begin
			n_el = 0
			type = 'Undefined'
			return, -1
		end
	1:	type = 'Byte'
	2:	type = 'Integer'
	3:	type = 'Longword integer'
	4:	type = 'Floating point'
	5:	type = 'Double precision floating'
	6:	type = 'Complex floating'
	7:	type = 'String'
	8:	type = 'Structure'
	else:	stop
end
				    ;Return number of dimensions.
return, ndim

end
