function mtf_tel,x

; calcula la mtf de un telescopio
; x = lambda (cm) * nu (rads-1) /D_telescopio(cm)
;    con lamnda= longitud de onda de la observacion
;        D_telescopio = diametro del telescopio
;        nu = frecuencia angular 

val=x
z=where(x gt 1)

if(z(0) ne -1) then val(z)=0.

z=where(x le 1)

if(z(0) ne -1) then begin
   xx=x(z)
   val(z)=acos(xx)-xx*sqrt(1-xx*xx)
   val(z)=2*val(z)/!pi
endif

return,val
end
