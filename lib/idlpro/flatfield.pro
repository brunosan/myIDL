;pro flatfield,ffin,ffout,filefit,ngrad,coef,minim,aj
pro flatfield,ffin,ffout,ngrad,coef,aj,minim,data=data

; A partir del flatfield con lineas (ffin), que es el promedio de los flat
; fields obtenidos menos la corriente de oscuridad, da el flat field defini-
; tivo (ffout), en el que han sido eliminadas las lineas. El fichero filefit
; contiene el numero de lineas que usara para ajustar y el principio y fin
; en pixeles, de donde debe hacer el ajuste.
; COEF es el vector de coeficientes del ajuste de la inclinacion de la rendi-
; ja a una parabola, que se obtiene como salida.
; keyword data: 0 introduccion de limites de los intervalos mediante teclado
;               1 lee esos datos de fichero
;               2 entran directamente en esa variable con la estructura
;		 [2,nlin,x0(1),x1(1),cota(1),....,x0(nlin),x1(nlin),cota(nlin)]

if(keyword_set(data) eq 0) then data=0

ffout=float(ffin)
tam=size(ffin)
nfil=tam(2)
ncol=tam(1)

num=0
if(keyword_set(data) eq 0 or data(0) eq 0) then begin
   esp=total(ffin,2)
   plot,esp/max(esp)
   !p.thick=1
   veri
   !p.thick=2
   print,'numero de lineas: '
   read,num
   x0=intarr(num)
   x1=x0
   cota=fltarr(num)
   data=[2,num]
   for j=0,num-1 do begin
      print,'limites inferior, superior y cota de la linea',j+1,': '
      read,dum1,dum2,dum3
      x0(j)=dum1
      x1(j)=dum2
      cota(j)=dum3
      data=[data,dum1,dum2,dum3]
   endfor
   wdelete
endif else if(data(0) eq 1) then begin
; Lectura del fichero que contiene los datos para ajustar la inclinacion
   print,'fichero con los datos de los intervalos: '
   filefit=' '
   read,filefit
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
endif else if(data(0) eq 2) then begin
   num=data(1)
   x0=intarr(num)
   x1=x0
   cota=fltarr(num)
   ind=1
   for i=0,num-1 do begin
      ind=ind+1
      x0(i)=data(ind)
      ind=ind+1
      x1(i)=data(ind)
      ind=ind+1
      cota(i)=data(ind)
   endfor
endif else begin
   print,'este caso para DATA no esta contemplado'
   return
endelse   
 

; Ajuste de una parabola a la desviacion
;minlin=intarr(num,nfil)
;minim=fltarr(nfil)
;for j=0,num-1 do begin
;   for i=0,nfil-1 do begin 
;      z=where(ffin(x0(j):x1(j),i) eq min(ffin(x0(j):x1(j),i)))
;      minlin(j,i)=z(0)
;   endfor
;endfor


minlin=fltarr(num,nfil)
for j=0,num-1 do begin
   for i=0,nfil-1 do begin
      core=float(ffin(x0(j):x1(j),i))
      core=core/max(ffin(*,i))
      z=where(core lt cota(j))
      z1=min(z)
      z2=max(z)
      npp=z2-z1+1
      while(npp lt 7) do begin
         z1=(z1-1)>0
         z2=(z2+1)<(x1(j)-x0(j))
         npp=z2-z1+1
      endwhile   
      x=findgen(npp)
      coef=poly_fit(x,core(z1:z2),4,yfit)
      c=[coef(1),coef(2)*2,coef(3)*3,coef(4)*4]
      xc=poly_root(c,0,npp-1)
      if(xc lt 0 or xc gt (x1(j)-x0(j))) then xc=(x1(j)-x0(j))/2.
;      zroots,c,xc
;      c=[coef(2)*2,coef(3)*6,coef(4)*12]
;     yfit=c(0)+c(1)*xc+c(2)*xc*xc
;      z=where(xc eq float(xc) and float(xc) lt npp and float(xc) gt 0 and float(yfit) gt 0)
;      minlin(j,i)=float(xc(z))+z1
      minlin(j,i)=float(xc)+z1
;      plot,x,core(z1:z2)
;      oplot,x,yfit,color=80
;      print,i
;      pause
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
;   plot,y,minim
;   oplot,y,aj,color=80
;   pause
   
   sig=std(minim-aj)
   z=where(abs(minim-aj) gt 4*sig)
   while(z(0) ne -1) do begin
      minim(z)=poly(z,coef)
      coef=poly_fit(y,minim,ngrad,aj)
      sig=std(minim-aj)
      z=where(abs(minim-aj) gt 4*sig)
;      plot,y,minim
;      oplot,y,aj,color=80
;      pause
;    stop
   endwhile
      
   
endif else begin
   aj=minim-minim(0)
endelse
   

; Interpolacion por splines para obtener las lineas derechas
x=findgen(ncol)
for j=0,nfil-1 do begin
   xx=x+aj(j)-aj(0)
;   xx=x+minim(j)-minim(0)
;   ffout(*,j)=spline(x,float(ffin(*,j)),xx)
   ffout(*,j)=interpolate(ffin(*,j),xx,/cubic)
;   ffout(*,j)=interpolate(ffin(*,j),xx)
endfor

; Obtencion del flatfield derecho (ya sin lineas).
; Se calcula la compresion en direccion espacial y se divide por ella.
by=ffin(*,0)
by(*)=0.
for i=0,ncol-1 do begin
   vec=ffout(i,*)
   z=where(abs(vec-median(vec)) lt 3*std(vec))
   by(i)=mean(vec(z))
;   by(i)=median(vec)
endfor   
;stop
;for i=0,nfil-1 do ffout(*,i)=ffout(*,i)/by(*)

; Inclinacion del flat field para poderlo utilizar con las imagenes originales.
; Se vuelve a colocar el FF con la inclinacion que tenia la rendija.
; Convendra guardar esta inclinacion para poder comprimir espacialmente los
; espectros individuales.
for j=0,nfil-1 do begin
   xx=x-aj(j)+aj(0)
;   xx=x-minim(j)+minim(0)
;   ffout(*,j)=spline(x,ffout(*,j),xx)
;   ffout(*,j)=interpolate(ffout(*,j),xx,/cubic)
;   ffout(*,j)=interpolate(ffout(*,j),xx)
   ffout(*,j)=ffin(*,j)/interpolate(by,xx,/cubic)
endfor
ffout=ffout/mean(ffout)

return
end
