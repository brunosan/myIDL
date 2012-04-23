pro calib_mod,file,m1,m2,dm1,dm2,mm

dc=rfits_im(file,1,/desp)
for j=2,8 do dc=dc+rfits_im(file,j,/desp)
dc=dc/8.

;tvscl,rfits_im(file,9,/desp)<3000
;rdpix,rfits_im(file,9,/desp)<3000
;print,"coordenadas a integrar (i1,i2,j1,j2,j3,j4)"
;para el 14 de julio: 42,100,43,93,42,100,161,211
;para el 15 de julio: 58,106,36,86,58,106,176,226 
;para el 8 de octubre: 10,240,38,105,10,240,105,220 
;read,i1,i2,j1,j2,i3,i4,j3,j4

i1=10
i2=240
j1=38
j2=105
i3=10
i4=240
j3=153
j4=220

haz1=fltarr(73,4)
haz2=fltarr(73,4)
for i=0,72 do begin
   for j=0,3 do begin
      im=rfits_im(file,4*i+j+9,/desp)-dc
;      tvwinp,im<200
;      stop
      cuad1=im(i1:i2,j1:j2)
      cuad2=im(i3:i4,j3:j4)
      haz1(i,j)=mean(cuad1)
      haz2(i,j)=mean(cuad2)
   endfor
endfor

;cte=max(haz1)
;haz1=haz1/cte
;haz2=haz2/cte
;coef=poly_fit(haz1,haz2,1)
;haz2=-haz2/coef(1)
;sum=(haz1+haz2)/2.
haz1b=haz1;/sum
haz2b=haz2;/sum

;stop

delta=89.6
uno=[1,0,0,0]
tuno=transpose(uno)

th=findgen(73)*5
luzin=fltarr(73,4)
for j=0,72 do luzin(j,*)=retarder(th(j),delta)#polariz(0.4)#uno

m1=fltarr(4,4)
m2=fltarr(4,4)

dm1=fltarr(4,4)
dm2=fltarr(4,4)

luzfit1=fltarr(73,4)
luzfit2=fltarr(73,4)
for j=0,3 do begin
   coef=lstsqfit(haz1b,luzin(*,j),yfit1)
   m1(j,*)=coef(*,0)
   dm1(j,*)=coef(*,1)
   luzfit1(*,j)=yfit1
   coef=lstsqfit(haz2b,luzin(*,j),yfit2)
   m2(j,*)=coef(*,0)
   dm2(j,*)=coef(*,1)
   luzfit2(*,j)=yfit2
;   stop
endfor

inv1=invert(m1)
norm1=max(inv1(*,0))
inv2=invert(m2)
norm2=max(inv2(*,0))

m1=m1*norm1
dm1=dm1*norm1
m2=m2*norm2
dm2=dm2*norm2

mm=fltarr(4,4)
mm(1:3,*)=(m1(1:3,*)-m2(1:3,*))/2.
mm(0,*)=(m1(0,*)+m2(0,*))/2.
   
stop
return
end
      
      
   

