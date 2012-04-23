pro acum2iquv2,map_in,fileff,filecalib,pzero,rzero,delta,display=display,$
   teles=teles,bitpix=bitpix,desp=desp,factor=factor,mast=mast,theta=theta,$
   filt=filt,data=data

if(keyword_set(display) eq 0) then display=0
if(keyword_set(teles) eq 0) then teles=0
if(keyword_set(desp) eq 0) then desp=0
if(keyword_set(factor) eq 0) then factor=1.
if(keyword_set(mast) eq 0) then teles=0
if(keyword_set(theta) eq 0) then teles=0
if(keyword_set(filt) eq 0) then filt=0

dum=rfits_im(map_in,1,dd,hdr,nrhdr,desp=desp)>0
if(mean(dum) lt 2000) then begin
      dc=dum
      ndc=1
endif else begin
   dc=fltarr(dd.naxis1,dd.naxis2)
   ndc=0
endelse   

if(keyword_set(bitpix) eq 0) then bitpix=dd.bitpix

bitpix=fix(bitpix)
if(bitpix/8*8 ne bitpix) then bitpix=32
if(bitpix/8 ne 1 and bitpix/8 ne 2) then bitpix=32

get_lun,unit
openr,unit,map_in
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
;npos=50
im1=(rfits_im2(datos,dd,9,desp=desp)>0)-dc
im2=(rfits_im2(datos,dd,10,desp=desp)>0)-dc
im3=(rfits_im2(datos,dd,11,desp=desp)>0)-dc
im4=(rfits_im2(datos,dd,12,desp=desp)>0)-dc

if(n_elements(data) ne 8) then begin
   j1=0
   j2=0
   j3=0
   j4=1
endif else begin
   j1=data(2)-3
   j2=data(3)+3
   j3=data(6)-3
   j4=data(7)+3 
endelse

print,' '
print,'MERGING BEAMS'
print,' '

while((j2-j1) ne (j4-j3)) do begin
   window,2,xsize=dd.naxis1,ysize=dd.naxis2
   tvscl,median((im1+im2+im3+im4)/4.,3)
   window,0,xsize=512,ysize=768
   !p.multi=0
   plot,total(im1+im2+im3+im4,1),findgen(dd.naxis2),psym=-1,/ystyle
   print,'Click Accurately Lower Position on Beam 1'
   cursor,idum,j1,3   ;,/device
   j1=fix(j1+0.5)
   print,'Click Accurately Upper Position on Beam 1'
   cursor,idum,j2,3   ;,/device
   j2=fix(j2+0.5) 
   print,'Click Accurately Lower Position on Beam 2'
   cursor,idum,j3,3   ;,/device
   j3=fix(j3+0.5) 
   print,'Click Accurately Upper Position on Beam 2'
   cursor,idum,j4,3  ;,/device
   j4=fix(j4+0.5)
   if((j2-j1) ne (j4-j3)) then begin
      print,'CLICK AGAIN'
   endif else begin
      print,'End of Mouse Entries'
      wset,0
      wdelete
      wset,2
      wdelete
   endelse 
endwhile
     
i1=10
i2=dd.naxis1-1-1	;-10
i3=10
i4=dd.naxis1-1-1	;-10
j1=j1+3
j2=j2-3
j3=j3+3
j4=j4-3
data=[i1,i2,j1,j2,i3,i4,j3,j4]
;print,data
;stop

print,' '
print,'CALIBRATION'
print,' '
calib2_mod,filecalib,dmod,pzero,rzero,delta,data=data

print,' '
print,'FLATFIELD'
print,' '
pos=0
pendiente=0

nff=n_elements(fileff)
nff=1.
flat_tip,fileff(0),ff1,dmod,zqq,zuu,zvv,poss,pendiente,data=data,time=timeff

flat_tip,fileff(1),ff2,dmod,zqq,zuu,zvv,poss,pendiente,data=data,time=timeff
ff=ff1

print,' '
print,'FLATFIELDING + DEMODULATING + MERGING BEAMS'
print,' '

im=fltarr(4,dd.naxis1,dd.naxis2)
im2=fltarr(4,i2-i1+1,j2-j1+1)
toti=fltarr(npos,j2-j1+1)
totq=fltarr(npos,j2-j1+1)
totu=fltarr(npos,j2-j1+1)
totv=fltarr(npos,j2-j1+1)

dmod2=dmod
modul=invert(dmod)
nrhdr=n_elements(hdr)
for j=0,3 do dmod2(*,j)=dmod(*,j)*modul(j,0)
dmod=dmod2
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
      if(pos ne -1) then strput,header,string(format='(i20)',4*npos),pos+10
;      pos=strpos(header,'BSCALE  =')
;      if(pos ne -1) then strput,header,string(format='(f20.5)',1.),pos+10
;      pos=strpos(header,'BZERO   =')
;      if(pos ne -1) then strput,header,string(format='(f20.5)',0.),pos+10
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
time=time(*,0)+(time(*,1)+time(*,2)/60.)/60.-1
date=param_fits(hdr,'DATE-OBS=',delimiter='-',vartype=1)
;date=param_fits(hdr,'DATE    =',delimiter='/',vartype=1)
;date(2)=date(2)+1900
lambda=param_fits(hdr,'WAVELENG=',vartype=1)*10. 
format=['(i2,$)','(i3,$)','(i4,$)','(i5,$)','(i6,$)']
print,npos
for i=0L,npos-1 do begin
   print,i+1,format=format(fix(alog10(i+1)))
   for j=0,3 do begin
      im(j,*,*)=((rfits_im2(datos,dd,4*i+j+9,desp=desp)>0)-dc)
;      im(j,*,*)=median(reform(im(j,*,*)),3)
   endfor   
   if(teles ne 0) then begin
;      if(time(i) lt 13.) then begin
;         theta=-60.
;      endif else begin
;         theta=60.
;         theta=90.
;      endelse 	 
;      mat_tel=vtt(n,k,date(2),date(1),date(0),time(i),theta,105.,lambda=lambda)
      mat_tel=vtt(n,k,date(2),date(1),date(0),time(i),theta,mast,lambda=lambda)
      mat_tel=invert(mat_tel)
   endif else begin
      mat_tel=fltarr(4,4)
      for j=0,3 do mat_tel(j,j)=1.
   endelse      


   if ( (I MOD 20) eq 0.) then alin,im,ff1,dmod,modul,mat_tel,data,ffnew   

   imm=im/ffnew
   imdemod=mat_tel # dmod # reform(imm,4,long(dd.naxis1)*long(dd.naxis2))
   imdemod=reform(imdemod,4,dd.naxis1,dd.naxis2)
   for j=0,3 do begin
      dum=reform(imdemod(j,i3:i4,j3:j4))
      dum=desplaza(dum,poss)
      imdemod(j,i3:i4,j3:j4)=dum
   endfor   
   im2(0,*,*)=(imdemod(0,i1:i2,j1:j2)+imdemod(0,i3:i4,j3:j4))/2.
   im2(1:3,*,*)=(imdemod(1:3,i1:i2,j1:j2)-imdemod(1:3,i3:i4,j3:j4))/2.
   if(filt eq 1) then for j=1,3 do im2(j,*,*)=filtra_tip(im2(j,*,*))
      
;   for j=0,3 do begin
;      dum=reform(im2(j,*,*))
;      dum=ponrecto(dum,pendiente)
;      im2(j,*,*)=dum
;   endfor   
   
   
   qq=reform(im2(1,*,*)/im2(0,*,*))
   uu=reform(im2(2,*,*)/im2(0,*,*))
   vv=reform(im2(3,*,*)/im2(0,*,*))

;   fqq=fft(qq,-1)
;   fuu=fft(uu,-1)
;   fvv=fft(vv,-1)

;   if(zqq(0) ne -1) then fqq(zqq)=0.
;   if(zuu(0) ne -1) then fuu(zuu)=0.
;   if(zvv(0) ne -1) then fvv(zvv)=0.

;   qq=float(fft(fqq,1))
;   uu=float(fft(fuu,1))
;   vv=float(fft(fvv,1))

   qq2=median(qq,5)
   uu2=median(uu,5)
   vv2=median(vv,5)
   ii2=median(reform(im2(0,*,*)),5)

   toti(i,*)=total(abs(ii2),1)/(i2-i1+1)
   totq(i,*)=total(abs(qq2),1)/(i2-i1+1)
   totu(i,*)=total(abs(uu2),1)/(i2-i1+1)
   totv(i,*)=total(abs(vv2),1)/(i2-i1+1)

   if(display ne 0) then begin
      tamv2=size(vv2)
      nv2=tamv2(1)
      mv2=tamv2(2)
      ii2=ii2(2:nv2-3,2:mv2-3)
      qq2=qq2(2:nv2-3,2:mv2-3)
      uu2=uu2(2:nv2-3,2:mv2-3)
      vv2=vv2(2:nv2-3,2:mv2-3)
      mm=-0.01>transpose([transpose(vv2),transpose(uu2),transpose(qq2)])<0.01
      mmm=max(mm)
      ii2=mmm*(ii2-min(ii2))/(max(ii2)-min(ii2))

      tvwinp,transpose([transpose(mm),transpose(ii2)])
;      stop
   endif  else begin
      im2(1,*,*)=qq*im2(0,*,*)
      im2(2,*,*)=uu*im2(0,*,*)
      im2(3,*,*)=vv*im2(0,*,*)
   
      if(!version.arch eq "alpha") then begin   
         if(bitpix eq 8) then begin
            for j=0,3 do dat_out(4*i+j) = byte(im2(j,*,*))
         endif else if(bitpix eq 16) then begin   
            for j=0,3 do begin
	       dum = fix(im2(j,*,*))
	       byteorder,dum
	       dat_out(4*i+j) = dum
	    endfor   
         endif else if(bitpix eq 32) then begin   
            for j=0,3 do begin
	       dum = long(im2(j,*,*))
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
;gamma=atan(sqrt(totp),totv)
;phi=atan(totu,totq)/2.
free_lun,unit
if(display eq 0) then free_lun,unit_out
save,filename=map_in+'m',toti,totq,totu,totv,totl,totp
return
end
