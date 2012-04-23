pro core,esp,posmin,imin,i,j,a
 
ngrad=4 
 
px1=(fix(posmin)-20 )>0
px2=(fix(posmin)+20)<(n_elements(esp)-1)
perf=esp(px1:px2) 
z=where(perf eq min(perf)) 
z=z(0) 
z1=(z-5)>0 
z2=(z+5)<(px2-px1+1) 
x=findgen(z2-z1+1) 
coef=poly_fit(x,perf(z1:z2),4,yfit) 
c=[coef(1),coef(2)*2,coef(3)*3,coef(4)*4] 
xc=poly_root(c,0,z2-z1)+z1 
if(xc lt z1 or xc gt z2) then begin 
	z1=(z-10)>0 
	z2=(z+10)<(px2-px1+1) 
	x=findgen(z2-z1+1) 
	coef=poly_fit(x,perf(z1:z2),4,yfit) 
	c=[coef(1),coef(2)*2,coef(3)*3,coef(4)*4] 
	xc=poly_root(c,0,z2-z1)+z1 
	if(xc lt z1 or xc gt z2) then begin 
		z1=(z-15)>0 
		z2=(z+15)<(px2-px1+1) 
		x=findgen(z2-z1+1) 
		coef=poly_fit(x,perf(z1:z2),4,yfit) 
		c=[coef(1),coef(2)*2,coef(3)*3,coef(4)*4] 
		xc=poly_root(c,0,z2-z1)+z1 
	 	if(xc lt z1 or xc gt z2) then begin 
	  		posmin=-100.
   			imin=-1.
   			print,'problemas para buscar el minimo del espectro ' 
  			plot, perf(z1:z2)
  			oplot,yfit,lin=2
  			wait,1
  			print, 'xc=',xc,'z=',z
		endif else begin
		  posmin=float(xc)+px1  
   	  	  imin=poly(xc-z1,coef)
		endelse
	endif else begin 
   	  posmin=float(xc)+px1  
   	  imin=poly(xc-z1,coef)
;   stop
	endelse
endif else begin 
  posmin=float(xc)+px1  
  imin=poly(xc-z1,coef)
endelse

;a(i)=a(i)+(z-xc)
;dif=total(abs(perf(z-2:z+2)-yfit(3:7)))
;if (dif gt .08) then begin
;  print, i, j
; plot, perf(z1:z2)
; wait,1
; oplot,yfit,lin=2

;mx=max(perf(z1:z2)-cur)
;mx2=max(perf(z1:z2)-cur2)
;mx6=max(perf(z1:z2)-cur6)
;  print, 'maksimale differencer:',mx,mx2,mx6
;  plot,perf(z1:z2)
;  oplot,cur
;endif

return 
end 
 
 
