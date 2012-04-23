function filtra_tip,im

imin=reform(im)
tam=size(imin)
fimout=complexarr(tam(1),tam(2))
x1=50
x2=60
for j=0,tam(2)-1 do fimout(*,j)=fft(imin(*,j),-1)
for j=0,tam(2)-1 do fimout(x1:x2,j)=0
for j=0,tam(2)-1 do fimout(tam(1)-x2:tam(1)-x1,j)=0

x1=75
x2=85
for j=0,tam(2)-1 do fimout(x1:x2,j)=0
for j=0,tam(2)-1 do fimout(tam(1)-x2:tam(1)-x1,j)=0
imout=fltarr(tam(1),tam(2))
for j=0,tam(2)-1 do imout(*,j)=float(fft(fimout(*,j),1))

x1=119
x2=tam(1)/2
for j=0,tam(2)-1 do fimout(x1:x2,j)=0
for j=0,tam(2)-1 do fimout(tam(1)-x2:tam(1)-x1,j)=0
imout=fltarr(tam(1),tam(2))
for j=0,tam(2)-1 do imout(*,j)=float(fft(fimout(*,j),1))

return,imout
end
