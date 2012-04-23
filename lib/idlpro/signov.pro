function signov,espv

esp=reform(espv)
tam=size(esp)

int1=esp
for j=1,tam(1)-1 do int1(j)=int1(j-1)+esp(j)

int2=total(int1)

if(int2 gt 0) then begin
   return,1
endif else if(int2 lt 0) then begin
   return,-1
endif else begin
   return,0
endelse

end   
