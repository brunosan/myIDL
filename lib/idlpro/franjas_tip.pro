function franjas_tip,im

tam=size(im)
fim=fft(im)

xvii=20
yvii=12
xvsd=75
yvsd=60

x=findgen(xvsd-xvii+1)+xvii
y=findgen(yvsd-yvii+1)+yvii
xx=meshx(x,y)
yy=meshy(x,y)

fim(xx,yy)=0.
fim(tam(1)-xx,tam(2)-yy)=0.

im2=float(fft(fim,1))
return,im2
end
