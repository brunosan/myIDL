pro tt,th1

for j=0,180 do begin
ferro2,th1,107,49.1,j,254,52,m1,inv1,eps     
;ferro2,th1,254,52,j,-107,49.1,m1,inv1,eps     
if(eps(3) gt 0.5) then print,j,eps
endfor

return
end
