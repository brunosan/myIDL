pro profile1, image, row=row, col=col, xtitle=xtitle, minv=minv, maxv=maxv, $
	      wsize = wsize, order = order, ticks=ticks, minor=minor
;+
;
;	procedure:  profile1
;
;	purpose:  do "profiles" on an image for a given row or column
;
;	author:  rob@ncar, 3/92
;
;	notes:  - used code from RSI's "profiles" procedure
;		- add PostScript output option?
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() lt 1 then begin
usage:
	print
	print, "usage:  profile1, image"
	print
	print, "	Do 'profiles' on an image for a given row or column."
	print, "	Be sure to specify the 'row' OR 'col' keyword."
	print, "	Set both minv and maxv, or neither."
	print
	print, "	Arguments"
	print, "		image	  - the image array; data need not be"
	print, "			    scaled into bytes, i.e., it"
	print, "			    may be floating."
	print, "	Keywords"
	print, "		row	  - the row to do a profile on"
	print, "			    (def = use 'col')"
	print, "		col	  - the column to do a profile on"
	print, "			    (def = use 'row')"
	print, "		xtitle	  - the title of the X-axis"
	print, "			    (def = no title)"
	print, "		minv	  - minimum value of dependent axis"
	print, "			    (def = let IDL choose)"
	print, "		maxv	  - maximum value of dependent axis"
	print, "			    (def = let IDL choose)"
	print, "		wsize	  - size of new window as a fraction"
	print, "			    or multiple of (640, 512)"
	print, "			    (def = 1.0)"
	print, "		order	  - set to 1 for images written top"
	print, "			    down, 0 for bottom up."
	print, "			    (def = current !ORDER)"
	print
	return
endif
;-
;
;	Set to return to caller on error.
;
on_error,2
;
;	Set keywords.
;
if (n_elements(row) eq 0) and (n_elements(col) eq 0) then goto, usage
if (n_elements(row) ne 0) and (n_elements(col) ne 0) then goto, usage

if n_elements(row) eq 0 then begin
	row = 0
	mode = 1
endif

if n_elements(col) eq 0 then begin
	col = 0
	mode = 0
endif

if n_elements(xtitle) eq 0 then xtitle = ''

if ((n_elements(minv) eq 0) and (n_elements(maxv) ne 0)) or $
   ((n_elements(minv) ne 0) and (n_elements(maxv) eq 0)) then goto, usage

if n_elements(minv) eq 0 then begin
	style = 0
	minv = min(image)
	maxv = max(image)
endif else style = 1

if n_elements(wsize) eq 0 then wsize = 1.0
if n_elements(order) eq 0 then order = !order
if n_elements(ticks) eq 0 then ticks = 0
if n_elements(minor) eq 0 then minor = 0
;
;	Set parameters.
;
x = col
y = row
s = size(image)
nx = s(1)					;Cols in image
ny = s(2)					;Rows in image
if (x lt 0) or (x gt nx) then begin
	print
	print, 'col out of range 0 to ' + stringit(nx)
	print
	return
endif
if (y lt 0) or (y gt ny) then begin
	print
	print, 'row out of range 0 to ' + stringit(ny)
	print
	return
endif
;
;	Set the window.
;
window, /free , xs=wsize*640, ys=wsize*512, title=''
;;window, 127 , xs=wsize*640, ys=wsize*512, title='', ypos=200
;
;	Set for hardware font.
;
old_font = !p.font
!p.font = 0
;
;	Draw profile plot.
;
if order then y = (ny-1)-y			;Invert y

if mode then begin				;get column
	vecy = findgen(ny)
	vecx = image(x,*)
endif else begin				;get row
	vecx = findgen(nx)
	vecy = image(*,y)
endelse
;
;		Set up and plot profiles.
;
if mode then begin				;Column profile
	plot,[minv,maxv],[0,ny-1],/nodata, $
		xtitle=xtitle, xstyle=style, xticks=ticks, xminor=minor
	oplot,vecx,vecy
	str = 'Column ' + stringit(col) + ' Profile'
	xyouts, .5, .975, /norm, align=.5, str

end else begin					;Row profile
	plot,[0,nx-1],[minv,maxv],/nodata, $
		xtitle=xtitle, ystyle=style, yticks=ticks, yminor=minor
	oplot,vecx,vecy
	str = 'Row ' + stringit(row) + ' Profile'
	xyouts, .5, .975, /norm, align=.5, str
endelse
;
;	Done.
;
!p.font = old_font				;Return original font
end
