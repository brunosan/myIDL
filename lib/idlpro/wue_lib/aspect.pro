;+
; NAME:
;	ASPECT
; PURPOSE:
;	Set the aspect ratio (x/y) of the plot frame
;	 ( i. e. set !p.position to appropriate values )
; CATEGORY:
;	Plotting
; CALLING SEQUENCE:
;	ASPECT [,a] [,b] [,/default]
; INPUTS:
;       If no parameter is given and ASPECT is called for the first time,
;	1.0 is used; otherwise the aspect ratio is set to its last value.
; OPTIONAL INPUT PARAMETERS:
;	a = aspect ratio (x/y) , if no b is given.
;           a may also be a 2 dimensional array. In this case the ratio of
;           dimensions (nx/ny) is used as aspect ratio.
;       b : if given , a/b is used as aspect ratio ( useful with integers)
; KEYWORD PARAMETERS:
;	/default : if set and non-zero the system variable !p.position
;	is reset to its default value !p.position=0.
; OUTPUTS:
;	No explicit outputs.
; COMMON BLOCKS:
;	common aspect_last,last_aspect  ; the last aspect ratio is saved here 
; SIDE EFFECTS:
;	The system variable !p.position is changed.
; RESTRICTIONS:
;	Each time the window is resized or the plotting device changed
;	ASPECT has to be called again (but without parameters).
; PROCEDURE:
;	Straight forward.
; MODIFICATION HISTORY:
;	Written, A. Welz, Univ. Wuerzburg, Germany, March 1992
;-
pro aspect,a,b,default=default
on_error,2

common aspect_last,last_aspect

; define some parameters.
aspmin=0.001 & aspmax=1.e3
; fraction of the window used for the plot frame and its center.
frac=.42  &  xcen=.53 & ycen=.51

case (n_params()<2) of
    0: if n_elements(last_aspect) ne 0 then newasp=last_aspect else newasp=1.
    1: begin
          s=size(a)
          if s(0) gt 1 then s=size(reform(a))
          if n_elements(a) eq 1 then newasp = abs(float(a))   $
          else if s(0) eq 2 then newasp = float(s(1))/float(s(2))  $
          else begin
             print,'ASPECT: Error , wrong parameter type'
             return
          endelse
       end
    2: begin
         if n_elements(a) eq 1 and n_elements(b) eq 1 then begin
            if b ne 0 then newasp=abs(float(a)/float(b)) else newasp=1.
         endif else begin
             print,'ASPECT: Error , wrong parameter type'
             return
         endelse
       end
endcase

newasp = aspmin > newasp < aspmax
last_aspect=newasp

if keyword_set(default) then begin
    !p.position=[0.0,0.0,0.0,0.0]
endif else begin
    sx=float(!d.x_vsize)
    sy=float(!d.y_vsize)
    newasp=newasp*sy/sx
    if newasp gt 1. then begin
        sx=frac
        sy=frac/newasp
    endif else begin
        sx=frac*newasp
        sy=frac
    endelse
    !p.position=[xcen-sx,ycen-sy,xcen+sx,ycen+sy]
endelse

return
end
