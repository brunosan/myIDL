pro oscila2,directorio,n1,n2,mdatc,mdatf,tdatc,tdatf,vdatc,vdatf,pot_tdatc,pot_tdatf,pot_vdatc,pot_vdatf,tau,x

;num=350
num=n2-n1+1
ntau=25
prefixc='/kc'
prefixf='/kf'
sufix='.mod'

nomc=directorio+prefixc
nomf=directorio+prefixf

; leemos los modelos
leer,nomc,sufix,indgen(num)+n1,datc,macc
leer,nomf,sufix,indgen(num)+n1,datf,macf

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

; calculamos el espectro de potencias
pot_tdatc=fltarr(ntau,num)
pot_vdatc=fltarr(ntau,num)
pot_tdatf=fltarr(ntau,num)
pot_vdatf=fltarr(ntau,num)
for j=0,ntau-1 do pot_tdatc(j,*)=fft(tdatc(j,*),-1)*conj( fft(tdatc(j,*),-1) )
for j=0,ntau-1 do pot_vdatc(j,*)=fft(vdatc(j,*),-1)*conj( fft(vdatc(j,*),-1) )
for j=0,ntau-1 do pot_tdatf(j,*)=fft(tdatf(j,*),-1)*conj( fft(tdatf(j,*),-1) )
for j=0,ntau-1 do pot_vdatf(j,*)=fft(vdatf(j,*),-1)*conj( fft(vdatf(j,*),-1) )

;muestreo en mHz
x=findgen(num)/14.5/(num/1000.)

return
end
