function signo,datin

datout=datin
z=where(datin ne 0)
if(z(0) ne -1) then datout(z)=datin(z)/abs(datout(z)) 
z=where(datin eq 0)
if(z(0) ne -1) then datout(z)=0

return,datout
end
