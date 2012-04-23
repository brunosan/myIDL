pro profil_xy,image,sx=sx,sy=sy,ex=ex,ey=ey,wsize=wsize,order=order,minv=minv,maxv=maxv,xoff=xoff,yoff=yoff
;+
; NAME:
;	PROFIL_XY
; PURPOSE:
;	Interactively draw row or column profiles of an image in a separate
;	window.
; CATEGORY:            $CAT-# 15 16@
;	Image Processing, Image Display
; CALLING SEQUENCE:
;	PROFIL_XY, Image [, SX=sx, SY=sy, EX=ex, EY=ey, XOFF=xoff, YOFF=yoff]
; INPUTS:
;	Image:	The variable that represents the image displayed in current 
;		window.  This data need not be scaled into bytes.
;		The profile graphs are made from this array.
; KEYWORD PARAMETERS:
;	SX:	Starting X position (pixels) of the sub-image;  if this 
;		keyword is omitted, 0 is assumed.
;	SY:	Starting Y position (pixels) of the sub-image; if this
;		keyword is omitted, 0 is assumed.
;	EX:	Ending X position (pixels) of the sub-image; if this 
;		keyword is omitted, maximum is assumed.
;	EY:	Ending Y position (pixels) of the sub-image; if this
;		keyword is omitted, maximum is assumed.
;       Profiles are plotted for the specified sub-image only.
;
;       XOFF:   Starting X position (pixels) of the image in the display-
;		window; if this keyword is omitted, 0 is assumed.
;       YOFF:   Starting Y position (pixels) of the image in the display-
;		window; if this keyword is omitted, 0 is assumed.
;
;	WSIZE:	The size of the PROFILES window as a fraction or multiple 
;		of 640 by 512.
;	ORDER:	Set this keyword param to 1 for images written top down or
;		0 for bottom up.  Default is the current value of !ORDER.
;	MINV:	minimum value in the profile. Default is the minimum of the
;		selected subarea of image
;	MAXV:	maximum value in the profile. Default is the maximum of the
;		selected subarea of image
; OUTPUTS:
;	No explicit outputs.
; COMMON BLOCKS:
;	None.
; SIDE EFFECTS:
;	A new window is created and used for the profiles.  When done,
;	the new window is deleted.
; RESTRICTIONS:
;	None.
; PROCEDURE:
;	A new window is created and the mouse location in the original
;	window is used to plot profiles in the new window.  Pressing the
;	left mouse button toggles between row and column profiles.
;	The right mouse button exits.
; EXAMPLE:
;	Create and display an image and use the PROFIL_XY routine on it.
;	Create and display the image by entering:
;		A = DIST(256)
;		TVSCL, A
;	Run the PROFIL_XY routine by entering:
;		PROFIL_XY, A
;
;	The PROFIL_XY window should appear.  Move the cursor over the original
;	image to see the profile at the cursor position.  Press the left mouse
;	button to toggle between row and column profiles.  Press the right
;	mouse button (with the cursor over the original image) to exit the
;	routine.
;
;             TVSCL, A, 300,250  ; lower left corner of image displayed at
;			           device coordinates (300,250) (pixel)
;             PROFIL_XY, A, XOFF=300,YOFF=250  
;
; MODIFICATION HISTORY:
;	DMS, Nov, 1988. (IDL-UserLib procedure PROFILES)
;       Auffret,H. Jun 1993. : print true value of pixel, plot true range 
;		               of image with true values for axes
;       nlte, 1993-Jun-22 : keyword params xoff,yoff; re-setting of original
;			   axis scaling of original raster graphic.
;-
on_error,2                              ;Return to caller if an error occurs
s = size(image)
nx = s(1)				;Cols in image
ny = s(2)				;Rows in image
if n_elements(sx) eq 0 then sx = 0	;Default start of image
if n_elements(sy) eq 0 then sy = 0
if n_elements(ex) eq 0 then ex = nx-1	;Default end of image
if n_elements(ey) eq 0 then ey = ny-1
if n_elements(wsize) eq 0 then wsize = .6
if n_elements(minv) eq 0 then minv = min(image(sx:ex,sy:ey))
if n_elements(maxv) eq 0 then maxv = max(image(sx:ex,sy:ey))
if n_elements(xoff) eq 0 then xoff=0
if n_elements(yoff) eq 0 then yoff=0
orig_w = !d.window & orig_xs=!x.s & orig_ys=!y.s
tvcrs,xoff+sx+(ex-sx)/2,yoff+sy+(ey-sy)/2,/dev
tickl = 0.07				;Cross length
print,'Left mouse button to toggle between rows and columns.'
print,'Right mouse button to Exit.'
window,/free ,color=0,xpos=20,ypos=20,xs=wsize*640, ys=wsize*512,$
              title='profil_xy' ;Make new window
new_w = !d.window
old_mode = -1				;Mode = 0 for rows, 1 for cols
old_font = !p.font			;Use hdw font
!p.font = 0
mode = 0
if n_elements(order) eq 0 then order = !order	;Image order

while 1 do begin
	wset,orig_w		;Image window
	cursor,x,y,2,/dev	;Read position
        x=x-xoff & y=y-yoff
	if !err eq 1 then begin
		mode = 1-mode	;Toggle mode
		repeat cursor,x,y,0,/dev until !err eq 0
		x=x-xoff & y=y-yoff
		endif
	wset,new_w		;Graph window

	if !err eq 4 then begin		;Quit
		wset,orig_w
		tvcrs,(ex-sx)/2,(ey-sy)/2,/dev	;curs to old window
		tvcrs,0			;Invisible
		wdelete, new_w
		!p.font = old_font
		!x.s=orig_xs & !y.s=orig_ys
		return
		endif
	if mode ne old_mode then begin
		old_mode = mode
		first = 1
		if mode then begin	;Columns?
			vecy = findgen(ey-sy+1)+sy
			crossx = [-2.*tickl,-tickl,tickl,2.*tickl]*(maxv-minv)
			crossy = [-2.*tickl,-tickl,tickl,2.*tickl]*(ey-sy+1)
		end else begin
			vecx = findgen(ex-sx+1)+sx
			crossx = [-2.*tickl,-tickl,tickl,2.*tickl]*(ex-sx+1)
			crossy = [-2.*tickl,-tickl,tickl,2.*tickl]*(maxv-minv)
		endelse
	endif

	if (x le ex) and (y le ey) and $
		(x ge sx) and (y ge sy) then begin	;Draw it
		
		if order then y = (ny-1)-y	;Invert y?
		if first eq 0 then begin	;Erase?
			plots, vecx, vecy, color=0	;Erase graph
			plots,old_xh(0:1),old_yh(0:1),color=0	;Erase cross
			plots,old_xh(2:3),old_yh(2:3),color=0
			plots,old_xv(0:1),old_yv(0:1),color=0
			plots,old_xv(2:3),old_yv(2:3),color=0
			xyouts,.2,0.02,/norm,value,color=0	;Erase text
			empty
		  endif else first = 0

;;;;		value = string([x,y],format="('(',i4,',',i4,')')")
		ixy = image(x,y)		;Data value
		value = ' x ='+strmid(x,8,4)+'    y ='+strmid(y,8,4)+$
                           '    image ='+strmid(float(ixy),5,12)
		if mode then begin		;Columns?
			plot,[minv,maxv],[sy,ey],/nodata,background=0,xstyle=1,ystyle=1,title='Column Profile',color=255
			vecx = image(x,sy:ey)	;get column
			old_xh = crossx + ixy
			old_yh = [y,y,y,y]
			old_xv = [ixy,ixy,ixy,ixy]
			old_yv = crossy + y
		  endif else begin
			plot,[sx,ex],[minv,maxv],/nodata,background=0,xstyle=1,ystyle=1,title='Row Profile',color=255
			vecy = image(sx:ex,y)	;get row
			old_xh = crossx + x
			old_yh = [ixy,ixy,ixy,ixy]
			old_xv = [x,x,x,x]
			old_yv = crossy + ixy
		  endelse
                text_color=255
		plots,vecx,vecy,color=text_color 		;Graph
                cross_color=155
		plots,old_xh(0:1),old_yh(0:1),color=cross_color	        ;Cross
		plots,old_xh(2:3),old_yh(2:3),color=cross_color
		plots,old_xv(0:1),old_yv(0:1),color=cross_color
		plots,old_xv(2:3),old_yv(2:3),color=cross_color
                text_color=255
		xyouts,.2,0.02,/norm,' ', color=cross_color	;Text of locn
		xyouts,.2,0.02,/norm,value, color=text_color	;Text of locn
		endif
endwhile
end
