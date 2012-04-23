function alinea,im1,im2

tam=size(im1)
if(tam(0) eq 1) then begin
   dum=recentra(im2,ref=im1,corr=corr) 
endif else if(tam(0) eq 2) then begin     
   corr=fltarr(tam(2),2)
   for j=0,tam(2)-1 do begin
      dum=recentra(im1(*,j),ref=im1(*,0),corr=cc)
      corr(j,0)=cc
      dum=recentra(im2(*,j),ref=im1(*,j),corr=cc)
      corr(j,1)=cc+corr(j,0)
   endfor
   cc=poly_fit(findgen(tam(2)),corr(*,0),2,yfit)
   corr(*,0)=yfit
   cc=poly_fit(findgen(tam(2)),corr(*,1),2,yfit)
   corr(*,1)=yfit
endif else begin
   print,'not more than 2 dimensions supported'
   return,0
endelse

return,corr
end
