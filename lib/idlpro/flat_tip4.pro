pro flat_tip4,file,ff,r,pos,pendiente,data=data,desp=desp   

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
ff=fltarr(4,i2-i1+1,j2-j1+1)
tam=size(ff)

pos=0.5	;;;;;AQUI:::::::::::::
for i=0,npos-1 do begin
   for j=0,3 do begin
      im=(rfits_im2(datos,dd,4*i+j+9,desp=desp)>0)-dc
;      im=median(im,3)
      cuad1(j,*,*)=cuad1(j,*,*)+im(i1:i2,j1:j2)
      cuad2(j,*,*)=cuad2(j,*,*)+im(i3:i4,j3:j4)
   endfor
endfor

cuad1=cuad1/npos
cuad2=cuad2/npos
for j=0,3 do cuad2(j,*,*)=desplaza(reform(cuad2(j,*,*)),pos)

dif=(cuad1-cuad2)/2.
sum=(cuad1+cuad2)/2.
r=dif/sum
iff=sum-r*dif

pendiente=0.   ;-0.010	;;;;;AQUI:::::::::::::
iffm=total(iff,1)/4
esp=fltarr(tam(2))
xx=findgen(tam(2))
if(pendiente ne 0) then begin
   for j=0,tam(3)-1 do begin
      esp=esp+interpol(iffm(*,j),xx,xx+j*pendiente)
   endfor   
   esp=esp/tam(3)

   for j=0,tam(1)-1 do begin
      for k=0,tam(3)-1 do begin
         ff(j,*,k)=iff(j,*,k)/interpol(esp,xx,xx-k*pendiente)
      endfor
   endfor
endif else begin
   for j=0,tam(2)-1 do esp(j)=median(iffm(j,*))
   cont=con_fit(esp,2)
   esp=esp*mean(cont)/cont
;   fesp=fft(esp-mean(esp),-1)
;   fesp(20:245-20)=0.
;   esp2=float(fft(fesp,1))+mean(esp)
;   ff2=fltarr(4,i2-i1+1,j2-j1+1)
   for j=0,tam(1)-1 do begin
      for k=0,tam(3)-1 do begin
         ff(j,*,k)=iff(j,*,k)/esp
;         ff2(j,*,k)=iff(j,*,k)/esp2
      endfor
   endfor
endelse   
   

;stop
free_lun,unit
return

end
      
      
   

