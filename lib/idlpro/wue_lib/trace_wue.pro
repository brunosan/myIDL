function trace,aa,xverts,yverts,nodes=nodes,restore=restore,silent=silent
;+
; NAME:		TRACE
;
; PURPOSE:	Define a path through an image using the image display 
;               system and the cursor/mouse.  This routine is designed to
;               be used on images which have been displayed with the TVIM
;               procedure.
;
; CATEGORY:	Image processing.
;
; CALLING SEQUENCE:
;	R = trace(aa)
;       R = trace(aa,xverts, yverts, /nodes, /restore, /silent)
;
; INPUTS:
;       aa       2-d image array used to establish index dimensions
;
; KEYWORD INPUT PARAMETERS:
;
;	RESTORE   if set, originaly displayed image is restored to its
;		  original state on completion. 
;
;       NODES     If set index array is not returned.
;                 Use this option when positions x and y vertices are
;                 all that are required.
;
;	ZOOM      Two element vector specifying zoom factor in x and y,
;                 if omitted, [1.,1.] is assumed.  A single scalar value
;                 will set both the x and y zoom factors.
;
;       SILENT    If set no intructional printout is issued at the 
;                 beginning of execution
; OUTPUTS:
;	Function result = subscript vector of pixels along defined path.
;
; OPTIONAL OUTPUTS:
;       XVERTS    Vector of x vertices of traced path
;       YVERTS    Vector of y vertices of traced path
;
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	Display is changed if RESTORE is not set.
;
; RESTRICTIONS:
;	Only works for interactive, pixel oriented devices with a
;		cursor and an exclusive or writing mode.
;	A path may have at most 1000 vertices.  If this is not enough
;		edit the line setting MAXPNTS.
; PROCEDURE:
;	The exclusive-or drawing mode is used to allow drawing and
;	erasing objects over the original object.
;
;	The operator marks the vertices of the path, either by
;	dragging the mouse with the left button depressed or by
;	marking individual points along the path by clicking the
;	left mouse button, or with a combination of both.
;
;	The center button removes the most recently drawn points.
;
;	Press the right mouse button when finished.  On exit gaps in the 
;       traced path are filled by interpolation
;
; Adapted from DEFROI by : Paul Ricchiazzi    oct92 
;                          Earth Space Research Group, UCSB
;
;-
;
on_error,2		;Return to caller if error
nc1 = !d.table_size-1	;# of colors available
px=!x.window*!d.x_vsize
py=!y.window*!d.y_vsize
x0=px(0)
y0=py(0)

sz=size(aa)
nx=sz(1)
ny=sz(2)
xf=(px(1)-px(0))/float(nx-1)
yf=(py(1)-py(0))/float(ny-1)

device, set_graphics=6             ;Set XOR mode
again:
n = 0
if keyword_set(silent) eq 0 then begin
  print,'Left button to mark point'
  print,'Middle button to erase previous point'
  print,'Right button to flush and exit'
endif
maxpnts = 1000			;max # of points.
xverts = intarr(maxpnts)		;arrays
yverts = intarr(maxpnts)
xprev = -1
yprev = -1
;
Cursor, xx, yy, /WAIT, /DEV		;Get 1st point with wait
repeat begin
  xx = (xx - x0) /xf 		        ;To image coords
  yy = (yy - y0) /yf
  if (xx lt nx) and (xx ge 0) and (yy ge 0) and (yy lt ny) and $
        (!err eq 1) and ((xx ne xprev) or (yy ne yprev)) then begin
    xprev = xx                                     	    ;New point?
    yprev = yy
    if n ge (maxpnts-1) then begin
      print,'Too many points'
      n = n-1
    endif
    xverts(n) = xx
    yverts(n) = yy
    if n ne 0 then $
      plots,xverts(n-1:n)*xf+x0,yverts(n-1:n)*yf + y0, /dev,color=nc1,/noclip
    n=n+1
    wait, .1             ;Dont add points too fast
  endif
; We use 2 or 5 for the middle button because some Microsoft
; compatible mice use 5.
  if ((!err eq 2) or (!err eq 5)) and (n gt 0) then begin
    n = n-1
    if n gt 0 then begin  ;Remove a vertex
      plots,xverts(n-1:n)*xf+x0,yverts(n-1:n)*yf+y0, color=nc1,/dev,/noclip
      wait, .1           ;Dont erase too fast
    endif
  endif
  Cursor, xx, yy, /WAIT, /DEV    
endrep until !err eq 4

if n lt 2 then begin
  print,'TRACE - Must have at least 2 points to define path.  Try again.'
  goto,again
endif
xverts = xverts(0:n-1)		                ;truncate
yverts = yverts(0:n-1)

if keyword_set(restore) then $
plots, xverts*xf+x0, yverts *yf + y0, /dev, color=nc1, /noclip

if !order ne 0 then yverts = ny-1-yverts	;Invert Y?
device,set_graphics=3                           ;Re-enable normal copy write
;
; fill in points between nodes
;
if keyword_set(nodes) then return,0
path=lonarr(10000)
m=0

for i=0,n-2 do begin
  pntx=abs(xverts(i+1)-xverts(i))
  pnty=abs(yverts(i+1)-yverts(i))
  pnts=max([pntx,pnty])
  if pnts gt 0 then begin
    pnts=findgen(pnts)/pnts
    xpath=interpol([xverts(i),xverts(i+1)],[0.,1.],pnts)
    ypath=interpol([yverts(i),yverts(i+1)],[0.,1.],pnts)
    mm=m+n_elements(xpath)-1
    path(m:mm)=fix(xpath)+fix(ypath)*nx
    m=mm+1
  endif
endfor
path=path(0:mm)
return,path
end








