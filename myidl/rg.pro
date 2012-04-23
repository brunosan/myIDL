pro rg,nombre ,check=check

;reguardar usando wrtfits

rdfits,rohdaten,nombre

mostrar,rohdaten
openw,unit,'g'+nombre,/xdr,/get
writeu,unit,rohdaten
close,unit

IF keyword_set(check) then begin
  window,1,retain=2
  wset,1
  print,'checking'
  wait,0.5
  tam=size(rohdaten)
  openr,unit,'g'+nombre,/get
  rohdaten=assoc(unit, intarr(tam(1)-1, tam(2)-1), 2880)
  for i=0,tam(3)-1 do begin
    bild = rohdaten(*,*, i)
    tvscl,bild
  endfor
  wset,0
endif
close,unit
end
