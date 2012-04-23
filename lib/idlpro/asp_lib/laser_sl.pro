pro laser_sl, infile, nim, psf=psf, freq=freq, sfile=sfile, $
	plot=plot, noverb=noverb
;+
;
;	procedure:  laser_sl
;
;	purpose:  create laser profile to input into the inversion code;
;		  the program averages cameras A and B after shifting them
;		  to have the maximum at the same location; the RGB frequency
;		  is filtered out in the Fourier domain
;
;	author:  vmp@ncar, 10/94	minor mod's by rob@ncar
;
; 	notes:  - Use this for laser in front of the slit.
;		- Routine gauss1.pro is used as a definition of the Gaussian.
;		- The FFT plot is hardcoded to use array values 'freq'-5 to
;		  'freq'+5.
;		- The 'sfile' should be included in a.instasp.f with a new
;		  ismear value; currently give this file to Paul.
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 2 then begin
	print
	print, "usage:  laser_sl, infile, nim"
	print
	print, "	Create laser profile to input into the inversion code."
	print
	print, "	Arguments"
	print, "		infile	- name of data camera A"
	print, "			  (camera B should be the same"
	print, "			   with a-->b)"
	print, "		nim	- number of images"
	print
	print, "	Keywords"
	print, "		psf	- returned laser profile"
	print, "			  (def=not returned)"
	print, "		sfile	- name of ASCII file to be included"
	print, "			  in the inversion program"
	print, "			  (def='cxpf')"
	print, "		freq	- maximum of pic due to RGB"
	print, "			  (def=85)"
	print, "		plot	- plotting flag (def=1)"
	print, "				0 = no plot"
	print, "				1 = plot Gaussian fit (/plot)"
	print, "				2 = 1 & plot FFT of profile"
	print, "		noverb	- if set, turn off verbose print"
	print, "			  (def=verbose print)"
	print
	print
	print, "   ex:  laser_sl, '22.fa.map', 5, psf=psf, plot=2"
	print
	return
endif
;-
;
;	Set general parameters.
;
if n_elements(freq) eq 0 then freq = 85
if n_elements(sfile) eq 0 then sfile = 'cxpf'
do_verb = 1 - keyword_set(noverb)
if n_elements(plot) eq 0 then plot = 1
;
;	Get file camera B.
; 
infileb = infile
strput, infileb, 'b', 4
;
;	Read & psf camera A.
;
for ns=0,nim-1 do begin
	readscan,infile,ns,i,q,u,v, /nohead
	if do_verb then print, 'Camera A, scan ' + stringit(ns)
	flipx,i            ; blue is to the left 
	if ns eq 0 then mlaser=float(i)/float(nim)
	if ns ne 0 then mlaser=mlaser+(float(i)/float(nim))
endfor
;
nx=sizeof(mlaser,1)
ny=sizeof(mlaser,2)
maxi=max(mlaser,nn)
nmy=nn/nx
nmx=nn-nmy*nx
psfa=avg_row(mlaser,0,nx-1,nmy-2,nmy+2)
psfa=psfa-mean(mlaser(nmx-50:nmx-30,30:180))	; dark subtraction
maxi=max(psfa,xmaxa)
psfa=psfa/maxi
psfa(nx-1)=psfa(0)	; apodization of last pixel
;
;	Read & psf camera B.
;
for ns=0,nim-1 do begin
	readscan,infileb,ns,i,q,u,v, /nohead
	if do_verb then print, 'Camera B, scan ' + stringit(ns)
	flipx,i            ; blue is to the left 
	if ns eq 0 then mlaser=float(i)/float(nim)
	if ns ne 0 then mlaser=mlaser+(float(i)/float(nim))
endfor
;
nx=sizeof(mlaser,1)
ny=sizeof(mlaser,2)
maxi=max(mlaser,nn)
nmy=nn/nx
nmx=nn-nmy*nx
psfb=avg_row(mlaser,0,nx-1,nmy-2,nmy+2)
psfb=psfb-mean(mlaser(nmx-50:nmx-30,30:180))	; dark subtraction
maxi=max(psfb,xmaxb)
psfb=psfb/maxi
psfb(nx-1)=psfb(0)	; apodization of last pixel
;
;	Add cameras A and B after shifting one over the other.
;
xmax=fix(0.5*(xmaxa+xmaxb))
x=findgen(nx)
ca=total(x(xmax-40:xmax+40)*psfa(xmax-40:xmax+40)^2)/ $
total(psfa(xmax-40:xmax+40)^2)		; centroid with quadratic term
cb=total(x(xmax-40:xmax+40)*psfb(xmax-40:xmax+40)^2)/ $
total(psfb(xmax-40:xmax+40)^2)
xb=x-cb+ca
psfbb=interpol(psfb,xb,x)
psfbb=psfbb/max(psfbb)
psf=0.5*(psfa+psfbb)
maxi=max(psf,xmax)
;
;	Filter out RGB variations.
;
psf=shift(psf,nx-xmax)		; maximum at origin
aa=fft(psf,-1)
;
if plot gt 1 then begin		; optionally plot FFT of laser profile
	msave = !p.multi
	!p.multi = [0, 1, 2, 0, 0]
	window, title='FFT of Laser Profile', /free
	ix1 = freq - 5
	ix2 = freq + 5
	xx = ix1 + indgen(ix2 - ix1 + 1)
	plot, xx, imaginary(aa(ix1:ix2)), title='imaginary amplitude',psym=1
	plot, xx,     float(aa(ix1:ix2)), title='real amplitude',     psym=1, $
		xtitle='frequency'
	!p.multi = msave
endif
;
s1=mean([float(aa(freq-1)),float(aa(freq+2))])
s2=mean([imaginary(aa(freq-1)),imaginary(aa(freq+2))])
aa(freq)=complex(s1,s2)
aa(freq+1)=complex(s1,s2)
;
s1=mean([float(aa(nx-freq-2)),float(aa(nx-freq+1))])
s2=mean([imaginary(aa(nx-freq-2)),imaginary(aa(nx-freq+1))])
aa(nx-freq)=complex(s1,s2)
aa(nx-freq-1)=complex(s1,s2)
;  
psf=float(fft(aa,1))
psf=shift(psf,xmax-nx)		; maximum at origin
;
;	Fit a Gaussian.
;
w=abs(psf)
w(*)=1.
ain=fltarr(3)
;
ain(0)=max(psf(30:210),xmax)
ain(1)=xmax+30.
ain(2)=3.
xmax=xmax+30.
yfiti=curvefit(x(xmax-10:xmax+10),psf(xmax-10:xmax+10),w(xmax-10:xmax+10),$
ain,sigma,funct='gauss1')
if do_verb then print,'FWHM (mA)=',1.665*ain(2)*12.59
;
if plot ge 1 then begin
	window, title='Gaussian Fit', /free
	plot, x(xmax-10:xmax+10), psf(xmax-10:xmax+10), xtitle='pixels', $
		ytitle='normalized units', psym=1, yrange=[0,1.5], ystyle=1
	oplot, x(xmax-10:xmax+10), yfiti
endif
;
;	Create file for inversion code. Format of a.instasp.f
;	We minimize the area of the imaginary part following Paul's suggestion.
;
psf(0:xmax-15)=0.
psf(xmax+15:nx-1)=0.
psf=shift(psf,nx-xmax)		; maximum at origin
areim=fltarr(1200)
apsf=fft(psf,-1)
for istep=0,1199 do begin
	ish=-3.+(6./1199.)*istep
	apsf1=xshift(apsf,ish)
	areim(istep)=total(abs(imaginary(apsf1)))
endfor
ddmin=where(areim eq min(areim))
ish=-3.+(6./1199.)*ddmin(0)
apsf1=xshift(apsf,ish)
spfft=apsf1/(float(apsf1(0)))
spfft(128)=float(spfft(128))	; possible bug in xshift...
;
openw, unit, sfile, /get_lun
for ix = 0,128 do printf, unit, 'cxpf(',ix+1,') = (', $
			float(spfft(ix)), ',', imaginary(spfft(ix)), ')'
close, unit
;
;	Return a centered psf.
;
psf=shift(psf,xmax-nx)		; maximum at origin

end
