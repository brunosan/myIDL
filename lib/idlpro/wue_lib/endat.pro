;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; NAME:
;	ENDAT
; PURPOSE:
;	Enter data interactively, from keyboard
; CATEGORY:
;	Gimmicks, but useful
; CALLING SEQUENCE:
;	endat,x [,y,/append]
; INPUTS:
;	-
; KEYWORDS:
;	append	: if set and nonzero, append to existing data
; OUTPUTS:
;	X,Y	- Vectors with the entered data
; RESTRICTIONS:
;	Create or append a maximum of 100 data points. You 
;	would not hack in more, don't you?
; NOTES:
;	designed for 1D or 2D data. In 2D case, x and y data
;	are requested alternately. Input is terminated with ^D.
; MODIFICATION HISTORY:
;	written 13.Feb.92  Reinhold Kroll
;------------------------------------------------------------
;
pro endat,x,y,append=append
on_error,2
on_ioerror,ex
np=n_params()

if (np lt 1) or (np gt 2) then begin
	print,'**** You must supply one or two input parameters!'
	print,'**** Exit with Error'
	return
	endif
if keyword_set(append) and (np eq 2) $
   and (n_elements(x) ne n_elements(y)) then begin
	print,'**** Sizes of input vectors must be equal while appending'
	return
	endif

if np eq 1 then print,' Enter 1D data (max.100), terminate with ^D'
if np eq 2 then print,' Enter 2D data (max.100), terminate with ^D'
xi=fltarr(100)
if np eq 2 then yi=fltarr(100)

j=0
if keyword_set(append) then j=n_elements(x)
for i=0,99 do begin
	idigs=fix(alog10(i+j>1)+1)
	sdigs=string(idigs,format="('I',I1)")
	form="('x('," + sdigs + ",')',$)"
	print,format=form,i+j
	read,a
	xi(i)=a
	if np eq 2 then begin
		form="('y('," + sdigs + ",')',$)"
		print,format=form,i+j
		read,a
		yi(i)=a
		endif 
	endfor

ex: 
if i le 0 then return
if keyword_set(append) then begin
	x=[x,xi(0:i-1)]
	if np eq 2 then y=[y,yi(0:i-1)]
	endif $
else begin
	x=fltarr(i)
	if np eq 2 then y=fltarr(i)
	x=xi(0:i-1)
	if np eq 2 then y=yi(0:i-1)
	endelse
end
