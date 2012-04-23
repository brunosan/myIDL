@/home/helio03/blanco/blanco/deconv/Julian/destre/fivepoint
@/home/helio03/blanco/blanco/deconv/Julian/destre/smoothe
@/home/helio03/blanco/blanco/deconv/Julian/destre/grid_spline
@/home/helio03/blanco/blanco/deconv/Julian/destre/distortion_map
@/home/helio03/blanco/blanco/deconv/Julian/destre/remap_reb_all

dir='/home/helio03/blanco/FPI/230805/data/ser15_2/res/'
dir_out='/home/helio03/blanco/FPI/save/'
Ser='15'
Scan='222'

openr,101,dir+Ser+'_'+Scan+'sizeha'
readf,101,xd,yd,zd
close,101

left=fltarr(xd,yd,zd)
right=left
speck=fltarr(xd,yd)
openr,101,dir+Ser+'_'+Scan+'lscanha'
readu,101,left
close,101
openr,102,dir+Ser+'_'+Scan+'rscanha'
readu,102,right
close,102
openr,103,dir+Ser+'_'+Scan+'speckha'
readu,103,speck
close,103


;rr=right(*,*,0)/mean(right(*,*,0))
;ll=left(*,*,0)/mean(left(*,*,0))
;desp=shc(rr,ll,/int)
;ll=frac_shift(ll,desp(0),desp(1))
;for i=0,zd-1 do left(*,*,i)=frac_shift(left(*,*,i),desp(0),desp(1))
rr=(total(right(*,*,0:2),3)/3.+total(right(*,*,19:21),3)/3.)/mean((total(right(*,*,0:2),3)/3.+total(right(*,*,19:21),3)/3.))
ll=(total(left(*,*,0:2),3)/3.+total(left(*,*,19:21),3)/3.)/mean((total(left(*,*,0:2),3)/3.+total(left(*,*,19:21),3)/3.))
desp=shc(rr,ll,/int)
ll=frac_shift(ll,desp(0),desp(1))
for i=0,zd-1 do left(*,*,i)=frac_shift(left(*,*,i),desp(0),desp(1))

remap_reb_all,rr,ll,left,7,1,/boxcar,interp=3

leftdes=left
rightdes=right
lldes=ll
rrdes=rr

ip=(left+right)/2.
vp=(right-left)/2.
ipm=fltarr(zd)
for h=0,zd-1 do ipm(h)=mean(ip(*,365:*,h))
cont=mean(ipm(0:2))
ip=ip/cont
vp=vp/cont

save,filename=dir_out+'2308_narrowdes15_222ha.save',leftdes,rightdes,rrdes,lldes,speck
save,filename=dir_out+'2308_stokesI&V15_222ha.save',ip,vp

END
