function vtt_xtau,x,tau,theta,yy,mm,dd,hh,thm1,mast

; n : parte real del indice de refraccion
; k : parte imaginaria del indice de refraccion
; h0: angulo horario del sol (en horas)
; delta0: declinacion del sol (en grados)
; thm1: angulo del mirror primario del celostato (en grados)
; mast: altura del mastil del mirror secundario del celostato (en cm)

r_frame_asp,0,0,yy,mm,dd,hh,0,0,d1,d2,d3,d4,d5,d6,d7,d8,raSun,decSun,d9, $
   b0,p,d10,d11,par,haSun,/lapalma

delta0=decSun
h0=haSun

;DEFINICIONES

r=155.          ; radio del semicirculo del mirror primario
                ; del celostato (en cm)
phi=28.         ;latitud de Izanya (en grados) 

; pasamos los angulos de grados a radianes 

phir=phi*!pi/180.
cosphi=cos(phir)
sinphi=sin(phir)
thm1r=thm1*!pi/180.
costh=cos(thm1r)
sinth=sin(thm1r)
deltar=delta0; 	*!pi/180.
cosd=cos(deltar)
sind=sin(deltar)
h0rad=h0;	/15.
cosh0=cos(h0rad)
sinh0=sin(h0rad)
sinalt0=cosd*cosh0*cosphi+sind*sinphi
alt0=asin(sinalt0)
cosalt0=cos(alt0)
sinaz0=sinh0*cosd/cosalt0
cosaz0=(cosd*cosh0*sinphi-sind*cosphi)/cosalt0
az0=atan(sinaz0,cosaz0)

; iniciamos los calculos
; A partir de aqui seguimos la nomenclatura de Captitani et al (1989)
; Sol. Phys., 120, 173

cosa2=cos(thm1r)
sina2=sin(thm1r)
a2=atan(sina2,cosa2)

cosh2=r/sqrt(r*r+mast*mast)
sinh2=mast/sqrt(r*r+mast*mast)
h2=atan(sinh2,cosh2)

coshc2=(sinh2+sinphi*sind)/cosphi/cosd
sinhc2=cosh2*sina2/cosd
hc2=atan(sinhc2,coshc2)

h=(hc2-h0rad)/2.
sinh=sin(h)
cosh=cos(h)

sin2th1=2*sind*sinh*cosh/(sind*sind*cosh*cosh+sinh*sinh)
cos2th1=(sind*sind*cosh*cosh-sinh*sinh)/(sind*sind*cosh*cosh+sinh*sinh)
th1_2=atan(sin2th1,cos2th1)
th1=th1_2/2

cosi1=cosd*cosh
sini1=-sinh/sin(th1)
i1=atan(sini1,cosi1)

if(i1 lt 0) then begin
   i1=-i1
   th1=th1+!pi
endif   

i2=(!pi/4.-h2/2.)   

sinth2=-cosalt0*sin(a2-az0)/sin(2*i1)
costh2=(sinh2*cos(2*i1)-sinalt0)/cosh2/sin(2*i1)
th2=atan(sinth2,costh2)

th3=-a2

i1=i1*180/!pi
i2=i2*180/!pi
i3=.85
i4=i3/2.
i5=45.
i6=i5
i7=i5
i8=1.5
i9=2*i8
i10=i8
i11=i5

sincor=sinh0*cosphi/cosalt0
cor=asin(sincor)*180/!pi	; angulo para pasar de la linea Norte-Sol a la
				; horizontal de lugar
;if(h0 gt 0) then cor=cor+90 else cor=cor-90

th1=th1*180/!pi		; rotacion para para pasar de la linea Norte-Sol
			; a eje de M1
th1=th1-cor		; rotacion para pasar de la horizontal a M1
while (th1 lt 0) do th1=th1+360 
while (th1 gt 360) do th1=th1-360 
th2=th2*180/!pi
while (th2 lt 0) do th2=th2+360 
while (th2 gt 360) do th2=th2-360 
th3=th3*180/!pi
while (th3 lt 0) do th3=th3+360 
while (th3 gt 360) do th3=th3-360 
r1=rotacion(th1)
r2=rotacion(th2)
r3=rotacion(theta)
r4=rotacion(-theta)
m1=espejo(x(0),tau(0))
m2=espejo(x(1),tau(1))
m3=espejo(x(2),tau(2))

m=r4#m3#r3#m2#r2#m1; #r1	

;print,'hh= ',hh,'; th1= ', th1,'; th2= ', th2,'; cor= ', cor
return,m

end

