pro ver,file,factor

im=rfits_im(file,1,dd,hdr,nrhdr)

get_lun,unit
openr,unit,file
if(dd.bitpix eq 8) then begin
   datos=assoc(unit,bytarr(dd.naxis1,dd.naxis2),long(2880)*nrhdr)
endif else if(dd.bitpix eq 16) then begin   
   datos=assoc(unit,intarr(dd.naxis1,dd.naxis2),long(2880)*nrhdr)
endif else if(dd.bitpix eq 32) then begin   
   datos=assoc(unit,lonarr(dd.naxis1,dd.naxis2),long(2880)*nrhdr)
endif
window,0,xsize=(dd.naxis1-2)*factor,ysize=(dd.naxis2-2)*factor*4+75
x=dd.naxis1/2
y1=(dd.naxis2)/2-1
y2=y1+2
format=['(i2,$)','(i3,$)','(i4,$)','(i5,$)','(i6,$)']
xp=[0,0,0,0]
yp=fltarr(4)
for j=0,3 do yp(3-j)=j*((dd.naxis2-2)*factor+25)
stop
for j=1,dd.naxis3/4 do begin
   print,j,format=format(fix(alog10(j+1)))
   for i=1,4 do begin
      im=median(rfits_im2(datos,dd,4*(j-1)+i),3)
      im=im(1:dd.naxis1-2,1:dd.naxis2-2)
;      im(x,y1:y2)=max(im)
      tvscl,rebin(im,(dd.naxis1-2)*factor,(dd.naxis2-2)*factor)/8000.,$
         xp(i-1),yp(i-1)
   endfor
   pause
endfor

free_lun,unit
return
end
