function RFITS,file,desc,header

on_ioerror, error

get_lun,unit
openr,unit,file

desc={desc,object:'',naxis:2,naxis1:1,naxis2:1,bscale:1.,bzero:0., $
            bitpix:0,date:'',origin:'',bunit:'',cdelt1:1.,cdelt2:1.}

hdr=bytarr(2880,/nozero)
nrhdr=0
pos=-1
while(pos eq -1) do begin
readu,unit,hdr
nrhdr=nrhdr+1

pos=strpos(strtrim(hdr),'NAXIS')
if(pos ne -1) then desc.naxis=fix(strtrim(hdr(pos+10:pos+79)))

pos=strpos(strtrim(hdr),'NAXIS1')
if(pos ne -1) then desc.naxis1=fix(strtrim(hdr(pos+10:pos+79)))

if(desc.naxis eq 2) then begin
   pos=strpos(strtrim(hdr),'NAXIS2')
   if(pos ne -1) then desc.naxis2=fix(strtrim(hdr(pos+10:pos+79)))
endif

pos=strpos(strtrim(hdr),'BSCALE')
if(pos ne -1) then desc.bscale=float(strtrim(hdr(pos+10:pos+79)))

pos=strpos(strtrim(hdr),'BZERO')
if(pos ne -1) then desc.bzero=float(strtrim(hdr(pos+10:pos+79)))

pos=strpos(strtrim(hdr),'OBJECT')
if(pos ne -1) then desc.object=strtrim(hdr(pos+10:pos+79))

pos=strpos(strtrim(hdr),'BITPIX')
if(pos ne -1) then desc.bitpix=fix(strtrim(hdr(pos+10:pos+79)))

pos=strpos(strtrim(hdr),'DATE')
if(pos ne -1) then desc.date=strtrim(hdr(pos+10:pos+79))

pos=strpos(strtrim(hdr),'ORIGIN')
if(pos ne -1) then desc.origin=strtrim(hdr(pos+10:pos+79))

pos=strpos(strtrim(hdr),'BUNIT')
if(pos ne -1) then desc.bunit=strtrim(hdr(pos+10:pos+79))

pos=strpos(strtrim(hdr),'CDELT1')
if(pos ne -1) then desc.cdelt1=float(strtrim(hdr(pos+10:pos+79)))

pos=strpos(strtrim(hdr),'CDELT2')
if(pos ne -1) then desc.cdelt2=float(strtrim(hdr(pos+10:pos+79)))

pos=strpos(hdr,'END                            ')
if(nrhdr eq 1) then begin
   header=hdr
endif else begin
   header=[header,hdr]
endelse
endwhile

dat=intarr(desc.naxis1,desc.naxis2)
readu,unit,dat

if(!version.arch eq "alpha") then byteorder,dat
header=strtrim(header)

error:
free_lun,unit
return,desc.bscale*dat+desc.bzero
end


