pro step_ct,range,inc,cs,off=off
;+
; ROUTINE:       step_ct
;
; USEAGE:        step_ct, range, inc[, cs]
;                step_ct, /off
;
; PURPOSE:       Discreetizes color scale at given numerical intervals.
;
; INPUT:   
;
;     range      array or vector which specifies range of physical values, 
;                e.g., [amin,amax]
;
;     inc        number scale increment
;
;     cs         a factor between -10 to +10 that translates the
;                color table upto a half a color step higher (cs=10) or
;                half a color step lower (cs=-10).  It has its most
;                noticeable effect when the number of steps is small,
;                because in this case a single step is usually a
;                significant change in color value.  (default = 0)
;
;     off        restore original unquantized color table, 
;                no other input is required when this keyword is set
;
; AUTHOR:        Paul Ricchiazzi    oct92 
;                Earth Space Research Group
;                UCSB
;-
common colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr

if keyword_set(r_orig) eq 0 then loadct,0

if keyword_set(off) then begin
  r_curr=r_orig
  g_curr=g_orig
  b_curr=b_orig
  tvlct,r_curr,g_curr,b_curr
  return
endif

if keyword_set(cs) eq 0 then cs=0.
amax=max(range)
amin=min(range)
max_color=!d.n_colors
;print,'n_table,max_color ',n_elements(r_curr),max_color
cind=findgen(max_color)/(max_color-1)
cind=amin+(amax-amin)*cind
;print,'1: '
;print,cind,form='(10f7.2)'
cind=fix(.99999*cind/inc)*inc
;print,'2: '
;print,cind,form='(10f7.2)'
cind=fix((max_color-1)*(cind-amin)/(amax-amin)) > 0 < (max_color-1)
color_shift=(.05*(cs+10.) > 0. < 1.)*(max_color-1-max(cind))
cind=cind+color_shift
r_curr=r_orig(cind)
g_curr=g_orig(cind)
b_curr=b_orig(cind)
;print,'3:'
;print,form='(10i7)',cind
tvlct,r_curr,g_curr,b_curr
end




