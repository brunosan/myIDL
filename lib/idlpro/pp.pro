function pp,imin

tam=size(imin)
esp=total(imin,2)/tam(2)

imout=fltarr(tam(1),tam(2))
for j=0,tam(2)-1 do imout(*,j)=imin(*,j)/esp

return,imout
end   
            
