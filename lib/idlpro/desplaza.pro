function desplaza,im,pos

tam=size(im)
im2=fltarr(tam(1),tam(2))

x=findgen(tam(1))

for j=0,tam(2)-1 do im2(*,j)=interpol(reform(im(*,j)),x,x+pos)

return,im2
end
   
