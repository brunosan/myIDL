function reversal, b_1incl, b__pip, b $
, pip_min=pip_min
;+
;
;	function:  reversal
;
;	purpose:  return where() in b_1incl there is magnetic field reversal
;
;	author:  paul@ncar, 4/93	(minor mod's by rob@ncar)
;
;==============================================================================
;
;       Check number of parameters.
;
if n_params() eq 0 then begin
	print
	print, "usage:	highlight = reversal( b_1incl, b__pip, b )	-or-"
	print, "	highlight = reversal( b_2incl, b__pip, b )	-or-"
	print, "	highlight = reversal( c_1incl, c__pip, c )	-or-"
	print, "	highlight = reversal( c_2incl, c__pip, c )"
	print
	print, "	Return where() array for 90. degree contour"
	print, "	in inclination."
	print
	print, "	Arguments"
	print, "		b_1incl	- 2D image of of magnetic field"
	print, "		b_2incl   inclination (0. to 180. degrees)"
	print, "		c_1incl"
	print, "		c_2incl"
	print
	print, "		b__pip	- 2D image of spectral polarization"
	print, "		c__pip 	  percent on a grid corresponding to"
	print, "			  the inclination array"
	print
	print, "		b, c	- structure of data and directory as"
	print, "			  returned by function b_image() or"
	print, "			  c_image()"
	print, "	Keywords"
	print, "		pip_min - polarization percent minimum"
	print, "			  for reversal (def=.8)"
	print
	return, 0
endif
;-

reversal =  cont( b_1incl, b.sxy, 90. )

if  n_elements(pip_min) eq 0  then  pip_min = .8
if  pip_min eq .0  then  return, reversal

tmp = lonarr( b.xdim, b.ydim )
tmp(reversal) = 1
whr = where( b__pip lt pip_min, nwhr )
if  nwhr ne 0  then  tmp(whr) = 0
return, where( tmp )

end
