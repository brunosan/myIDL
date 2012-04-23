pro prof4, im1, im2, im3, im4
;+
;
;	procedure:  prof4
;
;	purpose:  set up and do "profile4" on four images
;
;	author:  rob@ncar, 2/93
;
;	notes:  - see profile4.pro
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 4 then begin
	print
	print, "usage: prof4, im1, im2, im3, im4"
	print
	print, "	Set up and do 'profile4' on four images."
	print
	print, "	Arguments"
	print, "		i,q,u,v	  - the four images; data need not be"
	print, "			    scaled into bytes (i.e., they"
	print, "			    may be floating point arrays)"
	print
	print, "	Keywords"
	print, "		(none)"
	print
	return
endif
;-
;
;	Get image dimensions.
;
nx = sizeof(im1, 1)
ny = sizeof(im1, 2)
;
;	Set general parameters.
;
true = 1
false = 0
do_tv = false
border = 20
x1 = border
x2 = border * 2 + nx
x3 = x1
x4 = x2
y1 = border * 2 + ny
y2 = y1
y3 = border
y4 = y3
xsize = border*3 + nx*2
ysize = border*3 + ny*2
;
;	Open window and display images.
;
window, /free, xsize=xsize, ysize=ysize
window_ix = !d.window
tvscl, im1, x1, y1
tvscl, im2, x2, y2
tvscl, im3, x3, y3
tvscl, im4, x4, y4
;
;	Do profiling.
;
profile4, do_tv, im1, im2, im3, im4, x1, y1, x2, y2, x3, y3, x4, y4, /generic
wdelete, window_ix
;
end
