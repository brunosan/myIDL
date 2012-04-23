function promedia,dat,npoint
ndat=n_elements(dat)
datb=dat
for j=1,npoint-1 do datb=datb+shift(dat,j)
datb=datb/npoint
ndatb=ndat/npoint
ind=(indgen(ndatb)+1)*npoint-1
return,datb(ind)
end
