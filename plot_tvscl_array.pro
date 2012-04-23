pro plot_tvscl_array,array,xarray,yarray,$
	xwinsize=xwinsize,ywinsize=ywinsize,$
	pos=pos,nowindow=nowindow,max_value=max_value,min_value=min_value,$
	min_x=min_x,min_y=min_y,_extra=extra
; by Edwin Sirko
; input array must correspond to xarray and yarray abscissas, and 
; xarray and yarray must have uniform spacing between elements, and be
; monotonically increasing.

temp = size(array)
res_x = temp[1]
res_y = temp[2]

if (n_elements(xarray) ne res_x) or (n_elements(yarray) ne res_y) then begin
	print,n_elements(xarray),n_elements(yarray),res_x,res_y
	print,'supply xarray,yarray....'
	return
endif
if n_elements(xwinsize) eq 0 then xwinsize=640
if n_elements(ywinsize) eq 0 then ywinsize=512
if n_elements(pos) ne 4 then pos=[.1,.1,.95,.95]

dx = xarray[1]-xarray[0]
dy = yarray[1]-yarray[0]
xrange=[xarray[0]-dx/2.,xarray[res_x-1]+dx/2.]
yrange=[yarray[0]-dy/2.,yarray[res_y-1]+dy/2.]

xsize = pos[2]-pos[0]
ysize = pos[3]-pos[1]
if (!d.name eq 'X') then begin
	; will slightly modify resolution in preference of desired plotsize
	nom_xsize = fix(xsize*xwinsize)
	nom_ysize = fix(ysize*ywinsize)
	; nom_xsize/res_x is the mag it would have if rebin allowed nonint mag
	magx = fix(nom_xsize/res_x + .5)
	magy = fix(nom_ysize/res_y + .5)
print,nom_xsize,nom_ysize,res_x,res_y,magx,magy
	; here we don't modify res_x/y (analog to res_x/y) but we still have
	; to modify pos.
	pos[2] = pos[0] + (1.d*res_x*magx)/xwinsize
	pos[3] = pos[1] + (1.d*res_y*magy)/ywinsize
endif

; --- most of the following stolen from plot_tvscl:
; invoke contrast
if (n_elements(min_value) ne 0) then begin
	if (n_elements(max_value) ne 0) then begin
		if max_value lt min_value then begin
			print,min(array),max(array)
			junk = '' & read,junk
		endif
		array = min_value > array < max_value
	endif else begin
		array = min_value > array
	endelse
endif else begin
	if (n_elements(max_value) ne 0) then begin
		array = array < max_value
	endif
endelse

if (!d.name eq 'PS') then begin
	if not keyword_set(nowindow) then erase
	tvscl,array,pos[0],pos[1],xsize=xsize,ysize=ysize,/normal
endif else begin ; 'X'
	if not keyword_set(nowindow) then window,xs=xwinsize,ys=ywinsize
	tvscl,rebin(array,magx*res_x,magy*res_y,/sample),$
		pos[0],pos[1],/normal
endelse

plot,[0],[0],pos=pos,/noerase,/nodata,$
	xrange=xrange,yrange=yrange,/xstyle,/ystyle,_extra=extra

; Report the minimum (useful to establish a guess)
temp = min(array,min_i)
min_x_i = min_i mod res_x
min_y_i = fix(min_i/res_y)
min_x = xrange[0] + dx*(.5d + min_x_i)
min_y = yrange[0] + dy*(.5d + min_y_i)


return
end
