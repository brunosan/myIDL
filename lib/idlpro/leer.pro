pro leer,prefix,suffix,ind,dat,mac
nind=n_elements(ind)
ndat=25
dat=fltarr(8,ndat,nind)
mac=fltarr(nind)
dat1=fltarr(8,ndat)
for i=0,nind-1 do begin
   nom=prefix+strtrim(string(ind(i)),2)+suffix
   openr,1,nom
   readf,1,dum,dum1
   mac(i)=dum
   readf,1,dat1
   dat(*,*,i)=dat1
   close,1
endfor
return
end
