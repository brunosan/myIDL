;+
;
; NAME:
;	APOD
; PURPOSE:
;	APODIZATION WITH A PC-COSINE-BELL
; CATEGORY:
;	MATHEMATICS
; CALLING SEQUENCE:
;	XAPOD = APOD( X, PC, /PIX )
; INPUTS:
;	X = INPUTVECTOR
;	PC = EXTENT OF THE COSINE-BELL IN % OR PIXEL IF /PIX IS SET
; OUTPUTS:
;	XAPOD = APODIZED VECTOR
; HISTORY:
;	WRITTEN BY ELMAR KOSSACK, NOVEMBER 1991
;	Juergen Hofmann: /PIX added
;-

FUNCTION APOD,X,PC,PIX=PIX

on_error,2

xapod=reform(x)
nx=n_elements(xapod)

if n_elements(PIX) and pc gt nx/2 then begin
	message,'Apodized region should be less or equal '+strn(nx/2)
	endif
if not n_elements(PIX) and pc gt 50 then begin
	message,'Apodized region should be less or equal 50%'
	endif

if n_elements(PIX) then na=pc else na=fix(nx*pc/100)

for i=0,na do begin
	xapod(i)=xapod(i)*(cos(i*!pi/na)*(-0.5)+0.5)
	xapod(nx-1-i)=xapod(nx-1-i)*(cos(i*!pi/na)*(-0.5)+0.5)
endfor

return,xapod
end

