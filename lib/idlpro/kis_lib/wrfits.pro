PRO wrfits,ccd,out_file,over=over
;+
; NAME:
;	WRFITS
; PURPOSE:
;	Writes contents of "ccd-structure" on disk in FITS-format. 
;*CATEGORY:            @CAT-# 11  2@
;	FITS-Files , CCD Tools
; CALLING SEQUENCE:
;	WRFITS,ccd_struc [,out_file] [,/OVER]
; INPUTS:
;       ccd_struc : IDL-structure containing the image and all relevant 
;           parameters;
;	    The procedure recognizes one of the 4 following structure-types
;	    which differ only by the format of the image-array .pic: 
;	    {AT1_1024}  size of .pic: 1024x1024,
;	    {AT1_512}   size of .pic: 512x512,
;	    {AT1_400}   size of .pic: 400x600,
;	    {AT1_256}   size of .pic: 256x256,
;	    {RCA}	size of .pic: 320x512.
;	    Structure-tags:
;	    .status : string, status-info for image-data.
;	    .time   : string, start & end of exposure.
;	    .project: string, "general comment" of observer.
;	    .txt    : string, "image specific comment" of observer.
;	    .id     : integer, image-identification-number.
;	    .itime  : long integer, start_of-expos._time (sec since midnight). 
;	    .expos  : floating_point, length of exposure (sec).
;	    .par    : integer-array size=50, containing image parameters.
;	    .pic    : integer-array containing the extracted image
;	              it's size can be chosen by the user (see above 
;		      "size of .pic").
; OPTIONAL INPUT PARAMETER:
;	out_file  : (string) file name for FITS-file to be created;
;		    if out_file does'nt end on ."fits", the procedure will 
;		    append ".fits" to the file name; if such a file already
;		    exists, and unless /OVER was set, the file name will be 
;		    modified by ".nnn." (nnn from {000, 001,...,999}) to avoid
;		    overwriting.
;		    Default file name: 
;		    if ccd_struc.txt contains sub-string "%FILENAME <fname>^":
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
;	nlte (KIS), 1990-04-23 
;	nlte (KIS), 1992-08-26 : new code for output file name.
;-

on_error,1
npar=n_params()
if npar lt 1 or npar gt 2 then message,$
   'Usage: WRFITS,ccd_struc [,out_file] [,/OVER]'
if (size(ccd))(0) ne 1 or (size(ccd))(2) ne 8 then message,$
    '1st argument must be a structure'
if n_tags(ccd) ne 9 then message,$
   'Structure '+tag_names(ccd,/st)+' (1st argument) has invalid number of tags'
tagnames=['STATUS','TIME','PROJ','TXT','ID','ITIME','EXPOS','PAR','PIC']
tags=tag_names(ccd) & ii=where(tags ne tagnames,n)
if n gt 0 then begin
   print,'%WRFITS: tag-names of ccd_structure (1st argument) unknown or out of order:'
   for i=0,n do print,$
   'tag # '+string(ii(0),form='(i0)')+': '+tags(ii(i))+' expected: ',+tagnames(ii(i))
   return
endif
if npar gt 1 then begin
   if (size(out_file))(0) ne 0 or (size(out_file))(1) ne 7 then message,$
      '2nd argument must be a string'
   file=out_file
endif else file=''
;
; make FITS-header from tags "proj", "txt", & "par":
naxis1=(size(ccd.pic))(1) & naxis2=(size(ccd.pic))(2)
hdr=mkfitshdr(ccd.proj,ccd.txt,ccd.par,naxis1,naxis2)
;for i=0,n_elements(hdr)-1 do print,i,strcompress(hdr(i))
;
;get a unique name for output-file:
k=strlen(file)
if k lt 1 then begin
; filename unspecified: construct one from FITS-"FILENAME" and/or ccd.ID
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
   if ccd.id ge 0 and idfnam ne ccd.id then $
                                file=file+'_ID'+string(ccd.id,form='(i3.3)')
   endif else begin
;     no FITS-"FILENAME" found: default filename + ccd_structure.ID :
      file=getenv('USER')+'-CCD'
      if ccd.id ge 0 then file=file+'_ID'+string(ccd.id,form='(i3.3)')
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
img=ccd.pic
naxis1=(size(img))(1) & naxis2=(size(img))(2)
p=assoc(unit,intarr(naxis1,naxis2,/nozero),2880L*(nrecs+1))
   ;p(0)=ccd.pic ; geht bei grossen arrays (1024x1024 z.B.) nicht!!??
p(0)=img & img=0
free_lun,unit
print,'FITS-file written :',file
;
end
 

