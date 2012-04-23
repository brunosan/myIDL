function azam_smooth, azm, fld, psi, sdat, nchg, x0, y0, aax, aay
;+
;
;	function:  azam_smooth
;
;	purpose:  return WHERE() magnetic field is likely ambiguous
;		  point to point over the field arrays.
;
;	author:  paul@ncar, 5/94	(minor mod's by rob@ncar)
;
;==============================================================================
;
;       Check number of parameters.
;
if n_params() eq 0 then begin
	print
	print, "usage:	ambig = azam_smooth( azm, fld, psi, sdat, nchg )"
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
	print, "		x0 y0	- lower left position of sub array"
	print, "		aax aay	- dimensions of image"
	print, "			  in calling program"
	print
	print, "	Keywords"
	print, "		(none)"
	print
	return, -1
endif
;-
;							5/25/94
;
; There is a new option (smooth) available with the interactive mouse.
; To enable click on the lower right display button till it says (smooth).
; (smooth) is then run by moving the mouse with the right button pressed.
;
; (smooth) works on point to point continuity of the magnetic field.
; All azimuth changes with (smooth) improve continuity.  Lets say
; the mouse is working on (8x8) sub arrays.  With (smooth) only the 
; inner 6x6 are allowed to change.  By holding the mouse boundary fixed
; continuity outside the mouse boundary is not effected.
; Continuity of the inner 6x6 is force to the boundary.
; 
; The (wads) algorithm does not preserve continuity outside the
; mouse boundary.  For the bulk of work involving continuity
; you should use (wads).  (wads) can move the ambiguous boundaries
; boldly.
;
; For fine details use (smooth).  I do not recomend you use (smooth)
; till you are about done.  It will effect only ambiguous boundaries.
; I recomend (8x8) sub arrays when running (smooth).
;
;	 						5/25/94
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
;-----------------------------------------------------------------------------

				;Get dimension.
if n_dims( azm, xdim, ydim ) ne 2 then  return, -1

				;Test for null conditions.
nchg = 0
if  total(sdat) eq 0          then return, -1
if  xdim lt 2  or  ydim lt 2  then return, -1

				;Compute x y field components.
bx  = azm*(!pi/180.)
by  = fld*sin(psi*(!pi/180.))*sdat
bxs = round(by*cos(bx))
bys = round(by*sin(bx))
				;Get copy with zero edge.
bx = lonarr(xdim+2,ydim+2)  &  bx(1:xdim,1:ydim) = bxs
by = lonarr(xdim+2,ydim+2)  &  by(1:xdim,1:ydim) = bys

				;Set flip boundary.
				;Go to edge if sub array extends to
				;edge in calling program.
if x0 gt 0 then  imn=2  else  imn=1
if y0 gt 0 then  jmn=2  else  jmn=1
if x0+xdim lt aax then  imx=xdim-1  else  imx=xdim
if y0+ydim lt aay then  jmx=ydim-1  else  jmx=ydim

				;Loop several times over arrays.
				;The outside boundary is not touched.
for  its=0,10 do begin
break = 1
for  iii=0,2 do begin
for  jjj=0,2 do begin
for  i=1+iii,xdim,3  do begin
for  j=1+jjj,ydim,3  do begin
if i ge imn and i le imx and j ge jmn and j le jmx then begin

				;Get total dot product of the point
				;with all its neighbors.
	sum = total(bx(i,j)*bx(i-1:i+1,j-1:j+1)+by(i,j)*by(i-1:i+1,j-1:j+1)) $
	     -bx(i,j)*bx(i,j)-by(i,j)*by(i,j)

				;Reverse field direction if total dot
				;product is negative.
	if sum lt 0. then begin
		break = 0
		bx(i,j) = -bx(i,j)
		by(i,j) = -by(i,j)
	end
end
end
end
end
end
if break then goto, break0
end
break0:
				;Set where there are changes.
return, where( bx(1:xdim,1:ydim) ne bxs or by(1:xdim,1:ydim) ne bys, nchg )

end
