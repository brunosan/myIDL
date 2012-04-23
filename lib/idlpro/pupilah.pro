function pupilah,l
d=10
x=fltarr(d,d)
centro=(d-1.)/2.
radio=d/sqrt(2.*!pi)
xx=findgen(d)#transpose(fltarr(d)+1)
yy=transpose(xx)
; gt = transmision
; le = reflexion
zz=where((xx-centro)^2 + (yy-centro)^2 gt radio*radio)
x(zz)=1.
rep=l/d
y=fltarr(rep*d,rep*d)
for j=0,rep-1 do begin
   for i=0,rep-1,2 do begin
      y(i*d:(i+1)*d-1,j*d:(j+1)*d-1)=x
   endfor
   for i=1,rep-1,2 do begin
;      y(i*d:(i+1)*d-1,j*d:(j+1)*d-1)=x
      y(i*d:(i+1)*d-1,j*d:(j+1)*d-1)=transpose([x(d/2:d-1,*),x(0:d/2-1,*)])
   endfor
endfor
centro=(rep*d-1)/2.
radio=centro/4.
xx=findgen(rep*d)#transpose(fltarr(rep*d)+1)
yy=transpose(xx)
; si no comentamos la siguiente linea, sacamos la pupila sin mascara
;y=fltarr(rep*d,rep*d)+1
zz=where((xx-centro)^2+(yy-centro)^2 gt radio*radio)
y(zz)=0.
zz=where(fix(xx+yy)/2*2 ne fix(xx+yy))
y(zz)=-y(zz)
fy=abs(fft(y*l*l/total(abs(y)),-1))
fy=fy*fy
return,fy
end
   

