pro leerp,prefix,suffix,ind,dat
nind=n_elements(ind)
ndat=35
dat=fltarr(6,ndat,nind)
dat1=fltarr(6,ndat)
for i=0,nind-1 do begin
   nom=prefix+strtrim(string(ind(i)),2)+suffix
   openr,1,nom
   readf,1,dat1
   dat(*,*,i)=dat1
   close,1
endfor
return
end
