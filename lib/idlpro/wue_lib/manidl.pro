pro manidl,A,xc,yc,init=init,aiter=aiter,readonly=readonly
on_error,2
x=tvrd(0,0,1,1) ; be shure that a window is open before using !d.x_size
;
;   set initial parameters (= image contains the whole Mandelbrot set)
;
if keyword_set(init) then begin
   newxm=-.75
   newym= 0.0
   newside=2.7
   iter=500
   framesize=200
    xpic=(!d.x_size/2-framesize) > 0
    ypic=(!d.y_size/2-framesize) > 0
   goto,newpic
endif
;
;   read in old image
;
openr , Unit , '/usr/tmp/manidl.im' , /get_lun , /f77_unformatted
nxy=lonarr(2)
readu , Unit , nxy
nx=nxy(0)
ny=nxy(1)
A=fltarr(nx,ny)
readu , Unit , A
free_lun, Unit 
;
;   read in old parameters
;
xm=0.D0
ym=0.D0
side=0.D0
openr, Unit , '/usr/tmp/manidl.par' ,/get_lun
readf,unit, xm,ym,side,iter,framesize
free_lun, Unit
;
x0=double(xm)-0.5*side  &  y0=double(ym)-0.5*side
fac=double(0.5*side)/nx
;
xc=[x0,x0+side]
yc=[y0,y0+side]
;
if keyword_set(readonly) then return
;
;   show old image
;
   xpic=(!d.x_size/2-nx) > 0
   ypic=(!d.y_size/2-ny) > 0
tvscl,rebin(alog10(A>.5),2*nx,2*ny),xpic,ypic
;
;   get pixel coordinates of new image
;
box_cursor,ix,iy,sx,sy
;
;   calculate new parameters
;
ix=ix+0.5*sx-xpic & iy=iy+0.5*sy-ypic
newside=double(sx*fac)
newxm=x0+double(ix*fac)
newym=y0+double(iy*fac)
xc=[newxm-.5*newside,newxm+.5*newside]
yc=[newym-.5*newside,newym+.5*newside]
;
newpic: ;
;
;   output new parameters to the parameter file
;
spawn,/sh,' touch /usr/tmp/manidl.par '
spawn,/sh,' touch /usr/tmp/manidl.im '
spawn,' chmod ugo+w /usr/tmp/manidl.par /usr/tmp/manidl.im >&! /dev/null'
openw, Unit , '/usr/tmp/manidl.par' ,/get_lun
form='(D25.16)'
if n_elements(aiter) ne 0 then iter=aiter
printf,unit,format=form,newxm
printf,unit,format=form,newym
printf,unit,format=form,newside
printf,unit,iter
printf,unit,framesize
printf,unit
free_lun, Unit
;
;   calculate the new image using new parameters
;
spawn,/sh,' /usr/local/lib/idl/local/manidl '
;
;   read in new image
;
openr , Unit , '/usr/tmp/manidl.im' , /get_lun , /f77_unformatted
nxy=lonarr(2)
readu , Unit , nxy
nx=nxy(0)
ny=nxy(1)
A=fltarr(nx,ny)
readu , Unit , A
free_lun, Unit 
;
;   show new image
;
   xpic=(!d.x_size/2-nx) > 0
   ypic=(!d.y_size/2-ny) > 0
tvscl,rebin(alog10(A>.5),2*nx,2*ny),xpic,ypic
;
return
end
