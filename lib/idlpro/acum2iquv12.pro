pro acum2iquv12,map_in_base,fileff,filecalib,display=display,$
   teles=teles,bitpix=bitpix,desp=desp,factor=factor,mast=mast,theta=theta,$
   filt=filt,data=data,option=option,step=step,old=old,getdata=getdata,$
   lambda=lambda,xtalk=xtalk, $
   denoise_fft=denoise_fft          ;denoise keyword, added by A. Lagg, Oct05


if(keyword_set(display) eq 0) then display=0
if(keyword_set(teles) eq 0) then teles=0
if(keyword_set(desp) eq 0) then desp=0
if(keyword_set(factor) eq 0) then factor=1.
if(keyword_set(teles) ne 0 and n_elements(theta) eq 0) then theta = 0
if(keyword_set(filt) eq 0) then filt=0
if(keyword_set(option) eq 0) then option=0
if(keyword_set(step) eq 0) then step=1
if(keyword_set(old) eq 0) then old=0
if(keyword_set(getdata) eq 0) then getdata=0
if(keyword_set(lambda) eq 0) then lambda=0
if(keyword_set(xtalk) eq 0) then xtalk=0
if(keyword_set(denoise_fft) eq 0) then denoise_fft=0


;use file_search (A. Lagg, May 05)
files=file_search(map_in_base+'*',count=cnt)
if cnt eq 0 then message,'No TIP maps found.'
iraw=where(strpos(files,'c',/reverse_search) ne strlen(files)-1 and $
           strpos(files,'m',/reverse_search) ne strlen(files)-1)
if iraw(0) eq -1 then message,'No TIP raw data files found.'
files=files(iraw)
files=files(sort(files))
nmap_in=n_elements(files)
message,/cont,'Found raw data files: '+strjoin(files,', ')

;spawn,'ls -l '+map_in_base+'*',result
;pos=strpos(result,map_in_base)
;nmap_in=n_elements(pos)
;files=strarr(nmap_in)
;for j=0,nmap_in-1 do files(j)=strmid(result(j),pos(j),30)
;files=files(sort(files))


dc=rfits_im(files(0),1,dd,hdr,nrhdr,desp=desp,/badpix)>0

if(keyword_set(bitpix) eq 0) then bitpix=dd.bitpix

bitpix=fix(bitpix)
if(bitpix/8*8 ne bitpix) then bitpix=32
if(bitpix/8 ne 1 and bitpix/8 ne 2) then bitpix=32

get_lun,unit
openr,unit,files(0)
      
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
   dc=dc + rfits_im2(datos,dd,j,desp=desp,/badpix)>0
endfor

ndc=8
dc=dc/ndc        
z=where(abs(dc-mean(dc)) gt 5*stdev(dc))
if(z(0) ne -1) then dc(z)=mean(dc)

print,' '
print,'MERGING BEAMS'
print,' '

if(n_elements(data) ne 8) then begin
   dcff=rfits_im(fileff(0),1,/badpix)>0
   for j=2,8 do dcff=dcff+rfits_im(fileff(0),j,/badpix)>0
   dcff=dcff/8.
   im1=(rfits_im(fileff(0),9,desp=desp,/badpix)>0)-dcff
   im2=(rfits_im(fileff(0),10,desp=desp,/badpix)>0)-dcff
   im3=(rfits_im(fileff(0),11,desp=desp,/badpix)>0)-dcff
   im4=(rfits_im(fileff(0),12,desp=desp,/badpix)>0)-dcff
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
     
close,unit
free_lun,unit

if(getdata eq 1) then return

i1=data(0)
i2=data(1)
j1=data(2)
j2=data(3)
i3=data(4)
i4=data(5)
j3=data(6)
j4=data(7)

nslit=j4-j3+1

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

dmod2=dmod

for k=0,nslit-1 do begin
   modul=invert(dmod(*,*,k))
   for j=0,3 do dmod2(*,j,k)=dmod(*,j,k)*modul(j,0)
endfor
   
dmod=dmod2
nrhdr=n_elements(hdr)
;stop
for jj=0,nmap_in-1 do begin
   map_in=files(jj)
   print,map_in
   get_lun,unit
   openr,unit,map_in
   dum=rfits_im(map_in,1,dd,hdr,nrhdr,/badpix)
   tam=size(dum)
   close,1
   if(jj eq 0) then offset=8 else offset=0
   npos=(dd.naxis3-offset)/4 
   close,unit
   free_lun,unit
   
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

   im_a=fltarr(4,tam(1),tam(2))
   im_b=fltarr(4,tam(1),tam(2))
   im2_a=fltarr(4,i2-i1+1,j2-j1+1)
   im2_b=fltarr(4,i2-i1+1,j2-j1+1)
   im2=fltarr(4,i2-i1+1,j2-j1+1)
   fr=fltarr(4,i2-i1+1,j2-j1+1)
   toti=fltarr(npos,j2-j1+1)
   totq=fltarr(npos,j2-j1+1)
   totu=fltarr(npos,j2-j1+1)
   totv=fltarr(npos,j2-j1+1)

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
      im_a(j,*,*)=((rfits_im2(datos,dd,4*i+j+offset+1,desp=desp,/badpix)>0)-dc)/ff1(j,*,*)
      im_b(j,*,*)=((rfits_im2(datos,dd,4*i+j+offset+1,desp=desp,/badpix)>0)-dc)/ff2(j,*,*)
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

;      x=findgen(i2-i1+1)
;      for j=0,j2-j1 do begin
;         esp=reform(im2_a(0,*,j))
;         im2_a(0,*,j)=esp-ajusta_seno(x,esp,12)+mean(ajusta_seno(x,esp,12))
;      endfor

      for j=0,j2-j1 do begin
         esp=reform(im2_a(0,*,j))
         im2_a(0,*,j)=esp-franjas(esp,24,4)
;         esp=reform(im2_a(1,*,j))
;         im2_a(1,*,j)=esp-franjas(esp,180,4)
;         esp=reform(im2_a(2,*,j))
;         im2_a(2,*,j)=esp-franjas(esp,180,4)
;         esp=reform(im2_a(3,*,j))
;         im2_a(3,*,j)=esp-franjas(esp,180,4)
      endfor
      for j=1,3 do im2_a(j,*,*)=filtra_tip2(reform(im2_a(j,*,*)))
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

;         x=findgen(i2-i1+1)
;         for j=0,j2-j1 do begin
;            esp=reform(im2_b(0,*,j))
;            im2_b(0,*,j)=esp-ajusta_seno(x,esp,12)+mean(ajusta_seno(x,esp,12))
;         endfor
         for j=0,j2-j1 do begin
            esp=reform(im2_b(0,*,j))
            im2_b(0,*,j)=esp-franjas(esp,24,4)
;            esp=reform(im2_b(1,*,j))
;            im2_b(1,*,j)=esp-franjas(esp,180,4)
;            esp=reform(im2_b(2,*,j))
;            im2_b(2,*,j)=esp-franjas(esp,180,4)
;            esp=reform(im2_b(3,*,j))
;            im2_b(3,*,j)=esp-franjas(esp,180,4)
         endfor
         for j=1,3 do im2_b(j,*,*)=filtra_tip2(reform(im2_b(j,*,*)))
      endif  
      fact_time=(timeff2-time(i))/(timeff2-timeff1)
      im2=fact_time*im2_a + (1-fact_time)*im2_b
   endif else begin
      im2=im2_a
   endelse    

;stop   
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
      
                                ;added FFT denoising for TIP2 data,
                                ;A. Lagg, Oct 2005
   if keyword_set(denoise_fft) then im2=fft_denoise(im2)

   ii2=reform(im2(0,*,*))
   qq2=reform(im2(1,*,*)/im2(0,*,*))
   uu2=reform(im2(2,*,*)/im2(0,*,*))
   vv2=reform(im2(3,*,*)/im2(0,*,*))

   toti(i,*)=total(abs(ii2(1:i2-i1-1,*)),1)/(i2-i1-1)
   totq(i,*)=total(abs(qq2(1:i2-i1-1,*)),1)/(i2-i1-1)
   totu(i,*)=total(abs(uu2(1:i2-i1-1,*)),1)/(i2-i1-1)
   totv(i,*)=total(abs(vv2(1:i2-i1-1,*)),1)/(i2-i1-1)

;   for j=0,dd.naxis2-1 do begin
;      totq(i,j)=totq(i,j)-median(abs(qq2(*,j)))
;      totu(i,j)=totu(i,j)-median(abs(uu2(*,j)))
;      totv(i,j)=totv(i,j)-median(abs(vv2(*,j)))
;   endfor   

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
   free_lun,unit
   close,unit
   totl=sqrt(totu*totu+totq*totq)
   totp=sqrt(totl*totl+totv*totv)
   free_lun,unit
   if(display eq 0) then free_lun,unit_out
   save,filename=map_in+'m',toti,totq,totu,totv,totl,totp,hdr
   print,' '
   print,' '

   if(xtalk ne 0) then xtalk2f,map_in+'c'

endfor

return
end