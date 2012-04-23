function franjas,dat2,periodo,narm

tam=size(reform(dat2))
x=findgen(tam(1))
fr=fltarr(tam(1))
xx=fltarr(tam(1),3)

for j=0,narm-1 do begin
   per=float(periodo)/(j+1)
   dat=dat2
   factor=2*!pi/per

   xx(*,0)=1.
   xx(*,1)=cos(factor*x)
   xx(*,2)=sin(factor*x)
   xx2=xx

   z=indgen(tam(1))
   zbad=0
   while(zbad(0) ne -1) do begin
      dat=dat(z)
      xx2=xx2(z,*)
      coef=lstsqfit(xx2,dat,yfit)
      sig=std(dat-yfit)
      z=where(abs(dat-yfit) lt 3*sig)
      zbad=where(abs(dat-yfit) ge 3*sig)
   endwhile
   coef(0,0)=0.
   fr=fr+xx#reform(coef(*,0))  
endfor

return,fr
end
