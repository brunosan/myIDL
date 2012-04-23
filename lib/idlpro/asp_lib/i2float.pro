function i2float, intarray
;+
;
;	function:  i2float
;
;	purpose:  convert an I array (unsigned short) to floating point
;
;	author:  murphy@ncar (& rob@ncar)
;
;	notes:
;		<----(have this)----->	(want this)
;		hex		signed	unsigned	long(hex)
;
;		FFFF		-1	65536		FFFFFFFF
;		FFFD		-2	65535		FFFFFFFD
;					...
;
;		8000		 -32768	32768		ffff8000
;		7FFF		 32767	32767		00007FFF
;					...
;		0001		 1	    1		00000001
;		0000		 0	    0		00000000
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 1 then begin
	print
	print, "usage:  flt = i2float(intarray)"
	print
	print, "	Convert an I value (unsigned short) to a float."
	print
	return, 0
endif
;-
;
;	Convert.
;
ail = float((long(intarray) and '0000FFFF'XL))
return, ail
end
