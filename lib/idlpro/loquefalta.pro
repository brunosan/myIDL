en la rutina flat_ti


Al promediar las imagenes de flatfield, 

im=franjas_tip(im)

y tras extraer los dos haces (haz1 y haz2)

haz1=im2(data(0):data(1),data(2):data(3))
haz2=im2(data(4):data(5),data(6):data(7))

corr=alinea(haz1,haz2)

tam=size(haz1)

for j=0,tam(2)-1 do im2a(*,j)= desp1d(ima(*,j),-corr(j,0))
for j=0,tam(2)-1 do im2b(*,j)= desp1d(imb(*,j),-corr(j,1))

y promediar para sacar el espectro promedio y usar ese como referencia.

Pasar la variable corr al principal para que corrija los
espectros indiduales, como paso previo a la mezcla de los dos haces.
