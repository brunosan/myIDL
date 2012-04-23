function rot3d,imagen,angle,x,y,interpolate=interpolate

si=size(imagen)
rotado=imagen
for a=0,si[3]-1 do rotado[*,*,a]=rot(reform(imagen[*,*,a]),angle,1,x,y,/inter,missing=min(imagen))
return,rotado
end