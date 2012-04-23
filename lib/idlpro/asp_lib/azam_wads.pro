function azam_wads, azm, fld, psi, sdat, nchg
;+
;
;	function:  azam_wads
;
;	purpose:  return WHERE() magnetic field is likely ambiguous
;		  point to point over the array
;
;	author:  paul@ncar, 9/93	(minor mod's by rob@ncar)
;
;==============================================================================
;
;       Check number of parameters.
;
if n_params() eq 0 then begin
	print
	print, "usage:	ambig = azam_wads( azm, fld, psi, sdat, nchg )"
	print
	print, "	return WHERE() magnetic field is ambiguous 
	print, "	point to point over the array"
	print
	print, "	Arguments"
	print, "		azm	- input 2D array of line of sight"
	print, "			  azimuth (degrees)"
	print, "		fld	- input 2D array of field strength"
	print, "			  (gauss)"
	print, "		psi	- input 2D array of line of sight"
	print, "			  inclination (degrees)"
	print, "		sdat	- input 2D array true for data"
	print, "			  locations"
	print, "		nchg	- size of returned array"
	print
	print, "	Keywords"
	print, "		(none)"
	print
	return, 0
endif
;-
;                                                           9/28/93
;Last year I developed an algorithm to disambiguate based on
;point to point continuity.   The algorithm is now in azam
;and is called ( wads ).  It is available on the small scale with
;the interactive mouse.  To use the algorithm set the lower
;left azam display button to ( wads ); dragging the mouse with the
;left button down runs the algorithm.
;
;Dragging ( wads ) into a azimuth discontinuity will push the discontinuity
;back.  I think this algortithm works better than anything else for this
;purpose.
;
;There is a problem.  The computation time is long and you can easily go
;to fast.  Working with ( 8x8 ) or ( 16x16 ) areas seems to work best.
;( wads ) automatically sets a ( 4x4 ) area minimum.
;
;On quiet regions it is still best to go over them with the
;left mouse button set to ( up down ).  To use ( wads ) to clean up
;'salt & pepper' first move the cursor over a region then press
;the left button down.
;
;There are 'unavoidable' azimuth discontinuities drawn
;by ( ambigs ) from the ( menu ).  To try ( wads ) on these I recomend
;moving the cursor over top before pressing the button down.
;
;The ( wads ) algorithm works on power of 2 dimension arrays.  The small
;areas the mouse works on have been changed to powers of 2 dimensions.
;
; 						5/25/94
; 
; To resolve 180 ambiguity the University of Hawaii has as one step what
; is called "acute angle resolution".   I tried this portion of their
; code on ASP data.  The input ASP data had already been disambiguated
; with 'azam'.  The output showed some improvements in point to point
; continuity.
; 
; Reading the UH code I find "acute angle resolution" is done with
; dot products of field vectors point to point.  I picked up on the dot
; product idea.
; 
; 'azam' has been revised to use field vector dot products when working
; on point to point continuity.  Options effected are (wads) and (smooth).
; Of these options (smooth) has a sequence most like the UH code.
; The codes are only similar; it would be a mistake to say we are
; using the UH method.
; 
; The dot product gives a good measure of continuity.  Only the field 
; transverse to the line of sight need to be considered; the line of
; sight field component is unambiguous.  Let us represent the transverse
; component of two adjacent field vectors as
; 
;	S = Ai+Bj
;	T = Di+Ej
; 
; The ambiguous vectors are
; 
;	U = -Ai-Bj = -S
;	V = -Di-Ej = -T
; 
; Note the relation
; 
;	S dot T = AD+BE = |S||T|cos(angle between S & T)
;		= -(S dot V)
;		= -(U dot T)
;		= U dot V
; 
; For continuity one would pick a dot product that is positive. 
; 
; The trouble is that a point has more than one neighbor.  The point in
; the middle of a 3x3 array has 8 neighbors.  Let's take the dot product
; of the center point with each of its 8 neighbors and sum them.
; If sum of the 8 dot products is negative, it is likely the negative
; (or ambiguous) vector would be better for the center point.
; This is how the (smooth) option in 'azam' works.
;
; (wads) in 'azam' now works on the field vectors and not solely
; on line of sight azimuth.   I doubt if one can detect this upgrade
; from a user point of view.
;-----------------------------------------------------------------------------

				;Get dimension.
if n_dims( azm, xdim, ydim ) ne 2 then  return, -1

				;Test for null conditions.
nchg = 0
nsdat = total(sdat)
if  nsdat eq 0                then return, -1
if  xdim lt 2  or  ydim lt 2  then return, -1

				;Get x y vector components.
tmp0 = azm*(!pi/180.)
tmp1 = fld*sin(psi*(!pi/180.))
bx0 = round(tmp1*cos(tmp0))*sdat
by0 = round(tmp1*sin(tmp0))*sdat
bx = bx0
by = by0
				;Loop over power two dimensions.
pwr = 1
while  pwr lt xdim  or  pwr lt ydim  do begin
	pwr = 2*pwr
				;Set some frequently used numbers.
	pwm = pwr-1
	hlf = pwr/2
	hlm = hlf-1
				;Loop over xy space.
	for  x0 = 0,xdim-1,pwr  do begin
	for  y0 = 0,ydim-1,pwr  do begin

				;Range of sub array.
		x1 = (x0+pwr-1) < (xdim-1)
		y1 = (y0+pwr-1) < (ydim-1)
		xa = x1-x0
		ya = y1-y0
				;Get square sub arrays.
		xx = lonarr(pwr,pwr)
		yy = lonarr(pwr,pwr)
		xx(0:xa,0:ya) = bx(x0:x1,y0:y1)
		yy(0:xa,0:ya) = by(x0:x1,y0:y1)

				;Total dot product from left side to center.
		n0 = total( $
		  xx(0:hlm,hlm)*xx(0:hlm,hlf) $
		+ yy(0:hlm,hlm)*yy(0:hlm,hlf) )

				;Total dot product from center to top.
		n1 = total( $
		  xx(hlm,hlf:pwm)*xx(hlf,hlf:pwm) $
		+ yy(hlm,hlf:pwm)*yy(hlf,hlf:pwm) )

				;Total dot product from center to right side.
		n2 = total( $
		  xx(hlf:pwm,hlm)*xx(hlf:pwm,hlf) $
		+ yy(hlf:pwm,hlm)*yy(hlf:pwm,hlf) )

				;Total dot product from bottom to center.
		n3 = total( $
		  xx(hlm,0:hlm)*xx(hlf,0:hlm) $
		+ yy(hlm,0:hlm)*yy(hlf,0:hlm) )

				;Find best dot product sum.
		best = max([   $
		   n0+n1+n2+n3 $
		, -n0+n1+n2-n3 $
		, -n0-n1+n2+n3 $
		,  n0-n1+n2-n3 $
		,  n0-n1-n2+n3 $
		, -n0+n1-n2+n3 $
		,  n0+n1-n2-n3 $
		, -n0-n1-n2-n3 ])

				;Flip quadrants to get best dot product sum. 
		case !C of
				;Already have best score.
		0:  goto, break0

				;Flip lower left quadrant.
		1:  begin
			xx(0:hlm,0:hlm) = -xx(0:hlm,0:hlm)
			yy(0:hlm,0:hlm) = -yy(0:hlm,0:hlm)
		    end
				;Flip upper left quadrant.
		2:  begin
			xx(0:hlm,hlf:pwm) = -xx(0:hlm,hlf:pwm)
			yy(0:hlm,hlf:pwm) = -yy(0:hlm,hlf:pwm)
		    end
				;Flip left half.
		3:  begin
			xx(hlf:pwm,0:pwm) = -xx(hlf:pwm,0:pwm)
			yy(hlf:pwm,0:pwm) = -yy(hlf:pwm,0:pwm)
		    end
				;Flip upper right quadrant.
		4:  begin
			xx(hlf:pwm,hlf:pwm) = -xx(hlf:pwm,hlf:pwm)
			yy(hlf:pwm,hlf:pwm) = -yy(hlf:pwm,hlf:pwm)
		    end
				;Flip upper half.
		5:  begin	
			xx(0:pwm,hlf:pwm) = -xx(0:pwm,hlf:pwm)
			yy(0:pwm,hlf:pwm) = -yy(0:pwm,hlf:pwm)
		    end
				;Flip lower right quadrant.
		6:  begin
			xx(hlf:pwm,0:hlm) = -xx(hlf:pwm,0:hlm)
			yy(hlf:pwm,0:hlm) = -yy(hlf:pwm,0:hlm)
		    end
				;Flip upper left & lower right quadrants.
		7:  begin
			xx(0:hlm,hlf:pwm) = -xx(0:hlm,hlf:pwm)
			yy(0:hlm,hlf:pwm) = -yy(0:hlm,hlf:pwm)
			xx(hlf:pwm,0:hlm) = -xx(hlf:pwm,0:hlm)
			yy(hlf:pwm,0:hlm) = -yy(hlf:pwm,0:hlm)
		    end

		end
				;Save changes.
		bx(x0:x1,y0:y1) = xx(0:xa,0:ya)
		by(x0:x1,y0:y1) = yy(0:xa,0:ya)

		break0:
	end
	end
end
				;Set where there are changes.
wads = where( bx ne bx0  or  by ne by0, nchg )

				;Return if the number of changes is less
				;than half the data set.
if  2*nchg le nsdat  then  return, wads

				;Return inverted where array.
tmp = sdat
tmp(wads) = 0
return, where( tmp, nchg )

end
