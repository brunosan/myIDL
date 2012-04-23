pro calib2file,filecal,fileout,lambda,eps,dmod

data=0
acum2iquv9,filecal,filecal,filecal,data=data,/get

calib_slit2,filecal,dmod,delta,eps,data=data,lambda=lambda

tam=size(dmod)
dmod2=total(dmod,3)/tam(3)

openw,1,fileout
printf,1,dmod2,format='(4f9.4)'
close,1

return
end
