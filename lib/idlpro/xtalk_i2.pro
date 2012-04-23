pro xtalk_i2,file

dum=rfits_im(file,1,dd,hdr,nrhdr)

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

xi2quv=fltarr(3,npos,dd.naxis2)
step=2.e-4	;1.e-5	;2.e-4 	;5.e-6
xh=findgen(2501)*step
xh=xh-max(xh)/2.

format=['(i2,$)','(i3,$)','(i4,$)','(i5,$)','(i6,$)']

print,'Xtalk I --> Q,U,V'
print,'*****************'
for j=0,npos-1 do begin

   if((j+1)/10*10 eq j+1) then print,j+1,format=format(fix(alog10(j+1)))
   imi=median(rfits_im2(datos,dd,4*j+1),3)
   imq=median(rfits_im2(datos,dd,4*j+2),3)/imi
   imu=median(rfits_im2(datos,dd,4*j+3),3)/imi
   imv=median(rfits_im2(datos,dd,4*j+4),3)/imi

   imq=imq(1:dd.naxis1-2,*)
   imu=imu(1:dd.naxis1-2,*)
   imv=imv(1:dd.naxis1-2,*)

   for k=0,dd.naxis2-1 do begin
;      hq=smooth(histogram(imq(*,k),binsize=step,min=min(xh),max=max(xh)),5)
;      hu=smooth(histogram(imu(*,k),binsize=step,min=min(xh),max=max(xh)),5)
;      hv=smooth(histogram(imv(*,k),binsize=step,min=min(xh),max=max(xh)),5)
      hq=smooth(histogram(imq(0:40,k),binsize=step,min=min(xh),max=max(xh)),5)
      hu=smooth(histogram(imu(0:40,k),binsize=step,min=min(xh),max=max(xh)),5)
      hv=smooth(histogram(imv(0:40,k),binsize=step,min=min(xh),max=max(xh)),5)

      xi2quv(0,j,k)=xh(min(where(hq eq max(hq))))
      xi2quv(1,j,k)=xh(min(where(hu eq max(hu))))
      xi2quv(2,j,k)=xh(min(where(hv eq max(hv))))
   endfor
endfor
print,' '

xi2q=reform(xi2quv(0,*,*))
xi2u=reform(xi2quv(1,*,*))
xi2v=reform(xi2quv(2,*,*))


print,'Correcting Xtalk and saving data'
print,'********************************'
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

   for k=0,dd.naxis2-1 do begin
      imq(*,k)=imq(*,k)-xi2q(j,k)*imi(*,k)
      imu(*,k)=imu(*,k)-xi2u(j,k)*imi(*,k)
      imv(*,k)=imv(*,k)-xi2v(j,k)*imi(*,k)
   endfor

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

print,' '
print,'Generating maps'
print,'***************'
create_m,file

return
end


