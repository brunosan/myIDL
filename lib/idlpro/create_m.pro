pro create_m,map_in

dum=rfits_im(map_in+'c',1,dd,hdr,nrhdr)>0
get_lun,unit
openr,unit,map_in+'c'
if(dd.bitpix eq 8) then begin
   datos=assoc(unit,bytarr(dd.naxis1,dd.naxis2),long(2880)*nrhdr)
endif else if(dd.bitpix eq 16) then begin   
   datos=assoc(unit,intarr(dd.naxis1,dd.naxis2),long(2880)*nrhdr)
endif else if(dd.bitpix eq 32) then begin   
   datos=assoc(unit,lonarr(dd.naxis1,dd.naxis2),long(2880)*nrhdr)
endif

npos=dd.naxis3/4
toti=fltarr(npos,dd.naxis2)
totq=fltarr(npos,dd.naxis2)
totu=fltarr(npos,dd.naxis2)
totv=fltarr(npos,dd.naxis2)
im2=fltarr(4,dd.naxis1,dd.naxis2)

for i=0L,npos-1 do begin
   for j=0,3 do im2(j,*,*)=rfits_im2(datos,dd,4*i+j+1)
   ii2=reform(im2(0,*,*))
   qq2=reform(im2(1,*,*)/im2(0,*,*))
   uu2=reform(im2(2,*,*)/im2(0,*,*))
   vv2=reform(im2(3,*,*)/im2(0,*,*))
   toti(i,*)=total(abs(ii2(1:dd.naxis1-2,*)),1)/(dd.naxis1-2)
   totq(i,*)=total(abs(qq2(1:dd.naxis1-2,*)),1)/(dd.naxis1-2)
   totu(i,*)=total(abs(uu2(1:dd.naxis1-2,*)),1)/(dd.naxis1-2)
   totv(i,*)=total(abs(vv2(1:dd.naxis1-2,*)),1)/(dd.naxis1-2)
;   for j=0,dd.naxis2-1 do begin
;      totq(i,j)=totq(i,j)-median(abs(qq2(*,j)))
;      totu(i,j)=totu(i,j)-median(abs(uu2(*,j)))
;      totv(i,j)=totv(i,j)-median(abs(vv2(*,j)))
;   endfor   
endfor   

totq=median(totq,3)
totu=median(totu,3)
totv=median(totv,3)

totl=sqrt(totu*totu+totq*totq)
totp=sqrt(totl*totl+totv*totv)
save,filename=map_in+'m',toti,totq,totu,totv,totl,totp,hdr
free_lun,unit
return
end
