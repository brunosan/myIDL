function write_floats, file, floats, error
;+
;
;  purpose:  write the floating point array to a stream file,
;            this is a companion function to read_floats.pro
;
;   author:  paul@hao.ucar.edu
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() eq 0 then begin
	print
	print, "usage:  err = write_floats(file,array[,error])"
	print
	print, "	Write floating point array to a stream file."
	print, "	On sucess, returned function value is 0.
	print, "	On error and error argument present,"
	print, "	returned function value is 1."
	print, "	Stop on error if error argument not present."
	print
	print, "   ex:	path = '/hilo/d/asp/data/red/92.03.25/op05/a__cct'"
	print, "	err = write_floats( path, a__cct )"
	print
	return, 0
endif
;-
	;--------------------------------------------------
	;
	;Set error checking.
	;
error = 0
if n_params() eq 3 then  on_ioerror, ioerror
	;
	;Get a unique file unit and open the data file.
	;
OPENW, /GET_LUN, unit, file
	;
	;Write the file.
	;
WRITEU, unit, floats
	;
	;Deallocate the file unit.
	;The file will also be closed.
	;
FREE_LUN, unit
	;
	;Done.
	;
RETURN, 0
	;
	;Set error argument for return.
	;
ioerror:
error = !err
return, 1
	;
END
