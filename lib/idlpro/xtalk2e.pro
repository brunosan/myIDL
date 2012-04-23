pro xtalk2e,file

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
step=2.e-4	;2.e-4 	;5.e-6	
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
      hq=smooth(histogram(imq(*,k),binsize=step,min=min(xh),max=max(xh)),5)
      hu=smooth(histogram(imu(*,k),binsize=step,min=min(xh),max=max(xh)),5)
      hv=smooth(histogram(imv(*,k),binsize=step,min=min(xh),max=max(xh)),5)

      xi2quv(0,j,k)=xh(min(where(hq eq max(hq))))
      xi2quv(1,j,k)=xh(min(where(hu eq max(hu))))
      xi2quv(2,j,k)=xh(min(where(hv eq max(hv))))
   endfor
endfor
print,' '

xi2q=reform(xi2quv(0,*,*))
xi2u=reform(xi2quv(1,*,*))
xi2v=reform(xi2quv(2,*,*))

format=['(i2,$)','(i3,$)','(i4,$)','(i5,$)','(i6,$)']

print,' '
print,'Xtalk V --> Q,U and Q.U --> V'
print,'*****************************'
cota=5.
cV2Q=fltarr(npos,dd.naxis2)-10.
cV2U=fltarr(npos,dd.naxis2)-10.
cQ2V=fltarr(npos,dd.naxis2)-10.
cU2V=fltarr(npos,dd.naxis2)-10.

xV2Q=fltarr(dd.naxis2)-10
xV2U=fltarr(dd.naxis2)-10
xQ2V=fltarr(dd.naxis2)-10
xU2V=fltarr(dd.naxis2)-10

maxq=fltarr(npos,dd.naxis2)
maxu=fltarr(npos,dd.naxis2)
maxv=fltarr(npos,dd.naxis2)

for j=0,npos-1 do begin

   if((j+1)/10*10 eq j+1) then print,j+1,format=format(fix(alog10(j+1)))
   imi=median(rfits_im2(datos,dd,4*j+1),3)
   imq=median(rfits_im2(datos,dd,4*j+2),3)
   imu=median(rfits_im2(datos,dd,4*j+3),3)
   imv=median(rfits_im2(datos,dd,4*j+4),3)
   
   for k=0,dd.naxis2-1 do begin
      
      imq(*,k)=imq(*,k)-xi2q(j,k)*imi
      imu(*,k)=imu(*,k)-xi2u(j,k)*imi
      imv(*,k)=imv(*,k)-xi2v(j,k)*imi
      maxq(j,k)=max(abs(imq(*,k)))
      maxu(j,k)=max(abs(imu(*,k)))
      maxv(j,k)=max(abs(imv(*,k)))
      

      if(maxv(j,k) gt cota*maxq(j,k)) then begin
         cc=lstsqfit(imv(*,k),imq(*,k))
	 cV2Q(j,k)=cc(0)
      endif

      if(maxv(j,k) gt cota*maxu(j,k)) then begin
         cc=lstsqfit(imv(*,k),imu(*,k))
	 cV2U(j,k)=cc(0)
      endif

      if(maxq(j,k) gt cota*maxv(j,k) and maxu(j,k) gt cota*maxv(j,k)) then begin
         cc=lstsqfit([[imq(*,k)],[imu(*,k)]],imv(*,k))
	 cQ2V(j,k)=cc(0,0)
	 cU2V(j,k)=cc(1,0)
      endif      
   endfor
   
endfor
print,' '

for k=0,dd.naxis2-1 do begin
   z=where(cV2Q(*,k) ne -10)
   if(z(0) ne -1 and n_elements(z) gt 10) then xV2Q(k)=mean(cV2Q(z,k))
   z=where(cV2U(*,k) ne -10)
   if(z(0) ne -1 and n_elements(z) gt 10) then xV2U(k)=mean(cV2U(z,k))
   z=where(cQ2V(*,k) ne -10)
   if(z(0) ne -1 and n_elements(z) gt 10) then xQ2V(k)=mean(cQ2V(z,k))
   z=where(cU2V(*,k) ne -10)
   if(z(0) ne -1 and n_elements(z) gt 10) then xU2V(k)=mean(cU2V(z,k))
endfor

xslit=findgen(dd.naxis2)   
z=where(xV2Q ne -10)
if(z(0) ne -1 and n_elements(z) gt 10) then ccV2Q=poly_fit(xslit(z),xV2Q(z),1) else ccV2Q=[0,0]
z=where(xV2U ne -10)
if(z(0) ne -1 and n_elements(z) gt 10) then ccV2U=poly_fit(xslit(z),xV2U(z),1) else ccV2U=[0,0]
z=where(xQ2V ne -10)
if(z(0) ne -1 and n_elements(z) gt 10) then ccQ2V=poly_fit(xslit(z),xQ2V(z),1) else ccQ2V=[0,0]
z=where(xU2V ne -10)
if(z(0) ne -1 and n_elements(z) gt 10) then ccU2V=poly_fit(xslit(z),xU2V(z),1) else ccU2V=[0,0]

print,' '
print,'Average Xtalk I --> Q = ',mean(xi2q),' +/- ',std(xi2q)
print,'Average Xtalk I --> U = ',mean(xi2u),' +/- ',std(xi2u)
print,'Average Xtalk I --> V = ',mean(xi2v),' +/- ',std(xi2v)
print,'Average Xtalk Q --> V = ',poly(dd.naxis2/2,ccQ2V),' +/- ', $
   abs(poly(dd.naxis2/2,ccQ2V)-poly(0,ccQ2V))
print,'Average Xtalk U --> V = ',poly(dd.naxis2/2,ccU2V),' +/- ', $
   abs(poly(dd.naxis2/2,ccU2V)-poly(0,ccU2V))
print,'Average Xtalk V --> Q = ',poly(dd.naxis2/2,ccV2Q),' +/- ', $
   abs(poly(dd.naxis2/2,ccV2Q)-poly(0,ccV2Q))
print,'Average Xtalk V --> U = ',poly(dd.naxis2/2,ccV2U),' +/- ', $
   abs(poly(dd.naxis2/2,ccV2U)-poly(0,ccV2U))

print,' '
print,'Correcting Xtalk and saving data on file ',file+'c'
print,'******************************************************'
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
      imq(*,k)=imq(*,k)-xi2q(j,k)*imi(*,k)-poly(k,ccV2Q)*imv(*,k)
      imu(*,k)=imu(*,k)-xi2u(j,k)*imi(*,k)-poly(k,ccV2U)*imv(*,k)
      imv(*,k)=imv(*,k)-xi2v(j,k)*imi(*,k)-poly(k,ccQ2V)*imq(*,k)- $
         poly(k,ccU2V)*imu(*,k)
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

free_lun,unit
free_lun,unit_out

print,' '
print,' '
print,'Generating maps on file ',file+'m'	
print,'*************************************'
create_m,file

return
end

