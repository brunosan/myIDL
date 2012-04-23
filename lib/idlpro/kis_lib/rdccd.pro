PRO rdccd,file,ccd_struct,reset=ireset
;+
; NAME:
;	RDCCD
; PURPOSE:
;	Input of a CCD-image-file ("SUN-CCD-format") from SUN-disk,
;	returning contents as structure.
;*CATEGORY:            @CAT-#  2@
;	CCD Tools
; CALLING SEQUENCE:
;	RDCCD,file,ccd_structure [,/RESET]
; INPUTS:
;	file : name of disk-file containing image, must be of "SUN-CCD-format".
;	ccd_structure : 
; OUTPUTS:
;       ccd_structure : IDL-structure containing the image and all relevant 
;	    parameters; the structure will be created if the calling
;	    program has **not** passed a structure of appropriate format.
;	    The procedure recognizes/creates one of the 5 following structure-
;	    types which differ only by the format of the image-array .pic: 
;	    {AT1_1024}  size of .pic: 1024x1024,
;	    {AT1_512}   size of .pic: 512x512,
;	    {AT1_400}   size of .pic: 400x600,
;	    {AT1_256}   size of .pic: 256x256,
;	    {RCA}       size of .pic: 320x512.
;	       Structure-tags:
;	       .status : string, status-info for image-data.
;	       .time   : string, start & end of exposure.
;	       .project: string, "general comment" of observer.
;	       .txt    : string, "image specific comment" of observer.
;	       .id     : integer, image-identification-number.
;	       .itime  : long integer, start_of-exposure_time (sec since 
;	                 midnight).
;	       .expos  : floating_point, length of exposure (sec).
;	       .par    : integer-array size=50, containing image parameters.
;	       .pic    : integer-array containing the extracted image
;			 it's size can be specified by the user; if the
;			 original CCD-image does not fit into this array,
;			 the user will be requested to specify how to
;			 extract part of the image or how to compress it. 
; COMMON BLOCKS:
;	RDCCDCOM,x0,y0,xm,ym,binx,biny
;	         to save some variables for later calls.
; SIDE EFFECTS:
;	none
; RESTRICTIONS:
;	none
; PROCEDURE:
;	straight foreward
; MODIFICATION HISTORY:
;	H.Schleicher, KIS, 1990-Mar-17 
;	H.S., KIS, 1991-May-24 : major update.
;	H.S., KIS, 1991-Aug-26 : 5 structure-types, scissoring/binning.
;	H.S., KIS, 1992-Apr-02 : MESSAGE-string "Usage ..." updated.
;-
;
common rdccdcom,x0,y0,xm,ym,binx,biny,naxis1,naxis2
on_error,1
if n_params() le 1 then message,'Usage: RDCCD,filename,ccd_structure [,/RESET]'
;
neu=0
if keyword_set(ireset) then begin
  neu=1 & ccd_struct=0 & nx=0 & ny=0 & x0=0 & y0=0 & xm=32767 & ym=xm 
endif 
nc=1L
nxny=lonarr(2)
bb=intarr(50,/nozero)
comm=bytarr(4000,/nozero)
;
get_lun,unit
openr,unit,file,/f77_unformatted
readu,unit,nc,comm
readu,unit,bb
readu,unit,nxny
if n_elements(naxis1) eq 0 then neu=1 else $
   neu=neu + (nxny(0) ne naxis1) + (nxny(1) ne naxis2)
naxis1=nxny(0) & naxis2=nxny(1)
image=intarr(naxis1,naxis2,/nozero)
readu,unit,image
free_lun,unit
print,FORMAT='("File = ",a," has been read in. Size: ",i0," , ",i0)' $ 
     ,file,naxis1,naxis2
;
if n_tags(ccd_struct) eq 9 then begin
   case tag_names(ccd_struct,/str) of
       'AT1_1024': begin nx=1024 & ny=1024 & end
       'AT1_512':  begin nx=512 &  ny=512  & end
       'AT1_400':  begin nx=400 &  ny=600  & end
       'AT1_256':  begin nx=256 &  ny=256  & end
       'RCA':      begin nx=320 &  ny=512  & end
       else:       begin neu=1  & ccd=0    & end
   endcase
endif else neu=1
if neu eq 0 then $
   if (size(ccd_struct.pic))(1) ne nx or (size(ccd_struct.pic))(2) ne ny then $
      neu=1
if neu ne 0 then begin
   print,'Size of image-array CCD_STRUCT.PIC ?'
   jmp1: print ,$
'   Enter: b (=1024x1024), m (=512x512), s (=400x600), t (256x256) r (320,512)'
   form_pic=''
   read ,form_pic & form_pic=strlowcase(strcompress(form_pic,/remove))
   case strmid(form_pic,0,1) of
      'b': begin ccd_struct={at1_1024, $
               status:'',time:'',proj:'',txt:'',id:0,itime:0L,expos:0.0,$
	       par:intarr(50),pic:intarr(1024,1024)} & nx=1024 & ny=1024 & end
      'm': begin ccd_struct={at1_512, $
               status:'',time:'',proj:'',txt:'',id:0,itime:0L,expos:0.0,$
	       par:intarr(50),pic:intarr(512,512)} & nx=512 & ny=512 & end
      's': begin ccd_struct={at1_400, $
               status:'',time:'',proj:'',txt:'',id:0,itime:0L,expos:0.0,$
	       par:intarr(50),pic:intarr(400,600)} & nx=400 & ny=600 & end
      't': begin ccd_struct={at1_256, $
               status:'',time:'',proj:'',txt:'',id:0,itime:0L,expos:0.0,$
	       par:intarr(50),pic:intarr(256,256)} & nx=256 & ny=256 & end
      'r': begin ccd_struct={RCA, $
               status:'',time:'',proj:'',txt:'',id:0,itime:0L,expos:0.0,$
	       par:intarr(50),pic:intarr(320,512)} & nx=320 & ny=512 & end
      else: goto,jmp1
   endcase
   ccd_struct.par=0
endif
;
; check if file was extracted from PDP-tape before Nov. '90:
if bb(17) eq -9 then vers=0 else vers=1
;            old                    new
if vers eq 0 then begin
   ccd_struct.status=string(comm(18:73)) ; img-type, reduction-status, img-ID
   ccd.time=string(comm(0:17))
   ccd_struct.proj='RCA'
   bb(15)=2
   nc=nc-1
   if nc gt 2 then $
   for i=2,nc-1 do comm(80*i-1:80*i-1)=94 ; string(byte(94))='^'
   comm(80*nc-1:80*nc-1)=64 ; string(byte(64))='@'
   ccd.txt=strcompress(string(comm(80:nc*80-1)))
   bb(16)=nc
   ccd.expos=bb(9)*0.05
   bb(17)=50
endif else begin
   ccd_struct.status=string(comm(0:6))+' '+string(comm(27:79))
   ccd_struct.time=string(comm(8:25))
   ccd_struct.proj=strcompress(string(comm(80:bb(15)*80-1)))
   ccd_struct.txt=strcompress(string(comm(bb(15)*80:bb(16)*80-1)))
   ccd_struct.expos=float(bb(9)*bb(17))*0.001
endelse
ccd_struct.id=bb(2)
ccd_struct.itime=(long(bb(47)*60)+long(bb(48)))*60L+long(bb(49))
;
; image scissoring and/or binning?
if nx eq naxis1 and ny eq naxis2 then begin
;  ***** image is identical with ccd_struct.pic ***** :
   ccd_struct.pic=image
   print,'image -> ccd_struct.pic (binning=1,x0=y0=0)'
endif else if nx ge naxis1 and ny ge naxis2 then begin
;  ***** image is smaller than ccd_struct.pic ***** :
    ccd_struct.pic=0
    ccd_struct.pic(0:naxis1-1,0:naxis2-1)=image
    print,'image -> ccd_struct.pic (binning=1,x0=y0=0; image < pic !)'
endif else begin
;  ***** image is larger than ccd_struct.pic ***** :
   ccd_struct.pic=0
again3: 
   if neu gt 0 then begin
      print,$
 FORMAT='("size of read-in image = ",i0," , ",i0," larger than ",i0," , ",i0)'$
      ,naxis1,naxis2,nx,ny 
      print,'Extraction of a sub-image and/or rebinning neccessary!'
     print,'Enter x0,y0, xm,ym of lower-left, upper-right corners of sub-image'
      x0=0 & y0=0 & xm=0 & ym=0 & binx=1 & biny=1
      read,x0,y0,xm,ym & x0=x0>0 & y0=y0>0
      print,'Enter binning-factors x-,y-dimension (integer)'
      read,binx,biny & binx=binx>1 & biny=biny>1
   endif
   xm=(xm>(x0+1))<(naxis1-1) & ym=(ym>(y0+1))<(naxis2-1)
   nxsub=xm-x0+1 & nysub=ym-y0+1 
   kx=nxsub/binx & ky=nysub/biny
   nxsub=kx*binx & nysub=ky*biny
   xm=x0+nxsub-1 & ym=y0+nysub-1
;
   neu= (kx gt nx) + (ky gt ny)
   if neu gt 0 then goto,again3
   print,$
       FORMAT='(" ccd_struct.pic(0:",i0,",0:",i0,") <-")',kx-1,ky-1
   if binx gt 1 or biny gt 1 then print,$
    FORMAT='(" rebin(image(",i0,":",i0,",",i0,":",i0,"),",i0,",",i0,")")',$
       x0,xm,y0,ym,kx,ky else print,$
    FORMAT='(" image(",i0,":",i0," , ",i0,":",i0,")")',x0,xm,y0,ym
   if binx gt 1 or biny gt 1 then $
      ccd_struct.pic(0:kx-1,0:ky-1) = rebin(image(x0:xm,y0:ym),kx,ky) $
   else ccd_struct.pic(0:kx-1,0:ky-1)=image(x0:xm,y0:ym)
; update parameters:
   bb(23)=bb(23)+x0*bb(21) & bb(24)=bb(24)+y0*bb(22)
   bb(21)=bb(21)*binx & bb(22)=bb(22)*biny
; update exposure comments:
   i1=strpos(ccd_struct.txt,'new image format (n, offset, binning) axis1:')
   if i1 gt 0 then begin
      i2=strpos(ccd_struct.txt,' axis1:',i1)+8
      i3=strpos(ccd_struct.txt,'^',i2)+1 & i4=strlen(ccd_struct.txt)-i3
      txt0=strmid(ccd_struct.txt,0,i2)
      txt0=txt0+string(kx,bb(23),bb(21),format='(i4,1x,i4,1x,i2)')+' axis2: '
      txt0=txt0+string(ky,bb(22),bb(24),format='(i4,1x,i4,1x,i2)')+' ^'
      if i4 gt 0 then txt0=txt0+strmid(ccd_struct.txt,i3,i4)
      ccd_struct.txt=strcompress(txt0) & txt0=''
   endif else begin
      ccd_struct.txt= $
          ccd_struct.txt+'new image format (n, offset, binning) axis1: '
      ccd_struct.txt= $
          ccd_struct.txt+string(kx,bb(23),bb(21),format='(i4,1x,i4,1x,i2)')
      ccd_struct.txt= ccd_struct.txt+' axis2: '
      ccd_struct.txt= $
         ccd_struct.txt+string(ky,bb(22),bb(24),format='(i4,1x,i4,1x,i2)')+' ^'
   endelse
endelse
;
ccd_struct.par=bb
image=0
;
return
end
