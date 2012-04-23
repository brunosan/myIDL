pro jtb,ind,ind2

map_in='/home/mcv/trabajo/testpol/ssci/24nov98.018'
y=[-4,6]*.001
!p.multi=[0,1,4]
window,0,xsize=650,ysize=800

imi=rfits_im(map_in+'c',4*ind+1)
imq=rfits_im(map_in+'c',4*ind+2)
imu=rfits_im(map_in+'c',4*ind+3)
imv=rfits_im(map_in+'c',4*ind+4)
tam=size(imi)

plot,total(imi,2)/mean(imi),charsize=2.0
plot,total(imq/imi-0.0015,2)/tam(2),charsize=2.0,yrange=y
plot,total(imu/imi,2)/tam(2),charsize=2.0,yrange=y
plot,total(imv/imi,2)/tam(2),charsize=2.0,yrange=y

pause
if(ind2 gt ind) then begin
   espi=total(imi,2)/mean(imi)
   espq=total(imq-0.0015*imi,2)/tam(2)/mean(imi)
   espu=total(imu,2)/tam(2)/mean(imi)
   espv=total(imv,2)/tam(2)/mean(imi)
   for j=ind+1,ind2 do begin
      imi=rfits_im(map_in+'c',4*j+1)
      imq=rfits_im(map_in+'c',4*j+2)
      imu=rfits_im(map_in+'c',4*j+3)
      imv=rfits_im(map_in+'c',4*j+4)
      espi=total(imi,2)/mean(imi)
      espq=espq+total(imq/imi-0.0015,2)/tam(2)
      espu=espu+total(imu/imi,2)/tam(2)
      espv=espv+total(imv/imi,2)/tam(2)
   endfor
   espi=espi/(ind-ind2+1)
   espq=espq/(ind-ind2+1)
   espu=espu/(ind-ind2+1)
   espv=espv/(ind-ind2+1)

   window,2,xsize=650,ysize=800
   plot,total(imi,2)/mean(imi),charsize=2.0
   plot,total(imq-0.0015*imi,2)/tam(2)/mean(imi),charsize=2.0,yrange=y
   plot,total(imu,2)/tam(2)/mean(imi),charsize=2.0,yrange=y
   plot,total(imv,2)/tam(2)/mean(imi),charsize=2.0,yrange=y
endif   

      
      
      
return
end
