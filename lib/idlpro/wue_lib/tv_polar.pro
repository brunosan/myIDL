pro tv_polar,r,phi,theta,xdim=xdim,ydim=ydim,scale=scale,title=title,rot=rot,$
             image=image,xvec=xvec,yvec=yvec
;+
; ROUTINE:  tv_polar
; 
; USEAGE:   tv_polar,r,phi,theta
;
;           tv_polar,r,phi,theta,title=title,xdim=xdim,ydim=ydim,scale=scale,$
;                     image=image,xvec=xvec,yvec=yvec
; 
; PURPOSE:  Display of images defined in polar coordinates (without 
;           resorting to IDL's mapping routines). 
;
; INPUT:
;    r        image quantity (2-d array) one value at each (phi,theta) point
;             note that the phi coordinate is the first index 
;
;    phi      monitonically increasing vector specifying azimuthal coordinate
;             PHI must span either 0 to 360 degrees or 0 to 180 degrees.
;             If phi spans 0-180 degrees,  reflection symmetry is assumed,
;             i.e., r(phi,theta)=r(360-phi,theta).
;
;    theta    monitonically increasing vector specifying polar coordinate
;             (degrees)
; 
; KEYWORD INPUT:
;    title    plot title
;
;    xdim     size of rebined cartesian array in x direction (default=50)
;
;    ydim     size of rebined cartesian array in y direction (default=50)
;
;    scale    if set (or scale=1) display color scale, 
;             if scale eq 2 display color scale with discreet colors
;
;    rot      location of zero azimuth
;             0    left (default)
;             1    top
;             2    right
;             3    bottom
;
; OUTPUT:     none
;
; KEYWORD OUTPUT:
;    image    rebined image of size (xdim,ydim) 
;    xvec     vector of x coordinate values
;    yvec     vector of y coordinate values
;
;             These optional output quantities can be used to overplot 
;             contour lines over the TV_POLAR output. For example,
;
;             TV_POLAR,a,phi,theta,image=im,xvec=xv,yvec=yv
;             CONTOUR,im,xv,yv,/overplot,levels=.3+findgen(10)*.1
;
; AUTHOR:     Paul Ricchiazzi    oct92 
;             Earth Space Research Group, UCSB
;-
if keyword_set(rot) ne 0 then turn=rot mod 4 else turn=0
if keyword_set(image) eq 0 then image=0  
if keyword_set(xdim) eq 0 then xd=50 else xd=xdim
if keyword_set(ydim) eq 0 then yd=50 else yd=ydim
if max(phi)-min(phi) le 181 then begin
  rr=[r,reverse(r)]                       ; assume mirror symmetry
  ph=[phi,360-reverse(phi)] 
endif else begin
  rr=r
  ph=phi
endelse
;
rr=[rr,rr(0,*)]                           ; extra value to bridge cut line
ph=[ph,360+ph(0)]
;
tmax=max(theta)
ss=tmax*1.1
xvec=ss*(2.*findgen(xd)/(xd-1) - 1.)         
yvec=ss*(2.*findgen(yd)/(yd-1) - 1.)
xx=xvec # replicate(1,yd)                   ; x coordinate array
yy=replicate(1,xd) # yvec                   ; y coordinate array
;
tt=sqrt(xx^2+yy^2)                        ; polar angle array
pp=fltarr(xd,yd)
ii=where(tt ne 0.) 
pp(ii)=180+atan(yy(ii),-xx(ii))/!dtor     ; azimuth angle array
;
nth=n_elements(theta)
nph=n_elements(ph)
it=interpol(findgen(nth),theta,tt) > 0 < (nth-1)
it=reform(it,xd,yd)
ip=interpol(findgen(nph),ph,pp) > 0 < (nph-1)
ip=reform(ip,xd,yd)
blank=where(tt gt tmax)
image=interpolate(rr,ip,it)               ; rebined, rectilinear array
image(blank)=min(image)
if turn ne 0 then image=rotate(image,turn)
;
; use TVIM to display the image
;
ptle=''
if keyword_set(title) then ptle=title
if keyword_set(scale) eq 0 then scale=0
tvim,image,scale=scale,title=ptle,xrange=[-ss,ss],yrange=[-ss,ss],/noframe
;
; draw polar coordinate axis
;
circ=5*findgen(72+1)*!dtor
tst=[1,2,5,10,15,30,45]
ii=where(tmax/tst lt 5)
tinc=tst(ii(0))
ntt=fix(tmax)/tinc
mxclr=!d.n_colors
for i=1,ntt do begin 
  oplot,tinc*i*cos(circ),tinc*i*sin(circ),psym=3,color=mxclr
  xyouts,i*tinc*.707,i*tinc*.707,string(form='(i2)',i*tinc),color=mxclr 
endfor

for i=0,270,90 do begin
  ang=(i+90*turn)*!dtor
  xang=tmax*cos(ang)
  yang=tmax*sin(ang)
  oplot,[0,xang],[0,yang],linestyle=1,color=mxclr
  xyouts,xang,yang,string(form='(i3)',i),color=mxclr
endfor
end




