function corrige,im_in
  common an,oldval,bcg
  
  debug=0
  
  sz=size(im_in)
  im_out=im_in
  val=bytarr(sz(1),sz(2))+1b
  im_med=median(im_out,9)
  avg_row=total(im_med,1)/sz(1) ## (fltarr(sz(1))+1.)
  i_bad=where(abs(im_out-im_med) ge ((avg_row*2)>100))
  if i_bad(0) ne -1 then begin
    val(i_bad)=0b
    im_out(i_bad)=im_med(i_bad)
  endif
  
  if debug eq 1 then begin
    if n_elements(oldval) eq 0 then begin
      oldval=val
      bcg=val*0b
    endif
    bcg=bcg or (oldval ne val)
    wset,0 &  tv,bcg & print,n_elements(where(bcg) eq 1)
    wset,1 & tv,val
    oldval=val
  endif
  
  return,im_out
  
;manolos lines  
; im_in2=im_in
; tam=size(im_in)
; for j=0,tam(2)-1 do im_in2(*,j)=median(im_in2(*,j),5)
; for j=0,tam(3)-1 do im_in2(j,*)=median(reform(im_in2(j,*)),5)

; z=where(abs(im_in2-im_in) gt 100)

; im_in3=im_in
; im_in3(z)=im_in2(z)

; zz=where(im_in3 le 30)
; for j=0L,n_elements(zz)-1 do im_in3(zz(j))=median(im_in3(*,zz(j)/tam(1)))
; return,im_in3
end
