function RAYAS,ffin
tam=size(ffin)
n=tam(1)
m=tam(2)
esp=total(ffin,1)/n
ffout=ffin
for i=0,n-1 do ffout(i,*)=ffin(i,*)/esp
return,ffout
end
