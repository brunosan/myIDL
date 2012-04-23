function gausiana,puntos,centro=centro,ancho=ancho

IF NOT keyword_set(centro) THEN centro=puntos/2.
IF NOT keyword_set(ancho) THEN ancho=puntos/10.
ancho=float(ancho)
x=findgen(puntos)

g=(1/ancho/sqrt(2.*!PI))*exp(-((x-centro)^2)/2/(ancho^2))

return,g

end