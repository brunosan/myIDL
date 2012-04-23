function get_height,theta,deltasun

; INPUTS:
;
; theta    = angle position of M1 coelostat mirror (no matter sign)
; deltasun = solar declination (degrees)
;
; OUTPUT:
;
; height: height of mast (cm; same zero as ruler)
phi=28.

factor=!pi/180.
phir=phi*factor
thetar=theta*factor
deltar=deltasun*factor

h=findgen(91)
hr=h*factor

result=sin(phir)*sin(hr)-cos(thetar)*cos(phir)*cos(hr)+sin(deltar)

z=where(result(0:89)*result(1:90) le 0)
if(z(0) eq -1) then begin
   print,'No height compatible with the input data (THETA_M1 and DELTA_SUN)'
   stop
endif else begin
   z=z(0)
   hangle=h(z)-result(z)/(result(z+1)-result(z))
endelse

r=155.		; cm
height=r*tan(hangle*factor)-88.

return,height
end
