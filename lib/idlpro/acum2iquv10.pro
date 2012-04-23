pro acum2iquv10,map_in,fileff,filecalib,display=display,$
   teles=teles,bitpix=bitpix,desp=desp,factor=factor,mast=mast,theta=theta,$
   filt=filt,data=data,option=option,step=step,old=old,getdata=getdata,$
   lambda=lambda

if(keyword_set(display) eq 0) then display=0
if(keyword_set(teles) eq 0) then teles=0
if(keyword_set(desp) eq 0) then desp=0
if(keyword_set(factor) eq 0) then factor=1.
;if(keyword_set(mast) eq 0) then mast=0
if(keyword_set(theta) eq 0) then theta=0
if(keyword_set(filt) eq 0) then filt=0
if(keyword_set(option) eq 0) then option=0
if(keyword_set(step) eq 0) then step=1
if(keyword_set(old) eq 0) then old=0
if(keyword_set(getdata) eq 0) then getdata=0
if(keyword_set(lambda) eq 0) then lambda=0

dc=rfits_im(map_in,1,dd,hdr,nrhdr,desp=desp)>0
if(keyword_set(theta) eq 0 and dd.telescope eq 'VTT') then teles=0
;if(keyword_set(mast) eq 0 and dd.telescope eq 'VTT') then teles=0

if(keyword_set(bitpix) eq 0) then bitpix=dd.bitpix

bitpix=fix(bitpix)
if(bitpix/8*8 ne bitpix) then bitpix=32
if(bitpix/8 ne 1 and bitpix/8 ne 2) then bitpix=32

get_lun,unit
openr,unit,map_in
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
   dc=dc + (rfits_im2(datos,dd,j,desp=desp)>0)
endfor

ndc=8
dc=dc/ndc        
z=where(abs(dc-mean(dc)) gt 5*stdev(dc))
if(z(0) ne -1) then dc(z)=mean(dc)

npos=(dd.naxis3-8)/4

print,' '
print,'MERGING BEAMS'
print,' '

if(n_elements(data) ne 8) then begin
   im1=(rfits_im2(datos,dd,9,desp=desp)>0)-dc
   im2=(rfits_im2(datos,dd,10,desp=desp)>0)-dc
   im3=(rfits_im2(datos,dd,11,desp=desp)>0)-dc
   im4=(rfits_im2(datos,dd,12,desp=desp)>0)-dc
   data=limits_tip(median((im1+im2+im3+im4)/4.,3))
   if((data(3)-data(2)) ne (data(7)-data(6))) then begin
      print,'**********************************************************'
      print,'PROBLEMS IN THE AUTOMATIC DETERMINATION OF THE BEAM LIMITS'
      print,'Run the manual routine (acum2iquv4)'
      print,'**********************************************************'
      close,unit
      free_lun,unit
      return
   endif  
endif
     
if(getdata eq 1) then begin
   close,unit
   free_lun,unit
   return
endif

i1=data(0)
i2=data(1)
j1=data(2)
j2=data(3)
i3=data(4)
i4=data(5)
j3=data(6)
j4=data(7)

print,' '
print,'FLATFIELD'
print,' '
pos=0
pendiente=0

nff=n_elements(fileff)

flat_tip,fileff(0),ff1,dmod,zqq,zuu,zvv,poss,pendiente,data=data,time=timeff1
ff1=ff1>0.1
timeff1=mean(timeff1)
if(nff eq 1) then begin
   ff2=ff1
   timeff2=timeff1
endif else if(nff eq 2 and fileff(0) eq fileff(1)) then begin
   ff2=ff1
   timeff2=timeff1
endif else begin   
   flat_tip,fileff(1),ff2,dmod,zqq,zuu,zvv,poss,pendiente,data=data,time=timeff2
   ff2=ff2>0.1
   timeff2=mean(timeff2)
endelse   

print,' '
print,'CALIBRATION'
print,' '

pzero=0
rzero=0
if(lambda eq 0) then begin
   lambda=param_fits(hdr,'WAVELENG=',vartype=1)*10. 
   print,'ATTENTION: wavelength taken from header = ',lambda, ' Angstroem'
endif

;delta=773.*1.e4/lambda-401.8
;delta=786.5*1.e4/lambda-408.3	; NEW APRIL 2002
;delta=789.5*1.e4/lambda-412.4	; NEW MAY 2002

calib_slit3,filecalib,ff1,dmod,data=data,lambda=lambda

print,' '
print,'FLATFIELDING + DEMODULATING + MERGING BEAMS'
print,' '

im_a=fltarr(4,dd.naxis1,dd.naxis2)
im_b=fltarr(4,dd.naxis1,dd.naxis2)
im2_a=fltarr(4,i2-i1+1,j2-j1+1)
im2_b=fltarr(4,i2-i1+1,j2-j1+1)
im2=fltarr(4,i2-i1+1,j2-j1+1)
fr=fltarr(4,i2-i1+1,j2-j1+1)
toti=fltarr(npos,j2-j1+1)
totq=fltarr(npos,j2-j1+1)
totu=fltarr(npos,j2-j1+1)
totv=fltarr(npos,j2-j1+1)

nslit=j4-j3+1
dmod2=dmod

for k=0,nslit-1 do begin
   modul=invert(dmod(*,*,k))
   for j=0,3 do dmod2(*,j,k)=dmod(*,j,k)*modul(j,0)
endfor
   
dmod=dmod2
nrhdr=n_elements(hdr)

if(display eq 0) then begin

   map_out=map_in+'c'
   get_lun,unit_out
   openw,unit_out,map_out

   for j=0L,nrhdr-1 do begin
      header=hdr(j)
      pos=strpos(hdr(j),'BITPIX  =')
      if(pos ne -1) then strput,header,string(format='(i20)',fix(bitpix)),pos+10
      pos=strpos(header,'NAXIS1  =')
      if(pos ne -1) then strput,header,string(format='(i20)',i2-i1+1),pos+10
      pos=strpos(header,'NAXIS2  =')
      if(pos ne -1) then strput,header,string(format='(i20)',j2-j1+1),pos+10
      pos=strpos(header,'NAXIS3  =')
      if(pos ne -1) then strput,header,string(format='(i20)',4*fix(npos/step)),pos+10
      pos=strpos(hdr(j),'TELESCOP=')
      if(dd.telescope eq 'SVST' and pos ne -1) then $
         strput,header,string(format='(a8)','SVST_COR'),pos+11   
      hdr(j)=header
   endfor
   writeu,unit_out,byte(hdr)

   if(bitpix eq 8) then begin
      dat_out=assoc(unit_out,bytarr(i2-i1+1,j2-j1+1),long(2880)*nrhdr)
   endif else if(bitpix eq 16) then begin   
      dat_out=assoc(unit_out,intarr(i2-i1+1,j2-j1+1),long(2880)*nrhdr)
   endif else if(bitpix eq 32) then begin   
      dat_out=assoc(unit_out,lonarr(i2-i1+1,j2-j1+1),long(2880)*nrhdr)
   endif
endif

time=param_fits(hdr,'UT      =',delimiter=':',vartype=1) 
time=time(*,0)+(time(*,1)+time(*,2)/60.)/60.
istep=param_fits(hdr,'ISTEP   =',vartype=1)
if(old eq 0) then begin
   date=param_fits(hdr,'DATE-OBS=',delimiter='-',vartype=1)
   dum=date[0]
   date[0]=date[2]
   date[2]=dum
endif else begin
   date=param_fits(hdr,'DATE    =',delimiter='/',vartype=1)
   date[2]=date[2]+1900
endelse
   
format=['(i2,$)','(i3,$)','(i4,$)','(i5,$)','(i6,$)']
print,npos

for i=0L,npos-1,step do begin
   print,i+1,format=format(fix(alog10(i+1)))
   for j=0,3 do begin
      im_a(j,*,*)=((rfits_im2(datos,dd,4*i+j+9,desp=desp)>0)-dc)/ff1(j,*,*)
      im_b(j,*,*)=((rfits_im2(datos,dd,4*i+j+9,desp=desp)>0)-dc)/ff2(j,*,*)
   endfor   
   if(teles ne 0 and dd.telescope eq 'VTT') then begin
      mat_tel=vtt(n,k,date[2],date[1],date[0],time(i),theta,mast,lambda=lambda)
   endif else if (teles ne 0 and dd.telescope eq 'SVST') then begin
      x=[0.969392,0.969392,1.01156]
      tau=[157.036,157.036,145.447]
      windows=[1.54097,7.94586,306.629,0.816829]
      mat_tel=svst_xtau(x,tau,65.2,date[2],date[1],date[0],time(i),windows=windows)  
      mat_tel=invert(mat_tel)
   endif else begin
      mat_tel=fltarr(4,4)
      for j=0,3 do mat_tel(j,j)=1.
   endelse      
   
   imdemod1=fltarr(4,i2-i1+1,j2-j1+1)
   imdemod2=fltarr(4,i2-i1+1,j2-j1+1)
   for k=0,nslit-1 do begin
      dmodslit=reform(dmod(*,*,k))
      matriz=mat_tel#dmodslit
      imdemod1(*,*,k)=matriz#reform(im_a(*,i1:i2,k+j1))
      imdemod2(*,*,k)=matriz#reform(im_a(*,i3:i4,k+j3))
   endfor  
   if(poss ne 0.) then begin
      for j=0,3 do begin
         dum=reform(imdemod2(j,*,*))
         dum=desplaza(dum,poss)
         imdemod2(j,*,*)=dum
      endfor 
   endif     
   
;   AQUI HAY DUDA DE LO QUE HAY QUE HACER

   im2_a(0,*,*)=(imdemod1(0,*,*)+imdemod2(0,*,*))/2.
   im2_a(1:3,*,*)=(imdemod1(1:3,*,*)-imdemod2(1:3,*,*))/2.
;   stop
;   im2_a(0,*,*)=(imdemod(0,i1:i2,j1:j2)+imdemod(0,i3:i4,j3:j4))/2.
;   im2_a(1:3,*,*)=(imdemod(1:3,i1:i2,j1:j2)-imdemod(1:3,i3:i4,j3:j4))/2.
   if(filt eq 1) then begin
;      for j=0,j2-j1 do for k=0,3 do im2_a(k,*,j)=median(reform(im2_a(k,*,j)),3)
;      for j=0,i2-i1 do for k=0,3 do im2_a(k,j,*)=median(reform(im2_a(k,j,*)),3)
      x=findgen(i2-i1+1)
      for j=0,j2-j1 do begin
         esp=reform(im2_a(0,*,j))
         im2_a(0,*,j)=esp-ajusta_seno(x,esp,12)+mean(ajusta_seno(x,esp,12))
      endfor
      for j=1,3 do im2_a(j,*,*)=filtra_tip(reform(im2_a(j,*,*)))
   endif  

   if(timeff1 ne timeff2) then begin

      imdemod1=fltarr(4,i2-i1+1,j2-j1+1)
      imdemod2=fltarr(4,i2-i1+1,j2-j1+1)
      for k=0,nslit-1 do begin
         dmodslit=reform(dmod(*,*,k))
         matriz=mat_tel#dmodslit
         imdemod1(*,*,k)=matriz#reform(im_b(*,i1:i2,k+j1))
         imdemod2(*,*,k)=matriz#reform(im_b(*,i3:i4,k+j3))
      endfor  
      if(poss ne 0.) then begin
         for j=0,3 do begin
            dum=reform(imdemod2(j,*,*))
            dum=desplaza(dum,poss)
            imdemod2(j,*,*)=dum
         endfor 
      endif     
   
;   AQUI HAY DUDA DE LO QUE HAY QUE HACER

      im2_b(0,*,*)=(imdemod1(0,*,*)+imdemod2(0,*,*))/2.
      im2_b(1:3,*,*)=(imdemod1(1:3,*,*)-imdemod2(1:3,*,*))/2.
;      stop
;      im2_b(0,*,*)=(imdemod(0,i1:i2,j1:j2)+imdemod(0,i3:i4,j3:j4))/2.
;      im2_b(1:3,*,*)=(imdemod(1:3,i1:i2,j1:j2)-imdemod(1:3,i3:i4,j3:j4))/2.
      if(filt eq 1) then begin
;         for j=0,j2-j1 do for k=0,3 do im2_b(k,*,j)=median(reform(im2_b(k,*,j)),3)
;         for j=0,i2-i1 do for k=0,3 do im2_b(k,j,*)=median(reform(im2_b(k,j,*)),3)
         x=findgen(i2-i1+1)
         for j=0,j2-j1 do begin
            esp=reform(im2_b(0,*,j))
            im2_b(0,*,j)=esp-ajusta_seno(x,esp,12)+mean(ajusta_seno(x,esp,12))
         endfor
         for j=1,3 do im2_b(j,*,*)=filtra_tip(reform(im2_b(j,*,*)))
      endif  
      fact_time=(timeff2-time(i))/(timeff2-timeff1)
      im2=fact_time*im2_a + (1-fact_time)*im2_b
   endif else begin
      im2=im2_a
   endelse    
   
   if(option eq 1 and istep(i) eq 1) then begin
      period=45
      for k=1,3 do begin
         for j=0,j2-j1 do begin
            esp=reform(im2(k,*,j))
            fr(k,*,j)=ajusta_seno(x,esp,period)+ajusta_seno(x,esp,2*period)
            fr(k,*,j)=fr(k,*,j)-mean(fr(k,*,j))
         endfor
      endfor
   endif
   im2=im2-fr
      
   ii2=reform(im2(0,*,*))
   qq2=reform(im2(1,*,*)/im2(0,*,*))
   uu2=reform(im2(2,*,*)/im2(0,*,*))
   vv2=reform(im2(3,*,*)/im2(0,*,*))

   toti(i,*)=total(abs(ii2(1:i2-i1-1,*)),1)/(i2-i1-1)
   totq(i,*)=total(abs(qq2(1:i2-i1-1,*)),1)/(i2-i1-1)
   totu(i,*)=total(abs(uu2(1:i2-i1-1,*)),1)/(i2-i1-1)
   totv(i,*)=total(abs(vv2(1:i2-i1-1,*)),1)/(i2-i1-1)

   if(display ne 0) then begin
      tamv2=size(vv2)
      nv2=tamv2(1)
      mv2=tamv2(2)
      ii2=ii2(1:nv2-2,1:mv2-2)
      qq2=qq2(1:nv2-2,1:mv2-2)
      uu2=uu2(1:nv2-2,1:mv2-2)
      vv2=vv2(1:nv2-2,1:mv2-2)
      mm=transpose([transpose(vv2),transpose(uu2),transpose(qq2)])
      mmm=max(mm)
      ii2=mmm*(ii2-min(ii2))/(max(ii2)-min(ii2))

      tvwinp,transpose([transpose(mm),transpose(ii2)])
   endif  else begin
   
      if(!version.arch eq "alpha" or strmid(!version.arch,0,3) eq "x86") then begin   
         if(bitpix eq 8) then begin
            for j=0,3 do dat_out(4*i+j) = byte(im2(j,*,*)/factor)
         endif else if(bitpix eq 16) then begin   
            for j=0,3 do begin
	       dum = fix(im2(j,*,*)/factor)
	       byteorder,dum
	       dat_out(4*i+j) = dum
	    endfor   
         endif else if(bitpix eq 32) then begin   
            for j=0,3 do begin
	       dum = long(im2(j,*,*)/factor)
	       byteorder,dum,/lswap
	       dat_out(4*i+j) = dum
	    endfor   
         endif
      endif else begin
         if(bitpix eq 8) then begin
            for j=0,3 do dat_out(4*i+j) = byte(im2(j,*,*)/factor)
         endif else if(bitpix eq 16) then begin   
            for j=0,3 do dat_out(4*i+j) = fix(im2(j,*,*)/factor)
         endif else if(bitpix eq 32) then begin   
            for j=0,3 do dat_out(4*i+j) = long(im2(j,*,*)/factor)
         endif
      endelse
   endelse      
endfor
print,' '
totl=sqrt(totu*totu+totq*totq)
totp=sqrt(totl*totl+totv*totv)
free_lun,unit
if(display eq 0) then free_lun,unit_out
save,filename=map_in+'m',toti,totq,totu,totv,totl,totp,hdr
return
end
