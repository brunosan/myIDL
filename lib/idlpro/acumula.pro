pro acumula,file,desp=desp

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

dc=lonarr(dd.naxis1,dd.naxis2)
ndc=0
for j=1,8 do begin
   dum=(rfits_im2(datos,dd,j,desp=desp,/int)>0)
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

dcout=lonarr(dd.naxis1,dd.naxis2)
imout=lonarr(dd.naxis1,dd.naxis2,4)

for i=0,npos-1 do begin
   for j=0,3 do begin
      im=(rfits_im2(datos,dd,4*i+j+9,desp=desp,/int)>0)-dc
      imout(*,*,j)=imout(*,*,j)+im
   endfor
endfor

npos=1
free_lun,unit

bitpix=32
for j=0,nrhdr-1 do begin
   header=hdr(j)
   pos=strpos(hdr(j),'BITPIX  =')
   if(pos ne -1) then strput,header,string(format='(i20)',fix(bitpix)),pos+10
   pos=strpos(header,'NAXIS3  =')
   if(pos ne -1) then strput,header,string(format='(i20)',4*npos+8),pos+10
   hdr(j)=header
endfor

fileout=file+'a'
get_lun,unit_out
openw,unit_out,fileout
writeu,unit_out,byte(hdr)
for j=0,ndc-1 do writeu,unit_out,dcout
for j=0,4*npos-1 do writeu,unit_out,imout(*,*,j)
free_lun,unit_out
stop
return
end
