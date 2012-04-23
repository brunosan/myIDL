pro testsvd

;a=[[1,4,-2],[1,5,3],[-1,-3,10]]
a=[[1,4,1,5],[1,5,1,6],[-1,-3,-1,-4]]
nr_svd,a,w,u,v
tam=size(a)
ww=fltarr(tam(2),tam(2))
w2=ww
z=where(abs(w/max(abs(w))) gt 1.e-6)
w2(z,z)=1./w(z)

for j=0,tam(2)-1 do ww(j,j)=w(j)

inva=v#w2#transpose(u)

b=[5,25,6,30]

print,inva#b
stop
end

