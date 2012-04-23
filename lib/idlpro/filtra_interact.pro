function filtra_interact,im

tam=size(im)
fim=fft(im)

window,xsize=tam(1),ysize=tam(2)


tvwin,alog(abs(fim)>1.e-5)
print,'Pincha en el vertice inferior izquierdo del rombo'
cursor,xvii,yvii,/device,/down
print,'Tomo x,y=',xvii,yvii

print,'Pincha en el vertice superior derecho del rombo'
cursor,xvsd,yvsd,/device,/down

print,'Tomo x,y=',xvsd,yvsd

x=findgen(xvsd-xvii+1)+xvii
y=findgen(yvsd-yvii+1)+yvii
xx=meshx(x,y)
yy=meshy(x,y)

fim(xx,yy)=0.
fim(tam(1)-xx,tam(2)-yy)=0.

im2=float(fft(fim,1))
return,im2
end
