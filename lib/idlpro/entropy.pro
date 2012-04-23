function entropy,dat

dmin=min(dat)
dmax=max(dat)
his=histogram(dat,binsize=1,min=dmin,max=dmax)
his=his/total(his)
z=where(his ne 0)
return,-total(his(z)*alog10(his(z)))/alog10(2.)
end
