;PRO TEST_INTERP_IMAGE_SERIES
;
; Test-Programm zu INTERP_IMAGE_SERIES:
; Erzeugt eine Test-Serie zu 8 nicht-equidist. Zeiten, interpoliert zu equidist. Zeit-Skala
; und erzeugt einen Film: 
;   fuer jeden equidist. Zeitpunkt t: untere Reihe: zu t benachbarte "Original"-Bilder 
;   und deren Differenz, obere Reihe: interpoliertes Bild und Differenz Interpol. - Soll
;   Farbskalen: [-0.1, 1.1] f.d. Bilder, [-0.2, 0.2] f.d. Differenzen.
;
function test_cube,t
; Einzel-Bild oder Serie mit 8 Test-Bildern : 
;   2-d Gauss-Fkt. mit "zeitlich" variablen Zentrums-Koordinaten und Breiten.
; Aufruf cube = TEST_CUBE()  liefert cube zu 8 nicht-equidist. Zeiten [0.,..., 11.],
;        image =TEST_CUBE(t)  liefert Einzel- ("Soll"-) Bild f.d. Zeit t 
;
tto=[0.,1.5,2.7,4.,6.,7.,9.9,11.]
n=n_elements(tto)
cube=fltarr(21,21,n)
;
if n_params() eq 0 then t=tto
;
dx=2.5+0.05*t & dy=3.5-0.05*t 
x0=10.+3.*sin(!pi/2.*t/10.) & y0=10.-3.*cos(!pi/2.*t/10.)
ff=fltarr(21,21)
xx=findgen(21) & yy=xx
;
n=n_elements(t)
if n gt 1 then cube=fltarr(21,21,n)
for k=0,n-1 do begin
    expy=exp(-((yy-y0(k))/dy(k))^2)
    expx=exp(-((xx-x0(k))/dx(k))^2)
    for j=0,20 do ff(*,j)=expx*expy(j)
    if n gt 1 then cube(*,*,k)=ff
endfor
if n eq 1 then return,ff else return,cube
end
;---------
PRO TEST_INTERP_IMAGE_SERIES
; 
orig_ser=TEST_CUBE()
t_orig=[0.,1.5,2.7,4.,6.,7.,9.9,11.]
t_equi=findgen(12)
test_i=INTERP_IMAGE_SERIES(t_orig,t_equi,orig_ser)
window,/free
for k=0,11 do begin
    ti=t_equi(k)
    dtmin=min(abs(t_orig-ti),j)
    if t_orig(j) lt ti then begin 
         j1=(j-1) > 0 & j2=j
    endif else begin
         j1=j & j2=(j+1) < (n_elements(t_orig)-1)
    endelse
    if j1 eq j2 then begin
       if j1 gt 0 then j1=j1-1 else j2=j2+1
    endif
    tv,bytscl(rebin(orig_ser(*,*,j1),210,210),-0.1,1.1)
    tv,bytscl(rebin(orig_ser(*,*,j2),210,210),-0.1,1.1),215,0
    tv,bytscl(rebin(orig_ser(*,*,j2)-orig_ser(*,*,j1),210,210),-0.2,0.2),430,0
    tv,bytscl(rebin(test_i(*,*,k),210,210),-0.1,1.1),105,215
    tv,bytscl(rebin(test_i(*,*,k)-TEST_CUBE(float(k)),210,210),-0.2,0.2),430,215
    wait,0.3
endfor
end
