FUNCTION mkfitshdr,proj,txt,par,naxis1,naxis2
;+
; NAME:
;	MKFITSHDR
; PURPOSE:
;	Makes a FITS-header using informations in strings 
;	"project", "exposure-comments",  and integer-array "parameters"
;*CATEGORY:            @CAT-# 11  2@
;	FITS-Files , CCD Tools
; CALLING SEQUENCE:
;	header = MKFITSHDR (project, exposure-comments, parameters, ...
;	                    ... naxis1,naxis2)
; INPUTS:
;	project: (string) contains "general comments" common to a
;          series of images. MKFITSHDR searches for substrings of format 
;	   '%<label> <text>^' and creates a FITS-header "card image" from 
;	   <label> and <text>. The following labels will be recognized 
;	   (must be upper case): 
;	   DATE-OBS OBSERVER TELESCOP ORIGIN INSTRUME G .
;	   Label "G" will be translated into FITS-label COMMENT1 (for "general
;          comments").
;	   Sub-strings not enclosed between %<label> and ^ will be ignored.
;       exposure-comments: (string) contains "exposure specific comments".
;	   Same format as for project; recognized labels are:
;	   OBJECT TIME-BEG TIME-END DATE FILENAME C H .
;          In case of "OBJECT", <text> may have the form
;	       <1st text line>^<2nd text line>^...^<last text line>$^
;	   (note terminating "$^" !), which will be translated into one 
;	   separate "OBJECT" header line for each text-line.
;	   Label DATE is intended to show date & time of last modification
;	   (reduction) of image data.
;	   Label "C" will be translated into FITS-label COMMENT (for "exposure
;          specific comments").
;	   Label "H" will be translated into FITS-label HISTORY .
;       parameters: (short integer array size 50) contains numerical info's;
;	   values < 0 will be interpreted as "not set"; p(i) > -1 will
;	   be tranlated into a FITS-header "card image":
;	   IMG_TYPE p(0)  IMG_REDU p(1)     IMG_ID p(2)    O_BAXIS1 p(3)  
;	   O_BAXIS2 p(4)  O_FAXIS1 p(5)   O_FAXIS2 p(6)      BAXIS1 p(21)
;	     BAXIS2 p(22)   FAXIS1 p(23)  FAXIS2   p(24)     SZIMG1 p(25)
;	     SZIMG2 p(26)  CAMGAIN p(27)  ZEROLEV  p(28)    SPEED  (p(29))
;	    BITPIX  p(46)
;          (SIMPLE will always be set 'T'; NAXIS = {0,1,2} depending on
;	    naxis1,2 > 0); BITPIX = 16 if p(46) "not set".);
;	   If p(10:16), p(19:20), or p(30:45) contain values other than -9,
;	   these will be written on "blank" -labeled comment cards in the form:
;	          %PAR:ii nnnn %PAR:ii nnn ...
;          where <nnnn> = p(<ii>).
;	naxis1,2 : size of image-array (may be larger than format of 
;	           "true image"); naxis2=0 if image-array 1-dim.
;	   
; OUTPUTS:
;	header: (string-array size 80,n) Header for FITS-file
;	        with <n> "card images"; 1st "card": "SIMPLE ...", 
;		last "card": "END".
; SIDE EFFECTS:
;	none
; RESTRICTIONS:
;	none
; PROCEDURE:
;	straight
; MODIFICATION HISTORY:
;	nlte, 1992-Apr-30
;	nlte, 1992-Sep-22: truncation of text strings and/or string following
;			   '/' if necessary.  
;-
on_error,1
if n_params() ne 5 then message,'USAGE: hdr = MKFITSHDR (proj,txt,par,szx,szy)'
sz=size(proj) & if sz(0) ne 0 or sz(1) ne 7 or sz(2) ne 1 then message,$
                   '1st argument must be a string'
lproj=strlen(proj) gt 0
;
sz=size(txt) & if sz(0) ne 0 or sz(1) ne 7 or sz(2) ne 1 then message,$
                   '2nd argument must be a string'
ltxt=strlen(txt) gt 0
sz=size(par) & if sz(0) ne 1 or sz(1) ne 50 or sz(2) ne 2 then message,$
                   '3rd argument must be intarr size 50'
;
lform='(a,T9,"= ",T30,a1,"/ ",a,T80," ")'
iform='(a,T9,"= ",i20,"/ ",a,T80," ")'
cform='(a,T9,"= ",a,"/ ",a,T80," ")'
ccform='(a,T9,a,T80," ")'
;
hdr=string('SIMPLE','T',' ',form=lform)
if par(46) gt 0 then hdr=[hdr,string('BITPIX',par(46),' ',form=iform)] else $
                     hdr=[hdr,string('BITPIX',16,'(guessed)',form=iform)]
naxis=(naxis1 gt 0) + (naxis2 gt 0)
hdr=[hdr,string('NAXIS',naxis,' ',form=iform)]
if naxis gt 0 then hdr=$
              [hdr,string('NAXIS1',naxis1,'actual x-axis length',form=iform)]
if naxis gt 1 then hdr=$
              [hdr,string('NAXIS2',naxis2,'actual y-axis length',form=iform)]
if naxis gt 0 then hdr=$
        [hdr,string('FAXIS1',(par(23)>0),'actual start_x CCD-pix',form=iform)]
if naxis gt 1 then hdr=$
        [hdr,string('FAXIS2',(par(24)>0),'actual start_y CCD-pix',form=iform)]
if naxis gt 0 then hdr=$
        [hdr,string('BAXIS1',(par(21)>1),'actual x-axis binning',form=iform)]
if naxis gt 1 then hdr=$
        [hdr,string('BAXIS2',(par(22)>1),'actual y-axis binning',form=iform)]
if naxis gt 0 then hdr=$
          [hdr,string('SZIMG1',par(25),'size_x true image',form=iform)]
if naxis gt 1 then hdr=$
          [hdr,string('SZIMG2',par(26),'size_y true image',form=iform)]
if naxis gt 0 then hdr=$
      [hdr,string('O_FAXIS1',(par(5)>0),'original x-axis offset',form=iform)]
if naxis gt 1 then hdr=$
      [hdr,string('O_FAXIS2',(par(6)>0),'original y-axis offset',form=iform)]
if naxis gt 0 then hdr=$
     [hdr,string('O_BAXIS1',(par(3)>1),'original x-axis binning',form=iform)]
if naxis gt 1 then hdr=$
     [hdr,string('O_BAXIS2',(par(4)>1),'original y-axis binning',form=iform)]
if lproj then begin
   i=strpos(proj,'%DATE-OBS')
   if i ge 0 then begin
      j=strpos(proj,'^',i) & lz=j-i-10 < 65 & z="'"+strmid(proj,i+10,lz)+"'"
      lz=lz+2 & while lz lt 10 do begin z=z+' ' & lz=lz+1 & endwhile
      hdr=[hdr,string('DATE-OBS',z,' ',form=cform)]
   endif
endif
if ltxt then begin
   i=strpos(txt,'%TIME-BEG')
   if i ge 0 then begin
      z="'"+strmid(txt,i+10,12)+"'"
      hdr=[hdr,string('TIME-BEG',z,'exposure',form=cform)]
   endif
   i=strpos(txt,'%TIME-END')
   if i ge 0 then begin
      z="'"+strmid(txt,i+10,12)+"'"
      hdr=[hdr,string('TIME-END',z,'exposure',form=cform)]
   endif
endif
if par(27) gt -1 then hdr=[hdr,string('CAMGAIN',par(27),' ',form=iform)]
if par(28) gt -1 then hdr=[hdr,string('ZEROLEV',par(28),' ',form=iform)]
if par(29) gt 0 then begin
   case par(29) of
        1 : z='SLOW'
	2 : z='FAST'
     else : z=string(par(29),form='(i0)')
   endcase
   z="'"+z+"'"
   lz=strlen(z) & while lz lt 10 do begin z=z+' ' & lz=lz+1 & endwhile
   hdr=[hdr,string('SPEED',z,' ',form=cform)]
endif
if ltxt then begin
   i=strpos(txt,'%OBJECT') 
   if i ge 0 then begin
      i1=i+8
      j=strpos(txt,'$^',i) & k=strpos(txt,'^',i)
      if j lt 1 and k gt 0 then j=k
      if k lt 1 or k gt j then k=j
      while k le j and i1 lt j do begin
            z="= '"+strmid(txt,i1,k-i1<69)+"'"
            hdr=[hdr,string('OBJECT',z,form=ccform)]
	    i1=k+1 & k=strpos(txt,'^',i1) & if k lt 1 or k gt j then k=j
      endwhile
   endif
endif
if lproj then begin
   i=strpos(proj,'%OBSERVER')
   if i ge 0 then begin
      j=strpos(proj,'^',i) & lz=j-i-10<65 & z="'"+strmid(proj,i+10,lz)+"'"
      lz=lz+2 & while lz lt 10 do begin z=z+' ' & lz=lz+1 & endwhile
      hdr=[hdr,string('OBSERVER',z,' ',form=cform)]
   endif
   i=strpos(proj,'%TELESCOP')
   if i ge 0 then begin
      j=strpos(proj,'^',i) & lz=j-i-10<65 & z="'"+strmid(proj,i+10,lz)+"'"
      lz=lz+2 & while lz lt 10 do begin z=z+' ' & lz=lz+1 & endwhile
      hdr=[hdr,string('TELESCOP',z,' ',form=cform)]
   endif
   i=strpos(proj,'%ORIGIN')
   if i ge 0 then begin
      j=strpos(proj,'^',i) & lz=j-i-8<65 & z="'"+strmid(proj,i+8,lz)+"'"
      lz=lz+2 & while lz lt 10 do begin z=z+' ' & lz=lz+1 & endwhile
     if lz le 51 then zc=strmid('Tape writing institution',0,86-lz) else zc=' '
      hdr=[hdr,string('ORIGIN',z,zc,form=cform)]
   endif
   i=strpos(proj,'%INSTRUME')
   if i ge 0 then begin
      j=strpos(proj,'^',i) & lz=j-i-10<65 & z="'"+strmid(proj,i+10,lz)+"'"
      lz=lz+2 & while lz lt 10 do begin z=z+' ' & lz=lz+1 & endwhile
    if lz le 48 then zc=strmid('data aquisition instument',0,68-lz) else zc=' '
      hdr=[hdr,string('INSTRUME',z,zc,form=cform)]
   endif
   i=strpos(proj,'%G ') 
   while i ge 0 do begin
     j=strpos(proj,'^',i) & k=strpos(proj,'%',i+1)<j & if k lt 0 then k=j
     z=strmid(proj,i+3,k-i-3<69)
     hdr=[hdr,string('COMMENT1 ',z,form=ccform)]
     i=strpos(proj,'%G ',k)
   endwhile  
endif
if ltxt then begin
   i=strpos(txt,'%FILENAME')
   if i ge 0 then begin
      j=strpos(txt,'^',i) & k=strpos(txt,' ;/',i)<j & if k lt 0 then k=j 
      lz=k-i-10<65 & z="'"+strmid(txt,i+10,lz)+"'"
      lz=lz+2 & while lz lt 10 do begin z=z+' ' & lz=lz+1 & endwhile
      if lz le 52 then zc='on original tape' else zc=' ' 
      hdr=[hdr,string('FILENAME',z,zc,form=cform)]
   endif
   i=strpos(txt,'%C ')
   while i ge 0 do begin
     j=strpos(txt,'^',i) & k=strpos(txt,'%',i+1)<j & if k lt 0 then k=j
     z=strmid(txt,i+3,k-i-3<69)
     hdr=[hdr,string('COMMENT',z,form=ccform)]
     i=strpos(txt,'%C ',k)
   endwhile
   i=strpos(txt,'%DATE ')
   if i ge 0 then begin
      j=strpos(txt,'^',i) & lz=j-i-6<65 & z="'"+strmid(txt,i+6,lz)+"'"
      lz=lz+2 & while lz lt 10 do begin z=z+' ' & lz=lz+1 & endwhile
      if lz le 60 then zc=strmid('last modification',0,68-lz) else zc=' '
      hdr=[hdr,string('DATE',z,zc,form=cform)]
   endif   
   i=strpos(txt,'%H ')
   while i ge 0 do begin
     j=strpos(txt,'^',i) & k=strpos(txt,'%',i+1)<j & if k lt 0 then k=j
     z=strmid(txt,i+3,k-i-3<69)
     hdr=[hdr,string('HISTORY',z,form=ccform)]
     i=strpos(txt,'%H ',k)
   endwhile
endif
if par(2) gt -1 then hdr=[hdr,string('IMG_ID',par(2),' ',form=iform)]
if par(0) gt 0 then  begin
   case par(0) of
        1 : z='dark-field'
	2 : z='flat-field'
	3 : z='image'
     else : z='special'
   endcase
   hdr=[hdr,string('IMG_TYPE',par(0),z,form=iform)]
endif
if par(1) gt -1 then  begin
   case par(1) of
        0 : z='raw data'
	1 : z='dark subtracted'
	2 : z='flat-field divided'
	3 : z='cleaned'
     else : z='special'
   endcase
   hdr=[hdr,string('IMG_REDU',par(1),z,form=iform)]
endif
;
; other values from par ("user free") if not -9:
ii=[10,11,12,13,14,15,16,19,20,30+indgen(16)] ; only those
z=''
for i=0,n_elements(ii)-1 do begin
  if par(ii(i)) ne -9 then begin
     z=z+string(ii(i),par(ii(i)),form='(" %PAR:",i2,1x,i0)')
     if strlen(z) gt 57 then begin
        hdr=[hdr,string('        ',z,form=ccform)] & z='' & endif 
  endif
endfor
if z ne '' then hdr=[hdr,string('        ',z,form=ccform)]
;
hdr=[hdr,string('END',' ',form=ccform)]
;
return,hdr
end
