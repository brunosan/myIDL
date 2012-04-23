pro mostrars,imagen,pausa=pausa,loop=loop


sl = string(byte([27, 91, 68, 27, 91, 68, 27, 91, 68]))
x=0
;mostrar en tvscl todas las imagenes de un cubo
IF NOT keyword_set(pausa) THEN pausa = 0
sizes=size(imagen)
otra:
for cont=0,(sizes(3)-1) do begin
  tvscl,imagen(*,*,cont)
  xyouts,0,0,cont,/data
  writeu, -1,sl+string(cont+1, format="(i3)")
  wait,pausa
endfor
IF keyword_set(loop) then begin
x=x+1
writeu, -1,sl+string(x, format="(i3)")
print,''
if x GE loop then goto,salir
goto,otra
endif
salir:
end
