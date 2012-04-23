pro resultado,SerNr,ScanNr

serien=strtrim(string(SerNr),2)
scann=strtrim(string(ScanNr),2)
print,'dir=/users/bruno/data/cro/data2/res/s'+serien+'2_'+scann+'.fts'
s=intarr(3)
s=intarr(3)
openr,x,'/users/bruno/data/cro/data2/res/'+serien+'_'+scann+'size',/get
readf,x,s
close,x

im=fltarr(s(0),s(1),s(2))
openr,x,'/users/bruno/data/cro/data2/res/'+serien+'_'+scann+'scan'
readu,x,im
close,x
free_lun,x
hlp,im
wrtfits,im,filename='/users/bruno/data/cro/data2/res/'+serien+'_'+scann+'nr.fts',/overw
end

