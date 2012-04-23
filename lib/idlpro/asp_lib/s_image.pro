function s_image, a_file, b, bkg=bkg
;+
;
;	function:  s_image
;
;	purpose:  return a 2D array of an a_* file dumped by program "bite"
;		  expansions of *.bi files with the -x option.
;		  Structure b of data and directory must already exist
;		  and can be for unstretched or stretched images or
;		  non zoom azam structure.
;
;	author:  paul@ncar, 11/93	(minor mod's by rob@ncar)
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() eq 0 then begin
	print
	print, "usage:	image = s_image( a_file, b )"
	print
	print, "	Return a 2D array of a_* file dumped by program 'bite'"
	print, "	expansions of *.bi files with the -x option."
	print, "	Structure b of data and directory must already exist"
	print, "	and can be for unstretched or stretched images or"
	print, "	non zoom azam structure."
	print
	print, "	Arguments"
	print, "		a_file	- string variable with file path"
	print, "			  (the directory must hold several" 
	print, "			  other a_* files for the function"
	print, "			  to work; the a_file is assumed to"
	print, "			  be imageable)"
	print, "		b	- input structure of data and"
	print, "			  directory."
	print
	print, "	Keywords"
	print, "		bkg	- input background value (def=0.)"
	print
	print, "   ex:"
	print, "	a_path = '/hilo/d/asp/data/red/92.06.19/op9/a_1incl'"
	print, "	b_1incl = s_image( a_path, b, bkg=90. )"
	print
	return, 0
endif
;-
		    ;
		    ;Read data file.
		    ;
a_data = read_floats( a_file )
		    ;
		    ;Get file name.
		    ;
a_name = strcompress( strmid( a_file, strlen( b.dty), 1000 ), /remove_all )
		    ;
		    ;Put local frame azimuth in range -180. to 180.
		    ;
if  a_name eq 'a_1azm'  or  a_name eq 'a_2azm'  then begin
	whr = where( a_data gt 180., nwhr )
	if nwhr ne 0 then  a_data(whr)=a_data(whr)-360.
end
		    ;
		    ;Allocate 2D image array and install background.
		    ;
if  n_elements(bkg) eq 0  then  bkg = 0.
image = replicate( float(bkg), b.xdim, b.ydim )
		    ;
		    ;Check for stretched images.
		    ;
if b.stretch then begin
		    ;
		    ;Check if unsolved raster points are in image.
		    ;Expand data vector to right number of points and
		    ;move data into 2D array.
		    ;
	if  n_elements(a_data) eq b.npoints $
	then  image( b.pxy ) = a_data( b.vec_pxy ) $
	else  image( b.sxy ) = a_data( b.vec_sxy )
		    ;
end else begin
		    ;
		    ;Check if unsolved raster points are in image.
		    ;Move data into 2D array.
		    ;
	if  n_elements(a_data) eq b.npoints $
	then  image( b.pxy ) = a_data $
	else  image( b.sxy ) = a_data
		    ;
end
		    ;
		    ;Return 2D image as function value.
		    ;
return, image
		    ;
end
