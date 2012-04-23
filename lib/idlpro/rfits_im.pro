function RFITS_IM,file,im,desc,header,nrhdr,desp=desp,badpix=badpix

desc={object:'',naxis:2,naxis1:1,naxis2:1,naxis3:1,bscale:1.,bzero:0., $
            bitpix:0,date:0L,origin:'',bunit:'',cdelt1:1.,cdelt2:1., $
	    xtot_start:1,xtot_end:1,ytot_start:1,ytot_end:1, $
	    xstart:1,xend:1,ystart:1,yend:1, $
	    telescope:'',camera:'',filename:''}


dat=0

if keyword_set(desp) eq 0 then desp=0
if keyword_set(badpix) eq 0 then badpix=0
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
   if(z(0) ne -1) then head(z)=32

   pos=strpos(head,'END     ')
   if(pos ne -1) then fin=1

   pos=strpos(strtrim(head),'NAXIS   =')
   if(pos ne -1) then desc.naxis=fix(strtrim(head(pos+10:pos+29)))

   pos=strpos(strtrim(head),'NAXIS1  =')
   if(pos ne -1) then begin
      desc.naxis1=fix(strtrim(head(pos+10:pos+29)))
      desc.xtot_end=desc.naxis1
      desc.xend=desc.naxis1
   endif
      
   if(desc.naxis gt 1) then begin
      pos=strpos(strtrim(head),'NAXIS2  =')
      if(pos ne -1) then begin
         desc.naxis2=fix(strtrim(head(pos+10:pos+29)))
         desc.ytot_end=desc.naxis2
         desc.yend=desc.naxis2
      endif	 
   endif

   if(desc.naxis gt 2) then begin
      pos=strpos(strtrim(head),'NAXIS3  =')
      if(pos ne -1) then desc.naxis3=fix(strtrim(head(pos+10:pos+29)))
   endif

   pos=strpos(strtrim(head),'BSCALE  =')
   if(pos ne -1) then desc.bscale=float(strtrim(head(pos+10:pos+29)))

   pos=strpos(strtrim(head),'BZERO   =')
   if(pos ne -1) then desc.bzero=float(strtrim(head(pos+10:pos+29)))

   pos=strpos(strtrim(head),'OBJECT  =')
   if(pos ne -1) then desc.object=strtrim(head(pos+10:pos+29))

   pos=strpos(strtrim(head),'BITPIX  =')
   if(pos ne -1) then begin
      desc.bitpix=fix(strtrim(head(pos+10:pos+29)))
      bytesperpixel=desc.bitpix/8
   endif
   
   pos=strpos(strtrim(head),'DATE-OBS=')
   if(pos ne -1) then begin
      yy=fix(strtrim(head(pos+11:pos+14)))
      mm=fix(strtrim(head(pos+16:pos+17)))
      dd=fix(strtrim(head(pos+19:pos+20)))
      desc.date=yy*10000L+mm*100L+dd
   endif

   pos=strpos(strtrim(head),'ORIGIN  =')
   if(pos ne -1) then desc.origin=strtrim(head(pos+10:pos+29))

   pos=strpos(strtrim(head),'BUNIT   =')
   if(pos ne -1) then desc.bunit=strtrim(head(pos+10:pos+29))

   pos=strpos(strtrim(head),'CDELT1  =')
   if(pos ne -1) then desc.cdelt1=float(strtrim(head(pos+10:pos+29)))

   pos=strpos(strtrim(head),'CDELT2  =')
   if(pos ne -1) then desc.cdelt2=float(strtrim(head(pos+10:pos+29)))

   pos=strpos(strtrim(head),'TELESCOP=')
   if(pos ne -1) then desc.telescope=strtrim(head(pos+11:pos+27),2)

   pos=strpos(strtrim(head),'CAMERA  =')
   if(pos ne -1) then desc.camera=strtrim(head(pos+11:pos+27),2)

   desc.filename=file
;   pos=strpos(strtrim(head),'FILENAME=')
;   if(pos ne -1) then desc.filename=strtrim(head(pos+11:pos+27),2)

   pos=strpos(strtrim(head),'FULLFRAM=')
   if(pos ne -1) then begin
       dum1=byte(strtrim(head(pos+11:pos+27),2))

       pos1=strpos(strtrim(dum1),'[')
       pos2=strpos(strtrim(dum1),',')
       pos3=strpos(strtrim(dum1),']')
    
       dum2=byte(strtrim(dum1(pos1+1:pos2-1),2))
       dum3=byte(strtrim(dum1(pos2+1:pos3-1),2))
 
       pos4=strpos(strtrim(dum2),':')
       pos5=strpos(strtrim(dum3),':')
      
       desc.xtot_start=fix(strtrim(dum2(pos1:pos4-1)))
       desc.xtot_end=fix(strtrim(dum2(pos4+1:strlen(dum2)-1)))
       desc.ytot_start=fix(strtrim(dum3(pos1:pos5-1)))
       desc.ytot_end=fix(strtrim(dum3(pos5+1:strlen(dum3)-1)))
             
   endif
   
   pos=strpos(strtrim(head),'DATAFRAM=')
   if(pos ne -1) then begin
       dum1=byte(strtrim(head(pos+11:pos+27),2))

       pos1=strpos(strtrim(dum1),'[')
       pos2=strpos(strtrim(dum1),',')
       pos3=strpos(strtrim(dum1),']')

       dum2=byte(strtrim(dum1(pos1+1:pos2-1),2))
       dum3=byte(strtrim(dum1(pos2+1:pos3-1),2))
 
       pos4=strpos(strtrim(dum2),':')
       pos5=strpos(strtrim(dum3),':')
      
       desc.xstart=fix(strtrim(dum2(pos1:pos4-1)))
       desc.xend=fix(strtrim(dum2(pos4+1:strlen(dum2)-1)))
       desc.ystart=fix(strtrim(dum3(pos1:pos5-1)))
       desc.yend=fix(strtrim(dum3(pos5+1:strlen(dum3)-1)))
   endif
  
   
   if(z(0) ne -1 and fin eq 0) and (1 eq 0) then begin
      if(nrhdr eq 0) then begin
         hdr=head
	 nrhdr=1
      endif else begin	    
         hdr=[hdr,head]
         nrhdr=nrhdr+1
      endelse 
;use file_info instead of ls (A. Lagg, May05)
      fi=file_info(file)
      size_file=fi.size 
;      spawn,'ls -l '+file,result
;      size_file=long64(strmid(result(n_elements(result)-1),30,13))
;      size_file=size_file(0)
      nrhdr=size_file- $
         long(desc.naxis3)*long(desc.naxis2)*long(desc.naxis1)*bytesperpixel  
      nrhdr=long(nrhdr)
          
      cnt=(nrhdr/2880-5)>0
      pointer=2880l*cnt
      point_lun,unit,pointer  

      fin2=0
      while(fin2 eq 0) do begin
         cnt=cnt+1
         readu,unit,head
         z=where(head eq 0)
         if(z(0) ne -1) then head(z)=32
         pos=where (strpos(head,'END     ') ne -1)
         if(pos(0) ne -1) then fin2=1
      endwhile
      hdr=[hdr,head]
      nrhdr=cnt
      fin=1
   endif else begin
      if(nrhdr eq 0) then begin
         hdr=head
	 nrhdr=1
      endif else begin
         hdr=[hdr,head]
         nrhdr=nrhdr+1
      endelse
   endelse    

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
if(!version.arch eq "alpha" or !version.arch eq "x86") then begin
   if(desc.bitpix eq 16) then begin
      byteorder,dat
   endif else if(desc.bitpix eq 32) then begin   
      byteorder,dat,/lswap
   endif
endif
if(!version.arch eq "i386") then byteorder,dat,/lswap

if(desp ne 0) then dat(128:*,0:127)=shift(dat(128:*,0:127),0,1)     
;if(desc.telescope eq 'SVST') then begin
if(desc.camera eq 'Chil') then begin
   dat=transpose(dat)
   dum=desc.naxis1
   desc.naxis1=desc.naxis2
   desc.naxis2=dum
endif

if(desc.camera eq 'IR1024') then begin

   if(badpix eq 1) then begin
      if(desc.date lt 20060420) then $
         dat=badpixels(dat,desc) else $
	 dat=badpixels2006(dat,desc)
   endif
  
   end_character=strmid(desc.filename,strlen(desc.filename)-1,1)
   if(end_character ne 'c' and desc.date ge 20051001 and $
         desc.date le 20060101) then begin 
      dat=rotate(dat,1)

      if(desc.date ge 20051006 and desc.date le 20051006) then begin
         im1 = dat
         im1(*,0:509) = reverse(im1(*,0:509),1)
         im1(512:1023,0:509) = shift(im1(512:1023,0:509),0,255)
	 im1=reverse(im1,1)
         dat = im1
      endif
   endif

endif

error:

free_lun,unit
;   restore,'correc.idl'
;return,(desc.bscale*dat+desc.bzero)/correc
return,(desc.bscale*dat+desc.bzero)
end


