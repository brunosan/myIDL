function RFITS_IM2,datos,desc,nim,desp=desp,int=int,badpix=badpix

if keyword_set(int) eq 0 then int=0
if keyword_set(desp) eq 0 then desp=0
if keyword_set(badpix) eq 0 then badpix=0

if (nim lt 1 or nim gt desc.naxis3) then begin
   print,'La imagen debe estar comprendida entre 1 y ', desc.naxis3
   return,fltarr(desc.naxis1,desc.naxis2)
endif   

dat=datos(nim-1)

if(!version.arch eq "alpha" or strmid(!version.arch,0,3) eq "x86") then begin
   if(desc.bitpix eq 16) then begin
      byteorder,dat
   endif else if(desc.bitpix eq 32) then begin   
      byteorder,dat,/lswap
   endif
endif
if(!version.arch eq "i386") then byteorder,dat,/lswap

if(desp ne 0 and desc.telescope ne 'SVST') then dat(128:*,0:127)=shift(dat(128:*,0:127),0,1)     
;if(desc.telescope eq 'SVST') then dat=transpose(dat)
if(desc.camera eq 'Chil') then dat=transpose(dat)

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

if(int eq 0) then begin
   return,desc.bscale*dat+desc.bzero
endif else begin
   return,dat
endelse
     
end


