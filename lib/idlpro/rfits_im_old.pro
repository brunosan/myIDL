function RFITS_IM,file,im,desc,header,nrhdr,desp=desp

desc={descc,object:'',naxis:2,naxis1:1,naxis2:1,naxis3:1,bscale:1.,bzero:0., $
            bitpix:0,date:'',origin:'',bunit:'',cdelt1:1.,cdelt2:1., $
	    telescope:''}
dat=0

if keyword_set(desp) eq 0 then desp=0
on_ioerror, error

get_lun,unit
openr,unit,file
head=bytarr(2880,/nozero)
nrhdr=0L
bytesperpixel=4		; default

fin=0
cnt=0

while(fin eq 0) do begin
   readu,unit,head
   z=where(head eq 0)
   cnt=cnt+1
   if(z(0) ne -1) then begin
      head(z)=32
      if(nrhdr eq 0) then begin
         hdr=head
	 nrhdr=1
      endif else begin	    
         hdr=[hdr,head]
         nrhdr=nrhdr+1
      endelse 
      spawn,'ls -l '+file,result
      size_file=double(strmid(result(n_elements(result)-1),30,13))
      size_file=size_file(0)
      nrhdr=size_file- $
         long(desc.naxis3)*long(desc.naxis2)*long(desc.naxis1)*bytesperpixel  
      nrhdr=long(nrhdr)
          
      cnt=nrhdr/2880-5
      pointer=2880l*cnt
      point_lun,unit,pointer  

      fin2=0
      while(fin2 eq 0) do begin
         cnt=cnt+1
         readu,unit,head
         z=where(head eq 0)
         if(z(0) ne -1) then head(z)=32
         pos=where (strpos(strtrim(head),'END') ne -1)
         if(pos(0) ne -1) then fin2=1
      endwhile
      hdr=[hdr,head]
      nrhdr=cnt
   endif else begin
      if(nrhdr eq 0) then begin
         hdr=head
	 nrhdr=1
      endif else begin	    
         hdr=[hdr,head]
         nrhdr=nrhdr+1
      endelse 
   endelse    

;   stop
   pos=strpos(head,'END     ')
   if(pos ne -1) then fin=1

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
   if(pos ne -1) then begin
      desc.bitpix=fix(strtrim(hdr(pos+10:pos+29)))
      bytesperpixel=desc.bitpix/8
   endif
   
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

   pos=strpos(strtrim(head),'TELESCOP=')
   if(pos ne -1) then desc.telescope=strtrim(hdr(pos+11:pos+26),2)

endwhile  
header=string(reform(hdr,2880,n_elements(hdr)/2880))

if (im lt 1 or im gt desc.naxis3) then begin
   print,'La imagen debe estar comprendida entre 1 y ', desc.naxis3
endif   

if(desc.bitpix eq 8) then begin
   dat=bytarr(desc.naxis1,desc.naxis2)
endif else if(desc.bitpix eq 16) then begin
   dat=intarr(desc.naxis1,desc.naxis2)
endif else if(desc.bitpix eq 32) then begin
   dat=lonarr(desc.naxis1,desc.naxis2)
endif else begin
   print,'BITPIX desconocido'
   free_lun,unit
   return,0
endelse    

fac=long(desc.naxis1)*long(desc.naxis2)*bytesperpixel
pointer=long(2880)*nrhdr+long(im-1)*fac
point_lun,unit,pointer 
readu,unit,dat
if(!version.arch eq "alpha" or strmid(!version.arch,0,3) eq "x86") then begin
   if(desc.bitpix eq 16) then begin
      byteorder,dat
   endif else if(desc.bitpix eq 32) then begin   
      byteorder,dat,/lswap
   endif
endif

if(desp ne 0) then dat(128:*,0:127)=shift(dat(128:*,0:127),0,1)     
if(desc.telescope eq 'SVST') then begin
   dat=transpose(dat)
   dum=desc.naxis1
   desc.naxis1=desc.naxis2
   desc.naxis2=dum
endif
   
error:

free_lun,unit
return,desc.bscale*dat+desc.bzero
end


