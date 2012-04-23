pro void, anything, dummy
;+
;
;	procedure:  void
;
;	purpose:  void out a function, as in C (i.e., for when you don't need
;		  the result of a function)
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 1 then begin
	print
	print, "usage:  void, anything"
	print
	print, "	Void out a function, as in C (i.e., for when you"
	print, "	don't need the result of a function)."
	print
	print
	print, "   ex:  void, myfunc(stuff)"
	print
	return
endif
;-

return
end
