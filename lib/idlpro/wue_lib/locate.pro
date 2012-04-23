pro locate,lat,lon,alat,alon,x,y
;+
; ROUTINE:     locate
; 
; USEAGLE      locate,lat,lon,alat,alon,x,y
;
; PURPOSE:     Given the coordinate arrays alat(i,j) and alon(i,j), LOCATE
;              finds the indices x,y such the point (alat(x,y),alon(x,y))
;              is closest to a given point (lat,lon).  This routine
;              is used by COASTLINE.
;
; INPUT:
;    lat       geographic latitude 
;    lon       geographic longitude
;    alat      array of image latitudes 
;    alon      array of image longitudes
; OUTPUT:
;    x,y       array indicies such that alat(x,y), alon(x,y) is closest 
;              point to (alat,alon)
;
; AUTHOR:      Paul Ricchiazzi    oct92 
;              Earth Space Research Group, UCSB
;
;-
sz=size(alat)
nxm=sz(1)-1
nym=sz(2)-1
x=(x > 0) < (nxm-1)
y=(y > 0) < (nym-1)
ddx=2 & ddy=2
coslat=cos(!dtor*lat)
cosl2=coslat^2
loop=1
dxo=0
dyo=0
while loop do begin
  u=alat(x,y)
  v=alon(x,y)
  xp=(x+1) < nxm
  yp=(y+1) < nym
  dudx=alat(xp,y)-u
  dudy=alat(x,yp)-u
  dvdx=alon(xp,y)-v
  dvdy=alon(x,yp)-v
  f=(u-lat)^2+cosl2*(v-lon)^2
  f=sqrt(f) > .001
  dfdx=((u-lat)*dudx+cosl2*(v-lon)*dvdx)/f
  dfdy=((u-lat)*dudy+cosl2*(v-lon)*dvdy)/f
  g=dfdx^2+dfdy^2 > 1.e-6
  dx=-f*dfdx/g
  dy=-f*dfdy/g
  xn=x+dx
  yn=y+dy
  xnew=(xn > 0) < (nxm-1)
  ynew=(yn > 0) < (nym-1)
  dxn=abs(xn-xnew)
  dyn=abs(yn-ynew)
  ddx=abs(xnew-x)
  ddy=abs(ynew-y)
  if dxn*dxo gt 0 or dyn*dyo gt 0 then loop=0
  dxo=dxn
  dyo=dyn
;  print,dfdx,dfdy,dx,dy,xnew,ynew
  x=xnew
  y=ynew
  if ddx lt 1 and ddy lt 1 then loop=0
endwhile
if x eq 0 or x eq nxm-1 or y eq 0 or y eq nym-1 then begin
  x=-1
  y=-1
  return
endif  
fmin=min((alat(x-1:x+1,y-1:y+1)-lat)^2+cosl2*(alon(x-1:x+1,y-1:y+1)-lon)^2,ii)
yy=fix(ii/3)
xx=ii-yy*3
x=x-1+xx
y=y-1+yy
return 
end
