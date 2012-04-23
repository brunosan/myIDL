pro visual,file_in

dum=rfits_im(file_in+'c',1,dd,hdr,nrhdr)

get_lun,unit
openr,unit,file_in+'c'
if(dd.bitpix eq 8) then begin
   datos=assoc(unit,bytarr(dd.naxis1,dd.naxis2),long(2880)*nrhdr)
endif else if(dd.bitpix eq 16) then begin   
   datos=assoc(unit,intarr(dd.naxis1,dd.naxis2),long(2880)*nrhdr)
endif else if(dd.bitpix eq 32) then begin   
   datos=assoc(unit,lonarr(dd.naxis1,dd.naxis2),long(2880)*nrhdr)
endif

restore,file_in+'m'

tam=size(toti)

imi=median(rebin(toti,tam(1)*3,tam(2)*3),3)
imq=median(rebin(totq,tam(1)*3,tam(2)*3),3)
imu=median(rebin(totu,tam(1)*3,tam(2)*3),3)
imv=median(rebin(totv,tam(1)*3,tam(2)*3),3)
window,2,xsize=6*tam(1),ysize=6*tam(2)
tvscl,imi,0
tvscl,imq,1
tvscl,imu,2
tvscl,imv,3

window,0,xsize=512,ysize=512
plot,[0,tam(1)-1],[0,max(imi)],/nodata
plot,[0,tam(1)-1],[-max(imi)/10.,max(imi)/10.],/nodata
plot,[0,tam(1)-1],[-max(imi)/10.,max(imi)/10.],/nodata
plot,[0,tam(1)-1],[-max(imi)/10.,max(imi)/10.],/nodata
yold=1
while(1) do begin
   wset,2
   !p.multi=0
   cursor,x,y,3,/device,/nowait
   x=fix(x/6)
   y=fix(y/6)
   im1=rfits_im2(datos,dd,4*x+1)
   im2=rfits_im2(datos,dd,4*x+2)
   im3=rfits_im2(datos,dd,4*x+3)
   im4=rfits_im2(datos,dd,4*x+4)
   print,x,y
   wset,0
   !p.multi=[0,2,2]
   plot,im1(*,yold),/noerase,color=0
   plot,im2(*,yold),/noerase,color=0
   plot,im3(*,yold),/noerase,color=0
   plot,im4(*,yold),/noerase,color=0
   plot,im1(*,y)
   plot,im2(*,y)
   plot,im3(*,y);,/noerase
   plot,im4(*,y);,/noerase
   yold=y
endwhile

return
end   




