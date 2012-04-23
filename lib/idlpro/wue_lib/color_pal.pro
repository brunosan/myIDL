pro color_pal
;+
; ROUTINE:                 color_pal
;
; AUTHOR:                 Terry Figel, ESRG, UCSB 10-21-92
;
; CALLING SEQUENCE:        color_pal
;
; PURPOSE:                 Displays Color palette in a seperate window
;-

col_pal=findgen(255,50)
window,15,xs=255,ys=50,title='color_pal'
for i=0,254 do col_pal(i,*)=i 
tvscl,col_pal>0<255
wset,0
return
end

