pro imagenes,bild

;bild es una serie de imagenes
;jugar con rutinas nuevas

;representar los cortes en mosaico uno detras de otro

a=congrid(bild,100,100,17)
;para redimensionar a algo manejable

FOR i = 0, 16,1 DO TVSCL, a[*,*,i], i
;una tras de otra, las ordena 255b-a en negativo

;---------------------------------
;no se que es pero es en 3d
;da una formade cubo a los datos
a=congrid(bild,200,200,400)
a=PTR_NEW(a) 
;no se loque hace pero hay que hacerlo
slicer3,a
;y a jugar
;-------------
;en plan mas interactivo
;pasar la imagen sin pasar a putnero(lo del ptr_new)
xvolume,bild,/interpolate


;--------------------
;quitar la linea espectral normalizando a 100 para cada imagen del cubo
for i=0,16 do a(*,*,i)=a(*,*,i)*1.79812/max(a(*,*,i))


