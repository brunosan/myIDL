pro pot_usage
;+
;
;	procedure:  pot_field
;
;	purpose:  do University of Hawaii potential field calculation.
;
;	authors:  metcalf@mamane.IFA.Hawaii.Edu (University of Hawaii)
;		  paul@ncar 7/94
;
;	routines:  pot_usage  potential  pot_field
;
;=============================================================================
;
if 1 then begin
	print
	print, "usage:	pot_field, lng, lat, nfield, xfield, yfield"
	print
	print, "	Do University of Hawaii potential field calculation."
	print
	print, "	Arguments"
	print, "		lng	- input heliocentric longitude of"
	print, "			  scan center wrt disk center"
	print, "			  (positive west, radians)"
	print, "		lat	- input heliocentric latitude of"
	print, "			  scan center wrt disk center"
	print, "			  (positive north, radians)"
	print, "		nfield	- input array of mag field"
	print, "			  component normal to surface"
	print, "			  (heliocentric, x east to west"
	print, "			  y south to north)"
	print, "		xfield	- output array of mag field"
	print, "			  west component"
	print, "		yfield	- output array of mag field"
	print, "			  north component"
	print
	return
endif
;-
end
;-----------------------------------------------------------------------------
;
;	procedure:  potential
;
;	purpose:  original University of Hawaii potential field code
;
;-----------------------------------------------------------------------------
;*****************************************************************************
;
; Procedure Potential
; Calculating the potential field by using the measured line of sight
; megnetic field as a boundary condition.
;
; Input:
;     1) b0: the heliocentric lattitude of the subearth point
;            (or disk center)
;     2) p: the angle between the north point of the disk and the
;           projection of the solar rotation axis on the disk.
;           (eastward is positive)
;     3) lc: the heliocentric longitude of the center of the image
;            plane (i.e. center point of your scan)
;     4) bc: the heliocentric lattitude of the center of the image
;            plane (i.e. center point of your scan)
;     5) bizarraym: measured line of sight component of the magnetic field
;
; Output:
;     1) bixarrayp: x component of the calculated potential field
;     2) biyarrayp: y component of the calculated potential field
;
;*******************************************************************************
;
PRO Potential, b0,p,lc,bc,bizarraym,bixarrayp,biyarrayp,noplot=noplot,dBdz=dBdz
ss=size(bizarraym)
nx=ss(1)
ny=ss(2)
cxx=cos(p)*cos(lc)-sin(p)*sin(b0)*sin(lc)
cxy=(-1)*cos(p)*sin(bc)*sin(lc)-sin(p)*(cos(b0)*cos(bc)+sin(b0)* $
sin(bc)*cos(lc))
cyx=sin(p)*cos(lc)+cos(p)*sin(b0)*sin(lc)
cyy=(-1)*sin(p)*sin(bc)*sin(lc)+cos(p)*(cos(b0)*cos(bc)+ $
sin(b0)*sin(bc)*cos(lc))
axx=(-1)*sin(b0)*sin(p)*sin(lc)+ $
cos(p)*cos(lc)
axy=sin(b0)*cos(p)*sin(lc)+ $
sin(p)*cos(lc)
axz=(-1)*cos(b0)*sin(lc)
ayx=(-1)*sin(bc)*(sin(b0)*sin(p)*cos(lc) $
+cos(p)*sin(lc))-cos(bc)* $
cos(b0)*sin(p)
ayy=sin(bc)*(sin(b0)*cos(p)*cos(lc)- $
sin(p)*sin(lc))+cos(bc)* $
cos(b0)*cos(p)
ayz=(-1)*cos(b0)*sin(bc)*cos(lc)+ $
sin(b0)*cos(bc)
azx=cos(bc)*(sin(b0)*sin(p)*cos(lc)+ $
cos(p)*sin(lc))-sin(bc)* $
cos(b0)*sin(p)
azy=(-1)*cos(bc)*(sin(b0)*cos(p)*cos(lc) $
-sin(p)*sin(lc))+sin(bc)*cos(b0)*cos(p)
azz=cos(bc)*cos(b0)*cos(lc)+ $
sin(bc)*sin(b0)
x0=nx/2
y0=ny/2
lx=10 & ly=10
sarray=fltarr(nx+2*lx,ny+2*ly)
sarray(lx:nx+lx-1,ly:ny+ly-1)=bizarraym
if NOT keyword_set(noplot) then surface,sarray
average=total(bizarraym)/(nx*ny)
ix=findgen(lx)#replicate(1,ny)
left=sarray(lx,ly:ny+ly-1)
left=replicate(1,lx)#left
edgl=(left-average)*sin(ix*!pi/(2.*lx))+average
sarray(0:lx-1,ly:ny+ly-1)=edgl
right=sarray(lx+nx-1,ly:ny+ly-1)
right=replicate(1,lx)#right
edgr=(right-average)*cos((ix+1)*!pi/(2.*lx))+average
sarray(lx+nx:lx+nx+lx-1,ly:ny+ly-1)=edgr
iy=replicate(1,nx+2*lx)#findgen(ly)
down=sarray(*,ly)#replicate(1,ly)
edgd=(down-average)*sin(iy*!pi/(2.*ly))+average
sarray(*,0:ly-1)=edgd
up=sarray(*,ny+ly-1)#replicate(1,ly)
edgu=(up-average)*cos((iy+1)*!pi/(2.*ly))+average
sarray(*,ny+ly:ny+2*ly-1)=edgu
if NOT keyword_set(noplot) then surface,sarray
array=sarray
farray=fft(array,-1)
nx1=nx+2*lx
ny1=ny+2*ly
freqx=fltarr(nx1,ny1)
freqy=fltarr(nx1,ny1)
u=findgen(nx1)#replicate(1,ny1)
freqx(0:nx1/2,*)=u(0:nx1/2,*)*!pi*2/nx1
freqx(nx1/2+1:nx1-1,*)=-(nx1-u(nx1/2+1:nx1-1,*))*!pi*2/nx1
v=replicate(1,nx1)#findgen(ny1)
freqy(*,0:ny1/2)=v(*,0:ny1/2)*!pi*2/ny1
freqy(*,ny1/2+1:ny1-1)=-(ny1-v(*,ny1/2+1:ny1-1))*!pi*2/ny1
a=(-1)*cos(b0)*sin(lc)
b=(-1)*cos(b0)*sin(bc)*cos(lc)+sin(b0)* $
cos(bc)
c=cos(bc)*cos(b0)*cos(lc)+sin(bc)*sin(b0)
qx=cxx*freqx+cyx*freqy
qy=cxy*freqx+cyy*freqy
de=complex(a*qx+b*qy,c*sqrt(qx^2+qy^2))
de(0,0)=1.
fbxarray=farray*qx/de
fbyarray=farray*qy/de
fbzarray=complex(0,1)*farray*sqrt(qx^2+qy^2)/de
bxarray=float(fft(fbxarray,1))
byarray=float(fft(fbyarray,1))
bzarray=float(fft(fbzarray,1))
sbixarray=axx*bxarray+ayx*byarray+azx*bzarray
sbiyarray=axy*bxarray+ayy*byarray+azy*bzarray
sbizarray=axz*bxarray+ayz*byarray+azz*bzarray
bixarrayp=sbixarray(lx:lx+nx-1,ly:ly+ny-1)
biyarrayp=sbiyarray(lx:lx+nx-1,ly:ly+ny-1)
end
;-----------------------------------------------------------------------------
;
;	procedure:  pot_field
;
;	purpose: do University of Hawaii potential field calculation.
;
;-----------------------------------------------------------------------------
pro pot_field, lng, lat, field, xpot, ypot

				    ;Check number of parameters.
if n_params() eq 0 then begin
	pot_usage
	return
end
				    ;Call University of Hawaii's routine.
potential, 0., 0., lng, lat, field, xpot, ypot, /noplot

end
