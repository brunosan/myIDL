pro oscila2fit,directorio,num,mdatc,mdatf,ftdatc,ftdatf,fvdatc,fvdatf,pot_ftdatc,pot_ftdatf,pot_fvdatc,pot_fvdatf,tau,x

;num=350
ntau=25
prefixc='/kc'
prefixf='/kf'
sufix='.mod'

nomc=directorio+prefixc
nomf=directorio+prefixf

; leemos los modelos
leer,nomc,sufix,indgen(num)+1,datc,macc
leer,nomf,sufix,indgen(num)+1,datf,macf

; calculamos la media
mdatc=total(datc,3)/num
mdatf=total(datf,3)/num
tau=reform(datc(0,*,0))

; calculamos las perturbaciones en t y vz
tdatc=fltarr(ntau,num)
for j=0,num-1 do tdatc(*,j)=datc(1,*,j)-mdatc(1,*)
vdatc=fltarr(ntau,num)
for j=0,num-1 do vdatc(*,j)=datc(5,*,j)-mdatc(5,*)
tdatf=fltarr(ntau,num)
for j=0,num-1 do tdatf(*,j)=datf(1,*,j)-mdatf(1,*)
vdatf=fltarr(ntau,num)
for j=0,num-1 do vdatf(*,j)=datf(5,*,j)-mdatf(5,*)

ftdatc=fltarr(2,num)
for j=0,num-1 do ftdatc(*,j)=poly_fit(tau(*),tdatc(*,j),1)
fvdatc=fltarr(2,num)
for j=0,num-1 do fvdatc(*,j)=poly_fit(tau(*),vdatc(*,j),1)
ftdatf=fltarr(2,num)
for j=0,num-1 do ftdatf(*,j)=poly_fit(tau(*),tdatf(*,j),1)
fvdatf=fltarr(2,num)
for j=0,num-1 do fvdatf(*,j)=poly_fit(tau(*),vdatf(*,j),1)

; calculamos el espectro de potencias

pot_ftdatc=fltarr(2,num)
pot_fvdatc=fltarr(2,num)
pot_ftdatf=fltarr(2,num)
pot_fvdatf=fltarr(2,num)
for j=0,1 do pot_ftdatc(j,*)=fft(ftdatc(j,*),-1)*conj( fft(ftdatc(j,*),-1) )
for j=0,1 do pot_fvdatc(j,*)=fft(fvdatc(j,*),-1)*conj( fft(fvdatc(j,*),-1) )
for j=0,1 do pot_ftdatf(j,*)=fft(ftdatf(j,*),-1)*conj( fft(ftdatf(j,*),-1) )
for j=0,1 do pot_fvdatf(j,*)=fft(fvdatf(j,*),-1)*conj( fft(fvdatf(j,*),-1) )

;muestreo en mHz
x=findgen(num)/14.5/(num/1000.)

return
end
