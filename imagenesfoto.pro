;imas
print,"run foto.pro to get darks and flats until the first stop"

ima=fltarr(1024,30,4)

;for j=0,9 do begin
j=0
helioa=340 ;helio
heliob=420
cont=917 ;cont
telurica=588 ;telurica
landa=[helioa,heliob,cont,telurica]

for i=0,29 do begin 
 a=(rfits_im('14oct06.008',i+3+(30)*j,/bad)-dark)/flat 
  for l=0,n_elements(landa)-1 do ima[*,i,l]=reform(a[landa[l],*]) 
  
endfor
a=congrid(ima,1024,30*4,n_elements(landa),/interp)
tvwin,a 
;endfor


end