pro extraer
npoint=2048
nscan=350
step=5.37
dat=fltarr(npoint,nscan)
con=fltarr(nscan)

pcon1=[450,499]
pcon2=[1630,1679]
ncon1=pcon1(1)-pcon1(0)+1
ncon2=pcon2(1)-pcon2(0)+1
x=[findgen(ncon1)+pcon1(0),findgen(ncon2)+pcon2(0)]
xx=findgen(npoint)
for i=0,nscan-1 do begin
; leemos los datos (dat)
   dat(*,i) = kpno(i+1)
; extraemos los dos continuos (cuyos limites vienen dados por
;   pcon1 y pcon2)
; ajustamos una linea recta al continuo 
   coef=poly_fit(x,dat(x,i),1)
   fit=poly(xx,coef)
; extraemos el continuo promedio de un trozo (con)
   con(i) = mean(dat(pcon1(0):pcon1(1),i))
; normalizamos los espectros
   dat(*,i)=dat(*,i)/fit
endfor

; el espectro 337 esta mal. Lo calculamos como el promedio del anterior
;   y el posterior

con(337)=(con(336)+con(338))/2.
dat(*,337)=(dat(*,336)+dat(*,338))/2.

;evaluamos la deriva del continuo
coef=poly_fit(findgen(nscan),con,2,fit)

; buscamos los minimos de las lineas de oxigeno
;   (cuyas lambdas son lambref y sus limites p1,p2,p4)
; se ajusta una parabola al 30% inferior (cotao)

p1=[594,620]
p2=[790,808]
p4=[1880,1905]

cotao=.3

lambref=[7695.838,7696.869,7702.739]

;extraemos la linea (por debajo de .96 de intensidad)
cotap = .96

; p3 = limites de la linea del potasio
p3=[1100,1259]

nlin=150
nlinc=151
for i=0,nscan-1 do begin
   x1=minimo(dat(*,i),p1,cotao)
   x2=minimo(dat(*,i),p2,cotao)
   x4=minimo(dat(*,i),p4,cotao)
   x=[x1,x2,x4]

   coef=poly_fit(x,lambref,1)
   lambda=(poly(findgen(npoint),coef)-7698.977)*1000.+92.

   dat1=dat(p3(0):p3(1),i)
   x1=min(where(dat1 lt cotap))+p3(0)
   x2=max(where(dat1 lt cotap))+p3(0)
   ndat=fix(x2-x1+1)
; dividimos ndat por 2 porque vamos a promediar cada dos puntos
; y ncon1 por 5 porque vamos a promediar cada cinco puntos
   ndat=ndat/2
   ncon=ncon1/5
   x2=x1+2*ndat-1
   datos=fltarr(6,ndat+ncon)
   datos(0,0:ndat-1) = nlin
   datos(1,0:ndat-1) = promedia(lambda(x1:x2),2)
   datos(2,0:ndat-1) = promedia(dat(x1:x2,i),2)*con(i)/fit(i)
   datos(0,ndat:*) = nlinc
   datos(1,ndat:*) = promedia(lambda(pcon1(0):pcon1(1)),5)
   datos(1,ndat:*) = datos(1,ndat:*) - mean(datos(1,ndat:*))
   datos(2,ndat:*) = promedia(dat(pcon1(0):pcon1(1),i),5)*con(i)/fit(i)

   nom='k'+strtrim(string(i+1),2)+'.per'
   openw,1,nom
   printf,1,datos,format='((1x,i4,2x,f8.3,4(2x,f9.6)))'
   close,1

   nom='k'+strtrim(string(i+1),2)+'.may'
   openw,1,nom

   printf,1,1,nlin,format='(1x,i2,3x,i5)'
   delta=datos(1,1)-datos(1,0)
   datfin=datos(1,ndat-1)+delta/2.
   printf,1,datos(1,0),delta,datfin,format='(1x,3(f8.3,2x))'

;  printf,1,1,nlinc,format='(1x,i2,3x,i5)'
;   delta=datos(1,ndat+1)-datos(1,ndat)
;   datfin=datos(1,ndat+ncon-1)+delta/2.
;   printf,1,datos(1,ndat),delta,datfin,format='(1x,3(f8.3,2x))'
   close,1
endfor
return
end

