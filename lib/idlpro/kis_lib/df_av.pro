FUNCTION df_av,scan,n
;+
; NAME:
;       DF_AV
; PURPOSE:
;       Mean gradient in scan.
;*CATEGORY:            @CAT-#  0  9 30@
;       Array Manipulation Routines , Differentiation , Smoothing 
; CALLING SEQUENCE:
;       grad = DF_AV(scan,n)
; INPUTS:
;       scan = 1-dim tracing (e.g. of intensity);
;	n = **half** size of running average window (pixel).
; OUTPUTS:
;       grad = vector containing smooth gradient of scan (same size
;		as scan).
; PROCEDURE:
;       Linear least square fit of scan(i-n : i+n) for each i,
;	grad(i) = gradient of fit; 1st n points are set == grad(n),
;	last n points are set == grad(max -n).
; MODIFICATION HISTORY:
;       nlte, 1989-08-16 
;-
sz=size(scan)
av=fltarr(sz(1))
x=findgen(sz(1))
k=2*n
c=poly_fit(x(0:k),scan(0:k),1)
av(0:n)=c(1)
i1=0
i2=k
for i=n+1,(sz(1)-n-1) do begin
i1=i1+1
i2=i2+1
c=poly_fit(x(i1:i2),scan(i1:i2),1)
av(i)=c(1)
endfor
av(sz(1)-n:sz(1)-1)=av(sz(1)-n-1)
return,av
end
