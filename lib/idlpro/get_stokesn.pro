function get_stokesn,file,hdr

dum=rfits_im(file,1,dd,hdr,nrhdr)

npos=dd.naxis3/4
datc=fltarr(npos,4)
for j=0,npos-1 do for k=0,3 do datc(j,k)=mean(rfits_im(file,4*j+k+1))

datn=datc(*,1:3)
for j=0,npos-1 do datn(j,*)=datn(j,*)/datc(j,0)

return,datn
end
