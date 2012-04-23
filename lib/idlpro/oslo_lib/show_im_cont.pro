pro show_im_cont, a,b,x,y,lev=lev,WINDOW_SCALE = window_scale, $
ASPECT = aspect, INTERP = interp,color=color,xtit=xtit,ytit=ytit, $
thick=thick,position=position,lsty=lsty
;+
; NAME:
;	SHOW_IM_CONT
;
; PURPOSE:
;	Overlay an image and a contour plot.
;
; CATEGORY:
;	General graphics.
;
; CALLING SEQUENCE:
;	SHOW_IM_CONT, A, B, [X, Y, LEV= , ...]
;
; INPUTS:
;	A:	A two-dimensional array to be display as the background.
;	B:	A two-dimensional array to make contour plot. B must have
;		the same size of A.
;	
; OPTIONAL INPUT:
;	X:	Optional ordinate values. It must be a vector with a length
;		equal to the first dimention of A and B.
;
;	Y:	Optional ordinate values. It must be a vector with a length
;		equal to the second dimention of A and B.
;
; KEYWORD PARAMETERS:
; WINDOW_SCALE:	Set this keyword to scale the window size to the image size.
;		Otherwise, the image size is scaled to the window size.
;		This keyword is ignored when outputting to devices with 
;		scalable pixels (e.g., PostScript).
;
;	ASPECT:	Set this keyword to retain the image's aspect ratio.
;		Square pixels are assumed.  If WINDOW_SCALE is set, the 
;		aspect ratio is automatically retained.
;
;	INTERP:	If this keyword is set, bilinear interpolation is used if 
;		the image is resized.
;
;	   LEV: Inputted Contour levels.
;	 THICK: Set this keyword to change the thickness of contour lines.
;		The vector must have the same elements as "LEV".
;
;	  LSTY: Set this keyword to change the linestyle of contour lines.
;		The vector must have the same elements as "LEV".
;        COLOR: Set this keyword to change the color of contour lines.
;		The vector must have the same elements as "LEV".
;	 Xtit:  Title on x-axis
;	 Ytit:  Title on y-axis
;     POSITION: Graphic keyword.
;
; OUTPUTS:
;	No explicit outputs.
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	The currently selected display is affected.
;
; RESTRICTIONS:
;	None.
;
; PROCEDURE:
;	If the device has scalable pixels, then the image is written over
;	the plot window.
;
; MODIFICATION HISTORY:
;	DMS, May, 1988.
;	Accept the most of keywords by Z. Yi, 1992.
;-

on_error,2                      ;Return to caller if an error occurs
sz = size(a)			;Size of image

if n_elements(lev) le 0 then lev=(findgen(5)/5.)*max(b)
if n_elements(lsty) le 0 then lsty=intarr(n_elements(lev))
if n_elements(xtit) gt 0 then !x.title=xtit
if n_elements(ytit) gt 0 then !y.title=ytit
if n_elements(thick) le 0 then thick=intarr(n_elements(lev))+1
if n_elements(position) gt 0 then position=position else position=[0,0,1,1]

if sz(0) lt 2 then message, 'Parameter not 2D'

	;set window used by contour
contour,[[0,0],[1,1]],/nodata, xstyle=4, ystyle = 4,position=position

px = !x.window * !d.x_vsize	;Get size of window in device units
py = !y.window * !d.y_vsize
swx = px(1)-px(0)		;Size in x in device units
swy = py(1)-py(0)		;Size in Y
six = float(sz(1))		;Image sizes
siy = float(sz(2))
aspi = six / siy		;Image aspect ratio
aspw = swx / swy		;Window aspect ratio
f = aspi / aspw			;Ratio of aspect ratios

if (!d.flags and 1) ne 0 then begin	;Scalable pixels?
  if keyword_set(aspect) then begin	;Retain aspect ratio?
				;Adjust window size
	if f ge 1.0 then swy = swy / f else swx = swx * f
  endif

  tvscl,a,px(0),py(0),xsize = swx, ysize = swy, /device
endif else begin	;Not scalable pixels	
   if keyword_set(window_scale) then begin ;Scale window to image?
	tvscl,a,px(0),py(0)	;Output image
	swx = six		;Set window size from image
	swy = siy
   endif else begin		;Scale window
	if keyword_set(aspect) then begin
		if f ge 1.0 then swy = swy / f else swx = swx * f
	endif		;aspect
	tvscl,poly_2d(a,$	;Have to resample image
		[[0,0],[six/swx,0]], [[0,siy/swy],[0,0]],$
		keyword_set(interp),swx,swy), $
		px(0),py(0)
   endelse			;window_scale
  endelse			;scalable pixels

if n_elements(color) le 0 then begin
colors = intarr(n_elements(lev))+255	;color vectors
endif else colors=color

if n_elements(x) le 0 then begin
  contour,b,/noerase,/xst,/yst,levels=lev,$	;Do the contour
	   pos = [px(0),py(0), px(0)+swx,py(0)+swy],/dev,$
	c_color =  colors,c_thick=thick,c_linestyle=lsty
endif else begin
  contour,b,x,y,/noerase,xst=1,yst=1,levels=lev,$	;Do the contour
	   pos = [px(0),py(0), px(0)+swx,py(0)+swy],/dev,$
	c_color =  colors,c_thick=thick,c_linestyle=lsty
endelse

return
end






