pro profile4, special, im1, im2, im3, im4, xi, yi, xq, yq, xu, yu, xv, yv, $
	      im2_byte, im3_byte, wsize=wsize, order=order, generic=generic
;+
;
;	procedure:  profile4
;
;	purpose:  do "profiles" on 4 images at a time (e.g., ASP I,Q,U,V)
;
;	author:  rob@ncar, 2/92
;
;	notes:  used code from RSI's "profiles" procedure
;
;==============================================================================
;
;	Check number of parameters.
;
if (n_params() ne 13) and (n_params() ne 15) then begin
	print
	print, "usage: profile4, s, i, q, u, v, xi, yi, xq, yq, xu, yu, xv, yv"
	print, "		 [, q_byte, u_byte]"
	print
	print, "	Do profiles on 4 images."
	print
	print, "	Arguments"
	print, "		s	  - 0 = do tvscl; 1 = do tv;"
	print, "			    2 = do tvscl on i,v and tv on q,u"
	print, "			        ... must specify q_byte,u_byte"
	print, "			    3 = do newct_tvscl; 4 = do tvasp"
	print, "		i,q,u,v	  - the four images; data need not be"
	print, "			    scaled into bytes (i.e., they"
	print, "			    may be floating point arrays)."
	print, "		xi - xv,"
	print, "		yi - yv	  - lower left corners of 4 images"
	print
	print, "		q_byte,	  - byte images for 's=2' option"
	print, "		 u_byte"
	print
	print, "	Keywords"
	print, "		wsize	  - size of new window as a fraction"
	print, "			    or multiple of (640, 640)"
	print, "			    (def = 0.5)"
	print, "		order	  - set to 1 for images written top"
	print, "			    down, 0 for bottom up."
	print, "			    (def = current !ORDER)"
	print, "		generic	  - if set, use generic labels rather"
	print, "			    than I, Q, U, V"
	print
	return
endif
;-
;
;	Set to return to caller on error.
;
on_error,2
;
;	Specify common blocks.
;
common profile4, p4_qu_range, p4_v_range, p4_ngray
@iquv_label.com
;
;	Set keywords.
;
if n_elements(wsize) eq 0 then wsize = 0.5
if n_elements(order) eq 0 then order = !order
wsize = wsize * 2
;
;	Set parameters.
;
s = size(im1)
nx = s(1)				;Cols in image
ny = s(2)				;Rows in image
orig_w = !d.window
xbord = 0.05
ybord = 0.05
ybias = 0.03
p1 = [0.0 + xbord, 0.5 + ybord + ybias, 0.5 - xbord, 1.0 - ybord]
p2 = [0.5 + xbord, 0.5 + ybord + ybias, 1.0 - xbord, 1.0 - ybord]
p3 = [0.0 + xbord, 0.0 + ybord + ybias, 0.5 - xbord, 0.5 - ybord]
p4 = [0.5 + xbord, 0.0 + ybord + ybias, 1.0 - xbord, 0.5 - ybord]
ans = string(' ',format='(a1)')
tickl = 5
;
;	Set extrema.
;
minv1 = min(im1, max=maxv1)
minv2 = min(im2, max=maxv2)
minv3 = min(im3, max=maxv3)
minv4 = min(im4, max=maxv4)
if special eq 2 then begin		;Will plot same Q,U range if special=2
	minv2 = min([minv2, minv3])
	minv3 = minv2
	maxv2 = max([maxv2, maxv3])
	maxv3 = maxv2
endif
;
;	Set generic vs. I,Q,U,V parameters.
;
if keyword_set(generic) then begin
	xtitle1 = '1'
	xtitle2 = '2'
	xtitle3 = '3'
	xtitle4 = '4'
endif else begin
	xtitle1 = 'I'
	xtitle2 = 'Q'
	xtitle3 = 'U'
	xtitle4 = 'V'
endelse
;
;	Set for hardware font.
;
old_font = !p.font
!p.font = 0
;
first_time = 1
;
;-------------------------
;	MAIN LOOP
;-------------------------
;
while 1 do begin
;
;	Set image window to current window.
;
	wset,orig_w
;
;	Handle 1st time (user selects what to interact with) or later picks.
;
	if first_time then begin
		first_time = 0
		print
		print, 'Click on image to interact with (I, Q, U, or V).'
		print
		print, '    Left Mouse Button - row profile'
		print, '  Middle Mouse Button - column profile'
		print, '   Right Mouse Button - exit'
		print
		cursor, x, y, 3, /dev		;Read button down position
		if (x lt xq) and (y ge yi) then begin
			print, '	Interacting with I ...'
			sx = xi
			sy = yi
		endif else if (x ge xq) and (y ge yq) then begin
			print, '	Interacting with Q ...'
			sx = xq
			sy = yq
		endif else if (x lt xq) and (y lt yq) then begin
			print, '	Interacting with U ...'
			sx = xu
			sy = yu
		endif else begin
			print, '	Interacting with V ...'
			sx = xv
			sy = yv
		endelse
;
;		Set the cursor position and window.
		window, /free , xs=wsize*640, ys=wsize*640, title=''
		win_index = !d.window
;
	endif else begin
		cursor,x,y,3,/dev	 	;Read position if button down
	endelse
;
;
;	PERFORM ACTION BASED ON MOUSE CLICK.
;
;--------
;
;	Quit if mouse button 3 pushed.
;
	if !err eq 4 then begin
		wset,orig_w		;Original window becomes current one
		tvcrs,nx/2,ny/2,/dev	;Move cursor to old window
		tvcrs,0			;Make cursor invisible
		wdelete, win_index	;Delete profile window
		!p.font = old_font	;Return original font
		return
	endif
;
;--------
;
;	Set up for row or column profiling based on mouse click.
;
	mode = 0
	if !err eq 2 then mode = 1	;Mouse1 = row; Mouse2 = column
;
;--------
;
;	Draw profile if mouse pointer is within range.
;
	x = x - sx		;Remove bias
	y = y - sy
	wset,win_index		;Graph window becomes current window

	if (x lt nx) and (y lt ny) and (x ge 0) and (y ge 0) then begin

		if order then y = (ny-1)-y		;Invert y
		value = strmid(x,8,4)+strmid(y,8,4)

		if mode then begin			;Get column
			vecy1 = findgen(ny)
			vecy2 = vecy1
			vecy3 = vecy1
			vecy4 = vecy1
			vecx1 = im1(x,*)
			vecx2 = im2(x,*)
			vecx3 = im3(x,*)
			vecx4 = im4(x,*)
		endif else begin			;Get row
			vecx1 = findgen(nx)
			vecx2 = vecx1
			vecx3 = vecx1
			vecx4 = vecx1
			vecy1 = im1(*,y)
			vecy2 = im2(*,y)
			vecy3 = im3(*,y)
			vecy4 = im4(*,y)
		endelse
;
;		Set up and plot profiles.
;
		if mode then begin			;Column profile
			plot,[minv1,maxv1],[0,ny-1],/nodata, $
				xtitle=xtitle1, position=p1
			oplot,vecx1,vecy1
			plot,[minv2,maxv2],[0,ny-1],/nodata, /noerase, $
				xtitle=xtitle2, position=p2
			oplot,vecx2,vecy2
			plot,[minv3,maxv3],[0,ny-1],/nodata, /noerase, $
				xtitle=xtitle3, position=p3
			oplot,vecx3,vecy3
			plot,[minv4,maxv4],[0,ny-1],/nodata, /noerase, $
				xtitle=xtitle4, position=p4
			oplot,vecx4,vecy4
			str = 'Column Profile,' + string(value)
			xyouts, .5, .975, /norm, align=.5, str

		end else begin				;Row profile
			plot,[0,nx-1],[minv1,maxv1],/nodata, $
				xtitle=xtitle1, position=p1
			oplot,vecx1,vecy1
			plot,[0,nx-1],[minv2,maxv2],/nodata, /noerase, $
				xtitle=xtitle2, position=p2
			oplot,vecx2,vecy2
			plot,[0,nx-1],[minv3,maxv3],/nodata, /noerase, $
				xtitle=xtitle3, position=p3
			oplot,vecx3,vecy3
			plot,[0,nx-1],[minv4,maxv4],/nodata, /noerase, $
				xtitle=xtitle4, position=p4
			oplot,vecx4,vecy4
			str = 'Row Profile,' + string(value)
			xyouts, .5, .975, /norm, align=.5, str
		endelse
;
;		Plot crosshairs.
;
		wset, orig_w

		case special of				;Replot images
		   0: begin
			tvscl, im1, xi, yi
			tvscl, im2, xq, yq
			tvscl, im3, xu, yu
			tvscl, im4, xv, yv
		      end
		   1: begin
			tv, im1, xi, yi
			tv, im2, xq, yq
			tv, im3, xu, yu
			tv, im4, xv, yv
		      end
		   2: begin
			tvscl, im1, xi, yi
			tv, im2_byte, xq, yq
			tv, im3_byte, xu, yu
			tvscl, im4, xv, yv
		      end
		   3: begin
			newct_tvscl, im1, xi, yi
			newct_tvscl, im2, xq, yq
			newct_tvscl, im3, xu, yu
			newct_tvscl, im4, xv, yv
		      end
		   4: begin
			tvasp, im1, xi, yi, /red, center=p4_ngray, /gray
			tvasp, im2, xq, yq, /red, center=p4_ngray, $
				min=(-p4_qu_range), max=p4_qu_range
			tvasp, im3, xu, yu, /red, center=p4_ngray, $
				min=(-p4_qu_range), max=p4_qu_range
			tvasp, im4, xv, yv, /red, center=p4_ngray, $
				min=(-p4_v_range), max=p4_v_range
		      end
		   else:  message, "improper 'special' value"
		endcase

		x1 = x - tickl				;Do crosshairs
		x2 = x + tickl
		y1 = y - tickl
		y2 = y + tickl
		plots, [xi + x1, xi + x2], [yi + y, yi + y], /device
		plots, [xi + x, xi + x], [yi + y1, yi + y2], /device
		plots, [xq + x1, xq + x2], [yq + y, yq + y], /device
		plots, [xq + x, xq + x], [yq + y1, yq + y2], /device
		plots, [xu + x1, xu + x2], [yu + y, yu + y], /device
		plots, [xu + x, xu + x], [yu + y1, yu + y2], /device
		plots, [xv + x1, xv + x2], [yv + y, yv + y], /device
		plots, [xv + x, xv + x], [yv + y1, yv + y2], /device
	endif
endwhile
end
