function filtrab,im

tam=size(im)
fim=fft(im)

x=findgen(29)+16
y=findgen(15)+3
xx=meshx(x,y)
yy=meshy(x,y)

fim(xx,yy)=0.
fim(tam(1)-xx,tam(2)-yy)=0.

im2=float(fft(fim,1))

return,im2
end
