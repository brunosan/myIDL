function equal, v1, v2, noverb=noverb
;+
;
;	function:  equal
;
;	purpose:  compare two values for equality (scalar or array)
;
;	author:  rob@ncar, 12/92
;
;	notes:  - array comparision is done in double precision floating point
;		- comparision will fail (with message) if
;			either/both values are undefined
;			arrays contain strings of same dimensions
;
;==============================================================================
;
;	Check number of parameters.
;
on_error, 2
if n_params() ne 2 then begin
	print
	print, "usage:  ret = equal(v1 ,v2)"
	print
	print, "	Compare two values for equality"
	print, "	(return 1 on equality, else return 0)."
	print
	print, "	Arguments"
	print, "		v1	  - first value (scalar or array)"
	print, "		v2	  - second value (scalar or array)"
	print
	print, "	Keywords"
	print, "		noverb	  - if set, don't print run time info"
	print
	print, "	Legal Comparisons"
	print
	print, "		2 scalars of same type"
	print, "		2 arrays of same type and dimensions"
	print, "		an array and a scalar of the same type"
	print
	return, -1
endif
;-
;
;	Set general parameters.
;
true = 1
false = 0
do_verb = true
if keyword_set(noverb) then do_verb = false
;
;	Get variable types.
;
n1 = sizeof(v1, 0)		; # of dimensions
n2 = sizeof(v2, 0)
t1 = sizeof(v1, -1)		; type
t2 = sizeof(v2, -1)
;
;	Print verbose information.
;
if do_verb then begin
	print
	print, '1ST VALUE'
;
	if n1 eq 0 then begin
	  print, '          # of dimensions:  ' + stringit(n1) + ' (scalar)'
	endif else begin
	  print, '          # of dimensions:  ' + stringit(n1) + ' (array)'
	endelse
	  print, '            # of elements:  ' + stringit(sizeof(v1, -2))
	  print, '                     type:  ' + sizeof(v1, -3)
	if (n1 eq 0) and (t1 ne 0) then $
	  print, '                    value:  ' + stringit(v1)
;
	print
	print, '2ND VALUE'
;
	if n2 eq 0 then begin
	  print, '          # of dimensions:  ' + stringit(n2) + ' (scalar)'
	endif else begin
	  print, '          # of dimensions:  ' + stringit(n2) + ' (array)'
	endelse
	  print, '            # of elements:  ' + stringit(sizeof(v2, -2))
	  print, '                     type:  ' + sizeof(v2, -3)
	if (n2 eq 0) and (t2 ne 0) then $
	  print, '                    value:  ' + stringit(v2)
	  print
endif
;
;	Check for equality.
;
if (t1 eq 0) or (t2 eq 0) then begin			; UNDEFINED (error)
	if (t1 eq t2) then message, 'both values are undefined'
	if (t1 eq 0) then message, '1st value is undefined'
	message, '2nd value is undefined'

endif else if (t1 ne t2) then begin			; DIFFERENT TYPES
	if do_verb then print, 'They are NOT equal:  different types.'
	return, 0

endif else if (n1 eq 0) and (n2 eq 0) then begin	; BOTH SCALARS
	if (v1 eq v2) then begin
		if do_verb then print, 'They are equal.'
		return, 1
	endif else begin
		if do_verb then print, 'They are NOT equal:  different values.'
		return, 0
	endelse

endif else if (n1 ne 0) and (n2 ne 0) then begin	; BOTH ARRAYS
	if (n1 ne n2) then begin
		if do_verb then print, $
			'They are NOT equal:  different # of dimensions.'
		return, 0
	endif
	for n = 1, n1 do begin
		if (sizeof(v1, n) ne sizeof(v2, n)) then begin
			if do_verb then print, $
				'They are NOT equal:  different dimensions.'
			return, 0
		endif
	endfor
	if (t1 eq 7) then message, 'cannot compare arrays of strings'
	minv = min( double(v1)-double(v2), max=maxv ) ; (cannot min/max Bytes)
	if (minv ne 0.0) or (maxv ne 0.0) then begin
		if do_verb then print, 'They are NOT equal:  different values.'
		return, 0
	endif
	if do_verb then print, 'They are equal.'
	return, 1

endif else begin					; SCALAR AND ARRAY
	minv = min( double(v1)-double(v2), max=maxv ) ; (cannot min/max Bytes)
	if (minv ne 0.0) or (maxv ne 0.0) then begin
		if do_verb then print, 'They are NOT equal:  different values.'
		return, 0
	endif
	if do_verb then print, 'They are equal (scalar and array values).'
	return, 1
endelse
end
