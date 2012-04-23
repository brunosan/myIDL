function vtt,n,k,yy,mm,dd,hh,theta,mast,lambda=lambda

; n : real part of refractive index (output if lambda supplied, otherwise input)
; k : imaginary part of refractive index (output if lambda supplied, otherwise input)
; yy: year of the observations (4 digits)
; mm: month of the observations (1-12; 1=January)
; dd: day of the observations
; hh= UT of the observations
; theta: angle of the primary mirror of the coelostat (degrees, East: negative)
; mast: height of the secondary mirror of the coelostat (c, direct
;    reading of the ruler)
; lambda: wavelength (A)
if (n_elements(lambda) eq 1) then begin
   refr_ind=n_k_mirror(lambda)
   n=refr_ind(0)
   k=refr_ind(1)
endif   

r_frame_asp,0,0,yy,mm,dd,hh,0,0,d1,d2,d3,d4,d5,d6,d7,d8,raSun,decSun,d9, $
   b0,p,d10,d11,par,haSun,/lapalma

delta0=decSun
h0=haSun

mast=get_height(theta,delta0*180/!pi)
; h0: solar hour angle 
; delta0: solar declinacion del sol 
;DEFINICIONES

r=155.          ; radius of the semicircle of the coelostat
		; primary mirror (cm)

phi=28.         ; Izana latitude (degrees) 

; some definitions 

phir=phi*!pi/180.
cosphi=cos(phir)
sinphi=sin(phir)
thetar=theta*!pi/180.
costh=cos(thetar)
sinth=sin(thetar)
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

; start calculations
; We follow  Capitani et al (1989) Sol. Phys., 120, 173

cosa2=cos(thetar)
sina2=sin(thetar)
a2=atan(sina2,cosa2)

cosh2=r/sqrt(r*r+(mast+88.)*(mast+88.))
sinh2=(mast+88.)/sqrt(r*r+(mast+88.)*(mast+88.))
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
i4=i3
i5=45.
i6=i5
i7=i5
i8=1.5
i9=2*i8
i10=i8
i11=i5

th1=th1*180/!pi		; rotation angle to pass from North Pole - Sun Center
			; to M1 axis

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
r3=rotacion(th3+90)
r4=rotacion(-90)
m1=mirror(n,k,i1)
m2=mirror(n,k,i2)
m3=mirror(n,k,i3)
m4=mirror(n,k,i4)

; Correlation tracker optics (not included  now)

m5=mirror(n,k,i5)
m6=mirror(n,k,i6)
m7=mirror(n,k,i7)
m8=mirror(n,k,i8)
m9=mirror(n,k,i9)
m10=mirror(n,k,i10)
m11=mirror(n,k,i11)

;stop
;m=m11#m10#m9#m8#m7#m6#m5#m4#r4#m3#r3#m2#r2#m1#r1 	; with CT optics
m=r4#m4#m3#r3#m2#r2#m1#r1					; without CT optics

;print,'th1-th2+th3-th4 = ',(th1-th2+th3+180) MOD 360
;print,th1,th2,th3,n,k,i1,i2,i3,i4,mast
return,m

end

