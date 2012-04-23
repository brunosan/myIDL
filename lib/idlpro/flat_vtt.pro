pro flat_vtt,flat

file=['08','09','10','10']+'oct98.'+['002','001','001','012']

flat=fltarr(256,256,4,n_elements(file))

data=0
datalin=0
for j=0,n_elements(file)-1 do begin
   flat_tip,file(j),ff   ;,data=data,lineas=datalin
   save,filename='f'+file(j)+'_idl',ff
   flat(*,*,*,j)=ff
endfor

return
end   
