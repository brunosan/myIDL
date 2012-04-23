function aver,demod1,pendiente,esp

imm=reform(demod1)
tam=size(imm)
esp=reform(imm(*,0))
xx=findgen(tam(1))

for j=1,tam(2)-1 do esp=esp+interpol(reform(imm(*,j)),xx,xx+j*pendiente)
esp=esp/tam(2)
imm2=imm 
for j=0,tam(2)-1 do imm2(*,j)=imm2(*,j)/interpol(esp,xx,xx-j*pendiente)

return,imm2
end
