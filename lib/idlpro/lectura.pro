pro lectura,mono,dosc,dosf,orig,uno,dos
nind=n_elements(ind)
; perfiles
nperf=35
orig=fltarr(2,nperf,350)
uno=fltarr(2,nperf,350)
dos=fltarr(2,nperf,350)
;modelos
ndat=25
mono=fltarr(3,ndat,350)
dosc=fltarr(3,ndat,350)
dosf=fltarr(3,ndat,350)

openr,1,'/scratch/mcv/potasio/datos/mono.mod'
readu,1,mono
close,1

openr,1,'/scratch/mcv/potasio/datos/dosc.mod'
readu,1,dosc
close,1

openr,1,'/scratch/mcv/potasio/datos/dosf.mod'
readu,1,dosf
close,1

openr,1,'/scratch/mcv/potasio/datos/orig.per'
readu,1,orig
close,1

openr,1,'/scratch/mcv/potasio/datos/mono.per'
readu,1,uno
close,1

openr,1,'/scratch/mcv/potasio/datos/dos.per'
readu,1,dos
close,1


return
end
