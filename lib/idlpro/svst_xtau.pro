function svst_xtau,x,tau,th,yy,mm,dd,hh

; Matriz de Mueller de la torre solar sueca t sus derivadas con x(*) y tau(*)
; Modelamos el telescopio como un sistema de tres espejos y las rotaciones
; correspondientes. 
; La primera rotacion la quito porque utilizo esta rutina con un polarizador lineal


; INPUT
; x : cociente entre amplitudes (paralela/perpend) de la onda reflejada 
;     Vector de 3 elementos
; tau : desfase (vector de tres elementos)
; yy : anyo (ej.: 1991)
; mm : mes (ej.: 4)
; dd : dia (ej.: 28)
; hh : hora del dia (ej.: 11.5  --once y media--), TU
; OUTPUT
; mat(*,*,0)   : matriz 4x4 del teslecopio SVST 
; mat(*,*,1:6) : derivadas de la matriz del telescopio con x(0),tau(0),x(1)...
; mat(*,*,7)   : derivada de la matriz del telescopio con th


mat=fltarr(4,4,10)

r_frame_asp,0,0,yy,mm,dd,hh,0,0,d1,d2,d3,d4,d5,d6,d7,d8,raSun,decSun,d9, $
   b0,p,d10,d11,par,haSun,/lapalma


phi=(28.+45./60.)*!pi/180.
eq2altaz,haSun,decSun,phi,altSun,azSun
th1=asin(sin(haSun)*cos(phi)/cos(altsun))
if(haSun lt 0) then th1=-th1+3.*!pi/2. else th1=th1+3.*!pi/2.

;azN2=azSun+!pi/2.
azN2=azSun-!pi/2.
; FORMA ALTERNATIVA DE CALCULAR TH1 
;altN1=asin(sin(!pi/4.)*sin(altsun))
;azN1=azN2-acos(cos(!pi/4)/cos(altN1))

;altaz2eq,altN1,azN1,phi,haN1,decN1

;sinth1=-sin(haN1-haSun)*cos(decN1)/sin(!pi/4.)
;th1=asin(sinth1)

th2=!pi/2-altSun

; th: angulo que forma el banco optico de la sala de observacion
;	lo suponemos de momento 45 grados

;th=!pi/4.



th3=th*!pi/180.-azN2

fac=180./!pi
th1=th1*fac
th2=th2*fac
th3=th3*fac

espejo0=[[1,-0.04,0.02,0.0],[-0.03,0.98,-0.10,0.01],[0.0,-0.11,-0.95,0.21],[0.00,-0.01,-0.22,-0.96]]
espejo0=0.895*transpose(espejo0)

espejo1=espejo0

espejo2=[[1,0.02,0.0,0.0],[0.01,0.99,0.21,-0.04],[-0.05,0.19,-0.82,0.52],[-0.03,0.08,-0.52,-0.84]]
espejo2=.751*transpose(espejo2)

;mat(*,*,0)=espejo2#rotacion(th3)#espejo1#rotacion(th2)#espejo0 ;#rotacion(th1)

mat(*,*,0)=espejo(x(2),tau(2))#rotacion(th3)#espejo(x(1),tau(1))#rotacion(th2)#espejo(x(0),tau(0)) ;#rotacion(th1)


;Calculamos las derivadas:
mat(*,*,1)=espejo(x(2),tau(2))#rotacion(th3)#espejo(x(1),tau(1))#rotacion(th2)#despejo_x(x(0),tau(0));#rotacion(th1)

mat(*,*,2)=espejo(x(2),tau(2))#rotacion(th3)#espejo(x(1),tau(1))#rotacion(th2)#despejo_tau(x(0),tau(0));#rotacion(th1)

mat(*,*,3)=espejo(x(2),tau(2))#rotacion(th3)#despejo_x(x(1),tau(1))#rotacion(th2)#espejo(x(0),tau(0));#rotacion(th1)

mat(*,*,4)=espejo(x(2),tau(2))#rotacion(th3)#despejo_tau(x(1),tau(1))#rotacion(th2)#espejo(x(0),tau(0));#rotacion(th1)

mat(*,*,5)=despejo_x(x(2),tau(2))#rotacion(th3)#espejo(x(1),tau(1))#rotacion(th2)#espejo(x(0),tau(0));#rotacion(th1)

mat(*,*,6)=despejo_tau(x(2),tau(2))#rotacion(th3)#espejo(x(1),tau(1))#rotacion(th2)#espejo(x(0),tau(0));#rotacion(th1)

mat(*,*,7)=espejo(x(2),tau(2))#drotacion(th3)#espejo(x(1),tau(1))#rotacion(th2)#espejo(x(0),tau(0));#rotacion(th1)

;mat=mat/mat(0,0,0)
return,mat
end
