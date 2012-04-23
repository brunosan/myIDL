pro calibraSVT,prefix,num1,num2,nciclos,ncoef,fac,matrizLCs,x,tau,th,m,$
    dx,dtau,dth,dm

; Esta procedure calcula la matriz de Mueller de la torre sueca
; a partir de medidas de polarizacion utilizando LCs como polarimetro
; (cuya matriz de Mueller es matrizLCs y se calcula con calibraLCs.pro)
; y poniendo un polarizador lineal gigante a la entrada del telescopio.
; El telescopio se parametriza como un sistema de tres espejos en svst_xtau.pro
; Las matrices de los espejos y las rotaciones necesarias se calculan a
; partir de Capitani et al, 1989, Sol. Phys., 120, 173.

; El procedimiento busca iterativamente los parametros de los espejos
; ajustando los parametros de Stokes observados a los teoricos que resultan
; de multiplicar los parametros de Stokes de entrada en el telescopio por
; la matriz de mueller teorica del telescopio (modelada como tres espejos y
; sus correspondientes rotaciones en svst_xtau.pro).

; Vamos a ajustar 10+ncoef parametros: los 3 cocientes de amplitud y 
; los 3 desfases que introducen los espejos, el azimut th de la mesa de 
; observacion y los cuatro parametros de Stokes de la luz que pasa por el
; polarizador gigante (m1,m2,m3,m4). Si ncoef=0 entonces solo ajusto 10 parametros
; (dejo fuera el m1).Si ncoef=1 tambien ajusto m1. Si el polarizador fuese ideal 
; entonces m1=m2=1 y m3=m4=0, pero como no lo es lo modelamos con 4 parametros 
; (la luz que le entra es natural)

; Suponemos que el polarizador se gira entre 0 y 360 grados en (num2-num1+1)
; pasos. Esto se hace "nciclos" veces a lo largo del dia.

; ENTRADAS:
; prefix : Nombre de las imagenes donde se guardan las imagenes de calibracion.
; num1   : indice de la primera imagen de calibracion
; num2   : indice de la ultima imagen
; ncoef  : Si vale 0 no ajustamos m1. Si vale 1 tambien ajustamos m1
; fac    : Factor de reforzamiento para la primera aproximacion a m1
; matrizLCs: matriz de Mueller de los cristales liquidos.

; SALIDAS:
; x      : Vector de 3 elementos. Cocientes entre las amplitudes reflejadas
;	   paralelas y perpendiculares al plano de incidencia del espejo i.
; tau    : Vector de 3 elementos. Desfase entre las componentes paralela y
;	   perpendicular tras la reflexion en el espejo i.
; th	 : Azimut del banco optico (desconocido a priori)
; m      : Param. de Stokes de la luz que sale del polarizador gigante
; dx, dtau, dth, dm: Incertidumbres estimadas en x, tau, th y m. 


if(ncoef ne 0) then ncoef=1
if(fac eq 0) then fac=5
if(nciclos eq 0) then begin
   print,'Me tienes que decir cuantos ciclos has hecho!'
   stop
endif

x=fltarr(3)
tau=fltarr(3)
tel=fltarr(4,4,8,num2-num1+1)
stokes=fltarr(num2-num1+1,4)   
stokes2=fltarr(num2-num1+1,4)   
stoktrue=fltarr(num2-num1+1,4)  

; Matriz de demodulacion de los cristales liquidos:
a=1./sqrt(3.)
mat=[[1,-a,a,a],[1,-a,-a,-a],[1,a,-a,a],[1,a,a,-a]]
mat=transpose(mat)
invmat=invert(mat)

; Para leer las imagenes:
hdr=bytarr(512)
dat=lonarr(789,248,4)
mim=fltarr(4)   
mim2=fltarr(4)   
 
paso_pol=360.*nciclos/(num2-num1)
m=[1,1,0,0]   ;suponemos inicialmente que es un polarizador ideal


for j=num1,num2 do begin  ;leemos imagenes y sacamos param. Stokes observados

   if(j/4*4 eq j) then print,j

   if(j lt 10 ) then begin
      file=prefix+'0'+strtrim(string(j),2)
   endif else begin
      file=prefix+strtrim(string(j),2)
   endelse

   openr,1,file
   readu,1,hdr,dat
   close,1
   hora(j-num1)=fix(string(hdr(280:281)))+fix(string(hdr(283:284)))/60. $
                +fix(string(hdr(286:287)))/3600.
   byteorder,dat,/lswap


   fondo=mean(dat(700:750,20:240,0))
   im=dat(550:650,20:240,*)-fondo
   for i=0,3 do mim(i)=mean(im(*,*,i))

   im=dat(275:375,20:240,*)-fondo
   for i=0,3 do mim2(i)=mean(im(*,*,i))

   stokes(j-num1,*)=invmat#mim      ;demodulamos 
   stokes2(j-num1,*)=invmat#mim2
   stokes(j-num1,0)=(stokes(j-num1,0)+stokes2(j-num1,0))/2.
   stokes(j-num1,1:3)=(stokes(j-num1,1:3)-stokes2(j-num1,1:3))/2.

   stokes(j-num1,*)=matrizLCs#stokes(j-num1,*)        ;entrada a los LCs
;  stoktrue(j-num1,*)=rotacion(-paso_pol*(j-num1))#m  ;luz que entra
						      ;al telescopio
endfor
anyo=fix(string(hdr(269:272)))
mes=fix(string(hdr(274:275)))
dia=fix(string(hdr(277:278)))


;stokes=stokes/max(stokes)   ;normalizamos los vectores de Stokes
m=m*max(stokes(*,0))*fac


;inicializamos las matrices de los tres espejos. N=n+ik es una 
;aproximacion al indice de refraccion:
n=2.     ;segun Capitani et al es n=1
k=20.    ;  "      "      "  " es k=6

xtauespejo,n,k,45.,a,b  
x(*)=a		;suponemos los espejos iguales
tau(*)=b
th=45.
itmax=250.
iter=0
coef=fltarr(10+ncoef,2)
coef(*,*)=x(0)  ;por poner algo

eye=fltarr(4,4) ;matriz identidad
for j=0,3 do eye(j,j)=1.

;entramos en el ajuste iterativo:

while (iter le itmax and (max(abs(coef([0,2,4],0))/x) ge 0.0001 or $ 
       max(abs(coef([1,3,5],0))/tau) ge 0.0001 or coef(6,0) ge 0.001 $
       or max(coef(7:(9+ncoef),0)) ge 0.001)) do begin
	
	iter=iter+1 
	
	alfa=fltarr(10+ncoef,4,num2-num1+1)
	pert=stokes  ;para ponerle las dimensiones correctas
	
	for j=0,num2-num1 do begin
	   stoktrue(j,*)=rotacion(-paso_pol*j)#m  ;reevaluamos la iluminacion
	   tel(*,*,*,j)=svst_xtau(x,tau,th,anyo,mes,dia,hora(j))
	endfor
	
	for j=0,num2-num1 do pert(j,*)=stokes(j,*)-tel(*,*,0,j)#reform(stoktrue(j,*))
	pert=reform(transpose(pert),n_elements(pert))
	
	for j=0,num2-num1 do begin
	    for i=0,6 do alfa(i,*,j)=tel(*,*,i+1,j)#reform(stoktrue(j,*))
	endfor	
	for j=0,num2-num1 do begin
	    for i=7,9+ncoef do alfa(i,*,j)=tel(*,*,0,j)#rotacion(-paso_pol*j) $
		                           #reform(eye(*,i-(6+ncoef)))
	endfor
		
	; rotacion(-paso_pol*j)#eye(*,i-(6+ncoef))) es la derivada de 
	; stoktrue con respecto a m

	alfa=transpose(reform(alfa,10+ncoef,4*(num2-num1+1)))

	coef=lstsqfit(alfa,pert,yfit)	
	plot,pert-yfit,psym=1,symsize=.5

	x=x+coef([0,2,4],0)
	z=where(x lt 0)
	if(z(0) ne -1) then begin  ;si x es negativo lo hago positivo y sumo
	   x(z)=-x(z)		   ;180 grados al desfase.
	   tau(z)=tau(z)+180
	endif
	tau=tau+coef([1,3,5],0)
;	z=where(tau le 0)
;	if(z(0) ne -1) then tau(z)=tau(z)+180.
	tau=tau-fix(tau/360)*360
	th=th+coef(6,0)
	th=th-fix(th/360)*360
	m(1-ncoef:3)=m(1-ncoef:3)+coef(7:9+ncoef,0)
	if(m(0) le 0) then m(1-ncoef:3)=m(1-ncoef:3)-coef(7:9+ncoef,0) 
        ;si la iluminacion es negativa la dejo como estaba
	print,iter,x,tau,th,m

endwhile

dx=coef([0,2,4],1)
dtau=coef([1,3,5],1)
dth=coef(6,1)
dm=coef(7:9+ncoef,1)

if (iter ge itmax) then print,'Demasiadas iteraciones'
return
end




	












