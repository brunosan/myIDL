pro tvwin, array, free=free, tv=tv, profiles=profiles, title=title, $
	xr=xr, yr=yr, currw=currw
;+
;
;	function:  tvwin
;
;	purpose:  open up a window the dimensions of the plot and plot it
;
;	author:  rob@ncar, 1/92
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 1 then begin
	print
	print, "usage:  tvwin, array"
	print
	print, "	Plot an array in a window of the size of the array."
	print
	print, "	Arguments"
	print, "	    array	- input array to plot"
	print
	print, "	Keywords"
	print, "	    free	- if set, open window with an unused"
	print, "		          index (def=open window of index 0)"
	print, "	    currw	- if set, use current window"
	print, "		          (def=open new window a la 'free')"
	print, "	    profiles	- if set, do profiles on the plot"
	print, "		          (def=no profiles)"
	print, "	    title	- window title"
	print, "		          (def=use IDL default)"
	print, "	      tv	- if set, use tv to plot"
	print, "		          (def=use tvscl)"
	print, "	      xr	- factor to rebin X with (def=1=none)"
	print, "	      yr	- factor to rebin Y with (def=1=none)"
	print
	return
endif
;-
;
;	Check number of dimensions.
;
if sizeof(array, 0) ne 2 then begin
	print
	print, 'Must be a 2-D array.'
	print
	return
endif
;
;	Set general parameters.
;
true = 1
false = 0
do_rebin = false
;
;	Get dimensions of array.
;
nx = sizeof(array, 1)
ny = sizeof(array, 2)
;
;	Handle resizing of array.
;
if n_elements(xr) ne 0 then begin
	do_rebin = true
	nx = nx * xr
endif
if n_elements(yr) ne 0 then begin
	do_rebin = true
	ny = ny * yr
endif
if do_rebin  then arr = rebin(array, nx, ny, sample=1)    else arr = array
;
;	Open window.
;
if not keyword_set(currw) then begin
	if n_elements(title) eq 0 then begin
		window, xsize=nx, ysize=ny, free=free
	endif else begin
		window, xsize=nx, ysize=ny, free=free, title=title
	endelse
endif
;
;	Plot.
;
if keyword_set(tv)  then tv, arr    else tvscl, arr
;
;	Profile.
;
if keyword_set(profiles) then profiles, arr
;
end
