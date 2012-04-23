pro flat_gct,flat

file=['16','17']+'oct98.'+['005','002']

flat=fltarr(256,256,4,n_elements(file))

data=0
datalin=0
for j=0,n_elements(file)-1 do begin
   flat_tip,file(j),ff,data=data,lineas=datalin
   flat(*,*,*,j)=ff
endfor

return
end   
