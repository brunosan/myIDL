function svst,n,k,yy,mm,dd,hh

; INPUT
; n : parte real del indice de refraccion
; k : parte imaginaria del indice de refraccion
; yy : anyo (ej.: 1991)
; mm : mes (ej.: 4)
; dd : dia (ej.: 28)
; hh : hora del dia (ej.: 11.5  --once y media--), TU
; OUTPUT
; mat : matriz 4x4 del teslecopio SVST 

;jdcnv,yy,mm,dd,hh,jd
;sunpos,jd,raSun2,decSun2
;hmerid=13.1611  ; paso por el meridiano el 17 Abril de 1996
;haSun2=(hh-hmerid)*15.*!pi/180.

r_frame_asp,0,0,yy,mm,dd,hh,0,0,d1,d2,d3,d4,d5,d6,d7,d8,raSun,decSun,d9, $
   b0,p,d10,d11,par,haSun,/lapalma

phi=(28.+45./60.)*!pi/180.
eq2altaz,haSun,decSun,phi,altSun,azSun
th1=asin(sin(haSun)*cos(phi)/cos(altsun))
if(haSun lt 0) then th1=-th1+3.*!pi/2. else th1=th1+3.*!pi/2.

azN2=azSun-!pi/2.   ; CUIDADO, he cambiado el signo +!pi/2. ==> -!pi/2.

; FORMA ALTERNATIVA DE CALCULAR TH1 
;altN1=asin(sin(!pi/4.)*sin(altsun))
;azN1=azN2-acos(cos(!pi/4)/cos(altN1))

;altaz2eq,altN1,azN1,phi,haN1,decN1

;sinth1=-sin(haN1-haSun)*cos(decN1)/sin(!pi/4.)
;th1=asin(sinth1)

th2=!pi/2-altSun

; th: angulo que forma el banco optico de la sala de observacion
;	lo suponemos de momento 45 grados
;  th=78 para la mesa del espectrografo
;  th=56 para la mesa del filtro

th=78.*!pi/180.

th3=th-azN2		

fac=180./!pi
th1=th1*fac
th2=th2*fac
th3=th3*fac
espejo=mirror(n,k,45.)
;mat=espejo#rotacion(th3)#espejo#rotacion(th2)#espejo#rotacion(th1)
mat=espejo#rotacion(th3)#espejo#rotacion(th2)#espejo
;mat=mat/mat(0,0)

return,mat
end
