pro azam_cont, image, ifdata, level, t, cnt, ncnt
;+
;
;	procedure:  azam_cont
;
;	purpose:  Find where() 'level' contour is in 'image' magnified
;		  by factor t
;
;	author:  Paul Seagraves; mod's by Rob
;
;	notes:  isolated points of 'level' value will not be contoured
;		(fix later)
;
;==============================================================================

if n_params() eq 0 then begin
	print
	print, "usage:  azam_cont, image, sxy, level, t, cnt, ncnt"
	print
	print, "	Find where() the 'level' contour is in 'image'
	print, "	magnified by t."
	print
	print, "	Arguments"
	print, "		image	- 2D floating point array"
	print, "		ifdata	- 2D logical array for data locations"
	print, "		level	- contour level"
	print, "		t	- magnification 2 3 or 6."
	print, "		cnt	- output where array."
	print, "		ncnt	- size of output array."
	print
	return
endif
;-
			;Get array sizes.
ndim  = n_dims( image, xdim, ydim )
txdim = t*xdim
			;Null where array.
cnt = -1
ncnt = 0
			;Set where there are crossings in x direction.
whrx = where( ifdata( 0:xdim-2, * ) and ifdata( 1:xdim-1, * ) $
and $
(  ( image( 0:xdim-2, * ) le level and image( 1:xdim-1, * ) ge level ) $
or ( image( 0:xdim-2, * ) ge level and image( 1:xdim-1, * ) le level ) $
), nwhrx )
			;Set zero crossings in y direction.
whry = where( ifdata( *, 0:ydim-2 ) and ifdata( *, 1:ydim-1 ) $
and $
(  ( image( *, 0:ydim-2 ) le level and image( *, 1:ydim-1 ) ge level ) $
or ( image( *, 0:ydim-2 ) ge level and image( *, 1:ydim-1 ) le level ) $
), nwhry )
			;Mangify in x direction.
if nwhrx gt 0 then begin

	y = whrx/(xdim-1)
	x = whrx-y*(xdim-1)

	y = t*y
	x = t*(x+1)-1

	whrx = y*txdim+x

	case t of
		2: whrx = [ whrx, whrx+txdim ]
		3: whrx = [ whrx, whrx+txdim, whrx+2*txdim ]
		6: whrx = [ whrx, whrx+txdim, whrx+2*txdim $
			  , whrx+3*txdim, whrx+4*txdim, whrx+5*txdim ]
		else:
	end
end
			;Mangify in y direction.
if nwhry gt 0 then begin

	y = whry/xdim
	x = whry-y*xdim

	y = t*(y+1)-1
	x = t*x

	whry = y*txdim+x

	case t of
		2: whry = [ whry, whry+1 ]
		3: whry = [ whry, whry+1, whry+2 ]
		6: whry = [ whry, whry+1, whry+2, whry+3, whry+4, whry+5 ]
		else:
	end
end
			;Dimension of returned where array.
ncnt = t*(nwhrx+nwhry)
			;Combine where arrays and return.
if  nwhrx ne 0  and  nwhry ne 0  then begin
	cnt = [ whrx, whry ]
	return
end

if  nwhrx ne 0  then begin
	cnt = whrx
	return
end

cnt = whry

end
