pro mapac,serie,dc,ff,con,lin,pos,vel,imin,filefit

imin =[ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,  4,  4, 2, 1,  6, 2, 2, 2, 1, 6, 6]
imfin=[10,10,10,10,20,20,20,10,20, 3,50,114,140, 7,49,118, 2,29, 7, 5,15,16]

file='d'+strtrim(string(serie),2)+'.at1'
imi=imin(serie-1)
imf=imfin(serie-1)

n=long(512)
m=long(256)
nbloq=n*m*2/2880+1
hdr=bytarr(2880)
dum=intarr(nbloq*1440)
nfiles=imf-imi+1
tam=size(ff)
con=fltarr(nfiles,tam(2))
lin=fltarr(nfiles,tam(2),n_elements(pos))
vel=fltarr(nfiles,tam(2))
imin=fltarr(nfiles,tam(2))

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

openr,1,file
point_lun,1,imi*(nbloq+1)*2880

i1=15   ; limites del continuo
i2=40
sum=fltarr(tam(1),tam(2))
for j=0,nfiles-1 do begin
   readu,1,hdr
   readu,1,dum
   dum1=corte(reform(dum(0:n*m-1),n,m))
   dum1=(dum1-dc)/ff
   sum=sum+dum1
   con(j,*)=total(dum1(i1:i2,*),1)
   for k=0,n_elements(pos)-1 do begin
      lin(j,*,k)=dum1(pos(k),*)
   endfor  
   for k=0,num-1 do begin
      for i=0,tam(2)-1 do begin
         core=float(dum1(x0(k):x1(k),i))
;         core=core/max(dum1(*,i))
;         if(min(core) gt cota(k)) then begin
;            cotta=min(core)+.2
;         endif else begin
;            cotta=cota(k)
;         endelse
;         z=where(core lt cotta)
;         z1=min(z)
;         z2=max(z)
;         npp=z2-z1+1
;         x=findgen(npp)
;         coef=poly_fit(x,core(z1:z2),4,yfit)
;         c=[coef(1),coef(2)*2,coef(3)*3,coef(4)*4]
;         zroots,c,xc
;         c=[coef(2)*2,coef(3)*6,coef(4)*12]
;         yfit=c(0)+c(1)*xc+c(2)*xc*xc
;         z=where(xc eq float(xc) and float(xc) lt npp and float(xc) gt 0 and float(yfit) gt 0)
;         vel(j,i)=vel(j,i)+float(xc(z))+z1
	 z=where(core eq min(core))
         vel(j,i)=vel(j,i)+z(0)
         imin(j,i)=core(z(0))
      endfor
   endfor
endfor   
close,1
vel=vel/num
vel=vel-mean(vel)
   
sum=reform(total(sum(i1:i2,*),1))   ; estas son las rayas de este mapa

for j=0,nfiles-1 do begin
   con(j,*)=con(j,*)/sum
   for k=0,n_elements(pos)-1 do begin
      lin(j,*,k)=lin(j,*,k)/sum
   endfor
endfor    
con=rebin(con,2*nfiles,tam(2))
lin=rebin(lin,2*nfiles,tam(2),n_elements(pos))
vel=rebin(vel,2*nfiles,tam(2))
imin=rebin(imin,2*nfiles,tam(2))
conm=mean(con)
con=con/conm
lin=lin/conm
imin=imin/con

return
end

   
