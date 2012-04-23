pro prova,filename,fout

; Lee un fichero binario de reales escrito por un PC y 
; transforma los numeros convenientemente

; filename: Nombre del fichero
; fout: Matriz de numeros de salida

fin=bytarr(80000)
fout=fin
ncont=0l

openr,1,filename
readu,1,fin
close,1

while ncont lt 80000l do begin
   for i=0,3 do fout(ncont+i)=fin(ncont+3l-i)
   ncont=ncont+4
endwhile
openw,1,'tmp.tmp'
writeu,1,fout
close,1
fout=fltarr(20000)
openr,1,'tmp.tmp'
readu,1,fout
close,1
$rm tmp.tmp
return
end
