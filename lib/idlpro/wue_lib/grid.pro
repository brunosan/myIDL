;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; NAME:
;		GRID
; PURPOSE:
;		Draw a dotted grid on a plot
; CATEGORY:
;
; CALLING SEQUENCE:
;		GRID,NX,NY
; INPUTS:
;		NX	: number of grid lines an x axis
;		NY	: number of grid lines an y axis
; NOTES:
;		Default values will be taken from !x.ticks and
;		!y.ticks if they are set.
; EXAMPLES:
;
; MODIFICATION HISTORY:
;		Written Feb. 92, Reinhold Kroll
;-----------------------------------------------------------------------
;
pro grid,nx,ny
on_error,2
x=fltarr(2)
y=fltarr(2)
xmin=!x.crange(0)
xmax=!x.crange(1)
ymin=!y.crange(0)
ymax=!y.crange(1)

if n_elements(nx) eq 0 then nx=!x.ticks-1
if nx le 0 then nx=10
if n_elements(ny) eq 0 then ny=!y.ticks-1
if ny le 0 then ny=10

delx=(xmax-xmin)/(nx+1)
dely=(ymax-ymin)/(ny+1)
for xp=xmin+delx,xmax-delx/2.,delx do begin
	x(0)=xp
	x(1)=xp
	y(0)=ymin
	y(1)=ymax
	oplot,x,y,linestyle=1
	endfor
for yp=ymin+dely,ymax-dely/2.,dely do begin
	x(0)=xmin
	x(1)=xmax
	y(0)=yp
	y(1)=yp
	oplot,x,y,linestyle=1
	endfor
return
end
