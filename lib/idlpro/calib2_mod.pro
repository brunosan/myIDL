pro calib2_mod,file,dmod,pzero,rzero,delta,data=data,plot=plot,desp=desp

if(keyword_set(desp) eq 0) then desp=0
dum=rfits_im(file,1,dd,hdr,nrhdr,desp=desp)>0
;if(mean(dum) lt 2000) then begin
      dc=dum
      ndc=1
;endif else begin
;   dc=fltarr(dd.naxis1,dd.naxis2)
;   ndc=0
;endelse   

get_lun,unit
openr,unit,file
if(dd.bitpix eq 8) then begin
   datos=assoc(unit,bytarr(dd.naxis1,dd.naxis2),long(2880)*nrhdr)
endif else if(dd.bitpix eq 16) then begin   
   datos=assoc(unit,intarr(dd.naxis1,dd.naxis2),long(2880)*nrhdr)
endif else if(dd.bitpix eq 32) then begin   
   datos=assoc(unit,lonarr(dd.naxis1,dd.naxis2),long(2880)*nrhdr)
endif

for j=2,8 do begin
   dum=(rfits_im2(datos,dd,j,desp=desp)>0)
;   if(mean(dum) lt 2000) then begin
      dc=dc+dum
      ndc=ndc+1
;   endif
endfor

if(ndc eq 0) then begin
   print,'no hay DCs validas'
   return
endif
   
dc=dc/ndc        
z=where(abs(dc-mean(dc)) gt 5*stdev(dc))
if(z(0) ne -1) then dc(z)=mean(dc)

npos=(dd.naxis3-8)/4
thpol=param_fits(hdr,'INSPOLAR=',vartype=3)
thret=param_fits(hdr,'INSRETAR=',vartype=3)

;thpol_ret,hdr,thpol,thret
if(n_elements(thpol) ne npos or n_elements(thret) ne npos) then begin
   print,'Error en la lectura de las posiciones de la calibracion'
   return
endif   

im1=(rfits_im2(datos,dd,9,desp=desp)>0)-dc
im2=(rfits_im2(datos,dd,10,desp=desp)>0)-dc
im3=(rfits_im2(datos,dd,11,desp=desp)>0)-dc
im4=(rfits_im2(datos,dd,12,desp=desp)>0)-dc

if(n_elements(data) ne 8) then begin
   window,0,xsize=dd.naxis1,ysize=dd.naxis2
   tvscl,median((im1+im2+im3+im4)/4.,3)
   print,'Click Lower Left  Corner on Beam 1'
   cursor,i1,j1,3,/device
   print,'Click Upper Right Corner on Beam 1'
   cursor,i2,j2,3,/device
   print,'Click Lower Left  Corner on Beam 2'
   cursor,i3,j3,3,/device
   print,'Click Upper Right Corner on Beam 2'
   cursor,i4,j4,3,/device
   print,'End of Mouse Entries'
   wdelete
   data=[i1,i2,j1,j2,i3,i4,j3,j4]
endif else begin 
   i1=data(0)
   i2=data(1)
   j1=data(2)
   j2=data(3)  
   i3=data(4)
   i4=data(5)
   j3=data(6)
   j4=data(7)
endelse     

haz1=fltarr(npos,4)
haz2=fltarr(npos,4)
cuad1=fltarr(i2-i1+1,j2-j1+1)
cuad2=fltarr(i4-i3+1,j4-j3+1)
for i=0,npos-1 do begin
   for j=0,3 do begin
      im=(rfits_im2(datos,dd,4*i+j+9,desp=desp)>0)-dc
;      im=median(im,3)
      cuad1=im(i1:i2,j1:j2)
      cuad2=im(i3:i4,j3:j4)
      haz1(i,j)=mean(cuad1)
      haz2(i,j)=mean(cuad2)
   endfor
endfor

peso=fltarr(npos,4)
z=where(haz1 lt mean(haz1)+3*stdev(haz1) and $
   haz2 lt mean(haz2)+3*stdev(haz2))
peso(z)=1.   

;plot,haz1(z)+haz2(z),/ynoz
;stop
coef=poly_fit(haz1(z),haz2(z),1)
haz1=-haz1*coef(1)
haz=(haz1-haz2)/(haz1+haz2)

uno=[1,0,0,0]
tuno=transpose(uno)

;while(1) do begin
;read,pzero,rzero,delta

luzin=fltarr(npos,4)
for j=0,npos-1 do begin
   luzin(j,*)=retarder(thret(j)+rzero,delta)#polariz(thpol(j)+pzero)#uno
endfor   
mm=fltarr(4,4)
dmm=fltarr(4,4)
luzfit=fltarr(npos,4)

for j=0,3 do begin
   z=where(peso(*,j) eq 1)
   coef=lstsqfit(luzin(z,1:3),haz(z,j),yfit1)
   mm(j,1:3)=coef(*,0)
   dmm(j,1:3)=coef(*,1)
   luzfit(z,j)=yfit1
   if(keyword_set(plot) eq 1) then begin
      plot,haz(z,j),psym=1
      oplot,yfit1
      pause
   endif   
endfor

print,1./stdev((haz-luzfit)*peso)

for j=0,3 do begin
   z=where(peso(*,j) eq 1)
   mm(j,0)=mean((haz1(z,j)+haz2(z,j))/(haz1(z,0)+haz2(z,0)))
   dmm(j,0)=stdev((haz1(z,j)+haz2(z,j))/(haz1(z,0)+haz2(z,0)))
endfor   
norm=max(mm(*,0))
mm(*,0)=mm(*,0)/norm
dmm(*,0)=dmm(*,0)/norm
for j=1,3 do mm(*,j)=mm(*,j)*mm(*,0)
for j=1,3 do dmm(*,j)=dmm(*,j)*mm(*,0)

dmod=invert(mm)

dmod2=dmod*dmod
dmm2=dmm*dmm
errdmod=sqrt(dmod2#dmm2#dmod2)

print,transpose(dmod),format='(4f8.4)'
print,' '
print,transpose(errdmod),format='(4f8.4)'
print,' '
print,effic(mm),format='(5f8.3)'
print,' '

free_lun,unit
;endwhile
return
end
      
      
   

