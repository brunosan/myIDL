
loadct,3
tvscl,findgen(xm,xm)

c=findgen(600)

m=intarr(20,20)
for i=0,19 do for j=0,19 do m[i,j]=(i+1)*(j+1)
mm=congrid(m,20*30,20*30)
tvwin,mm
for x=0,19 do for y=0,19 do begin & xyouts,x*30,y*30,nnumber(x+y,3),/dev& wait,0.2

end