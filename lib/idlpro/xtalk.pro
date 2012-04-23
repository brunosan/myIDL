pro xtalk,file,xi2quv,xv2q,xv2u

dum=median(rfits_im(file,1,dd,hdr,nrhdr),3)

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

;npos=200

cnt_QV=0
cnt_UV=0
cnt_QU=0
maxqq=0
maxuu=0
maxvv=0
minqq=0
minuu=0
minvv=0
xi2quv=fltarr(3,npos)
step=1.e5
xh=findgen(1001)/step
xh=xh-max(xh)/2.

nmax=10000
xq_V=fltarr(dd.naxis1-2,nmax)
xu_V=fltarr(dd.naxis1-2,nmax)
xv_QV=fltarr(dd.naxis1-2,nmax)
xv_UV=fltarr(dd.naxis1-2,nmax)
xq_QU=fltarr(dd.naxis1-2,nmax)
xu_QU=fltarr(dd.naxis1-2,nmax)
xv_QU=fltarr(dd.naxis1-2,nmax)

format=['(i2,$)','(i3,$)','(i4,$)','(i5,$)','(i6,$)']

for j=0,npos-1 do begin

   if((j+1)/10*10 eq j+1) then print,j+1,format=format(fix(alog10(j+1)))
   imi=median(rfits_im2(datos,dd,4*j+1),3)
   imq=median(rfits_im2(datos,dd,4*j+2),3)/imi
   imu=median(rfits_im2(datos,dd,4*j+3),3)/imi
   imv=median(rfits_im2(datos,dd,4*j+4),3)/imi
   
   imq=imq(1:dd.naxis1-2,1:dd.naxis2-2)
   imu=imu(1:dd.naxis1-2,1:dd.naxis2-2)
   imv=imv(1:dd.naxis1-2,1:dd.naxis2-2)
   
   hq=histogram(imq,binsize=step,min=min(xh),max=max(xh))
   hu=histogram(imu,binsize=step,min=min(xh),max=max(xh))
   hv=histogram(imv,binsize=step,min=min(xh),max=max(xh))

   xi2quv(0,j)=xh(min(where(hq eq max(hq))))
   xi2quv(1,j)=xh(min(where(hu eq max(hu))))
   xi2quv(2,j)=xh(min(where(hv eq max(hv))))

   for i=0,dd.naxis2-3 do begin
      
      maxq=max(abs(imq(*,i)))
      maxu=max(abs(imu(*,i)))
      maxv=max(abs(imv(*,i)))
      maxqq=max([maxq,maxqq])
      maxuu=max([maxu,maxuu])
      maxvv=max([maxv,maxvv])
      
      minq=min(abs(imq(*,i)))
      minu=min(abs(imu(*,i)))
      minv=min(abs(imv(*,i)))
      minqq=min([maxq,maxqq])
      minuu=min([maxu,maxuu])
      minvv=min([maxv,maxvv])
      
;      if(maxq lt 0.02 and maxu lt 0.02 and maxv gt 0.05) then begin
      if(maxv/maxq gt 5 and cnt_QV lt nmax) then begin
         cnt_QV=cnt_QV+1
	 xq_V(*,cnt_QV-1)=imq(*,i)
	 xv_QV(*,cnt_QV-1)=imv(*,i)
      endif
      if(maxv/maxu gt 5 and cnt_UV lt nmax) then begin
         cnt_UV=cnt_UV+1
	 xu_V(*,cnt_UV-1)=imu(*,i)
	 xv_UV(*,cnt_UV-1)=imv(*,i)
      endif
;      if(sqrt(maxq*maxq+maxu*maxu) gt 0.05 and maxv lt 0.02) then begin
      if(sqrt(maxq*maxq+maxu*maxu)/maxv gt 5 and cnt_QU lt nmax) then begin
         cnt_QU=cnt_QU+1
	 xq_QU(*,cnt_QU-1)=imq(*,i)
	 xu_QU(*,cnt_QU-1)=imu(*,i)
	 xv_QU(*,cnt_QU-1)=imv(*,i)
      endif
   endfor
endfor
print,' '
free_lun,unit

print,'xtalk I --> Q = ',mean(xi2quv(0,*)),' +/- ',std(xi2quv(0,*))
print,'xtalk I --> U = ',mean(xi2quv(1,*)),' +/- ',std(xi2quv(1,*))
print,'xtalk I --> V = ',mean(xi2quv(2,*)),' +/- ',std(xi2quv(2,*))

if(cnt_QV ne 0) then begin
   xq_V=xq_V(*,0:cnt_QV-1)-mean(xi2quv(0,*))
   xv_QV=xv_QV(*,0:cnt_QV-1)-mean(xi2quv(2,*))
   print,'xtalk V --> Q = ',format='(a,$)'
   xx=reform(xv_QV,n_elements(xv_QV))
   y=reform(xq_V,n_elements(xq_V))
   coef=lstsqfit(xx,y)
   print,coef(0),' +/- ', coef(1)
   xv2q=coef(0)
endif else begin
   print,'Insuficientes perfiles con polarizacion lineal Q debil ',$
       'y circular intensa'
   xv2q=0    
   xv2u=0    
endelse

if(cnt_UV ne 0) then begin
   xu_V=xu_V(*,0:cnt_UV-1)-mean(xi2quv(1,*))
   xv_UV=xv_UV(*,0:cnt_UV-1)-mean(xi2quv(2,*))
   print,'xtalk V --> U = ',format='(a,$)'
   xx=reform(xv_UV,n_elements(xv_UV))
   y=reform(xu_V,n_elements(xu_V))
   coef=lstsqfit(xx,y)
   print,coef(0),' +/- ', coef(1)
   xv2u=coef(0)
endif else begin
   print,'Insuficientes perfiles con polarizacion lineal U debil ',$
       'y circular intensa'
   xv2q=0    
   xv2u=0    
endelse


if(cnt_QU ne 0) then begin

   xq_QU=xq_QU(*,0:cnt_QU-1)-mean(xi2quv(0,*))
   xu_QU=xu_QU(*,0:cnt_QU-1)-mean(xi2quv(1,*))
   xv_QU=xv_QU(*,0:cnt_QU-1)-mean(xi2quv(2,*))
   xx=fltarr(n_elements(xq_QU),2)
   xx(*,0)=reform(xq_QU,n_elements(xq_QU))
   xx(*,1)=reform(xu_QU,n_elements(xq_QU))
   y=reform(xv_QU,n_elements(xv_QU))
   coef=lstsqfit(xx,y)

   print,'xtalk Q --> V = ',format='(a,$)'
   print,coef(0,0)
   print,'xtalk U --> V = ',format='(a,$)'
   print,coef(1,0)
endif else begin
   print,'Insuficientes perfiles con polarizacion circular debil ',$
      'y lineal intensa'
endelse

stop   
return
end      	    

