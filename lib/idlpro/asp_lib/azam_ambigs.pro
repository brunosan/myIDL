pro azam_ambigs, azm, sdat, t, amb, namb
;+
;
;	procedure:  azam_ambigs
;
;	purpose:  find t magnified WHERE() the magnetic field is ambiguous
;		  point to point
;
;	author:  paul@ncar, 4/93	(minor mod's by rob@ncar)
;
;==============================================================================
;
;       Check number of parameters.
;
if n_params() eq 0 then begin
	print
	print, "usage:	azam_ambigs, azm, sxy, t, amb, namb"
	print
	print, "	find t magnified WHERE() array where the locations"
	print, "	correspond to ambiguous boundaries in the input"
	print, "	azimuth array."
	print
	print, "	Arguments"
	print, "		azm	- input line of sight azimuth array."
	print, "		sdat	- input logical 2D array for data"
	print, "			  in input array."
	print, "		t	- magnification 2 3 or 6."
	print, "		amb	- output where array."
	print, "		namb	- size of output array."
	print
	return
endif
;-
			;Array sizes.
ndim  = n_dims( azm, xdim, ydim )
txdim = t*xdim
			;Null where array.
amb = -1
namb = 0
			;Convert to integer.
izm = round(azm)
			;Find ambigs in x direction.
whrx = where( sdat(1:xdim-1,*) and sdat(0:xdim-2,*) and $
((izm(1:xdim-1,*)-izm(0:xdim-2,*))+(360+90)) mod 360  gt  180 $
, nwhrx )
			;Find ambigs in y direction.
whry = where( sdat(*,1:ydim-1) and sdat(*,0:ydim-2) and $
((izm(*,1:ydim-1)-izm(*,0:ydim-2))+(360+90)) mod 360  gt  180 $
, nwhry )
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
namb = t*(nwhrx+nwhry)
			;Combine where arrays and return.
if  nwhrx ne 0  and  nwhry ne 0  then begin
	amb = [ whrx, whry ]
	return
end

if  nwhrx ne 0  then begin
	amb = whrx
	return
end

amb = whry

end
