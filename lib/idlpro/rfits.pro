function RFITS,file,desc,headerr,swap=swap


if(keyword_set(swap) eq 0) then swap=0
desc={descc,object:'',naxis:2,naxis1:1,naxis2:1,naxis3:1,bscale:1.,bzero:0., $
            bitpix:0,date:'',origin:'',bunit:'',cdelt1:1.,cdelt2:1.}
dat=0

on_ioerror, error

get_lun,unit
openr,unit,file

head=bytarr(2880,/nozero)
nrhdr=0

fin=0
while(fin eq 0) do begin
   readu,unit,head
   nrhdr=nrhdr+1

   pos=strpos(strtrim(head),'END')
   if(pos ne -1) then fin=1

   if(nrhdr eq 1) then begin
      hdr=head
   endif else begin   
      hdr=[hdr,head]
   endelse    

   pos=strpos(strtrim(head),'NAXIS   =')
   if(pos ne -1) then desc.naxis=fix(strtrim(hdr(pos+10:pos+29)))

   pos=strpos(strtrim(head),'NAXIS1  =')
   if(pos ne -1) then desc.naxis1=fix(strtrim(hdr(pos+10:pos+29)))

   if(desc.naxis gt 1) then begin
      pos=strpos(strtrim(head),'NAXIS2  =')
      if(pos ne -1) then desc.naxis2=fix(strtrim(hdr(pos+10:pos+29)))
   endif

   if(desc.naxis gt 2) then begin
      pos=strpos(strtrim(head),'NAXIS3  =')
      if(pos ne -1) then desc.naxis3=fix(strtrim(hdr(pos+10:pos+29)))
   endif

   pos=strpos(strtrim(head),'BSCALE  =')
   if(pos ne -1) then desc.bscale=float(strtrim(hdr(pos+10:pos+29)))

   pos=strpos(strtrim(head),'BZERO   =')
   if(pos ne -1) then desc.bzero=float(strtrim(hdr(pos+10:pos+29)))

   pos=strpos(strtrim(head),'OBJECT  =')
   if(pos ne -1) then desc.object=strtrim(hdr(pos+10:pos+29))

   pos=strpos(strtrim(head),'BITPIX  =')
   if(pos ne -1) then desc.bitpix=fix(strtrim(hdr(pos+10:pos+29)))

   pos=strpos(strtrim(head),'DATE    =')
   if(pos ne -1) then desc.date=strtrim(hdr(pos+10:pos+29))

   pos=strpos(strtrim(head),'ORIGIN  =')
   if(pos ne -1) then desc.origin=strtrim(hdr(pos+10:pos+29))

   pos=strpos(strtrim(head),'BUNIT   =')
   if(pos ne -1) then desc.bunit=strtrim(hdr(pos+10:pos+29))

   pos=strpos(strtrim(head),'CDELT1  =')
   if(pos ne -1) then desc.cdelt1=float(strtrim(hdr(pos+10:pos+29)))

   pos=strpos(strtrim(head),'CDELT2  =')
   if(pos ne -1) then desc.cdelt2=float(strtrim(hdr(pos+10:pos+29)))

endwhile  

header=strtrim(reform(hdr,2880,nrhdr))

if(desc.bitpix eq 8) then begin
   dat=bytarr(desc.naxis1,desc.naxis2,desc.naxis3)
endif else if(desc.bitpix eq 16) then begin
   dat=intarr(desc.naxis1,desc.naxis2,desc.naxis3)
endif else if(desc.bitpix eq 32) then begin
   dat=lonarr(desc.naxis1,desc.naxis2,desc.naxis3)
endif else begin
   print,'BITPIX desconocido'
   free_lun,unit
   return,0
endelse    
         
readu,unit,dat

if(!version.arch eq "alpha" or swap ne 0) then byteorder,dat
error:

free_lun,unit
return,desc.bscale*dat+desc.bzero
end


