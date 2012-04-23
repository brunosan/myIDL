pro flat_tip2,file,ff,dmod,zqq,zuu,zvv,data=data,desp=desp   

if(keyword_set(desp) eq 0) then desp=0
dum=rfits_im(file,1,dd,hdr,nrhdr,desp=desp)>0
   
if(mean(dum) lt 2000) then begin
      dc=dum
      ndc=1
endif else begin
   dc=fltarr(dd.naxis1,dd.naxis2)
   ndc=0
endelse   

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
   if(mean(dum) lt 2000) then begin
      dc=dc+dum
      ndc=ndc+1
   endif
endfor

if(ndc eq 0) then begin
   print,'no hay DCs validas'
   return
endif
   
dc=dc/ndc        
z=where(abs(dc-mean(dc)) gt 5*stdev(dc))
if(z(0) ne -1) then dc(z)=mean(dc)

npos=(dd.naxis3-8)/4

im1=(rfits_im2(datos,dd,9,desp=desp)>0)-dc
im2=(rfits_im2(datos,dd,10,desp=desp)>0)-dc
im3=(rfits_im2(datos,dd,11,desp=desp)>0)-dc
im4=(rfits_im2(datos,dd,12,desp=desp)>0)-dc

if(n_elements(data) ne 8) then begin
   window,0,xsize=dd.naxis1,ysize=dd.naxis2
   tvscl,(im1+im2+im3+im4)/4.
   print,'Click Lower Position on Beam 1'
   cursor,idum,j1,3,/device
   print,'Click Upper Position on Beam 1'
   cursor,idum,j2,3,/device
   print,'Click Lower Position on Beam 2'
   cursor,idum,j3,3,/device
   print,'Click Upper Position on Beam 2'
   cursor,idum,j4,3,/device
   print,'End of Mouse Entries'
   wdelete
   i1=0
   i2=dd.naxis1-1
   i3=0
   i4=dd.naxis1-1
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
cuad1=fltarr(4,i2-i1+1,j2-j1+1)
cuad2=fltarr(4,i4-i3+1,j4-j3+1)
ff=fltarr(4,dd.naxis1,dd.naxis2)+1

for i=0,npos-1 do begin
   for j=0,3 do begin
      im=(rfits_im2(datos,dd,4*i+j+9,desp=desp)>0)-dc
      im=median(im,3)
      cuad1(j,*,*)=cuad1(j,*,*)+im(i1:i2,j1:j2)
      cuad2(j,*,*)=cuad2(j,*,*)+im(i3:i4,j3:j4)
   endfor
endfor

cuad1=cuad1/npos
cuad2=cuad2/npos

tam1=size(cuad1)
tam2=size(cuad2)
demod1=dmod # reform(cuad1,4,tam1(2)*tam1(3))
demod2=dmod # reform(cuad2,4,tam2(2)*tam2(3))
demod1=reform(demod1,4,tam1(2),tam1(3))
demod2=reform(demod2,4,tam2(2),tam2(3))
;stop
;esp=reform(demod1(0,*,*)+demod2(0,*,*))/2.
esp=reform(demod1(0,*,*)+demod2(0,*,*))/2.
esp=total(esp,2)/tam1(3)

;esp=reform(total(total(cuad1,3),1))/tam1(1)/tam1(3)
;esp=esp+reform(total(total(cuad2,3),1))/tam2(1)/tam2(3)
;esp=esp/2.

;ngrad=4
;x=par_confit(esp,ngrad) 
;cont=con_fit2(esp,ngrad,x)
;cont=cont/mean(cont)
;esp=esp/cont

imout1=fltarr(tam1(1),tam1(2),tam1(3))
imout2=fltarr(tam2(1),tam2(2),tam2(3))

for j=0,tam1(1)-1 do begin
   for k=0,tam1(3)-1 do begin
      imout1(j,*,k)=cuad1(j,*,k)/esp
   endfor
endfor

for j=0,tam2(1)-1 do begin
   for k=0,tam2(3)-1 do begin
      imout2(j,*,k)=cuad2(j,*,k)/esp
   endfor
endfor

; esto es nuevo

;ffin=[reform(cuad1(0,*,*)),reform(cuad2(0,*,*))]
;for j=1,tam1(1)-1 do ffin=[ffin,reform(cuad1(j,*,*)),reform(cuad2(j,*,*))]
;ffin=reform(ffin,tam1(2),2*tam1(1)*tam1(3))
;flatfield,ffin,ffout,1

;x=2*tam1(1)*findgen(tam1(3))
;for j=0,tam1(1)-1 do begin
;   imout1(j,*,*)=ffout(*,x+j)
;   imout2(j,*,*)=ffout(*,x+j)
;endfor

; hasta aqui

ff(*,i1:i2,j1:j2)=imout1 
ff(*,i3:i4,j3:j4)=imout2 

;z=where(ff lt 0.7 or ff gt 1.4)
;if(z(0) ne -1) then ff(z)=1.

im=fltarr(4,dd.naxis1,dd.naxis2)
im2=fltarr(4,i2-i1+1,j2-j1+1)
qq=fltarr(i2-i1+1,j2-j1+1)
uu=fltarr(i2-i1+1,j2-j1+1)
vv=fltarr(i2-i1+1,j2-j1+1)

for i=0,npos-1 do begin
   for j=0,3 do begin
      im(j,*,*)=((rfits_im2(datos,dd,4*i+j+9,desp=desp)>0)-dc)/ff(j,*,*)
      im(j,*,*)=median(reform(im(j,*,*)),3)
   endfor   
   imdemod=dmod # reform(im,4,long(dd.naxis1)*long(dd.naxis2))
   imdemod=reform(imdemod,4,dd.naxis1,dd.naxis2)
   im2(0,*,*)=(imdemod(0,i1:i2,j1:j2)+imdemod(0,i3:i4,j3:j4))/2.
   im2(1:3,*,*)=(imdemod(1:3,i1:i2,j1:j2)-imdemod(1:3,i3:i4,j3:j4))/2.
   qq=qq+reform(im2(1,*,*)/im2(0,*,*))
   uu=uu+reform(im2(2,*,*)/im2(0,*,*))
   vv=vv+reform(im2(3,*,*)/im2(0,*,*))
endfor

;stop    
qq=median(qq/npos,3)
uu=median(uu/npos,3)
vv=median(vv/npos,3)

fqq=abs(fft(qq,-1))
fuu=abs(fft(uu,-1))
fvv=abs(fft(vv,-1))

fqq(0)=0.
fuu(0)=0.
fvv(0)=0.

zqq=where(fqq gt mean(fqq)+10*std(fqq))
zuu=where(fuu gt mean(fuu)+10*std(fuu))
zvv=where(fvv gt mean(fvv)+10*std(fvv))

zqq=zuu
zvv=zuu

;zqq=-1
;zuu=-1
;zvv=-1

free_lun,unit
;stop
return
end
      
      
   

