PRO wrfitsa,img_arr,header,out_file,over=over
;+
; NAME:
;	WRFITSA
; PURPOSE:
;	Creates a FITS-file on disk.
;*CATEGORY:            @CAT-# 11  2@
;	FITS-Files , CCD Tools
; CALLING SEQUENCE:
;	WRFITS,img_array,fits_header [,out_file] [,/OVER]
; INPUTS:
;       img_array : 2-dim short integer array containing the image.
;       header: string array containing the FITS header.
; OPTIONAL INPUT PARAMETER:
;	out_file  : (string) file name for FITS-file to be created;
;		    if out_file does'nt end on ."fits", the procedure will 
;		    append ".fits" to the file name; if such a file already
;		    exists, and unless /OVER was set, the file name will be 
;		    modified by ".nnn." (nnn from {000, 001,...,999}) to avoid
;		    overwriting.
;		    Default file name: 
;		    if header contains label "FILENAME <fname>":
;		       out_fil = './<fname>[.nnn].fits' 
;		       or      = './<fname>_ID<id>[.nnn].fits'
;		       (second form if fname contains a counter unequal 
;		        ccd_struc.id)
;		    else: 
;		       out_fil = './<user>-CCD_ID<id>[.nnn].fits'
;		    (id= ccd_struc.id, ".nnn" only if to avoid overwriting.)
;      /OVER      : Allows overwriting existing FITS-file.
; OUTPUTS:
;	none
; COMMON BLOCKS:
;	none
; SIDE EFFECTS:
;	A file (FITS-format) will be written on disk; the (modified) file-
;	name will be written to standard output.
; RESTRICTIONS:
;	
; PROCEDURE:
;	Uses KIS_LIB procedures MKFITSHDR, MKFILNAM; Associated write to disk.
; MODIFICATION HISTORY:
;	nlte (KIS), 1992-08-26 : created from wrfits
;-
;
on_error,1
npar=n_params()
if npar lt 2 or npar gt 3 then message,$
   'Usage: WRFITSA,img_array, fits_header [,out_file] [,/OVER]'
sza=size(img_arr) & szh=size(header)
if sza(0) ne 2 or sza(1) le 1  or sza(2) le 1 or sza(3) ne 2 then message,$
    '1st argument must be a 2-dim short integer array'
if szh(0) ne 1 or szh(1) lt 10 or szh(2) ne 7 then message,$
   '2nd argument not a valid FITS header (string array)'
if strmid(header(0),0,6) ne 'SIMPLE' or strmid(header(1),0,6) ne 'BITPIX' $
   or strmid(header(2),0,5) ne 'NAXIS' or strmid(header(3),0,6) ne 'NAXIS1' $
   or strmid(header(4),0,6) ne 'NAXIS2' then message,$
   '2nd argument contents not a valid FITS header'
if npar gt 2 then begin
   if (size(out_file))(0) ne 0 or (size(out_file))(1) ne 7 then message,$
      '3rd argument (filename) must be a string'
   file=out_file
endif else file=''
;
; make FITS-header from tags "proj", "txt", & "par":
iform='(a,T9,"= ",i20,"/ ",a,T80," ")'
naxis1=sza(1) & naxis2=sza(2)
hdr=header
hdr(3)=string('NAXIS1',naxis1,'actual x-axis length',form=iform)
hdr(4)=string('NAXIS2',naxis2,'actual y-axis length',form=iform)
;
;get a unique name for output-file:
k=strlen(file)
if k lt 1 then begin
; filename unspecified: construct one from FITS-"FILENAME"
   ii=where(strmid(hdr,0,9) eq 'FILENAME=',n)
   if n gt 0 then begin
;     there is a FITS-"FILENAME":
      i=strpos(hdr(ii(n-1)),"'",12)
      fitsfil=strmid(hdr(ii(n-1)),11,strpos(hdr(ii(n-1)),"'",12)-11)
   j=strpos(fitsfil,':')
   if strmid(fitsfil,j+1,1) eq '\' then j=j+2 else j=j+1
   file=mkfilnam(strmid(fitsfil,j,strlen(fitsfil)-j))
;  search for last dot in fitsfil:
   j3=strpos(fitsfil,'.',j) & j2=strlen(fitsfil)
   while j3 ge 0 do begin j2=j3 & j3=strpos(fitsfil,'.',j2+1) & endwhile
;  j2 = pos. of last dot or of last char +1
;  1-4 digits left of last dot or at end of fitsfil  for "tape-file number": 
   j1=j2 & bf=byte(fitsfil)
   for i=j2-1,(j2-4)>0,-1 do begin
       if bf(i) ge 48 and bf(i) le 57 then j1=i else goto,jmpfid
   endfor
jmpfid: if j1 lt j2 then idfnam=fix(strmid(fitsfil,j1,j2-j1)) else idfnam=-9
; look for IMG_ID in header:
  ii=where(strmid(hdr,0,6) eq 'IMG_ID',ni)
  if ni gt 0 then begin
     k2=strpos(hdr(ii(ni-1)),'/') & if k2 le 0 then k2=80
     cc=strtrim(strcompress(strmid(hdr(ii(ni-1)),10,k2-10)),2)
     ccdid=fix(cc)
  endif else ccdid=-9
   if ccdid ge 0 and idfnam ne ccdid then $
                                file=file+'_ID'+string(ccdid,form='(i3.3)')
   endif else begin
;     no FITS-"FILENAME" found: default filename + ccdID :
      file=getenv('USER')+'-CCD'
      if ccdid ge 0 then file=file+'_ID'+string(ccdid,form='(i3.3)')
   endelse
endif
;make file a regular UNIX filename:
   file=mkfilnam(file)
;remove ".fits" fo a while:
   k=strlen(file) & i=strpos(file,'.fits')
   if i gt 0 and i eq k-5 then file=strmid(file,0,i)
;modify by suffix if neccessary:
files=file+'.fits'
if not keyword_set(over) then begin
   ff=findfile(files,count=n)
   suff=-1
   while n gt 0 do begin
      suff=suff+1 & if suff gt 999 then message,$
                                        'file '+files+' suffix overflow'
      files=file+string(suff,form='(".",i3.3,".fits")')
      ff=findfile(files,count=n)
   endwhile
endif
file=files ; now file terminates with ".fits" in any case!
;
openw,unit,file,/get_lun
;
h=assoc(unit,bytarr(2880))
nhdr=n_elements(hdr)-1 
nrecs=-1
for i=0,nhdr,36 do begin
    hdrbyt=replicate(32b,2880)
    imax=(i+35)<nhdr
    imxbyt=80L*(imax-i+1)-1 & hdrbyt(0:imxbyt)=byte(hdr(i:imax))
    nrecs=nrecs+1 & h(nrecs)=hdrbyt
endfor
;
p=assoc(unit,intarr(naxis1,naxis2,/nozero),2880L*(nrecs+1))
p(0)=img_arr
free_lun,unit
print,'FITS-file written :',file
;
end
 

