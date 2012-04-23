FUNCTION cor,a,b,m,pr=iprnt
;+
; NAME:
;	COR
; PURPOSE:
;	Correlation of 2 1-dim tracings.
;*CATEGORY:            @CAT-#  4 16@
;	Correlation Analysis , Image Processing
; CALLING SEQUENCE:
;	c = COR(a,b,m [,/PR])
; INPUTS:
;	a = 1-dim vector containing "reference" tracing;
;	b = 1-dim vector containing tracing to be correlated with reference;
;	m = shift b relative to a by -m to +m positions; 2*m+1 corre-
;		lation coefficients will be computed.
; OUTPUTS:
;	Vector of 2*m+1 correlation coefficients.
; OPTIONAL OUTPUTS:
;	If keyword /PR set:
;       Print output of correlation coef's together with sub-vector
;	boundaries for input vectors a,b.
; SIDE EFFECTS:
;	error message if invalid arguments
; RESTRICTIONS:
;	Size of a may not be smaller than size of b.
; PROCEDURE:
;	Subsequent calls to IDL procedure CORRELATE.
; MODIFICATION HISTORY:
;       nlte, 1989-Nov-09
;	nlte, 1990-Oct-26 (error message if a or b not a 1-dim vector) 
;-
sza=size(a)
szb=size(b)
if sza(0) ne 1 then message,'1st argument not a 1-dim vector'
if szb(0) ne 1 then message,'2nd argument not a 1-dim vector'
if sza(1) lt szb(1) then message,'size(a)'+string(sza(1))+' must be ge size(b)'+string(szb(1))
;
c=fltarr(2*m+1)
na=sza(1)-1
nb=szb(1)-1
for k=-m,m do begin
ia1=max([k,0])
ia2=min([nb+k,na])
ib1=max([-k,0])
ib2=ib1+ia2-ia1
c(k+m)=correlate(a(ia1:ia2),b(ib1:ib2))
if keyword_set(iprnt) then print,k,ia1,ia2,ib1,ib2,c(k+m)
endfor
;
return,c
end
