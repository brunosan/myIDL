pro zoom2,xsize=xs, ysize=ys, fact = fact, interp = interp, continuous = cont, mark=mrk
;+
; NAME:	
;	ZOOM2
; PURPOSE:
;	Display part of an image (or graphics) from the current window
;	expanded in another window.
;	The cursor is used to mark the center of the zoom.
; CATEGORY:
;	Display.
; CALLING SEQUENCE:
;	Zoom, .... Keyword parameters.
; INPUTS:
;	All input parameters are keywords.
;	Fact = zoom expansion factor, default = 4.
;	Interp = 1 or set to interpolate, otherwise pixel replication is used.
;	xsize = X size of new window, if omitted, 512.
;	ysize = Y size of new window, default = 512.
;	Continuous = keyword param which obviates the need to press the
;		left mouse button.  The zoom window tracks the mouse.
;		Only works well on fast computers.
;	MARK marks cursor position and lists coordinates.
;
; OUTPUTS:
;	No explicit outputs.   A new window is created and destroyed when
;	the procedure is exited.
; COMMON BLOCKS:
;	None.
; SIDE EFFECTS:
;	A window is created / destroyed.
; RESTRICTIONS:
;	Only works with color systems.
; PROCEDURE:
;	Straightforward.
; MODIFICATION HISTORY:
;	R. Sterner, 2 May 1990 --- Added /MARK to ZOOM.PRO
;-
if n_elements(xs) le 0 then xs = 512
if n_elements(ys) le 0 then ys = 512
if n_elements(fact) le 0 then fact=4
if keyword_set(cont) then waitflg = 2 else waitflg = 3
ifact = fact
old_w = !d.window
zoom_w = -1		;No zoom window yet
tvcrs,1			;enable cursor
ierase = 0		;erase zoom window flag
print,'Left for zoom center, Middle for new zoom factor, Right to quit'
again:
	tvrdc,x,y,waitflg,/dev	;Wait for change
	case !err of
4:	goto, done
2:	if !d.name eq 'SUN' or !d.name eq 'X' then begin	;Sun view?
		s  = ['New Zoom Factor:',strtrim(indgen(19)+2,2)]
		ifact = wmenu(s, init=ifact-1,title=0)+1
		tvcrs,x,y,/dev	;Restore cursor
		ierase = 1
	endif else begin
		Read,'Current factor is',ifact+0,'.  Enter new factor: ',ifact
		if ifact le 0 then begin
			ifact = 4
			print,'Illegal Zoom factor.'
			endif
			ierase = 1	;Clean out previous display
	endelse
else:	begin
	x0 = 0 > (x-xs/(ifact*2)) 	;left edge from center
	y0 = 0 > (y-ys/(ifact*2)) 	;bottom
	nx = xs/ifact			;Size of new image
	ny = ys/ifact
	nx = nx < (!d.x_vsize-x0)
	ny = ny < (!d.y_size-y0)
	x0 = x0 < (!d.x_vsize - nx)
	y0 = y0 < (!d.y_vsize - ny)
	if keyword_set(mrk) then begin
	  old = tvrd(x,y,1,1)
	  if old(0) lt 128 then clr = [255] else clr = [0]
	  tv,clr,x,y
	endif
	a = tvrd(x0,y0,nx,ny)		;Read image
	if keyword_set(mrk) then begin
	  tv,old,x,y
	endif
	if zoom_w lt 0 then begin	;Make new window?
		window,/free,xsize=xs,ysize=ys,title='Zoomed Image'
		zoom_w = !d.window
	endif else begin
		wset,zoom_w
		if ierase then erase		;Erase it?
		ierase = 0
	endelse
	xss = nx * ifact	;Make integer rebin factors
	yss = ny * ifact
	tv,rebin(a,xss,yss,sample=1-keyword_set(interp))
	txt = 'X = '+strtrim(x,2)+',  Y = '+strtrim(y,2)
	for ix = -1, 1 do begin
	  for iy = -1, 1 do begin
	    xyouts,10+ix,10+iy,txt,color=0,/dev
	  endfor
	endfor
	xyouts,10,10,txt,/dev
	wset,old_w
	endcase
endcase
goto,again

done:
if zoom_w ge 0 then wdelete,zoom_w		;Done with window
end
