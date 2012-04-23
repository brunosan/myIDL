function read_floats, file, error
;+
;
;  purpose:  read all the floating point values from a stream file and
;	     return the result as a floating point vector
;
;  source:  IDL User's Guide, Version 2.2, page 13-50, by Paul, 7/92
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() eq 0  then begin
	print
	print, "usage:  ret = read_floats( file [, error] )"
	print
	print, "	Read all the floating point values from a stream file"
	print, "	and return the result as a floating point vector."
	print
	print, "	If error is an argument return function value"
	print, "	of 1 on i/o error with error set to !ERR."
	print
	return, 0
endif
;-
				    ;Set no error condition.
error = 0
				    ;Set branch for error condition.
on_ioerror, ioerror
				    ;Loop over 10 tries.
for try=0,9 do begin
				    ;Open unique file unit.
	OPENR, /GET_LUN, unit, file
				    ;Get file status.
	status = FSTAT( unit )
				    ;Make an array to hold the input data.
				    ;SIZE field of status gives the number
				    ;of bytes in the file.
				    ;Single precision floating point values
				    ;are 4 bytes each.
	floats = FLTARR( status.SIZE / 4, /NOZERO )

				    ;Read the data.
	READU, unit, floats
				    ;Deallocate the file unit.
				    ;The file will also be closed.
	FREE_LUN, unit
				    ;Done.
	RETURN, floats
				    ;There is an error.
	ioerror: print, 'read_floats: '+!err_string
	wait, .1
end
				    ;Set error argument for return.
if n_params() eq 1 then stop
error = !err
return, 1

end
