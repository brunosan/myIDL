PRO WHERE2,expr,ivec,jvec,nvec
;+
; NAME:
;       WHERE2
; PURPOSE:
;       returns 2 integer-vectors containing the subscripts of all
;       non-zero elements of $$ 2-dimensional $$ input-expression.
;*CATEGORY:            @CAT-#  0 16 28@
;       Array Manipulation Routines , Image Processing , Programming
; CALLING SEQUENCE:
;       WHERE2,expr,ixvec,iyvec,nvec
; INPUTS:
;       expr : 2-dimensional expression
; OUTPUTS:
;       ixvec : integer-array (1-dim, size=nvec+1) containing the
;               values of 1st index of non-zero elements; 
;               if expr has no non-zero elements, -1 will be returned.
;       iyvec : integer-array (1-dim, size=nvec+1) containing the
;               values of 2nd index of non-zero elements;
;               if expr has no non-zero elements, -1 will be returned.
;       nvec  : expr has nvec+1 non-zero elements:
;               expr( ixvec(0:nvec) , iyvec(0:nvec) ) ;
;               if expr has no non-zero elements, -1 will be returned.
; EXAMPLE:
;       image = DIST(512)  ; create a 512x512 fltarr & fill it with values
;       WHERE2, image gt 361., ix,iy,n
;       for i=0,n do print,ix(i0),iy(i),image(ix(i),iy(i))
;
;       result of print-out:
;         256         255      361.332
;         255         256      361.332
;         256         256      362.039
;         257         256      361.332
;         256         257      361.332
;
; SEE ALSO:  kis_lib / where123.pro  for 1-, 2-, or 3-dim arrays.
;
; COMMON BLOCKS:
;       none
; SIDE EFFECTS:
;       none
; RESTRICTIONS:
;       none
; PROCEDURE:
;       straight
; MODIFICATION HISTORY:
;       nlte, 2001-Apr-10 re-created 
;             (old version  1990-03-17 required less memory but was very slow
;              in case of big arrays)
;-
on_error,2
;
sz=SIZE(expr)
if (sz(0) ne 2) then MESSAGE,'expression not a 2-dim array'
;
nx=sz(1) 
;
ii=WHERE(expr,nvec)
if nvec eq 0 then begin
   ivec=-1 & jvec=-1 & nvec=-1 & ii=0
   RETURN   ; nowhere
endif
;
ivec = ii mod nx
jvec = ii / nx
nvec=nvec-1L
ii=0
;
end
