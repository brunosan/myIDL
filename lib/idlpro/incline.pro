pro incline,ffin,ffout,filefit,ngrad,minim,aj,coef

; ffin: imagen espectral de entrada
;      eje x: direccion espectral
;      eje y: direccion espacial
; ffout: imagen espectral de salida, corregida de la inclinacion de la
;      rendija
; filefit: fichero con las posiciones de las lineas espectrales
; ngrad: grado del polinomio que define la inclinacion de la rendija
; minim: forma medida de la inclinacion de la rendija
; aj: forma ajustada de la inclinacion de la rendija
; coef: coeficientes del polinomio

ffout=float(ffin)

tam=size(ffin)
nfil=tam(2)
ncol=tam(1)

num=0
; Lectura del fichero que contiene los datos para ajustar la inclinacion
openr,1,filefit
readf,1,num
x0=intarr(num)
x1=x0
cota=fltarr(num)
for i=0,num-1 do begin
   readf,1,x00,x11,cot
   x0(i)=x00
   x1(i)=x11
   cota(i)=cot
endfor
close,1

minlin=fltarr(num,nfil)
for j=0,num-1 do begin
   for i=0,nfil-1 do begin
      core=float(ffin(x0(j):x1(j),i))
      core=core/max(ffin(*,i))
      z=where(core lt cota(j))
      z1=min(z)
      z2=max(z)
      npp=z2-z1+1
      x=findgen(npp)
      coef=poly_fit(x,core(z1:z2),4,yfit)
      c=[coef(1),coef(2)*2,coef(3)*3,coef(4)*4]
      xc=poly_root(c,0,npp-1)
      minlin(j,i)=float(xc)+z1
   endfor
endfor
   
; Se calcula el promedio de las posiciones absolutas de los minimos de las
; lineas elegidas (puede ser una sola).
; El ajuste se hace a estas posics. promedio para cada fila
minim=fltarr(nfil)
for i=0,num-1 do minim=minim+minlin(i,*)
minim=minim/num
y=findgen(nfil)
if(ngrad gt 0) then begin
   coef=poly_fit(y,minim,ngrad,aj)
endif else begin
   aj=minim
endelse
   
; Interpolacion por splines para obtener las lineas derechas
x=findgen(ncol)
for j=0,nfil-1 do begin
   xx=x+aj(j)-aj(0)
;   ffout(*,j)=spline(x,float(ffin(*,j)),xx)
;   ffout(*,j)=interpolate(ffin(*,j),xx,/cubic)
   ffout(*,j)=interpolate(ffin(*,j),xx)
endfor

return
end
