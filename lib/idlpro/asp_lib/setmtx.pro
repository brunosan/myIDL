function setmtx          $
  , e00, e01, e02, e03   $
  , e10, e11, e12, e13   $
  , e20, e21, e22, e23   $
  , e30, e31, e32, e33
;+
;
;  purpose:  Return 4x4 matrix set with argument list.
;	     Note a transpose is done to get matrix operations
;	     to work as one would expect.
;
;  author:  paul seagraves 92.09.03
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 16 then begin
	print
	print, "usage:  m = setmtx (e00, e01, e02, e03, $"
	print, "	            e10, e11, e12, e13, $"
	print, "	            e20, e21, e22, e23, $"
	print, "	            e30, e31, e32, e33)"
	print
	print, "	Return 4x4 matrix set with argument list."
	print, "	Note a transpose is done to get matrix operations"
	print, "	to work as one would expect."
	print
	return, 0
endif
;-


return,                  $
[ [ e00, e10, e20, e30 ] $
, [ e01, e11, e21, e31 ] $
, [ e02, e12, e22, e32 ] $
, [ e03, e13, e23, e33 ] ]

end
