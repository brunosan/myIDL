PRO WHERE2,expr,ivec,jvec,nvec
;+
; NAME:
;	WHERE2
; PURPOSE:
;	returns 2 integer-vectors containing the subscripts of all
;	non-zero elements of $$ 2-dimensional $$ input-expression.
;*CATEGORY:            @CAT-#  0 16 28@
;	Array Manipulation Routines , Image Processing , Programming
; CALLING SEQUENCE:
;	WHERE2,expr,ixvec,iyvec,nvec
; INPUTS:
;	expr : 2-dimensional expression
; OUTPUTS:
;	ixvec : integer-array (1-dim, size=nvec+1) containing the
;	        values of 1st index of non-zero elements; 
;		if expr has no non-zero elements, -1 will be returned.
;       iyvec : integer-array (1-dim, size=nvec+1) containing the
;	        values of 2nd index of non-zero elements;
;		if expr has no non-zero elements, -1 will be returned.
;       nvec  : expr has nvec+1 non-zero elements:
;	        expr( ixvec(0:nvec) , iyvec(0:nvec) ) ;
;		if expr has no non-zero elements, -1 will be returned.
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
;-
on_error,1
sz=size(expr)
nx=sz(1)
if sz(0) ne 2 then message,'expression not 2-dim'
nvec=-1
ivec=-1
jvec=-1
for i=0,nx-1 do begin
   jw=where(expr(i,*),n)
   if n gt 0 then begin
      if nvec eq -1 then begin
         ivec=intarr(n)+i
         jvec=jw
         nvec=n-1
      endif else begin
         ivec=[ivec,intarr(n)+i]
         jvec=[jvec,jw]
         nvec=nvec+n
      endelse
   endif
endfor
return
end
