pro leecontrol,ficheroin,n,nciclos,chi

openr,1,ficheroin
cab='estoeslacabecera'
a=cab
nn=nciclos*n
poscab=intarr(nn+1)
chi=fltarr(n)  
i=0
j=0
poscab(i)=0
;print,'ya abri el fichero',ficheroin
readf,1,cab
;print,'ya lei la primera cabecera',cab

while i lt nn and not EOF(1) do begin
   readf,1,a
   j=j+1
   while a ne cab and not EOF(1) do begin
      readf,1,a
      j=j+1
;      print,i,j,a
   endwhile 
   i=i+1
   poscab(i)=j 
endwhile

close,1
openr,1,ficheroin

iii=0
for i=0,n-1 do begin
    for ii=1,nciclos-1 do begin
       readf,1,cab
       for k=1,poscab(iii+1)-poscab(iii)-1 do begin
          readf,1,a
;         print,a
       endfor
       iii=iii+1
    endfor
    readf,1,cab
    for k=1,poscab(iii+1)-poscab(iii)-3 do begin
        readf,1,a
;       print,a
    endfor
    iii=iii+1
    readf,1,b,c,d

    chi(i)=d
    if b eq 0 then chi(i)=c
;    print,b,c,chi(i)
 
    readf,1,b 
endfor

close,1
return
end   
    

 
