pro xtalk2,file,xi2quv,xv2q,xv2u

dum=median(rfits_im(file,1,dd,hdr,nrhdr),3)

time=param_fits(hdr,'UT      =',delimiter=':',vartype=1) 
time=time(*,0)+(time(*,1)+time(*,2)/60.)/60.-1
ntime=n_elements(time)

get_lun,unit
openr,unit,file
if(dd.bitpix eq 8) then begin
   datos=assoc(unit,bytarr(dd.naxis1,dd.naxis2),long(2880)*nrhdr)
endif else if(dd.bitpix eq 16) then begin   
   datos=assoc(unit,intarr(dd.naxis1,dd.naxis2),long(2880)*nrhdr)
endif else if(dd.bitpix eq 32) then begin   
   datos=assoc(unit,lonarr(dd.naxis1,dd.naxis2),long(2880)*nrhdr)
endif

npos=dd.naxis3/4
if(npos gt ntime) then begin
   npos=ntime
endif else begin
   ntime=npos
   time=time(0:ntime-1)
endelse        

xi2quv=fltarr(3,npos)
step=2.e-4
xh=findgen(1001)*step
xh=xh-max(xh)/2.

format=['(i2,$)','(i3,$)','(i4,$)','(i5,$)','(i6,$)']

print,'xtalk I --> Q,U,V'
print,'*****************'
for j=0,npos-1 do begin

   if((j+1)/10*10 eq j+1) then print,j+1,format=format(fix(alog10(j+1)))
   imi=median(rfits_im2(datos,dd,4*j+1),3)
   imq=median(rfits_im2(datos,dd,4*j+2),3)/imi
   imu=median(rfits_im2(datos,dd,4*j+3),3)/imi
   imv=median(rfits_im2(datos,dd,4*j+4),3)/imi
   
   imq=imq(1:dd.naxis1-2,1:dd.naxis2-2)
   imu=imu(1:dd.naxis1-2,1:dd.naxis2-2)
   imv=imv(1:dd.naxis1-2,1:dd.naxis2-2)
   
   hq=smooth(histogram(imq,binsize=step,min=min(xh),max=max(xh)),5)
   hu=smooth(histogram(imu,binsize=step,min=min(xh),max=max(xh)),5)
   hv=smooth(histogram(imv,binsize=step,min=min(xh),max=max(xh)),5)

   xi2quv(0,j)=xh(min(where(hq eq max(hq))))
   xi2quv(1,j)=xh(min(where(hu eq max(hu))))
   xi2quv(2,j)=xh(min(where(hv eq max(hv))))
endfor
print,' '
xx=fltarr(npos,3)
xx(*,0)=1
xx(*,1)=time-time(0)
xx(*,2)=xx(*,1)*xx(*,1)

;coefI2Q=lstsqfit(xx,reform(xi2quv(0,*)),xi2qfit)   
;coefI2U=lstsqfit(xx,reform(xi2quv(1,*)),xi2ufit)   
;coefI2V=lstsqfit(xx,reform(xi2quv(2,*)),xi2vfit)   

xi2qfit=reform(xi2quv(0,*))
xi2ufit=reform(xi2quv(1,*))
xi2vfit=reform(xi2quv(2,*))

xqV2Q=fltarr(dd.naxis1-2,dd.naxis2-2)
xvV2Q=fltarr(dd.naxis1-2,dd.naxis2-2)
xuV2U=fltarr(dd.naxis1-2,dd.naxis2-2)
xvV2U=fltarr(dd.naxis1-2,dd.naxis2-2)

ccV2Q=fltarr(npos)
ccV2U=fltarr(npos)

print,'xtalk V --> Q,U'
print,'***************'

for j=0,npos-1 do begin
   cntV2Q=0
   cntV2U=0
   if((j+1)/10*10 eq j+1) then print,j+1,format=format(fix(alog10(j+1)))
   imi=median(rfits_im2(datos,dd,4*j+1),3)
   imq=median(rfits_im2(datos,dd,4*j+2),3)/imi
   imu=median(rfits_im2(datos,dd,4*j+3),3)/imi
   imv=median(rfits_im2(datos,dd,4*j+4),3)/imi
   
   imq=imq(1:dd.naxis1-2,1:dd.naxis2-2)-xi2qfit(j)
   imu=imu(1:dd.naxis1-2,1:dd.naxis2-2)-xi2ufit(j)
   imv=imv(1:dd.naxis1-2,1:dd.naxis2-2)-xi2vfit(j)
   
   for i=0,dd.naxis2-3 do begin
      
      maxq=max(abs(imq(*,i)))
      maxu=max(abs(imu(*,i)))
      maxv=max(abs(imv(*,i)))
      
      if(maxv/maxq gt 5) then begin
         cntV2Q=cntV2Q+1
	 xqV2Q(*,cntV2Q-1)=imq(*,i)
	 xvV2Q(*,cntV2Q-1)=imv(*,i)
      endif
      if(maxv/maxu gt 5) then begin
         cntV2U=cntV2U+1
	 xuV2U(*,cntV2U-1)=imu(*,i)
	 xvV2U(*,cntV2U-1)=imv(*,i)
      endif
   endfor
   if(cntV2Q ne 0) then begin
      xx=reform(xvV2Q(*,0:cntV2Q-1),n_elements(xvV2Q(*,0:cntV2Q-1)))
      yy=reform(xqV2Q(*,0:cntV2Q-1),n_elements(xqV2Q(*,0:cntV2Q-1)))
      coef=lstsqfit(xx,yy)
      ccV2Q(j)=coef(0)
   endif else begin
      ccV2Q(j)=-1
   endelse
   if(cntV2U ne 0) then begin
      xx=reform(xvV2U(*,0:cntV2U-1),n_elements(xvV2U(*,0:cntV2U-1)))
      yy=reform(xuV2U(*,0:cntV2U-1),n_elements(xuV2U(*,0:cntV2U-1)))
      coef=lstsqfit(xx,yy)
      ccV2U(j)=coef(0)
   endif else begin
      ccV2U(j)=-1
   endelse

endfor
print,' '

zq=where(ccV2Q ne -1)
zu=where(ccV2U ne -1)

if(zq(0) ne -1) then begin
   xx=fltarr(n_elements(zq),3)
   xx(*,0)=1
   xx(*,1)=time(zq)-time(0)
   xx(*,2)=xx(*,1)*xx(*,1)
   coefV2Q=lstsqfit(xx,ccV2Q(zq))
   xv2qfit=poly(time-time(0),coefV2Q(*,0))
endif else begin
   xv2qfit=fltarr(npos)   
endelse

if(zu(0) ne -1) then begin
   xx=fltarr(n_elements(zu),3)
   xx(*,0)=1
   xx(*,1)=time(zu)-time(0)
   xx(*,2)=xx(*,1)*xx(*,1)
   coefV2U=lstsqfit(xx,ccV2U(zu))
   xv2ufit=poly(time-time(0),coefV2U(*,0))
endif else begin
   xv2ufit=fltarr(npos)   
endelse

print,' '
print,'Average Xtalk I --> Q = ',mean(xi2qfit),' +/-',std(xi2quv(0,*)-xi2qfit)
print,'Average Xtalk I --> U = ',mean(xi2ufit),' +/-',std(xi2quv(1,*)-xi2ufit)
print,'Average Xtalk I --> V = ',mean(xi2vfit),' +/-',std(xi2quv(2,*)-xi2vfit)
print,' '
if(zq(0) ne -1) then $
print,'Average Xtalk V --> Q = ',mean(xv2qfit),' +/-',std(ccV2Q(zq)-xv2qfit(zq))
if(zu(0) ne -1) then $
print,'Average Xtalk V --> U = ',mean(xv2ufit),' +/-',std(ccV2U(zu)-xv2ufit(zu))
print,' '
print,'Correcting data'
print,'***************'

map_out=file+'c'
get_lun,unit_out
openw,unit_out,map_out
writeu,unit_out,byte(hdr)

if(dd.bitpix eq 8) then begin
   dat_out=assoc(unit_out,bytarr(dd.naxis1,dd.naxis2),long(2880)*nrhdr)
endif else if(dd.bitpix eq 16) then begin   
   dat_out=assoc(unit_out,intarr(dd.naxis1,dd.naxis2),long(2880)*nrhdr)
endif else if(dd.bitpix eq 32) then begin   
   dat_out=assoc(unit_out,lonarr(dd.naxis1,dd.naxis2),long(2880)*nrhdr)
endif

for j=0,npos-1 do begin
   if((j+1)/10*10 eq j+1) then print,j+1,format=format(fix(alog10(j+1)))
   imi=rfits_im2(datos,dd,4*j+1)
   imq=rfits_im2(datos,dd,4*j+2)
   imu=rfits_im2(datos,dd,4*j+3)
   imv=rfits_im2(datos,dd,4*j+4)
   
   imq=imq-xi2qfit(j)*imi
   imu=imu-xi2ufit(j)*imi
   imv=imv-xi2vfit(j)*imi
   imq=imq-xv2qfit(j)*imv
   imu=imu-xv2ufit(j)*imv
   if(!version.arch eq "alpha" or strmid(!version.arch,0,3) eq "x86") then begin   
      if(dd.bitpix eq 8) then begin
         dat_out(4*j)=byte(imi)
         dat_out(4*j+1)=byte(imq)
         dat_out(4*j+2)=byte(imu)
         dat_out(4*j+3)=byte(imv)
      endif else if(dd.bitpix eq 16) then begin
 	 dum = fix(imi)
         byteorder,dum
	 dat_out(4*j)=dum
 	 dum = fix(imq)
         byteorder,dum
	 dat_out(4*j+1)=dum
 	 dum = fix(imu)
         byteorder,dum
	 dat_out(4*j+2)=dum
 	 dum = fix(imv)
         byteorder,dum
	 dat_out(4*j+3)=dum
      endif else if(dd.bitpix eq 32) then begin   
 	 dum = long(imi)
         byteorder,dum,/lswap
	 dat_out(4*j)=dum
 	 dum = long(imq)
         byteorder,dum,/lswap
	 dat_out(4*j+1)=dum
 	 dum = long(imu)
         byteorder,dum,/lswap
	 dat_out(4*j+2)=dum
 	 dum = long(imv)
         byteorder,dum,/lswap
	 dat_out(4*j+3)=dum
      endif
   endif else begin
      if(dd.bitpix eq 8) then begin
         dat_out(4*j)=byte(imi)
         dat_out(4*j+1)=byte(imq)
         dat_out(4*j+2)=byte(imu)
         dat_out(4*j+3)=byte(imv)
      endif else if(dd.bitpix eq 16) then begin   
	 dat_out(4*j)=fix(imi)
	 dat_out(4*j+1)=fix(imq)
	 dat_out(4*j+2)=fix(imu)
	 dat_out(4*j+3)=fix(imv)
      endif else if(dd.bitpix eq 32) then begin   
	 dat_out(4*j)=long(imi)
	 dat_out(4*j+1)=long(imq)
	 dat_out(4*j+2)=long(imu)
	 dat_out(4*j+3)=long(imv)
      endif
   endelse
endfor   
print,' '

free_lun,unit
free_lun,unit_out

create_m,file

return
end      	    

