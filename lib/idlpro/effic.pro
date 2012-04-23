function effic,mat1

tam=size(mat1)
;n=tam(1)

; n  es el numero de pasos de un ciclo
; eps es la eficiencia [e_i,e_q,e_u,e_v,e_total}
;eps=fltarr(n+1)

;if(determ(mat1) ne 0) then begin
;  invmat1=invert(mat1)
;  for j=0,n-1 do eps(j)=n*invmat1(j,*)#transpose(invmat1(j,*))
;  eps(0:n-1)=1./eps(0:n-1)
;  eps=sqrt([eps(0:n-1),total(eps(1:n-1))])
;endif

if(determ(mat1) ne 0) then begin
   nr_svd,mat1,w,u,v

   n_w=n_elements(w)
   ww=fltarr(n_w,n_w)
   z=where(w ne 0) 
   if(z(0) ne -1) then begin
      nz=n_elements(z)
      for j=0,nz-1 do ww(z(j),z(j))=1./w(z(j)) 
      inv1=v#ww#transpose(u)
      eps=1./tam(1)/total(inv1*inv1,2)
      eps=sqrt([eps,total(eps(1:*))])
   endif   
endif else begin
   eps=fltarr(5)
endelse
      
return,eps
end
