function lee_chil6,yy,mm,dd,num,hora,acc,channel=channel


if keyword_set(channel) eq 0 then channel=0

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
n1=hdr(193)*256+hdr(192)
n2=hdr(197)*256+hdr(196)
n3=hdr(201)*256+hdr(200)
if(acc le 16) then begin
   dat=intarr(n1,n2,n3)
;   dat=intarr(789,248,6)
   readu,1,dat
   byteorder,dat
   z=where(dat lt 0)
   if(z(0) ne -1) then begin
      dat=long(dat)
      dat(z)=dat(z)+65536l
   endif      
endif else begin
   dat=lonarr(n1,n2,n3)
;   dat=lonarr(789,248,6)
   readu,1,dat
   byteorder,dat,/lswap
endelse

close,1

; estas dos sentencias para devolver solo el primer canal de los tres
if(channel ne 0) then begin
   z=findgen(n1/3)*3
   return,dat(z,*,*)
endif else begin
   return,dat
endelse

end
