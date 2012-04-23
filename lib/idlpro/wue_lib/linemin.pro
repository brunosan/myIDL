;
;+
; NAME:
;	LINEMIN
; PURPOSE:
;	SEARCHES LOCAL MINIMUM POSITION OF A VECTOR, FITS POLYNOMIAL TO
;	THE DATA AND USES NEWTON ITERATION FOR MINIMUM CALCULATION.
; CATEGORY:
;	SPECTROSCOPICS
; CALLING SEQUENCE:
;	POS = LINEMIN( FKT [, EP, NPS, NPF, D, VAL=VAL, PMAX=PMAX] )
; INPUTS:
;	FKT = VECTOR WITH DATA
; OPTIONAL INPUT PARAMETERS:
;	EP  = ESTIMATED POSITION OF MINIMUM (DEFAULT=N_ELEMENTS(FKT)/2)
;	NPS = RANGE OF DATA TO SEARCH ON BOTH SIDES OF EP (DEFAULT=EP)
;	NPF = RANGE OF DATA TO FIT THE POLYNOMIAL (DEFAULT=3)
;	D   = DEGREE OF POLYNOMIAL (DEFAULT=4)
; KEYWORDS:
;	PMAX: IF SET, FUNKTION SEARCHES FOR MAXIMUM
; OUTPUTS:
;	POS = POSITION OF MINIMUM (MAXIMUM, IF KEYWORD IS SET)
; OPTIONAL OUTPUT PARAMETERS:
;	VAL = INTENSITY VALUE OF MINIMUM (MAXIMUM, IF KEYWORD IS SET)
; SIDE EFFECTS:
;	VALUES OF POS MAY BE OUT OF RANGE TO SEARCH
; HISTORY:
;	IDL-VERSION BY ELMAR KOSSACK, FEBRUARY 1992
;	LAST MODIFICATION 23.02.92
;-
function linemin,fkt,ep,nps,npf,d,val=val,pmax=pmax
on_error,2
;
spe=fkt
nx=n_elements(spe)
np=n_params()
;
; keywords and parameters
;
if np lt 2 then ep=nx/2
;
if np lt 3 then nps=nx/2
npsa=(ep-nps)>0
npse=(ep+nps)<(nx-1)
;
if np lt 4 then npf=3
;
if np lt 5 then d=4
;
if keyword_set(pmax) then begin
	ims=max(spe(npsa:npse),im)
endif else begin
	ims=min(spe(npsa:npse),im)
endelse
;
; polynomial fit
;
im=im+npsa
x=findgen(nx)
par=fltarr(d+1)
if im lt npf then im=npf
if im+npf gt nx-1 then im=nx-1-npf
par=poly_fit(x(0:2*npf),spe(im-npf:im+npf),d)
;
; newton interpolation
;
x0=float(npf)
for i0=1,5 do begin
f1=0.
f2=0.
for i=d,2,-1 do f1=(f1+i*par(i))*x0
f1=f1+par(1)
for i=d,3,-1 do f2=(f2+i*(i-1)*par(i))*x0
f2=f2+par(2)*2
x0=x0-f1/f2
endfor
;
; funktionvalue of extremum
;
val=0.
for i=d,1,-1 do val=(val+par(i))*x0
val=val+par(0)
pos=x0+float(im-npf)
;
return,pos
;
end

