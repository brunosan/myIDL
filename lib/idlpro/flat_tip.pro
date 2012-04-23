pro flat_tip,file,ff,dmod,zqq,zuu,zvv,pos,pendiente,data=data,desp=desp,$
   time=time  

if(keyword_set(desp) eq 0) then desp=0
dum=rfits_im(file,1,dd,hdr,nrhdr,desp=desp,/badpix)>0
   
time=param_fits(hdr,'UT      =',delimiter=':',vartype=1) 
time=time(*,0)+(time(*,1)+time(*,2)/60.)/60.

tam=size(dum)
dc=dum
ndc=1

get_lun,unit
openr,unit,file

if(dd.telescope eq 'SVST') then begin
   if(dd.bitpix eq 8) then begin
      datos=assoc(unit,bytarr(dd.naxis2,dd.naxis1),long(2880)*nrhdr)
   endif else if(dd.bitpix eq 16) then begin   
      datos=assoc(unit,intarr(dd.naxis2,dd.naxis1),long(2880)*nrhdr)
   endif else if(dd.bitpix eq 32) then begin   
      datos=assoc(unit,lonarr(dd.naxis2,dd.naxis1),long(2880)*nrhdr)
   endif
endif else begin   
   if(dd.bitpix eq 8) then begin
      datos=assoc(unit,bytarr(dd.naxis1,dd.naxis2),long(2880)*nrhdr)
   endif else if(dd.bitpix eq 16) then begin   
      datos=assoc(unit,intarr(dd.naxis1,dd.naxis2),long(2880)*nrhdr)
   endif else if(dd.bitpix eq 32) then begin   
      datos=assoc(unit,lonarr(dd.naxis1,dd.naxis2),long(2880)*nrhdr)
   endif
endelse 
for j=2,8 do begin
   dum=(rfits_im2(datos,dd,j,desp=desp,/badpix)>0)
   dc=dc+dum
   ndc=ndc+1
endfor

if(ndc eq 0) then begin
   print,'no hay DCs validas'
   return
endif
   
dc=dc/ndc        
z=where(abs(dc-mean(dc)) gt 5*stdev(dc))
if(z(0) ne -1) then dc(z)=mean(dc)

npos=(dd.naxis3-8)/4
npos=npos<15
time=time(0:npos-1)

if(n_elements(data) ne 8) then begin
   im1=(rfits_im2(datos,dd,9,desp=desp,/badpix)>0)-dc
   im2=(rfits_im2(datos,dd,10,desp=desp,/badpix)>0)-dc
   im3=(rfits_im2(datos,dd,11,desp=desp,/badpix)>0)-dc
   im4=(rfits_im2(datos,dd,12,desp=desp,/badpix)>0)-dc

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
cuad1=dblarr(4,i2-i1+1,j2-j1+1)
cuad2=dblarr(4,i4-i3+1,j4-j3+1)
ff=fltarr(4,tam(1),tam(2))+1

format=['(i2,$)','(i3,$)','(i4,$)','(i5,$)','(i6,$)']
print,npos
for i=0,npos-1 do begin
   print,i+1,format=format(fix(alog10(i+1)))
   for j=0,3 do begin
      im=(rfits_im2(datos,dd,4*i+j+9,desp=desp,/badpix)>0)-dc
      cuad1(j,*,*)=cuad1(j,*,*)+im(i1:i2,j1:j2)
      cuad2(j,*,*)=cuad2(j,*,*)+im(i3:i4,j3:j4)
   endfor
endfor
print,' '
cuad1=cuad1/npos
cuad2=cuad2/npos

;stop

;for j=0,3 do begin
;   cuad1(j,*,*)=cuad1(j,*,*)/mean(cuad1(j,*,*))
;   cuad2(j,*,*)=cuad2(j,*,*)/mean(cuad2(j,*,*))
;endfor
norm=mean([cuad1,cuad2])
for j=0,3 do begin
   cuad1(j,*,*)=cuad1(j,*,*)/norm
   cuad2(j,*,*)=cuad2(j,*,*)/norm
endfor

tam1=size(cuad1)
tam2=size(cuad2)

imout1=fltarr(tam1(1),tam1(2),tam1(3))
imout2=fltarr(tam2(1),tam2(2),tam2(3))

pendiente=0.   ;-0.010
pos=0.0
xx=findgen(tam1(2))
esp1=total(total(cuad1,3),1)/tam1(1)/tam1(3)
esp2=total(total(cuad2,3),1)/tam2(1)/tam2(3)

esp1(128-i1:*)=esp1(128-i1:*)*esp1(127-i1)/esp1(128-i1)
esp2(128-i1:*)=esp2(128-i1:*)*esp2(127-i1)/esp2(128-i1)

if(pos eq 0.0) then begin
   esp=(esp1+esp2)/2.
endif else begin
   esp=(esp1+interpol(esp2,xx,xx+pos))/2.
endelse
   
;cont=con_fit(esp,2)
cont=continuum(esp,0)
esp=esp*mean(cont)/cont

if(pos eq 0.0) then begin
   for j=0,tam1(1)-1 do begin
      for k=0,tam1(3)-1 do begin
         imout1(j,*,k)=cuad1(j,*,k)/esp
         imout2(j,*,k)=cuad2(j,*,k)/esp
      endfor
   endfor
endif else begin
   for j=0,tam1(1)-1 do begin
      for k=0,tam1(3)-1 do begin
         imout1(j,*,k)=cuad1(j,*,k)/esp
         imout2(j,*,k)=cuad2(j,*,k)/interpol(esp,xx,xx-pos)
      endfor
   endfor
endelse     

ff(*,i1:i2,j1:j2)=imout1 
ff(*,i3:i4,j3:j4)=imout2 
z=where(ff le 0) 
if(z(0) ne -1) then ff(z)=1.

free_lun,unit
return

end
      
      
   

