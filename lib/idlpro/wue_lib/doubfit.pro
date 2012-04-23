;+
; NAME:
;       DOUBFIT
; PURPOSE:
;       fit a profile with a double-gaussian
; CATEGORY:
;	Curve fitting
; CALLING SEQUENCE:
; 	DOUBFIT,xwert,ywert,fita,fitb
; INPUTS:
;       xwert - vector with independent data values
;       ywert - vector with independent data values
; KEYWORDS:
; OUTPUTS:
;       fita,fitb - vector with parameters of each gaussian
;                   amplitude,x-max (<x>),standard deviation
;                   background,aquivalent width,integrated area
; MODIFCATION HISTORY:
;       Antje Klein & Georg Jung, Astronomie Wuerzburg
;       written March 1993
;-
;
pro doubfit,xwert,ywert,fita,fitb
nel=n_elements(xwert)  ;length of array
a=fltarr(nel,2)        ;create data arrays
b=fltarr(nel,2)
c=fltarr(nel,2)
d=fltarr(nel,2)
e=fltarr(nel,2)
f=fltarr(nel,2)
g=fltarr(nel)
par=fltarr(4)
zfit=fltarr(4)

a(*,0)=xwert
a(*,1)=ywert

loadct,2               ;load color table
repeat begin
plot,a(*,0),a(*,1)     ;plot original profile
richt=''
fl=''
gl=''
b(*,0)=a(*,0)          ;set all x-values equal for all arrays         
c(*,0)=a(*,0)
d(*,0)=a(*,0)
e(*,0)=a(*,0)
f(*,0)=a(*,0)
repeat begin
print,'manual startvalues (y/n)?'
read,fl
case fl of
 'n': begin                   ;fit only by computer
       par(0)=max(a(*,1))     ;try to find best start values
       for i=0,nel-1 do begin     ;amplitude,x-max
                      if a(i,1) eq par(0) then begin
                                                par(1)=a(i,0)
                                                xm=i
                                               endif
                      if (a(i,1) lt .7*par(0)) and (a(i,1) gt par(0)/2) $
                      then g(i)=a(i,0)
                     endfor
       par(2)=min(sqrt((g(*)-par(1))^2))  ;standard deviation
       for i=0,nel-1 do begin             ;direction of decrease
                      if (sqrt((g(i)-par(1))^2) eq par(2)) and $
                         (a(i,0) lt par(1)) then richt='-'
                      if (sqrt((g(i)-par(1))^2) eq par(2)) and $
                         (a(i,0) gt par(1)) then richt='+'
                     endfor
      end
 'y': begin                     ;fit with the manual start value 
       print,'x-value of Gaussian-maximum'
       veri,wert
       zw=min(sqrt((a(*,0)-wert)^2)) 
       for i=0,nel-1 do begin   ;find x-max (nearest to wert)
                         if a(i,0)+zw eq wert then par(1)=a(i,0) 
                         if a(i,0)-zw eq wert then par(1)=a(i,0) 
                        endfor 
       ; find amplitude for x-max
       for i=0,nel-1 do if a(i,0) eq par(1) then begin 
                                                  par(0)=a(i,1)
                                                  xm=i
                                                 endif
       print,'direction of decrease (+/-)'
       read,richt 
      end
 else: begin
        print,'not allowed'
        fl=''
       end
endcase
endrep until fl ne ''

par(3)=(a(0,1)+a(nel-1,1))/2   ;background

; create one-peak-array 
if richt eq '-' then begin  
                      for i=0,xm do b(i,1)=a(i,1)
                      for k=xm+1,nel-1 do begin
                                         if 2*xm-k ge 0 then begin
                                                             b(k,1)=a(2*xm-k,1)
                                         endif else begin
                                               b(k,1)=0
                                              endelse
                                        endfor
                     endif

if richt eq '+' then begin
                      for i=xm,nel-1 do b(i,1)=a(i,1)
                      for k=0,xm-1 do begin
                                        if xm+k+1 le nel-1 then begin
                                                       b(xm-k-1,1)=a(xm+k+1,1)
                                        endif else b(xm-k-1,1)=0
                                       endfor
                endif

;find standard deviation for manual-fit
if fl eq 'y' then begin
                  for i=1,nel-1 do if (b(i,1) ge .5*par(0)) and (b(i-1,1) lt .5*par(0))$
                                 then par(2)=sqrt((b(i,0)-par(1))^2)
                  endif

;plot one-peak-array
oplot,b(*,0),b(*,1),linestyle=1,color=220 

print,'startvalues for fitting :'
print,par

;fit one-peak-array
gs_fit,b(*,0),b(*,1),par,/nostart 

for i=0,nel-1 do c(i,1)=par(0)*exp(-.5*((c(i,0)-par(1))/par(2))^2)+par(3)

;plot fit for one-peak-array
oplot,c(*,0),c(*,1),linestyle=2,color=100
;create ,rest' of array 
d(*,1)=a(*,1)-c(*,1)
;plot ,rest' of array
oplot,d(*,0),d(*,1),linestyle=3,color=220 

zfit(0)=max(d(*,1))      ;find start values for fitting ,rest'
for i=0,nel-1 do if d(i,1) eq zfit(0) then zfit(1)=d(i,0)
for i=1,nel-1 do if (d(i,1) ge .5*zfit(0)) and (d(i-1,1) lt .5*zfit(0)) $
              then zfit(2)=sqrt((d(i,0)-zfit(1))^2)

zfit(3)=(d(0,1)+d(nel-1,1))/2
print,zfit
;fit ,rest'
gs_fit,d(*,0),d(*,1),zfit,/nostart

for i=0,nel-1 do e(i,1)=zfit(0)*exp(-.5*((e(i,0)-zfit(1))/zfit(2))^2)+zfit(3)
;plot fit for ,rest'
oplot,e(*,0),e(*,1),linestyle=4,color=80

;sum of the two fits (endfit)
f(*,1)=c(*,1)+e(*,1)
;plot endfit (color: green)
oplot,f(*,0),f(*,1),linestyle=5,color=30

chi=0
for i=0,nel-1 do chi=(f(i,1)-a(i,1))^2+chi
print,'square deviation :',chi
print,'fitted Gaussian-parameters :'
print,par,zfit
pi=2*acos(0)
fita=fltarr(6)
fitb=fltarr(6)
for i=0,3 do begin
              fita(i)=par(i)
              fitb(i)=zfit(i)
             endfor
fita(4)=abs(sqrt(2*pi)*par(2))   ;aquivalent width
fita(5)=par(0)*fita(4)           ;integrated area
fitb(4)=abs(sqrt(2*pi)*zfit(2))
fitb(5)=zfit(0)*fitb(4)
print,fita,fitb
print,'again (y/n) ?'
read,gl
endrep until gl eq 'n'
return
end
;Noch einige Bemerkungen:
;Das Programm fittet nur Emissionslinien,
;fuer Absorptionslinien sind die entsprechenden Zeilen
;..=max(..) durch ..=min(..) zu ersetzen.
;(oder die Daten durch -..umzukehren)
;Es ist jedoch moeglich folgendes Profil zu fitten:
;
;                 **
;                *  *
;              *     *
;            *        *
;  * * * * *           *         * * *
;                       *      *
;                        *   *
;                         **
;indem man MANUELL das Minimum anwaehlt.


