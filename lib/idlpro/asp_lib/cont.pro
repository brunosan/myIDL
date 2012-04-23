function cont, image, sxy, level
;+
;
;	function:  cont
;
;	purpose:  Return where() the 'level' contour is in 'image'.
;
;	author:  Paul Seagraves; mod's by Rob
;
;	notes:  isolated points of 'level' value will not be contoured
;		(fix later)
;
;==============================================================================

if n_params() ne 3 then begin
	print
	print, "usage:  ret = cont(image, sxy, level)"
	print
	print, "	Return where() the 'level' contour is in 'image'."
	print
	print, "	Arguments"
	print, "		image	- 2D floating point array"
	print, "		sxy	- where() there is data in the image"
	print, "		level	- contour level"
	print
	return, 0
endif
;-
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			;
			;Get dimensions.
			;
xdim = sizeof(image, 1)
ydim = sizeof(image, 2)
			;
			;Set logical 2D array for if data is present.
			;Return a -1 if there is no data.
			;
ifdata = lonarr( xdim, ydim )
if  sizeof(sxy, 0) eq 0  then  return, -1  else  ifdata( sxy ) = 1
			;
			;Initial false 2D array for no zero crossings.
			;
ifcross = lonarr( xdim, ydim )
			;
			;Set zero crossings in x direction.
			;
ifcross( 0:xdim-2, * ) = ( $
	ifdata( 0:xdim-2, * ) and ifdata( 1:xdim-1, * ) $
 and (   ( image( 0:xdim-2, * ) le level and image( 1:xdim-1, * ) ge level ) $
      or ( image( 0:xdim-2, * ) ge level and image( 1:xdim-1, * ) le level ) $
     )                   )
			;
			;Set zero crossings in y direction.
			;
ifcross( *, 0:ydim-2 ) =  ifcross( *, 0:ydim-2 ) or $
	 ( ifdata( *, 0:ydim-2 ) and ifdata( *, 1:ydim-1 ) $
  and (   ( image( *, 0:ydim-2 ) le level and image( *, 1:ydim-1 ) ge level ) $
       or ( image( *, 0:ydim-2 ) ge level and image( *, 1:ydim-1 ) le level ) $
      )  )
			;
			;Return where() there is zero crossing array.
			;
return, where( ifcross )
			;
end
