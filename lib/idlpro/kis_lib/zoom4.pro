;+
; NAME:
;	ZOOM4
; PURPOSE:
;	creates a "4x -zoomed" copy of an image array
;*CATEGORY:            @CAT-# 15@
;	Image Display
; CALLING SEQUENCE:
;	ZOOM4,small,big
; INPUTS:
;	small = image array (2-dim) to be zoomed;
; OUTPUTS:
;	big   = zoomed image array .	
; RESTRICTIONS:
;	size of "small": 512 x 512
; PROCEDURE:
;	each pixel in small will be copied 2x2 -times into big.
; MODIFICATION HISTORY:
;	nlte, 1990-01-15
;	nlte, 1990-08-02  max size 512x512 of "small"
;-
PRO z4,s,b
nx=min([(size(s))(1)*4,1024])
ny=min([(size(s))(2)*4,1024])
b=fltarr(nx,ny)
for i=0,nx-1 do begin
ii=i/4
for j=0,ny-1 do begin
jj=j/4
b(i,j)=s(ii,jj)
endfor
endfor
return
end
