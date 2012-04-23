pro xtalk2f,file

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

maxq=fltarr(npos,dd.naxis2)
maxu=fltarr(npos,dd.naxis2)
maxv=fltarr(npos,dd.naxis2)

format=['(i2,$)','(i3,$)','(i4,$)','(i5,$)','(i6,$)']

print,' '
print,'Checking Q,U,V profiles'	
print,'***********************'
for j=0,npos-1 do begin

   if((j+1)/10*10 eq j+1) then print,j+1,format=format(fix(alog10(j+1)))
   imi=median(rfits_im2(datos,dd,4*j+1),3)
   imq=median(rfits_im2(datos,dd,4*j+2),3)/imi
   imu=median(rfits_im2(datos,dd,4*j+3),3)/imi
   imv=median(rfits_im2(datos,dd,4*j+4),3)/imi
   
   for k=0,dd.naxis2-1 do begin
      imq(*,k)=imq(*,k)-xi2q(j,k)
      imu(*,k)=imu(*,k)-xi2u(j,k)
      imv(*,k)=imv(*,k)-xi2v(j,k)
   endfor

   for k=0,dd.naxis2-1 do begin
      
      maxq(j,k)=max(abs(imq(21:dd.naxis1-21,k)))
      maxu(j,k)=max(abs(imu(21:dd.naxis1-21,k)))
      maxv(j,k)=max(abs(imv(21:dd.naxis1-21,k)))
      
   endfor
 
endfor

print,' '

nminV2Q=0.01*float(dd.naxis2)*float(npos)
nminV2U=0.01*float(dd.naxis2)*float(npos)
nminQ2V=0.01*float(dd.naxis2)*float(npos)
nminU2V=0.01*float(dd.naxis2)*float(npos)

cotaV2Q=3.
cotaV2U=3.
cotaQ2V=3.
cotaU2V=3.

print,' '
maskV2Q=intarr(npos,dd.naxis2)
zV2Q=where(maxv gt cotaV2Q*maxq)
if(zV2Q(0) ne -1 and n_elements(zV2Q) ge nminV2Q) then begin
   maskV2Q(zV2Q)=1
   print,'V --> Q ',n_elements(zV2Q),' profiles available'
endif else begin
   print,'not enough V --> Q profiles available' 
endelse

maskV2U=intarr(npos,dd.naxis2)
zV2U=where(maxv gt cotaV2U*maxu)
if(zV2U(0) ne -1 and n_elements(zV2U) ge nminV2U) then begin
   maskV2U(zV2U)=1
   print,'V --> U ',n_elements(zV2U),' profiles available'
endif else begin
   print,'not enough V --> U profiles available' 
endelse

maskQ2V=intarr(npos,dd.naxis2)
zQ2V=where(maxq gt cotaQ2V*maxv )
if(zQ2V(0) ne -1 and n_elements(zQ2V) ge nminQ2V) then begin
   maskQ2V(zQ2V)=1
   print,'Q --> V ',n_elements(zQ2V),' profiles available'
endif else begin
   print,'not enough Q --> V profiles available' 
endelse
      
maskU2V=intarr(npos,dd.naxis2)
zU2V=where(maxu gt cotaU2V*maxv)
if(zU2V(0) ne -1 and n_elements(zU2V) ge nminU2V) then begin
   maskU2V(zU2V)=1
   print,'U --> V ',n_elements(zU2V),' profiles available'
endif else begin
   print,'not enough U --> V profiles available' 
endelse
      
print,' '

np=dd.naxis1
if(zV2Q(0) ne -1 and n_elements(zV2Q) ge nminV2Q) then xxV2Q=fltarr(np*n_elements(zV2Q))
if(zV2U(0) ne -1 and n_elements(zV2U) ge nminV2U) then xxV2U=fltarr(np*n_elements(zV2U))
if(zQ2V(0) ne -1 and n_elements(zQ2V) ge nminQ2V) then xxQ2V=fltarr(np*n_elements(zQ2V))
if(zU2V(0) ne -1 and n_elements(zU2V) ge nminU2V) then xxU2V=fltarr(np*n_elements(zU2V))

if(zV2Q(0) ne -1 and n_elements(zV2Q) ge nminV2Q) then yV2Q=fltarr(np*n_elements(zV2Q))
if(zV2U(0) ne -1 and n_elements(zV2U) ge nminV2U) then yV2U=fltarr(np*n_elements(zV2U))
if(zQ2V(0) ne -1 and n_elements(zQ2V) ge nminQ2V) then yQ2V=fltarr(np*n_elements(zQ2V))
if(zU2V(0) ne -1 and n_elements(zU2V) ge nminU2V) then yU2V=fltarr(np*n_elements(zU2V))


print,'Xtalk V --> Q,U and Xtalk Q,U --> V'
print,'***********************************'

j1_V2Q=0
j1_V2U=0
j1_Q2V=0
j1_U2V=0

for j=0,npos-1 do begin
   cntQ2V=0
   cntU2V=0
   if((j+1)/10*10 eq j+1) then print,j+1,format=format(fix(alog10(j+1)))

   imi=median(rfits_im2(datos,dd,4*j+1),3)
   imq=median(rfits_im2(datos,dd,4*j+2),3)/imi
   imu=median(rfits_im2(datos,dd,4*j+3),3)/imi
   imv=median(rfits_im2(datos,dd,4*j+4),3)/imi
   
   for k=0,dd.naxis2-1 do begin
      imq(*,k)=imq(*,k)-xi2q(j,k)
      imu(*,k)=imu(*,k)-xi2u(j,k)
      imv(*,k)=imv(*,k)-xi2v(j,k)
   endfor

   z=where(maskV2Q(j,*) eq 1)
   if(z(0) ne -1) then begin
      j2_V2Q=j1_V2Q+n_elements(z)*np-1
      xxV2Q(j1_V2Q:j2_V2Q)=imv(0:np-1,z)
      yV2Q(j1_V2Q:j2_V2Q)=imq(0:np-1,z)
      j1_V2Q=j2_V2Q+1
   endif   

   z=where(maskV2U(j,*) eq 1)
   if(z(0) ne -1) then begin
      j2_V2U=j1_V2U+n_elements(z)*np-1
      xxV2U(j1_V2U:j2_V2U)=imv(0:np-1,z)
      yV2U(j1_V2U:j2_V2U)=imu(0:np-1,z)
      j1_V2U=j2_V2U+1
   endif   

   z=where(maskQ2V(j,*) eq 1)
   if(z(0) ne -1) then begin
      j2_Q2V=j1_Q2V+n_elements(z)*np-1
      xxQ2V(j1_Q2V:j2_Q2V)=imq(0:np-1,z)
      yQ2V(j1_Q2V:j2_Q2V)=imv(0:np-1,z)
      j1_Q2V=j2_Q2V+1
   endif   

   z=where(maskU2V(j,*) eq 1)
   if(z(0) ne -1) then begin
      j2_U2V=j1_U2V+n_elements(z)*np-1
      xxU2V(j1_U2V:j2_U2V)=imq(0:np-1,z)
      yU2V(j1_U2V:j2_U2V)=imv(0:np-1,z)
      j1_U2V=j2_U2V+1
   endif   
endfor

ccV2Q=fltarr(2)
ccV2U=fltarr(2)
ccQ2V=fltarr(2)
ccU2V=fltarr(2)
if(zV2Q(0) ne -1 and n_elements(zV2Q) ge nminV2Q) then ccV2Q=lstsqfit(xxV2Q,yV2Q)
if(zV2U(0) ne -1 and n_elements(zV2U) ge nminV2U) then ccV2U=lstsqfit(xxV2U,yV2U)
if(zQ2V(0) ne -1 and n_elements(zQ2V) ge nminQ2V) then ccQ2V=lstsqfit(xxQ2V,yQ2V)
if(zU2V(0) ne -1 and n_elements(zU2V) ge nminU2V) then ccU2V=lstsqfit(xxU2V,yU2V)

xxV2Q=0.
xxV2U=0.
xxQ2V=0.
xxU2V=0.
yV2Q=0.
yV2U=0.
yQ2V=0.
yU2V=0.


print,' '
if(zV2Q(0) ne -1 and n_elements(zV2Q) ge nminV2Q) then print,'Xtalk V --> Q = ',ccV2Q(0),' +/-',ccV2Q(1)
if(zV2U(0) ne -1 and n_elements(zV2U) ge nminV2U) then print,'Xtalk V --> U = ',ccV2U(0),' +/-',ccV2U(1)
if(zQ2V(0) ne -1 and n_elements(zQ2V) ge nminQ2V) then print,'Xtalk Q --> V = ',ccQ2V(0),' +/-',ccQ2V(1)
if(zU2V(0) ne -1 and n_elements(zU2V) ge nminU2V) then print,'Xtalk U --> V = ',ccU2V(0),' +/-',ccU2V(1)
print,' '

print,'Correcting for Xtalk and saving data'
print,'************************************'
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
      imq(*,k)=imq(*,k)-xi2q(j,k)*imi(*,k)-ccV2Q(0)*imv(*,k)
      imu(*,k)=imu(*,k)-xi2u(j,k)*imi(*,k)-ccV2U(0)*imv(*,k)
      imv(*,k)=imv(*,k)-xi2v(j,k)*imi(*,k)-ccQ2V(0)*imq(*,k)- $
         ccU2V(0)*imu(*,k)
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



