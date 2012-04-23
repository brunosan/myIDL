function scalew, array, ncolors, nodat
;+
;
;	function:  scalew
;
;	purpose:  scale array for use with "colorw.pro" colormap
;
;	author:  rob@ncar, 4/93
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() lt 2 then begin
	print
	print, "usage:  a_byte = scalew( array, ncolors [,nodat] )"
	print
	print, "	Scale array for use with 'colorw.pro' colormap."
	print
	print, "	Arguments"
	print, "		array	- array to scale"
	print, "		ncolors	- number of avail. colors"
	print, "		nodat	- optional WHERE array corresponding"
	print, "			  to data to be given unique color"
	print
	print, "	Keywords"
	print, "		(none)"
	print
	print
	print, "   ex:  nc = get_ncolor()"
	print, "        nodat = where(fld eq 0.0)"
	print, "        fldb = scalew(fld, nc, nodat)"
	print
	print, "        colorw"
	print, "        tvwin, /tv, fldb"
	print
	return, 0
endif
;-
;
;	Scale image to use all colors but one.
;
a = bytscl(array, top=ncolors-1) + 1
;
;	Optionally fill part of image with special index.
;
if n_params() eq 3 then a(nodat) = 0
;
;	Return image.
;
return, a
end
