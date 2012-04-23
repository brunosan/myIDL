pro parametros,con,weq,posmin,dmin
npoint=2048
nscan=350
step=5.37
dat=fltarr(npoint,nscan)
con=fltarr(nscan)
pcon=[1630,1680]
;pcon=[450,500]
;pcon=[850,1050]
for i=0,nscan-1 do begin
   dat(*,i) = kpno(i+1)
   con(i) = mean(dat(pcon(0):pcon(1),i))
   dat(*,i)=dat(*,i)/con(i)
endfor

; el 337 esta mal. Promediamos el 336 y el 338

dat(*,337)=(dat(*,336)+dat(*,338))/2.
con(337)=(con(336)+con(338))/2.

coef=poly_fit(findgen(nscan),con,ngrad,fit)
con=con/fit
   
pos=[1130,1250]
dmin = fltarr(nscan)
posmin = dmin
weq=dmin

for i=0,nscan-1 do begin
   pp=dat(pos(0):pos(1),i)
   z=where(pp le 0.3)
   pp=pp(z)
   npp=n_elements(pp)
   p0=pos(0)+z(0)
   x=findgen(npp)
   coef=poly_fit(x,pp,4,fitpp)
   c=[coef(1),coef(2)*2,coef(3)*3,coef(4)*4]
   zroots,c,xc
   z=where(xc eq float(xc) and abs(xc) lt npp)
   posmin(i)=float(xc(z))
   dmin(i)=poly(posmin(i),coef)
   posmin(i)=posmin(i)+p0
   weq(i)=total(1.-dat(pos(0):pos(1),i))*step
endfor
return
end

