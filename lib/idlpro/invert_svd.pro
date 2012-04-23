function invert_svd,mat,tol=tol

if(keyword_set(tol) eq 0) then tol=1.e-6

svdc,transpose(mat),w,u,v

nw=n_elements(w)
ww=fltarr(nw,nw)
z=where(abs(w/max(abs(w))) lt tol) 
if(z(0) ne -1) then for j=0,n_elements(z)-1 do ww(z(j),z(j))=0.
z=where(abs(w/max(abs(w))) ge tol) 
if(z(0) ne -1) then for j=0,n_elements(z)-1 do ww(z(j),z(j))=1./w(z(j))

invmat=v##ww##transpose(u)

return,transpose(invmat)
end
