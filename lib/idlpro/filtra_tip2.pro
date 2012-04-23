function filtra_tip2,im

tam=size(im)
fim=fft(im)

;stop
xvii=45		;105
yvii=1		;8

xvsd= 153	;129
yvsd=35		;25

x=findgen(xvsd-xvii+1)+xvii
y=findgen(yvsd-yvii+1)+yvii
xx=meshx(x,y)
yy=meshy(x,y)

fim(xx,yy)=0.
fim(tam(1)-xx,tam(2)-yy)=0.

xvii=45		;110
yvii=186	;190

xvsd=153	; 130
yvsd=202

x=findgen(xvsd-xvii+1)+xvii
y=findgen(yvsd-yvii+1)+yvii
xx=meshx(x,y)
yy=meshy(x,y)

fim(xx,yy)=0.
fim(tam(1)-xx,tam(2)-yy)=0.

im2=float(fft(fim,1))

return,im2
end
