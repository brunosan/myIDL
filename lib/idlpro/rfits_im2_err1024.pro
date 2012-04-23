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

if(desp ne 0 and desc.telescope ne 'SVST') then dat(128:*,0:127)=shift(dat(128:*,0:127),0,1)     
;if(desc.telescope eq 'SVST') then dat=transpose(dat)
if(desc.camera eq 'Chil') then dat=transpose(dat)

if(desc.camera eq 'IR1024' and badpix eq 1) then dat=badpixels(dat,desc) 
if(desc.camera eq 'IR1024') then dat=rotate(dat,1)

error:

if(int eq 0) then begin
   return,desc.bscale*dat+desc.bzero
endif else begin
   return,dat
endelse
     
end


