function ambigs, b_azm, sxy, nchg
;+
;
;	function:  ambigs
;
;	purpose:  return WHERE() the magnetic field is ambiguous
;		  point to point
;
;	author:  paul@ncar, 4/93	(minor mod's by rob@ncar)
;
;==============================================================================
;
;       Check number of parameters.
;
if n_params() ne 2 and n_params() ne 3 then begin
	print
	print, "usage:	highlight = ambigs( b_azm, sxy [, nchg]  )"
	print
	print, "	Return a WHERE() array where the locations correspond"
	print, "	to ambiguous boundaries in the input azimuth array."
	print
	print, "	Arguments"
	print, "		b_azm	- input line of sight azimuth array"
	print, "		sxy	- input WHERE() array where there is"
	print, "			  in input arrayy."
	print, "		nchg	- size of output array."
	print
	print, "	Keywords"
	print, "		(none)"
	print
	return, 0
endif
;-

			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			;
			;Get 2D dimension.
			;
azm = long(b_azm)
sizeazm = size(azm)
xdim = sizeazm(1)
ydim = sizeazm(2)
			;
			;Set logical 2D array for if data is present.
			;Return a -1 if there is no data.
			;
nchg = 0
ifdata = lonarr( xdim, ydim )
sizesxy = size(sxy)
if  sizesxy(0) eq 0  then  return, -1  else  ifdata( sxy ) = 1
			;
			;Initial false 2D array for ambiguous point to points.
			;
hilite = lonarr( xdim, ydim )
			;
			;In x direction find magnitude azimuth change.
			;
a11 = abs( azm( 1:xdim-1, * ) - azm( 0:xdim-2, * ) ) mod 360
			;
			;Mark where there is data and where the ambiguous
			;case is closer.
			;
hilite( 0:xdim-2, * ) = ( $
ifdata( 1:xdim-1, * )  and  ifdata( 0:xdim-2, * )  and $
( a11 gt 90  and  a11 lt 270 ) )
			;
			;In y direction find magnitude azimuth change.
			;
a11 = abs( azm( *, 1:ydim-1 ) - azm( *, 0:ydim-2 ) ) mod 360
			;
			;Mark where there is data and where the ambiguous
			;case is closer.
			;
hilite( *, 0:ydim-2 ) = hilite( *, 0:ydim-2 ) or ( $
ifdata( *, 1:ydim-1 )  and  ifdata( *, 0:ydim-2 )  and $
( a11 gt 90  and  a11 lt 270 ) )
			;
			;Return where() array as ambigs() value.
			;
return, where( hilite, nchg )
			;
end
