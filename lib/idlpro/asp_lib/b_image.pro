pro b_image_usage
;+
;
;	function:  b_image
;
;	purpose:  return a 2D array of an a_* file dumped by program "bite"
;		  expansions of *.bi files with the -x option
;
;	routines: b_image_usage  b_image_str  b_image
;
;	author:  paul@ncar, 4/93	(minor mod's by rob@ncar)
;
;==============================================================================
;
if 1 then begin
	print
	print, "usage:	image = b_image( a_file )"
	print
	print, "	Return a 2D array of a_* file dumped by program 'bite'"
	print, "	expansions of *.bi files with the -x option."
	print
	print, "	Arguments"
	print, "		a_file	- string variable with file path"
	print, "			  (the directory must hold several" 
	print, "			  other a_* files for the function"
	print, "			  to work; the a_file is assumed to"
	print, "			  be imageable)"
	print, "	Keywords"
	print, "		bkg	- input background value (def=0.)"
	print, "		b_str	- output structure of data and"
	print, "			  directory (def=not output)"
	print, "		reuse	- reuse b_str if it exists,"
	print, "			  do not recompute b_str."
	print, "			  Must be same directory."
	print
	print, "   ex:"
	print, "	a_path = '/hilo/d/asp/data/red/92.06.19/op9/a_1incl'"
	print, "	b_1incl = b_image( a_path, bkg=90., b_str=b )"
	print
	return
endif
;-
end
;------------------------------------------------------------------------------
;
;	procedure:  b_image_str
;
;	purpose:  return structure for producing 2D images from
;		  expansions of *.bi files with the -x option
;
;------------------------------------------------------------------------------
pro b_image_str, b, a_file
		    ;
		    ;Isolate directory path by finding last '/'.
		    ;
j = -1
i =  0
while  i ne -1  do begin
	i = strpos( a_file, '/', i )
	if  i ne -1  then  begin
		j = i
		i = i+1
	end
end
dty = strmid( a_file, 0, j+1 )
		    ;
		    ;Read header(0:127) to get y-dimension used to
		    ;generate raster point numbers.
		    ;
		    ;Warning, header(0:127) isn't all floating point.
		    ;IDL's "help, header" will look funny.
		    ;
a___header = read_floats( dty+'a___header' )
		    ;
		    ;Y-dimension is element 57 of a___header(0:127).
		    ;For ASP these are positions along the slit.
		    ;Inversion code gets this value from model files.
		    ;Default (at this time) in the inversion code is 256.
		    ;Recomend 256 be even if all slit positions aren't kept.
		    ;
nspan  = round( a___header(57) )
		    ;
		    ;Read the array of raster point numbers.
		    ;These may not have a corresponding stokes inversion
		    ;depending on polarization.
		    ;These are used to number the raster points
		    ;in a__* files (note two underscores).
		    ;
a__points  = round( read_floats( dty+'a__points' ) )
		    ;
		    ;Read the array of raster point numbers that.
		    ;have a corresponding stokes inversion.
		    ;These are used to number the raster points
		    ;in a_* files (note one underscore).
		    ;
a_solved = round( read_floats( dty+'a_solved' ) )
		    ;
		    ;Convert the raster point numbers to x & y values.
		    ;x corresponds to an ASP steps.
		    ;y corresponds to a postions along the slit.
		    ;y varies fastest (reversed below for 2D images).
		    ;
xpnt = a__points/nspan
ypnt = a__points-xpnt*nspan
xslv = a_solved/nspan
yslv = a_solved-xslv*nspan
		    ;
		    ;Find ranges of x and y.
		    ;
x0 = min( xpnt, max=x1 )
y0 = min( ypnt, max=y1 )
		    ;
		    ;Get image dimensions.
		    ;IDL coordinates will agree with ASP coordinates
		    ;iff asp scan numbers are not truncated from x=0
		    ;and position along the slit are not truncated 
		    ;from y=0.
		    ;
xdim = x1-x0+1
ydim = y1-y0+1
		    ;
		    ;Form where() arrays used to move a_vectors to b_images.
		    ;Note that x varies fastest.
		    ;
pxy = (ypnt-y0)*xdim + (xpnt-x0)
sxy = (yslv-y0)*xdim + (xslv-x0)
		    ;
		    ;Form where arrays for background locations.
		    ;
tmp = replicate( 1, xdim, ydim )
tmp( sxy ) = 0
sbkg = where( tmp )
tmp( pxy ) = 0
pbkg = where( tmp )
		    ;
		    ;Length of stream files.
		    ;
npxy = long( n_elements(pxy) )
nsxy = long( n_elements(sxy) )
		    ;
		    ;Read continuum data file.
		    ;
a_data = read_floats( dty+'a__cct' )
		    ;
		    ;Find continuum min max away from hair lines.
		    ;
whr = where( ypnt gt 50 and ypnt lt 180, nwhr )
if  nwhr ne 0  $
then  cct_min = min( a_data(whr), max=cct_max ) $
else  cct_min = min(      a_data, max=cct_max )
		    ;
		    ;Set structure of the image and directory.
		    ;
b =						$
{ index		: 0L				$
, stretch	: 0L				$
, npoints	: npxy				$
, nsolved	: nsxy				$
, npxy		: npxy				$
, nsxy		: nsxy				$
, x0		: x0				$
, y0		: y0				$
, xpnt		: xpnt				$
, ypnt		: ypnt				$
, cct_min	: cct_min			$
, cct_max	: cct_max			$
, mxfld		: 4000L				$
, head		: a___header			$
, xdim		: xdim				$
, ydim		: ydim				$
, pxy		: pxy				$
, sxy		: sxy				$
, vec_pxy	: lindgen( npxy )		$
, vec_sxy	: lindgen( nsxy )		$
, pbkg		: pbkg				$
, sbkg		: sbkg				$
, pix_deg	: 0.				$
, mm_per_deg    : 12.148			$
, dty		: dty				$
}
		    ;
end
;------------------------------------------------------------------------------
;
;	function:  b_image
;
;	purpose:  return a 2D array of an a_* file dumped by program "bite"
;		  expansions of *.bi files with the -x option
;
;------------------------------------------------------------------------------
function b_image, a_file, bkg=bkg, b_str=b, reuse=reuse
		    ;
		    ;Check number of parameters.
		    ;
if n_params() eq 0 then begin
	b_image_usage
	return, 0
end
		    ;
		    ;On reuse keyword skip b_str calculation.
		    ;
if n_elements(reuse) eq 0 then reuse = 0
if n_elements(b    ) eq 0 then reuse = 0
if reuse eq 0 then b_image_str, b, a_file
		    ;
		    ;Return 2D image.
		    ;
return, s_image( a_file, b, bkg=bkg )
		    ;
end
