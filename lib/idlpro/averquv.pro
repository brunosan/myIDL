pro averquv,file,imq,imu,imv,desp=desp

if(keyword_set(desp) eq 0) then desp=0
dum=rfits_im(file,1,dd,hdr,nrhdr,desp=desp)
get_lun,unit
openr,unit,file
if(dd.bitpix eq 8) then begin
   datos=assoc(unit,bytarr(dd.naxis1,dd.naxis2),long(2880)*nrhdr)
endif else if(dd.bitpix eq 16) then begin   
   datos=assoc(unit,intarr(dd.naxis1,dd.naxis2),long(2880)*nrhdr)
endif else if(dd.bitpix eq 32) then begin   
   datos=assoc(unit,lonarr(dd.naxis1,dd.naxis2),long(2880)*nrhdr)
endif

imq=dblarr(dd.naxis1,dd.naxis2)
imu=dblarr(dd.naxis1,dd.naxis2)
imv=dblarr(dd.naxis1,dd.naxis2)
npos=dd.naxis3/4

;npos=npos/4.

for j=0,npos-1 do begin
   im1=median(rfits_im2(datos,dd,4*j+1,desp=desp),3)
   im2=median(rfits_im2(datos,dd,4*j+2,desp=desp),3)
   im3=median(rfits_im2(datos,dd,4*j+3,desp=desp),3)
   im4=median(rfits_im2(datos,dd,4*j+4,desp=desp),3)
   
   im2=im2/im1
   im3=im3/im1
   im4=im4/im1
   
   
   imq=imq+im2
   imu=imu+im3
   imv=imv+im4
endfor

imq=imq/npos
imu=imu/npos
imv=imv/npos

imq=imq-mean(imq)
imu=imu-mean(imu)
imv=imv-mean(imv)

free_lun,unit
return
end   
   

