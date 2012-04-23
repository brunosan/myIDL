function pupilac,l
rflx=.4
d=10
rep=l/d
centro=(rep*d-1)/2.
radio=centro/4.
xx=findgen(rep*d)#transpose(fltarr(rep*d)+1)
yy=transpose(xx)
; si no comentamos la siguiente linea, sacamos la pupila sin mascara
y=fltarr(rep*d,rep*d)+sqrt((xx-centro)^2 + (yy-centro)^2)/radio
zz=where(y gt 1. or y le sqrt(rflx))
zz1=where(y le 1. and y gt sqrt(rflx))
y(zz1)=1
y(zz)=0.
zz=where(fix(xx+yy)/2*2 ne fix(xx+yy))
y(zz)=-y(zz)
fy=abs(fft(y*l*l/total(abs(y)),-1))
fy=fy*fy
return,fy
end
   

