function lee_mplus,yy,mm,dd,num,hora

file='m16a_im'

if(dd lt 10) then begin
   file=file+'0'+strtrim(string(dd),2)
endif else begin
   file=file+strtrim(string(dd),2)
endelse

mes=['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']

file=file+mes(mm-1)+strtrim(string(yy),2)+'.'+strtrim(string(num),2)

hdr=bytarr(512)
openr,1,file
readu,1,hdr

hora=fix(string(hdr(290:291)))+fix(string(hdr(293:294)))/60.+fix(string(hdr(296:297)))/3600.

dat=intarr(1536,1032)
readu,1,dat
byteorder,dat
close,1

return,dat
end
