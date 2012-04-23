FUNCTION run_av,scan,n
;+
; NAME:
;	RUN_AV
; PURPOSE:
;	Returns running average of a scan.
;*CATEGORY:            @CAT-# 30 12  0@
;	Smoothing , Filtering , Array Manipulation Routines
; CALLING SEQUENCE:
;	rav = RUN_AV (scan,n)
; INPUTS:
;	scan : 1-dim real vector of data to be averaged.
;	n    : size of running window
; OUTPUTS:
;	rav : 1-dim real vector (same size as scan) containing
;	      the running average; The 1st and last n points
;	      are constant (= average of 1st, last n points in scan).
; COMMON BLOCKS:
;	none
; SIDE EFFECTS:
;	none
; RESTRICTIONS:
;	none
; PROCEDURE:
;	straight
; MODIFICATION HISTORY:
;	nlte, 1990-03-17 
;       nlte, 1993-02-09  missprint in description; on_error
;-
on_error,1
sz=size(scan)
av=fltarr(sz(1))
k=2*n
f=1./(k+1)
av(0:n)=total(scan(0:k))
i1=0
i2=k
for i=n+1,(sz(1)-n-1) do begin
i1=i1+1
i2=i2+1
av(i)=total(scan(i1:i2))
endfor
av(sz(1)-n:sz(1)-1)=av(sz(1)-n-1)
av=av*f
return,av
end
