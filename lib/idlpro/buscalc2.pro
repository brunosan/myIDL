pro buscalc2,lambda,cota
;ferro2,-18,90,51,-6,90,51,m1,inv1,eps & print,eps
;ferro2,-16,100,51,-8,80,51,m1,inv1,eps & print,eps
;ferro2,-16,110,51,-6,80,51,m1,inv1,eps & print,eps
;ferro2,-13,110,51,-3,110,51,m1,inv1,eps & print,eps
;ferro2,9,110,45,7,110,45,m1,inv1,eps & print,eps
;ferro2,-12,110,51,-4,110,51,m1,inv1,eps & print,eps

smin=1000
imin=0
jmin=0
fac=1.65/lambda
for i=0,90,2 do begin
;   print,'****',i
   for j=0,180,2 do begin
      ferro3,i+[0,51],[237.1,237.1]*fac,j+[0.,49.1],[100.7,99.8]*fac,m1,inv1,eps
      if(eps(0) gt 0.95 and eps(1) gt cota and eps(2) gt cota and $ 
         eps(3) gt cota) then begin
         print,i,j,eps
	 smin2=std(eps(1:3))
	 if(smin2 lt smin) then begin
	    smin=smin
	    imin=i
	    jmin=j
	 endif    
      endif
   endfor
endfor

;ferro3,imin+[0,52.7],[161,152]*fac,jmin+[0.,49.1],[103.8,102.9]*fac,m1,inv1,eps
;print,imin,jmin,eps

return
end      	 
