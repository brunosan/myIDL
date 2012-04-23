pro suma,file,im,esp

imi=rfits_im(file+'c',1,dd)
imq=rfits_im(file+'c',2)
imu=rfits_im(file+'c',3)
imv=rfits_im(file+'c',4)

npos=dd.naxis3/4

for j=1,npos-1 do imi=imi+rfits_im(file+'c',4*j+1)
for j=1,npos-1 do imq=imq+rfits_im(file+'c',4*j+2)
for j=1,npos-1 do imu=imu+rfits_im(file+'c',4*j+3)
for j=1,npos-1 do imv=imv+rfits_im(file+'c',4*j+4)

im=fltarr(dd.naxis1,dd.naxis2,4)
esp=fltarr(dd.naxis1,4)

im(*,*,0)=imi
im(*,*,1)=imq
im(*,*,2)=imu
im(*,*,3)=imv


esp(*,0)=total(imi,2)
esp(*,1)=total(imq,2)
esp(*,2)=total(imu,2)
esp(*,3)=total(imv,2)

return
end
