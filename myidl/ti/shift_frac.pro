FUNCTION SHIFT_FRAC, image, dx,dy, method, MISSING=missing ,HELP=help
;+
; NAME SHIFT_FRAC
;	
; PURPOSE: 
;       Shift an 2-d image by fractional pixels in x and y direction,
;	either by bilinear or bicubic interpolation.
;*CATEGORY:            @CAT-# 16 18@
;       Image Processing , Interpolation
; CALLING SEQUENCE:
;	result = SHIFT_FRAC (image, dx,dy [, {'L' | 'C'} ] [,MISSING=missing] )
; INPUTS:
;	image: the 2-dim image array to be shifted.
;       dx, dy: the shift to be done in 1st ("x") and 2nd ("y") dimension
;              of the image. If positive, the shift is done towards right
;              or upper direction. 
; OPTIONAL INPUT:
;	method: string specifying the interpolation method;
;              either = 'L': bilinear interpolation (the default)
;              or     = 'C': cubic interpolation.
; KEYWORD PARAMETERS:
;       MISSING=missing: The value to return for elements outside the bounds 
;              of array image. 
;              Default: Interpolated positions that fall outside the bounds of
;              the image, are set to the value of the nearest image pixel. 
; OUTPUTS:
;	Array with the shifted image. Same size as input image array.
;	
; PROCEDURE:
;	Calls IDL-function INTERPOLATE.
;
; MODIFICATION HISTORY:
;	nlte&kis, 2000-Jul-05
;----------------------------------------------------------------------------
;
on_error,2
if n_params() lt 3 or n_params() gt 4 or keyword_set(help) then begin
   message,/info,'wrong number of arguments.'
   return,-1
endif
;
if n_params() eq 3 then method='L'
if (size(method))((size(method))(0)+1) ne 7 then $
   message,'3rd argument (method) must be a string'
;
if dx eq 0. and dy eq 0. then return,image
;
sz=size(image)
meth=strupcase(strtrim(method,2))
case meth of
  'L': return, INTERPOLATE(image,findgen(sz(1))-dx,findgen(sz(2))-dy,/GRID,$
                           MISSING=missing)
  'C': return, INTERPOLATE(image,findgen(sz(1))-dx,findgen(sz(2))-dy,/GRID,$
                           CUBIC=-0.5, MISSING=missing)
  else: message,'Unknown method switch (must be "L" or "C"): '+meth
endcase
;
end
