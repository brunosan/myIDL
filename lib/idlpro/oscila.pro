pro oscila,directorio,sufix,num,mdat,tdat,vdat,pot_tdat,pot_vdat,tau,x

;num=350
ntau=25
prefix='/k'
; sufix='.mod'

nom=directorio+prefix

; leemos los modelos
leer,nom,sufix,indgen(num)+1,dat,mac

; calculamos la media
mdat=total(dat,3)/num
tau=reform(dat(0,*,0))

; calculamos las perturbaciones en t y vz

tdat=fltarr(ntau,num)
for j=0,num-1 do tdat(*,j)=dat(1,*,j)-mdat(1,*)
vdat=fltarr(ntau,num)
for j=0,num-1 do vdat(*,j)=dat(5,*,j)-mdat(5,*)

; calculamos el espectro de potencias para cada tau
pot_tdat=fltarr(ntau,num)
pot_vdat=fltarr(ntau,num)
for j=0,ntau-1 do pot_tdat(j,*)=fft(tdat(j,*),-1)*conj( fft(tdat(j,*),-1) )
for j=0,ntau-1 do pot_vdat(j,*)=fft(vdat(j,*),-1)*conj( fft(vdat(j,*),-1) )

;muestreo en mHz
x=findgen(num)/14.5/(num/1000.)

return
end
