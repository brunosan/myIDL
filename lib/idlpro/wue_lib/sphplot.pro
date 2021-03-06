;+
; NAME:
;       SPHPLOT
; PURPOSE:
;       Plot a curve in spherical polar coordinates.
; CATEGORY:
; CALLING SEQUENCE:
;       sphplot, lng, lat, rad
; INPUTS:
;       lng = array of longitudes.     in
;       lat = array of latitudes       in
;       rad = array of radii.          in
; KEYWORD PARAMETERS:
;       Keywords:
;         COLOR=c  plot color.
;         LINESTYLE=s  plot linestyle.
;           Over-rides defaults for visible and hidden points.
;         THICK=t  plot thickness.
;         /HIDDEN plot hidden points.
;         MAXRAD=r clip points using a sphere of radius r.
;         /XYZ  allows the call: sphplot, x, y, z, /xyz.
;	  PSYM=p  set plot symbol.
;	  SYMSIZE=s  set symbol size.
;	  XOUT=x  returns array of plotted data coordinate X.
;	  YOUT=y  returns array of plotted data coordinate Y.
;	  PEN=p   returns array of pen codes for XOUT, YOUT.
; OUTPUTS:
; COMMON BLOCKS:
;       sph_com
; NOTES:
;       Notes: Call SPHINIT first to set sphere orientation and
;         point clipping to the visible hemisphere (def=front).
;         Point clipping may alternatively be done using a
;         clipping sphere defined by MAXRAD.
; MODIFICATION HISTORY:
;       R. Sterner, 6 Feb, 1991
;-
 
	pro sphplot, lnga, lata, rada, help=hlp, $
	  color=color, linestyle=linestyle, thick=thick, $
	  hidden=hidden, maxrad=maxrad, xyz=xyz, psym=psym, $
	  symsize=symsize, xout=xout, yout=yout, pen=pen
 
        common sph_com, lng0,lat0,pa0,x0,y0,inc0,vpa0,vaz0,ls_v,ls_h
 
	if (n_params(0) lt 2) or keyword_set(hlp) then begin
	  print,' Plot a curve in spherical polar coordinates.'
	  print,' sphplot, lng, lat, rad'
	  print,'   lng = array of longitudes.     in'
	  print,'   lat = array of latitudes       in'
	  print,'   rad = array of radii.          in'
          print,' Keywords:'
          print,'   COLOR=c  plot color.'
          print,'   LINESTYLE=s  plot linestyle.'
	  print,'     Over-rides defaults for visible and hidden points.'
          print,'   THICK=t  plot thickness.'
          print,'   /HIDDEN plot hidden points.'
	  print,'   MAXRAD=r clip points using a sphere of radius r.'
	  print,'   /XYZ  allows the call: sphplot, x, y, z, /xyz.'
	  print,'   PSYM=p  set plot symbol.'
	  print,'   SYMSIZE=s  set symbol size.'
	  print,'   XOUT=x  returns array of plotted data coordinate X.'
	  print,'   YOUT=y  returns array of plotted data coordinate Y.'
	  print,'   PEN=p   returns array of pen codes for XOUT, YOUT.'
          print,' Notes: Call SPHINIT first to set sphere orientation and'
          print,'   point clipping to the visible hemisphere (def=front).'
	  print,'   Point clipping may alternatively be done using a'
	  print,'   clipping sphere defined by MAXRAD.'
	  return
	endif
 
        ;--------------------------------------;
        ;          Set default values          ;
        ;--------------------------------------;
	if n_elements(color) eq 0 then color = !p.color
        if keyword_set(hidden) then begin
          if n_elements(linestyle) eq 0 then linestyle = ls_h
        endif else begin
          if n_elements(linestyle) eq 0 then linestyle = ls_v
        endelse
	if n_elements(thick) eq 0 then thick = !p.thick
	if n_elements(psym) eq 0 then psym = 0 
	if n_elements(symsize) eq 0 then symsize = 1. 
 
        ;--------------------------------------------;
        ;   Transform points to sphere orientation   ;
        ;--------------------------------------------;
	if not keyword_set(xyz) then begin
	  polrec3d, rada, (90.-lata)/!radeg, lnga/!radeg, x, y, z
	endif else begin
	  x = lnga
	  y = lata
	  z = rada
	endelse
	if not isarray(x) then begin	; Handle scalars.
	  x = [x,x]
	  y = [y,y]
	  z = [z,z]
	endif
	rot_3d, 3, x, y, z, lng0/!radeg, x1, y1, z1
	rot_3d, 2, x1, y1, z1, -lat0/!radeg, x, y, z
	rot_3d, 1, x, y, z, -pa0/!radeg, x1, y1, z1
 
	;---------------------------------;
	;   Clip to find desired points   ;
	;---------------------------------;
	if n_elements(maxrad) ne 0 then begin
          ;-------------------------------------------------;
          ;    Handle points selected by clipping sphere    ;
          ;-------------------------------------------------;
	  r3 = x1^2 + y1^2 + z1^2
	  r2 = y1^2 + z1^2
	  r2mx = maxrad^2
	  if keyword_set(hidden) then begin
	    w = where(((r3 lt r2mx) and (x1 gt 0)) or $
	              ((r2 lt r2mx) and (x1 lt 0)), cnt)
	  endif else begin
	    w = where(((r3 gt r2mx) and (x1 gt 0)) or $
	              ((r2 gt r2mx) and (x1 lt 0)), cnt)
	  endelse
	endif else begin
          ;------------------------------------------------------;
          ;    Handle points selected by visible hemisphere.     ;
	  ;    Rotate points based on visible hemisphere center. ;
          ;------------------------------------------------------;
	  rot_3d, 2, 1., 0., 0., vaz0/!radeg, x, y, z
	  rot_3d, 1, x, y, z, -vpa0/!radeg, xv, yv, zv
	  sdist = vect_angle(x1,y1,z1, xv, yv, zv, /deg)
          if keyword_set(hidden) then begin
            w = where(sdist ge 90.01, cnt)
          endif else begin
            w = where(sdist le 90.01, cnt)
          endelse
	endelse
 
        ;--------------------------------------;
        ;        Plot desired points           ;
        ;--------------------------------------;
	if cnt eq 0 then return
	xout = [0.]
	yout = [0.]
	pen = [0]
	nr = nruns(w)
	for i = 0, nr-1 do begin
	  ind = getrun(w, i)
	  oplot, y1(ind)+x0, z1(ind)+y0, color=color, $
	    linestyle=linestyle, thick=thick, psym=psym, symsize=symsize
	  xout = [xout, y1(ind)+x0]
	  yout = [yout, z1(ind)+y0]
	  tmp = fix(y1(ind)*0.)+1
	  tmp(0) = 0
	  pen = [pen,tmp]
	endfor

	xout = xout(1:*)
	yout = yout(1:*)
	pen = pen(1:*)
 
	return
	end
