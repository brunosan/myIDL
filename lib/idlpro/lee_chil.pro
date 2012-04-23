function lee_chil,yy,mm,dd,num,hora,acc

file='chil_'+strtrim(string(yy),2)+'-'

if(mm lt 10) then begin
   file=file+'0'+strtrim(string(mm),2)
endif else begin
   file=file+strtrim(string(mm),2)
endelse

file=file+'-'
if(dd lt 10) then begin
   file=file+'0'+strtrim(string(dd),2)
endif else begin
   file=file+strtrim(string(dd),2)
endelse

file=file+'_'
if(num lt 10 ) then begin
   file=file+'000'+strtrim(string(num),2)
endif else if(num lt 100) then begin
   file=file+'00'+strtrim(string(num),2)
endif else if(num lt 1000) then begin
   file=file+'0'+strtrim(string(num),2)
endif else if(num lt 10000) then begin
   file=file+strtrim(string(num),2)
endif

hdr=bytarr(512)
openr,1,file
readu,1,hdr
hora=fix(string(hdr(280:281)))+fix(string(hdr(283:284)))/60.+fix(string(hdr(286:287)))/3600.
acc=fix(string(hdr(318:321)))
if(acc le 16) then begin
   dat=intarr(789,248,4)
   readu,1,dat
   byteorder,dat
endif else begin
   dat=lonarr(789,248,4)
   readu,1,dat
   byteorder,dat,/lswap
endelse

close,1

tam=size(dat)
z=findgen(tam(1)/3)*3

return,dat(z,*,*)
end
