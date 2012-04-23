function puff, array, tt
;+
;
;	function:  puff
;
;	purpose:  Return 2D byte float or long array with dimensions
;		  changed by an integer factor (replacement for
;		  buggy userlib routine 'congrid').
;
;	author:  paul@ncar, 5/93	(minor mod's by rob@ncar)
;
;==============================================================================
;
;       Check number of parameters.
;
if n_params() ne 2 then begin
	print
	print, "usage:	ret = puff( array, tt )"
	print
	print, "	Return 2D byte float or long array with dimensions"
	print, "	changed by an integer factor."
	print
	print, "	Arguments"
	print, "		array	- 2D byte float or long array,"
	print, "			  Any scalar is ok"
	print, "		tt	- (tt>2) for increased dimensions"
	print, "			  (0<tt<.5) for decreased dimensions"
	print
	return,0
endif
;-
		    ;
		    ;Get properties of the array argument.
		    ;
ndim = sizeof( array,  0 )
xdim = sizeof( array,  1 )
ydim = sizeof( array,  2 )
type = sizeof( array, -1 )
nelm = sizeof( array, -2 )
		    ;
		    ;
		    ;
if  tt lt 0.  then stop, 'puff.pro: tt must be positive'
if  tt ge 2./3.  then  begin
		    ;
		    ;Get nearest integer in tt.
		    ;
	t = long(tt+.5)
		    ;
		    ;Return t*t array if argument is scalar.
		    ;
	if  nelm eq 1  then  return, replicate( array(0), t, t )
		    ;
		    ;Return argument if no magnification.
		    ;
	if  t eq 1  then  return, array
		    ;
		    ;Expand in x direction.
		    ;
	if  type eq 1  then  xx = bytarr( t*xdim, ydim, /nozero )
	if  type eq 3  then  xx = lonarr( t*xdim, ydim, /nozero )
	if  type eq 4  then  xx = fltarr( t*xdim, ydim, /nozero )
	for  i=0,xdim-1  do begin
		vec = array(i,*)
		for  ii=t*i,t*i+t-1  do begin
			xx(ii,*) = vec
		end
	end
		    ;
		    ;Expand in y direction.
		    ;
	if  type eq 1  then  yy = bytarr( t*xdim, t*ydim, /nozero )
	if  type eq 3  then  yy = lonarr( t*xdim, t*ydim, /nozero )
	if  type eq 4  then  yy = fltarr( t*xdim, t*ydim, /nozero )
	for  j=0,ydim-1  do begin
		vec = xx(*,j)
		for  jj=t*j,t*j+t-1  do begin
			yy(*,jj) = vec
		end
	end
		    ;
		    ;Return expanded array.
		    ;
	return, yy
		    ;
end else begin
		    ;
		    ;Get nearest integer in reciprocal tt.
		    ;
	t = long(1./tt+.5)
		    ;
		    ;Return single value for scalar argument.
		    ;
	if  nelm eq 1  then  return, replicate( array(0), 1, 1 )
		    ;
		    ;Compress in y direction.
		    ;
	dimy = (ydim+t-1)/t
	if  type eq 1  then  yy = bytarr( xdim, dimy, /nozero )
	if  type eq 3  then  yy = lonarr( xdim, dimy, /nozero )
	if  type eq 4  then  yy = fltarr( xdim, dimy, /nozero )
	for  j=0,dimy-1  do begin
		yy(*,j) = array(*,t*j)
	end
		    ;
		    ;Compress in y direction.
		    ;
	dimx = (xdim+t-1)/t
	if  type eq 1  then  xx = bytarr( dimx, dimy, /nozero )
	if  type eq 3  then  xx = lonarr( dimx, dimy, /nozero )
	if  type eq 4  then  xx = fltarr( dimx, dimy, /nozero )
	for  i=0,dimx-1  do begin
		xx(i,*) = yy(t*i,*)
	end
		    ;
		    ;Return compressed array.
		    ;
	return, xx
		    ;
end
		    ;
end
