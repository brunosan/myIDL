pro calib_slit2,file,dmod,delta,eps,rms,data=data,plot=plot,desp=desp,lambda=lambda

if(keyword_set(desp) eq 0) then desp=0
if(keyword_set(lambda) eq 0) then lambda=0

pzero=0.
rzero=0.
;delta=789.5*1.e4/lambda-412.4	; NEW MAY 2002
;delta=274.112

; NEW JULY2002
lamref=[10830.,11500.,12500.,15648.,16500.,17500.]
deltaref=[316.9,274.1,222.0,90.6,63.9,40.3]
delta=interpol(deltaref,lamref,lambda)

; less accurate delta=793.2*1.e4/lambda-415.0
; END NEW JULO 2002

dum=rfits_im(file,1,dd,hdr,nrhdr,desp=desp,/badpix)>0

if(dd.date ge 20070514) then pzero=-17.3

if(lambda eq 0) then begin
   lambda=param_fits(hdr,'WAVELENG=',vartype=1)*10. 
   print,'ATTENTION: wavelength taken from header = ',lambda, ' Angstroem'
endif

;if(mean(dum) lt 2000) then begin
      dc=dum
      ndc=1
;endif else begin
;   dc=fltarr(dd.naxis1,dd.naxis2)
;   ndc=0
;endelse   

get_lun,unit
openr,unit,file
if(dd.telescope eq 'SVST') then begin
   if(dd.bitpix eq 8) then begin
      datos=assoc(unit,bytarr(dd.naxis2,dd.naxis1),long(2880)*nrhdr)
   endif else if(dd.bitpix eq 16) then begin   
      datos=assoc(unit,intarr(dd.naxis2,dd.naxis1),long(2880)*nrhdr)
   endif else if(dd.bitpix eq 32) then begin   
      datos=assoc(unit,lonarr(dd.naxis2,dd.naxis1),long(2880)*nrhdr)
   endif
endif else begin   
   if(dd.bitpix eq 8) then begin
      datos=assoc(unit,bytarr(dd.naxis1,dd.naxis2),long(2880)*nrhdr)
   endif else if(dd.bitpix eq 16) then begin   
      datos=assoc(unit,intarr(dd.naxis1,dd.naxis2),long(2880)*nrhdr)
   endif else if(dd.bitpix eq 32) then begin   
      datos=assoc(unit,lonarr(dd.naxis1,dd.naxis2),long(2880)*nrhdr)
   endif
endelse 

for j=2,8 do begin
   dum=(rfits_im2(datos,dd,j,desp=desp,/badpix)>0)
;   if(mean(dum) lt 2000) then begin
      dc=dc+dum
      ndc=ndc+1
;   endif
endfor

if(ndc eq 0) then begin
   print,'no hay DCs validas'
   return
endif
   
dc=dc/ndc        
z=where(abs(dc-mean(dc)) gt 5*stdev(dc))
if(z(0) ne -1) then dc(z)=mean(dc)

npos=(dd.naxis3-8)/4
thpol=param_fits(hdr,'INSPOLAR=',vartype=3)
thret=param_fits(hdr,'INSRETAR=',vartype=3)

;thpol_ret,hdr,thpol,thret
if(n_elements(thpol) ne npos or n_elements(thret) ne npos) then begin
   print,'Error en la lectura de las posiciones de la calibracion'
   return
endif   

if(n_elements(data) ne 8) then begin

   im1=(rfits_im2(datos,dd,9,desp=desp,/badpix)>0)-dc
   im2=(rfits_im2(datos,dd,10,desp=desp,/badpix)>0)-dc
   im3=(rfits_im2(datos,dd,11,desp=desp,/badpix)>0)-dc
   im4=(rfits_im2(datos,dd,12,desp=desp,/badpix)>0)-dc
   window,0,xsize=dd.naxis1,ysize=dd.naxis2
   tvscl,median((im1+im2+im3+im4)/4.,3)
   print,'Click Lower Left  Corner on Beam 1'
   cursor,i1,j1,3,/device
   print,'Click Upper Right Corner on Beam 1'
   cursor,i2,j2,3,/device
   print,'Click Lower Left  Corner on Beam 2'
   cursor,i3,j3,3,/device
   print,'Click Upper Right Corner on Beam 2'
   cursor,i4,j4,3,/device
   print,'End of Mouse Entries'
   wdelete
   data=[i1,i2,j1,j2,i3,i4,j3,j4]
endif else begin 
   i1=data(0)
   i2=data(1)
   j1=data(2)
   j2=data(3)  
   i3=data(4)
   i4=data(5)
   j3=data(6)
   j4=data(7)
endelse     

nslit=j2-j1+1
nx=i2-i1+1
hazz1=fltarr(npos,4,nslit)
hazz2=fltarr(npos,4,nslit)
cuad1=fltarr(i2-i1+1,j2-j1+1)
cuad2=fltarr(i4-i3+1,j4-j3+1)
for i=0,npos-1 do begin
   for j=0,3 do begin
      im=(rfits_im2(datos,dd,4*i+j+9,desp=desp,/badpix)>0)-dc
      im=median(im,3)
      cuad1=im(i1:i2,j1:j2)
      cuad2=im(i3:i4,j3:j4)
;      cuad1=im(i1+50:i2-50,j1:j2)
;      cuad2=im(i3+50:i4-50,j3:j4)
      hazz1(i,j,*)=total(cuad1,1)/nx
      hazz2(i,j,*)=total(cuad2,1)/nx
   endfor
endfor

luzin=fltarr(npos,4)
uno=[1,0,0,0]

;q=0.;
;q=0.177		; valido para 10830

lamq=[10830.,11500.,12500.,15648.,16500.,17500]
;qc=[0.150573,0.0696133,0.0718126 ,0.0569844  ,0.117483 ,0.171324 ]
;qp=[0.0621332,0.0289879,0.0415977 ,0.0746026,0.0832780,0.164791 ]
qc=[ 0.152063, 0.0713315, 0.0369905, 0.0358317, 0.095329, 0.191610]
;qp=[ 0.058414, 0.0297562, 0.0743774, 0.0867949, 0.108030, 0.141162]
qp=[ 0.058414, 0.0663691 , 0.0743774, 0.0867949, 0.108030, 0.141162]
q=interpol(qc,lamq/1.e4,lambda/1.e4)	;,/spline)
;q=0.

for j=0,npos-1 do begin
   luzin(j,*)=retarder(thret(j)+rzero,delta)#impolariz2(q,thpol(j)+pzero)#uno
endfor   

mm=fltarr(4,4,nslit)
dmm=fltarr(4,4,nslit)
dmod=fltarr(4,4,nslit)
dmod2=fltarr(4,4,nslit)
dmm2=fltarr(4,4,nslit)
errdmod=fltarr(4,4,nslit)

if(keyword_set(plot) eq 1) then !p.multi=[0,2,2]

rms=fltarr(nslit)

cc=fltarr(nslit)
h=fltarr(nslit,4)
for slit=0,nslit-1 do begin

   haz1=hazz1(*,*,slit)
   haz2=hazz2(*,*,slit)
   peso=fltarr(npos,4)
   z=where(haz1 lt mean(haz1)+3*stdev(haz1) and $
      haz2 lt mean(haz2)+3*stdev(haz2))
   peso(z)=1.   

;plot,haz1(z)+haz2(z),/ynoz
;stop
   coef=poly_fit(haz1(z),haz2(z),1)
   haz1=-haz1*coef(1)
   cc(slit)=-coef(1)
   haz=(haz1-haz2)/(haz1+haz2)

;while(1) do begin
;read,pzero,rzero,delta

   luzfit=fltarr(npos,4)

   cmed=0
   for j=0,3 do begin
      z=where(peso(*,j) eq 1)
      coef=lstsqfit(luzin(z,0:3),haz(z,j),yfit1)
      cmed=cmed+coef(0,0)
   endfor      
   haz=haz-cmed/4.
   cc(slit)=cmed/4.
   for j=0,3 do begin
      z=where(peso(*,j) eq 1)
;      coef=lstsqfit(luzin(z,0:3),haz(z,j),yfit1)
;      haz(z,j)=haz(z,j)-coef(0,0)
;      h(slit,j)=coef(0,0)
      coef=lstsqfit(luzin(z,1:3),haz(z,j),yfit1)
      mm(j,1:3,slit)=coef(*,0)
      dmm(j,1:3,slit)=coef(*,1)
      luzfit(z,j)=yfit1
      if(keyword_set(plot) eq 1) then begin
         plot,haz(z,j),psym=1
         oplot,yfit1
      endif   
   endfor
;   if(slit eq 60) then stop
   rms(slit)=1./stdev((haz-luzfit)*peso)
   if(keyword_set(plot) eq 1) then pause

;   stop
   for j=0,3 do begin
      z=where(peso(*,j) eq 1)
      mm(j,0,slit)=mean((haz1(z,j)+haz2(z,j))/(haz1(z,0)+haz2(z,0)))
      dmm(j,0,slit)=stdev((haz1(z,j)+haz2(z,j))/(haz1(z,0)+haz2(z,0)))
   endfor   
;   norm=max(mm(*,0,slit))
   
;   mm(*,*,slit)=mm(*,*,slit)/norm
   
;   mm(*,0,slit)=mm(*,0,slit)/norm
;   dmm(*,0,slit)=dmm(*,0,slit)/norm
;   for j=1,3 do mm(*,j,slit)=mm(*,j,slit)*mm(*,0,slit)
;  for j=1,3 do dmm(*,j,slit)=dmm(*,j,slit)*mm(*,0,slit)

   dmod(*,*,slit)=invert(mm(*,*,slit))

   dmod2(*,*,slit)=dmod(*,*,slit)*dmod(*,*,slit)
   dmm2(*,*,slit)=dmm(*,*,slit)*dmm(*,*,slit)
   errdmod(*,*,slit)=sqrt(dmod2(*,*,slit)#dmm2(*,*,slit)#dmod2(*,*,slit))
;   stop
endfor

;!p.multi=[0,1,2]
;plot,rms,/ynoz
;plot,cc,/ynoz
;!p.multi=0

avdmod=total(dmod,3)/nslit
averrdmod=total(errdmod,3)/nslit

eps=fltarr(5,nslit)
for j=0,nslit-1 do eps(*,j)=effic(mm(*,*,j))
aveps=total(eps,2)/nslit

seps=fltarr(5)
for j=0,4 do seps(j)=std(eps(j,*))
print,mean(rms),' +/- ',std(rms)
print,' '
print,transpose(avdmod),format='(4f8.4)'
print,' '
print,transpose(averrdmod),format='(4f8.4)'
print,' '
print,aveps,format='(5f8.3)'
print,' '
print,seps,format='(5f8.3)'
print,' '

;stop
if(keyword_set(plot) eq 1) then !p.multi=0
free_lun,unit
;endwhile
return
end
      
      
   

