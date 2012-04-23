function ajusta_seno,x2,dat2,periodo

x=x2
dat=dat2
factor=2*!pi/periodo
ndat=n_elements(dat)

xx=fltarr(ndat,3)
xx(*,0)=1.
xx(*,1)=cos(factor*x)
xx(*,2)=sin(factor*x)
xx2=xx

z=indgen(n_elements(dat))
zbad=0
while(zbad(0) ne -1) do begin
   dat=dat(z)
   xx=xx(z,*)
   coef=lstsqfit(xx,dat,yfit)
   sig=std(dat-yfit)
   z=where(abs(dat-yfit) lt 3*sig)
   zbad=where(abs(dat-yfit) ge 3*sig)
endwhile
yfit=xx2#reform(coef(*,0))   
return,yfit
end
