PRO VECTPLOT,UU,VV,XX,YY,XRANGE=XRANGE,YRANGE=YRANGE,Missing = Missing, $
Length = length, Title = title, position=position, $
noerase=noerase, color=color, xtit=xtit,ytit=ytit,charsize=charsize
;
;+
; NAME:
;	VECKPLOT
;
; PURPOSE:
;	Produce a two-dimensional velocity field plot.
;
;	A directed arrow is drawn at each point showing the direction and 
;	magnitude of the field.
;               
; CATEGORY:
;	Plotting, two-dimensional.
;
; CALLING SEQUENCE:
;	VECTPLOT, U, V , X, Y
;
; INPUTS:
;	UU:	The X component of the two-dimensional field.  
;		U must be a two-dimensional array.
;
;	VV:	The Y component of the two dimensional field.  Y must have
;		the same dimensions as X.  The vector at point (i,j) has a 
;		magnitude of:
;
;			(U(i,j)^2 + V(i,j)^2)^0.5
;
;		and a direction of:
;
;			ATAN2(V(i,j),U(i,j)).
;
; 	XX:	Optional abcissae values.  X must be a vector with a length 
;		equal to the first dimension of U and V.
;
;	YY:	Optional ordinate values.  Y must be a vector with a length
;		equal to the first dimension of U and V.
;
; KEYWORD INPUT PARAMETERS:
;      MISSING:	Missing data value.  Vectors with a LENGTH greater
;		than MISSING are ignored.
;	LENGTH:	Length factor.  The default of 1.0 makes the longest (U,V)
;		vector the length of a cell.
;	TITLE:	A string containing the plot title.
;	XTIT:	A string containing the title in X-axis.
;	YTIT:	A string containing the title in Y-axis.
;       POSITION:	A four-element, floating-point vector of normalized 
;		coordinates for the rectangular plot window.
;		This vector has the form  [X0, Y0, X1, Y1], where (X0, Y0) 
;		is the origin, and (X1, Y1) is the upper-right corner.
;       NOERASE:	Set this keyword to inhibit erase before plot.
;	COLOR:	The color index used for the plot.
;	CHARSIZE:	Charcter size
;	XRANGE:	
;	YRANGE
; OUTPUTS:
;	None.
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	Plotting on the selected device is performed.  System
;	variables concerning plotting are changed.
;
; RESTRICTIONS:
;	None.
;
; PROCEDURE:
;	Straightforward.  The system variables !XTITLE, !YTITLE and
;	!MTITLE can be set to title the axes.
;
; MODIFICATION HISTORY:
; 	Modified "VELOVECT" procedure, Z. Yi, UiO, May, 1992 
;================================================================================
;-
        on_error,2                      ;Return to caller if an error occurs
        s = size(UU)

	case s(0) of
	2: begin
		n=s(4)
		u=reform(UU,n) & v=reform(VV,n) 
		x=reform(XX,n) & y=reform(YY,n)
	end
	1: begin
		u=UU & v=VV & x=xx & y=yy
	end
endcase	

;
        if n_elements(xrange) gt 0 then !x.range=xrange
        if n_elements(yrange) gt 0 then !y.range=yrange
        if n_elements(xtit) le 0 then !x.title='!6Pixel' else !x.title=xtit
        if n_elements(ytit) le 0 then !y.title='!6Pixel' else !y.title=ytit
        if n_elements(missing) le 0 then missing = 1.0e30
        if n_elements(length) le 0 then length = 1.0
	if n_elements(charsize) le 0 then !p.charsize=1 else !p.charsize=charsize

        mag = sqrt(u^2+v^2)             ;magnitude.
        ;Subscripts of good elements
        nbad = 0                        ;# of missing points
        if n_elements(missing) gt 0 then begin
                good = where(mag lt missing) 
                if keyword_set(dots) then bad = where(mag ge missing, nbad)
        endif else begin
                good = lindgen(n_elements(mag))
        endelse

        mag = mag(good)                 ;Discard missing values
        maxmag = max(mag)
        ugood = u(good)
        vgood = v(good)
        x0 = min(x)                     ;get scaling
        x1 = mx
        y0 = min(y)
        y1 = my
;        sina = length * (x1-x0)/x1/maxmag*ugood ;sin & cosine components.
;        cosa = length * (y1-y0)/y1/maxmag*vgood
        sina = length * ugood ;sin & cosine components.
        cosa = length * vgood

        if n_elements(title) le 0 then title = ''
        ;--------------  plot to get axes  ---------------
        if n_elements(color) eq 0 then color = !p.color
        if n_elements(position) eq 0 then begin
          plot,[x0,x1],[y1,y0],/nodata,/xst,/yst,title=title,xtit=xtit,$
ytit=ytit,noerase=noerase, color=color
        endif else begin
          plot,[x0,x1],[y1,y0],/nodata,xst=1,yst=1,title=title, $
            noerase=noerase, color=color, position=position,xrange=[0,mx],yrange=[0,my]
        endelse

        r = .3                          ;len of arrow head
        angle = 22.5 * !dtor            ;Angle of arrowhead
        st = r * sin(angle)             ;sin 22.5 degs * length of head
        ct = r * cos(angle)

        for i=0,n_elements(good)-1 do begin     ;Each point

                x0 = x(good(i))        ;get coords of start & end
                dx = sina(i)
                x1 = x0 + dx
                y0 = y(good(i))
                dy = cosa(i)
                y1 = y0 + dy
                plots,[x0,x1,x1-(ct*dx-st*dy),x1,x1-(ct*dx+st*dy)], $
                      [y0,y1,y1-(ct*dy+st*dx),y1,y1-(ct*dy-st*dx)], $
                      color=color
                endfor
        if nbad gt 0 then $             ;Dots for missing?
                oplot, x(bad mod s(1)), y(bad / s(1)), psym=3, color=color
end










