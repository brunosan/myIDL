pro cct_min_max, a__cct, c
;+
;
;	procedure:  cct_min_max
;
;	purpose:  Install continuum minimum and maximum in structure c. 
;		  The structure can be either a b_str or a c_str.
;
;	author:  paul@ncar, 4/93	(minor mod's by rob@ncar)
;
;==============================================================================
;
;	Check number of arguments.
;
if n_params() ne 2 then begin
	print
	print, "usage:  cct_min_max, a__cct, c"
	print
	print, "	Install continuum minimum and maximum in structure c."
	print, "	The structure can be either a b_str or a c_str."
	print
	print, "	Arguments"
	print, "		a__cct	   - 2D array of continuum"
	print, "		c	   - structure"
	print
	print, "	Keywords"
	print, "		(none)"
	print
	return
endif
;-
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			;
			;Find continuum min max away from hair lines.
			;
have   = lonarr( c.xdim, c.ydim )  &  have(c.pxy)   = 1
b__cct = fltarr( c.xdim, c.ydim )  &  b__cct(c.pxy) = a__cct
ypnt = have*( c.y0+lindgen( c.xdim, c.ydim )/c.xdim )
c.cct_min = min( b__cct( where( ypnt gt 50 and ypnt lt 200 ) ), max=cct_max )
c.cct_max = cct_max
			;
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
end
