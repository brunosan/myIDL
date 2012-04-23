function kpno,isc
nscans=350
ndat=2048
if(isc gt nscans or isc le 0) then return,fltarr(ndat)
nhdr=598
dat=fltarr(ndat,/nozero)
idat=intarr(ndat,/nozero)
hdr=bytarr(nhdr,/nozero)
size=long(2*(2*ndat+nhdr))
pos=(isc-1)*size
openr,1,'/scratch/mcv/potasio/datos/k4479.5'
point_lun,1,pos
readu,1,hdr
readu,1,idat
dat=float(idat)
readu,1,hdr
readu,1,idat
dat=dat+float(idat)
close,1
return,dat
end
