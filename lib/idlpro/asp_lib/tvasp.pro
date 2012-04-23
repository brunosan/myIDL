pro tvasp, image, x0, y0 $
	, red_blue=red_blue $
	, gray=gray, center=center, min=min, max=max $
	, yellow=yellow, white_nd=white, black_nd=black, wrap=wrap $
	, invert=invert $
	, notv=notv, bi=bi
;+
;
;	procedure:  tvasp
;
;	purpose:  perform special ASP scaling on an image
;
;	author:  paul@ncar, 11/92  (mod's by rob@ncar)
;
;==============================================================================
;
;	Check number of parameters.
;
if  n_params() eq 0  then begin
	print
	print, "usage:  tvasp, image [, x0 [, y0]]"
	print
	print, "	Perform special ASP scaling on an image."
	print, "	Use tvasp like TVSCL.  Note that a special colormap"
	print, "	is installed consisting of a grayscale followed by a"
	print, "	colorscale.  Images of both types may be displayed"
	print, "	simultaneously."
	print
	print, "	Arguments:"
	print, "	    image	- image to display"
	print, "	    x0, y0	- lower left corner of image within"
	print, "		          window (pixels; defs=0)"
	print
	print, "	Keywords:"
	print, "	    red_blue	- if set, the colormap loaded"
	print, "	       	          is a grayscale table followed"
	print, "	       	          by a red-blue table"
	print, "		          (def=load grayscale table followed"
	print, "		           by a green-yellow-red-magenta-blue"
	print, "		           -cyan-green)"
	print, "	    min, max	- range at which to scale the image"
	print, "		          (defs=min(image) to max(image))"
	print, "	    invert	- if set, invert color scale for this"
	print, "		          image (def=don't invert)"
	print, "	    gray	- if set, use grayscale for this"
	print, "		          image (def=use colored indices)"
	print, "	    wrap	- if set, and if green-yellow-red"
	print, "	    		  -magenta-blue-cyan-green table"
	print, "		          is used for this image;"
	print, "		          use green portion of table for wrap"
	print, "		          around (ignored if using gray or"
	print, "		          red-blue scale)"
	print, "		          (def=use yellow-red-megenta-blue"
	print, "			  -cyan; 2/3 of the color indices)"
	print, "	    center	- percent of color map to fill gray" 
	print, "		          or black; this in effect makes a"
	print, "		          red-gray-blue image or a"
	print, "		          yellow-red-black-blue-yellow image;"
	print, "		          1% is about 1.2 color indices;"
	print, "		          it has no effect on color table"
	print, "		          (def=no gray|black region)"
	print, "	    yellow	- subscripts of image to mark"
	print, "		          yellow, i.e., result of WHERE"
	print, "		          function where you want the image"
	print, "		          highlighted yellow (def=not applied)"
	print, "	    white_nd	- subscripts of image where no data"
	print, "		          exists, i.e., result of WHERE"
	print, "		          function where you want the image"
	print, "		          displayed as white (def=not applied)"
	print, "	    black_nd	- subscripts of image where no data"
	print, "		          exists, i.e., result of WHERE"
	print, "		          function where you want the image"
	print, "		          displayed as black (def=not applied)"
	print, "	    notv	- if set, do not alter display"
	print, "	    bi		- returned byte image"
	print
	print
	print, "   ex:  tvasp, ii, 10, 10, min=-3000, max=3000, /gray"
	print
	return
endif
;-
		    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		    ;
		    ;Common area used by IDL library routines.
		    ;
common colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr
		    ;
		    ;Commons with information about tvasp color table.
		    ;
@tvasp.com
common tvasp_only, r_tvasp, g_tvasp, b_tvasp $
, n_colors, red_blue_com
		    ;
		    ;Get number of available colors on first entry.
		    ;For output to PostScript, tvasp should be called
		    ;at least once from X windows before going into
		    ;PostScript.
		    ;
if n_elements(n_colors) eq 0 then begin
	w_sav = !d.window
	window, /free, /pixmap, xs=1, ys=1
	n_colors = !d.n_colors
	wdelete, !d.window
	if w_sav ge 0 then  wset, w_sav
end
n_colors = !d.n_colors < n_colors
		    ;
		    ;Check if color arrays need to be reset.
		    ;
if n_elements(red_blue_com) eq 0 then  red_blue_com = -9876
		    ;
		    ;Set default to use colors and not gray scale.
		    ;
if  n_elements( gray ) eq 0  then  gray = 0
		    ;
		    ;Color indices will be devided in two halves.
		    ;Special colors are reserved at the end.
		    ;See "special color indices" below.
		    ;Last color entry will be used for labeling (set white).
		    ;'half' is assured to be divisable by 6.
		    ;
num_special = 7
half = ((n_colors-num_special)/12)*6
		    ;
		    ;Set ramp from 0 to 255 to fit half.
		    ;
ramp = (indgen(half)*255 + half/2) / (half-1)
		    ;
		    ;Allocate space for current color arrays.
		    ;
r_tvasp = intarr(n_colors)
g_tvasp = r_tvasp
b_tvasp = r_tvasp
		    ;
		    ;Set gray scale in lower half of colors.
		    ;
ix1 = 0
ix2 = half - 1
r_tvasp( ix1 : ix2 ) = ramp
g_tvasp( ix1 : ix2 ) = ramp
b_tvasp( ix1 : ix2 ) = ramp
		    ;
		    ;Set first color index used and number colors used.
		    ;
idxclr = half
numclr = half
		    ;
		    ;Check if red_blue color table is to be used.
		    ;
if  n_elements( red_blue ) eq 0  then  red_blue = 0
if  not red_blue then begin
		    ;
		    ;Set variation in color scale.
		    ;
	lgt = 255L
	tip = replicate( lgt, half )
	tip(0:half/3-1) = findgen(half/3)*lgt/(half/3)+.5
	tip(2*half/3:half-1) = reverse( tip(0:half/3-1) )
		    ;
		    ;Set RGB scale with middle brightness shifted.
		    ;
	red = shift( tip, 5*half/6 )
	gre = shift( tip, 3*half/6 )
	blu = shift( tip,   half/6 )
		    ;
		    ;Move colors scale to common arrays.
		    ;
	ix1 = half
	ix4 = half+half-1
	r_tvasp(ix1:ix4) = red
	g_tvasp(ix1:ix4) = gre
	b_tvasp(ix1:ix4) = blu
		    ;
		    ;If colors are used and yellow wraps into green
		    ;reset first color index used and number colors used
		    ;
	if  n_elements( wrap ) eq 0  then wrap=0
	if  wrap eq 0  and  gray eq 0  then begin
		idxclr = half+half/6
		numclr = half-half/3
	end
		    ;
end else begin
		    ;
		    ;Set third quadrant to a red scale, bright to dark.
		    ;
	ix1 = half
	ix2 = half + half/2 - 1
	r_tvasp( ix1 : ix2 ) = reverse( ramp( half/2 : half-1 ) )
	g_tvasp( ix1 : ix2 ) = 0
	b_tvasp( ix1 : ix2 ) = 0
		    ;
		    ;Set forth quadrant to a blue scale.
		    ;
	ix1 = half + half/2
	ix2 = half + half - 1
	r_tvasp( ix1 : ix2 ) = 0
	g_tvasp( ix1 : ix2 ) = 0
	b_tvasp( ix1 : ix2 ) = ramp( half/2 : half-1 )
		    ;
end
		    ;
		    ;Set special color indices (c3 = center color).
		    ;
if  red_blue  then  c3 = 128   else c3 = 0
m = n_colors - num_special
n = n_colors - 1
r_tvasp( m : n ) = [ 180,   0,   0, 255, 255, c3, 255 ]
g_tvasp( m : n ) = [ 180,   0, 255,   0, 255, c3, 255 ]
b_tvasp( m : n ) = [ 180, 255,   0,   0,   0, c3, 255 ]
		    ;
		    ;Save special color indices in common.
		    ;
@tvasp.set
tvasp.ix_white  = n_colors - 1
tvasp.ix_center = n_colors - 2
tvasp.ix_yellow = n_colors - 3
tvasp.ix_red    = n_colors - 4
tvasp.ix_green  = n_colors - 5
tvasp.ix_blue   = n_colors - 6
tvasp.ix_gray   = n_colors - 7
tvasp.ix_black  = 0
		    ;
		    ;Load color table.
		    ;
r_curr = r_tvasp
g_curr = g_tvasp
b_curr = b_tvasp
tvlct, r_curr, g_curr, b_curr
		    ;
		    ;Set default lower left corner to (0,0).
		    ;
if n_elements( x0 ) eq 0 then  x0 = 0
if n_elements( y0 ) eq 0 then  y0 = 0
		    ;
		    ;Get image dimensions.
		    ;
tmp = n_dims( image, xdim, ydim )
		    ;
		    ;If there is no active image window open one.
		    ;
if  n_elements(notv) eq 0  then  notv=0
if  not notv  and  !d.window eq -1  then begin
	window, /free, xsize=x0+xdim, ysize=y0+ydim
end
		    ;
		    ;Determine if where() array exists for special
		    ;color indices.
		    ;
haveYellow = n_dims( yellow ) gt 0
haveWhite  = n_dims( white  ) gt 0
haveBlack  = n_dims( black  ) gt 0
		    ;
		    ;Set pointers to where data exists.
		    ;
if  haveWhite or haveBlack  then begin
	exist = replicate( 1, xdim, ydim )
	if  haveWhite  then  exist( white ) = 0
	if  haveBlack  then  exist( black ) = 0
	exist = where( exist, nwhr )
	if  nwhr eq 0  then begin
		    ;
		    ;Return if everything is background.
		    ;
		bi = bytarr(xdim,ydim)
		if  haveWhite   then  bi( white ) = tvasp.ix_white
		if notv eq 0 then  tv, bi, x0, y0
		return
	end
end
		    ;
		    ;Get floating point data.
		    ;
if  haveWhite or haveBlack  then begin
	fimage = float(image(exist))
end else begin
	fimage = float(image)
end
		    ;
		    ;If not keywords, find min and max to scale to.
		    ;
if  n_elements( min ) eq 0  then  min = min( fimage )
if  n_elements( max ) eq 0  then  max = max( fimage )
		    ;
		    ;Scale the image.
		    ;Note bimage is floating point.
		    ;
if  max-min ne 0.  then begin
	bimage = ( (min > fimage < max) - min ) * ( (numclr-1.)/(max-min) )
end else begin
	bimage = fimage
	bimage( * ) = .5*( half - 1. )
end
		    ;
		    ;Invert color scale on keyword.
		    ;
if  n_elements( invert ) eq 0  then  invert = 0
if  invert ne 0  then  bimage = numclr-1.-bimage
		    ;
		    ;Check if colors are to be used.
		    ;
if  gray ne 0  then begin
		    ;
		    ;No colors.  Its not needed but convert to integer.
		    ;
	bimage =  round( bimage )
		    ;
end else begin
		    ;
		    ;Set default percent of middle grey colors to 0.
		    ;
	if  n_elements( center ) eq 0  then  center = 0
		    ;
		    ;Check for middle gray colors.
		    ;
	if  center eq 0  then begin
		    ;
		    ;Add offset to red-blue indices and convert to integer.
		    ;
		bimage = round( idxclr+bimage )
		    ;
	end else begin
		    ;
		    ;Number of indices extension for middle grays. 
		    ;Round to nearest integer.
		    ;
		grays = round( (center*numclr)/(100.-center) )
		    ;
		    ;Scale image to half plus grays.
		    ;
		bimage = bimage*(numclr+grays-1.)/(numclr-1.) 
		    ;
		    ;Convert to integer.
		    ;
		bimage = round( bimage )
		    ;
		    ;Find where grays are to be set.
		    ;
		whr_gray = $
			where( bimage ge numclr/2 and $
			       bimage lt numclr/2+grays $
			     , num_gray )
		    ;
		    ;Squeeze out grays by offseting blues.
		    ;
		whr_blue = where( bimage ge numclr/2+grays $
				, num_blue )
		if  num_blue ne 0  then $
			bimage( whr_blue ) = bimage( whr_blue ) - grays
		    ;
		    ;Add offset to red-blue color indices.
		    ;
		bimage =  idxclr+bimage
		    ;
		    ;Set middle grays.
		    ;
		if  num_gray ne 0  then $
			bimage( whr_gray ) = tvasp.ix_center
		    ;
	end
		    ;
end
		    ;
if  haveWhite or haveBlack  then begin
		    ;
		    ;Recover 2D image.
		    ;
	tmp = lonarr( xdim, ydim )
	tmp( exist ) = bimage
	if  haveYellow  then  tmp( yellow ) = tvasp.ix_yellow
	if  haveWhite   then  tmp(  white ) = tvasp.ix_white
		    ;
		    ;Display the image.
		    ;
	bi = byte( tmp )
	if notv eq 0 then  tv, bi, x0, y0
		    ;
end else begin
		    ;
		    ;Set yellow pixels on keyword.
		    ;
	if  haveYellow  then  bimage( yellow ) = tvasp.ix_yellow
		    ;
		    ;Display the image.
		    ;
	bi = byte( bimage )
	if notv eq 0 then  tv, bi, x0, y0
		    ;
end
		    ;
end
		    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
