function lee6302,serie

imfin=[10,10,10,10,20,20,20,10,20, 3,50,114,140, 7,49,118, 2,29, 7, 5,15,16]
nfiles=imfin(serie-1)+1

file='d'+strtrim(string(serie),2)+'.at1'

n=long(512)
m=long(256)
nbloq=n*m*2/2880+1
hdr=bytarr(2880)
dum=intarr(nbloq*1440)
; dat=intarr(n,m,nfiles-1)   asi, si no se quiere leer la DC inicial
dat=intarr(n,m,nfiles)

openr,1,file
; readu,1,hdr                asi, si no se quiere leer la DC inicial
; readu,1,dum                asi, si no se quiere leer la DC inicial
; for j=0,nfiles-2 do begin  asi, si no se quiere leer la DC inicial

for j=0,nfiles-1 do begin
    readu,1,hdr
    readu,1,dum
    dat(*,*,j)= reform(dum(0:n*m-1),n,m)  
endfor   
close,1

return,dat
end
