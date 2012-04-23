FUNCTION smspline,scan,tens,nodes,xspl,plot=ploti
;+
; NAME:
;	SMSPLINE
; PURPOSE:
;	Smoothing a 1-dim scan by a spline; the spline-nodes
;	are determined by least-square-cubes fitted thru
;	segments of the scan.
;*CATEGORY:            @CAT-# 30  5@
;	Smoothing , Curve Fitting
; CALLING SEQUENCE:
;	smooth = SMSPLINE (scan [,tens] [,nodes] [,xspl] [,/PLOT] )
; INPUTS:
;	scan   : 1-dim vector of data to be smoothed.
; OPTIONAL INPUT PARAMETER:
;	tens : "tension"-parameter used for spline:
;	       tens -> 0 : spline -> cubic spline,
;	       tens -> inf (e.g. 20): spline -> polygon;
;	       default: tens=5.
;       nodes: number of spline nodes to be used;
;	       default: nodes = max([3,n/20]), n=number of data.
;       xspl : real-vector containing x-positions for spline-nodes,`
;	       (x-scale == subscripts of data);
;	       default: equidistant nodes.
;       /PLOT: if set, the scan-data, the spline-nodes, and the spline
;	       will be plotted. 
; OUTPUTS:
;	smooth: vector of spline-values (at each scan-point).
; OPTIONAL OUTPUTS:
;	tens, nodes,xspl : as used for smoothing.
; COMMON BLOCKS:
;	none
; SIDE EFFECTS:
;	A color-plot if /PLOT was set.
; RESTRICTIONS:
;	scan must contain enough values (more than 3 per node).
; PROCEDURE:
;	a) at each node-position: least-square cube from next node
;	   "to the left" to next node "to the right" (using "POLY_FIT"
;	   from IDL-USER's Library);
;	   y-value of spline-node = value of cube at node-position.
;       b) spline with "tension" thru spline-nodes (using "SPLINE"
;	   from IDL-USER's Library).
; MODIFICATION HISTORY:
;	nlte, 1990-03-17
;       nlte, 1993-03-29  colored overplot only if !d.table_size > 0 
;-

npar=n_params()
;print,'npar:',npar
if npar lt 1 then begin
print,'SMSPLINE: no arguments'
return,0
endif
sz=size(scan)
n=sz(1)
if npar eq 1 then tens=5.
if npar lt 3 then nodes=max([3,n/20])
nodm2=nodes-2
if npar lt 4 then begin
xspl=findgen(nodes)*float(n-1)/float((nodes-1))
xspl(nodes-1)=n-1.
endif
if keyword_set(ploti) then iplot=1 else iplot=0
;print,'tens=',tens,' nodes',nodes
;print,'xspl:',xspl
;
x=findgen(n)
binw=max(xspl(1:nodes-1)-xspl(0:nodm2))+1
yspl=fltarr(nodes)
c3=fltarr(4)
pol3=fltarr(binw)
;
for k=1,nodm2 do begin
i1=fix(xspl(k-1)+0.5)
i2=fix(xspl(k+1)+0.5)
c3=poly_fit(findgen(i2-i1+1),scan(i1:i2),3)
if k eq 1 then yspl(0)=poly(0.,c3)
yspl(k)=poly(xspl(k)-xspl(k-1),c3)
if k eq nodm2 then begin
   yspl(nodes-1)=poly(xspl(nodes-1)-xspl(nodes-3),c3)
endif
endfor
if iplot gt 0 then begin
   plot,scan
   if !d.table_size gt 0 then begin
     col=!d.table_size/3
     oplot,xspl,yspl,psym=4,color=col
     col=col*2
     oplot,spline(xspl,yspl,x,tens),color=col
   endif else begin
     oplot,xspl,yspl,psym=4
     oplot,spline(xspl,yspl,x,tens)
   endelse
endif
;
return,spline(xspl,yspl,x,tens)
end
