function FASES,fase

ceros=fltarr(512-32)
unos=fltarr(64)+1

c=cos(fase)
s=sin(fase)

cor=complex(c,s)

dat=[ceros,unos*cor,ceros]

fdat=abs(fft(dat,-1))
fdat=shift(fdat,512)
fdat=fdat*fdat

return,fdat
end
