PRO fits_hdr,unit,dateobs,time,datemod,proj,txt,file,id,itime,expos,par,$
         nx,ny,nrecs
;+
; NAME:
;	FITS_HDR
; PURPOSE:
;	Reads header of a FITS file from disk; extracts parameters & comments
;*CATEGORY:            @CAT-# 11  2@
;	FITS-Files , CCD Tools
; CALLING SEQUENCE:
;	FITS_HDR,unit,dateobs,time,datemodif,project,expos_comments, ...
;	      ... filename,image_id,itime,expos,parameters,naxis1,naxis2,nrecs
; INPUTS:
;	unit:    (integer) unit-number of opened FITS-file
; OUTPUTS:
;	dateobs: (string) date of observation (FITS-label DATE-OBS);
;	time   : (string) time of exposure start (FITS-label TIME-BEG)
;	         form: hh:mm.ss with ss rounded)
;	datemodif: (string) date & time of last modification of image data
;		 (FITS-label "DATE")
;       project: (string) Comments common to a series of images; obtained
;		 from FITS-labels "COMMENT1" (abbrev.: "%G"), "OBSERVER", 
;		 "ORIGIN", "INSTRUME", "TELESCOP", "DATE-OBS"
;		 The contents of these FITS-"card images" will concatenated 
;		 after removal of superfluous blanks and enclosed by % ^ .
;       expos_comments: (string) Comments specific to this image; obtained
;		 from FITS-labels "COMMENT" (abbrev.: "%C"), "OBJECT", 
;		 "        " (-> "%C"), "HISTORY" (abbrev.: "%H"), 
;		 "TIME-BEG", "TIME-END", "FILENAME", "DATE" (of last data 
;		 modification); 
;	filename: (string) name of FITS-File as obtained from FITS-label 
;	         "FILENAME" 
;       image_id: (short integer) "image-identification-no." obtained from
;		  FITS-label "IMG_ID"; if no such label but 
;		  "FILENAME XXXXnnnn.xxx", image_id = max. 4 digitsleft of dot 
;       itime  : (long integer) start time of exposure, seconds since midnight
;	         calculated from FITS-label "TIME-BEG" (rounded).
;	expos  : (floating) exposure time (seconds, not rounded) calculated 
;	         from FITS-labels "TIME-BEG", "TIME-END".
;	naxis1,2 : Size of image-array (may be larger than format of "true"
;		   image data); from FITS-labels "NAXIS1", "NAXIS2".
;	parameters: (short integer array size 50) numeric parameters:
;	         (0) IMG_TYPE; (1) IMG_REDU; (2) IMG_ID; 
;		 (3) O_BAXIS1; (4) O_BAXIS2; (5) O_FAXIS1; (6) O_FAXIS2
;		     (binning, off-sets done by CCD-AT-program);
;		 (7:8) co-ordinates (orig. CCD-pix) of "upper-right" corner
;		       of "true image" (calculated from other parameters);
;		 (9) <expos>*1000 (rounded);
;		 (10:14) "%PAR:ii nnn" on "blank-comment" (unspecified para-
;		          meters as set by user);
;		 (15) number of "print lines" in string project (e-o-l indi-
;		      cated by ^);
;		 (16) ditto for string expos_comments;
;		 (17) set = 1 (indicating parameters(9) expressed in msec);
;		 (18) "Tape-file-#" <nnnn> obtained from "FILENAME" (4 digits 
;		       left of dot : XXXXnnnn.xxx );
;		 (19:20) same rule as for (10:14) (may be : "loop-Id, -count");
;		 (21) BAXIS1; (22) BAXIS2 (actual binning); 
;		 (23) FAXIS1; (24) FAXIS2 : co-ordinates (orig. CCD-pix) of
;		       "lower-left" corner of actual image relat. to CCD-
;		       offset-point;
;		 (25) NAXIS1; (26) NAXIS2 (size of "true image" after binning);
;		 (27) CAMGAIN; (28) ZEROLEV;
;		 (29) SPEED (1='SLOW', 2='FAST', 0= else);
;		 (30:45) same rule as for (10:14);
;		 (46) BITPIX; 
;		 (47:49) <hh>, <mm>, <ss> (rounded) from "TIME-BEG".
;		 parameters not found will be set to -9 .
;       nrecs  : number of FITS-header records (a 2880 bytes) read in.
; COMMON BLOCKS:
;	none
; SIDE EFFECTS:
;	
; RESTRICTIONS:
;	FITS-File must be opened (OPENR) by calling program.
; PROCEDURE:
;	Associated read of one or more 2880-byte records; the FITS-file
;	may or may not be byte-swapped; this procedure will do internal 
;	swapping if 1st "image card" begins with "ISPMEL" instead of "SIMPLE". 
; MODIFICATION HISTORY:
;	nlte, 1992-05-05 
;       nlte, 1992-07-08  file, file_id from FILENAME
;       nlte, 1992-08-18  bug error message (nrec -> nrecs)
;-
on_error,1
if n_params() ne 14 then message, $
'USAGE: FITS_HDR,unit,date,time,datemodif,proj,txt,file,id,itime,expos,par,naxis1,naxis2,nrecs' 
;
naxis=-9 & naxis1=-9 & naxis2=-9 & nx=-9 & ny=-9 & xoff=-9 & yoff=-9
xofforig=-9 & yofforig=-9 & nximg=-9 & nyimg=-9 & binxorig=-9 & binyorig=-9 
binx=-9 & biny=-9 & tbeg='' & tend='' & gain=-9 & bzero=-9 & id=-9 & imgtyp=-9 
imgred=-9 & dateobs='' & datemod='' & speed='' & filenam='' & chist=''
cobj='' & comm1='' & comm2=''
;
nrecs=-1
h=assoc(unit,bytarr(2880))
;
nexthdr: 
nrecs=nrecs+1
hdrbyt=h(nrecs)
if nrecs eq 0 then begin
;check header starts according to FITS-rules (may be after byte-swapping):
   v=where(hdrbyt(0:5) eq [83b,73b,77b,80b,76b,69b],nv)
;                           S   I   M   P   L   E
   flagbs=0
   if nv ne 6 then begin
      v=where(hdrbyt(0:5) eq [73b,83b,80b,77b,69b,76b],nv)
;                              I   S   P   M   E   L
      if nv eq 6 then flagbs=1 else begin
         if nrecs eq 1 then print,'1st record of input-file not FITS'
         id=-999 & return
      endelse
   endif
endif
if flagbs then byteorder,hdrbyt
hdrbyt=hdrbyt>32b
;
i=0 & iend=0
while i lt 2880 and not iend do begin
      c=string(hdrbyt(i:i+79)) & flag=strupcase(string(hdrbyt(i:i+7)))
      j1=strpos(c,"'",10) & j2=-1 & if j1 gt 0 then j2=strpos(c,"'",j1+1)
      if j1 lt 0 then j1=10 else j1=j1+1
      if j2 lt 0 then begin
         i2=strpos(c,'/',j1) & if i2 lt 0 then i2=80 & j2=i2 & endif
      cc=strtrim(strcompress(strmid(c,j1,j2-j1)),2)
;      print,'flag=',flag,' j1,j2=',j1,j2,' cc=',cc
;      print,'ok?' & yn='' & read,yn & if yn ne 'y' then return 
      case flag of
      'SIMPLE  ' : simp=strcompress(cc,/remove_all)
      'BITPIX  ' : nbits=fix(cc)
      'NAXIS   ' : naxis=fix(cc)
      'NAXIS1  ' : nx=fix(cc)     ; actual size of image-array (x)
      'NAXIS2  ' : ny=fix(cc)     ; actual size of image-array (y)
      'SZIMG1  ' : nximg=fix(cc)  ; size "true (& binned) image" (x)
      'SZIMG2  ' : nyimg=fix(cc)  ; size "true (& binned) image" (y)
      'FAXIS1  ' : xoff=fix(cc)   ; actual value x-offset
      'FAXIS2  ' : yoff=fix(cc)   ; actual value y-offset
      'O_FAXIS1' : xofforig=fix(cc) ; original value x-offset
      'O_FAXIS2' : yofforig=fix(cc) ; original value y-offset
      'BAXIS1  ' : binx=fix(cc)   ; actual value x-binning
      'BAXIS2  ' : biny=fix(cc)   ; actual value y-binning
      'O_BAXIS1' : binxorig=fix(cc) ; original value x-binning
      'O_BAXIS2' : binyorig=fix(cc) ; original value y-binning
      'TIME-BEG' : tbeg=strcompress(cc,/remove_all)
      'TIME-END' : tend=strcompress(cc,/remove_all)
      'CAMGAIN ' : gain=fix(cc)
      'ZEROLEV ' : bzero=fix(cc)
      'DATE-OBS' : dateobs=strcompress(cc,/remove_all)
      'DATE    ' : datemod=cc
      'SPEED   ' : speed=strcompress(cc,/remove_all)
      'FILENAME' : filenam=strcompress(cc,/remove_all)
      'COMMENT1' : comm1=comm1+'%G '+strtrim(strcompress(strmid(c,8,72)),2)+'^'
      'ORIGIN  ' : comm1=comm1+'%ORIGIN '+cc+'^'
      'INSTRUME' : comm1=comm1+'%INSTRUME '+cc+'^'
      'TELESCOP' : comm1=comm1+'%TELESCOP '+cc+'^'
      'OBSERVER' : comm1=comm1+'%OBSERVER '+cc+'^'
      'HISTORY ' : chist=chist+'%H '+strtrim(strcompress(strmid(c,8,72)),2)+'^'
      'IMG_ID  ' : id=fix(cc)       ; "Image-Identification #"
      'IMG_TYPE' : imgtyp=fix(cc)   ; 1='dark', 2='flat', 3='image' 
      'IMG_REDU' : imgred=fix(cc)   ; 0='raw', 1='-dark', 2='/ff', 3='cleaned'
      'END     ' : iend=1
      else       : begin 
		     if strlen(strtrim(c,2)) gt 0 then begin
        case strmid(flag,0,7) of
        '       ': comm2=comm2+'%C '+strtrim(strcompress(strmid(c,8,72)),2)+'^'
        'COMMENT': comm2=comm2+'%C '+strtrim(strcompress(strmid(c,8,72)),2)+'^'
	'OBJECT ': cobj=cobj+cc+'^'
	else	   : comm2=comm2+'%'+strtrim(strcompress(c),2)+'^'
	endcase
                     endif
                   end
      endcase
      i=i+80 & endwhile
if not iend then goto,nexthdr
nrecs=nrecs+1  ; = number of header records read
;
if strupcase(simp) ne 'T' then print,$
   '%FITS_HDR (Warning): SIMPLE = '+simp+' (not "T")'
if nbits ne 16 then print,$
   '%FITS_HDR (Warning): BITPIX = '+string(nbits,form='(i0)')+' (not 16)'
;
binx= binx > 1 & biny= biny > 1 & xoff= xoff > 0 & yoff= yoff > 0
if nximg lt 0 then begin ; data file "original"
   nximg=nx & nyimg=ny
   binxorig=binx & binyorig=biny
   xofforig=xoff & yofforig=yoff & xoff=0 & yoff=0
endif
;
proj='' & txt='' & par=intarr(50)-9
if strlen(comm1) gt 0 then proj=comm1
proj=proj+'%DATE-OBS '+dateobs+'^'
;
itg=0 & i=0 
while i ne -1 do begin 
    i=strpos(proj,'^',i) & if i ne -1 then begin itg=itg+1 & i=i+1 & endif
endwhile ; (i now number of "print lines" in proj)
;
i=strlen(cobj) 
if i gt 0 then txt='%OBJECT '+strmid(cobj,0,i-1)+' $^'
;
if strlen(comm2) gt 0 then begin
;  search for & interprete %PAR:
   ip=strpos(comm2,'%PAR:') & ic2=strlen(comm2)-1
   while ip ge 0 and ip lt ic2 do begin
         j=fix(strmid(comm2,ip+5,2)) 
	 jp1=strpos(comm2,'%',ip+5) & jp2=strpos(comm2,'^',ip+5)
	 if jp1 lt 0 then jp1=ic2+2 & if jp2 lt 0 then jp2=ic2+2
	 jp1=min([jp1-1,jp2-1,ic2])
	 if (j ge 10 and j le 14) or (j ge 19 and j le 20) or $
            (j ge 30 and j le 45) then begin
            par(j)=fix(strmid(comm2,ip+7,jp1-ip-6))
	    comm2=strmid(comm2,0,ip)+strmid(comm2,jp1+1,ic2+1)
	    ic2=strlen(comm2)-1 & ip=ip-1
         endif
	 ip=strpos(comm2,'%PAR:',ip+1)
   endwhile
endif
if strlen(strtrim(comm2,2)) gt 0 then begin
;  remove empty comments
   i=strpos(comm2,'%C') & ic2=strlen(comm2)
   while i ge 0 and i lt ic2 do begin
         j=strpos(comm2,'^',i) 
	 if j gt 0 and strcompress(strmid(comm2,i,j-i),/rem) eq '%C' then $
	    comm2=strmid(comm2,0,i)+strmid(comm2,j+1,ic2-j) else i=i+1
	 i=strpos(comm2,'%C',i) & ic2=strlen(comm2)
   endwhile
endif
if strlen(strtrim(comm2,2)) gt 0 then txt=txt+comm2
txt=txt+'%TIME-BEG '+tbeg+' %TIME-END '+tend+' ;/ (exposure)^'
;
idfnam=-9
if strlen(filenam) gt 0 then begin
   txt=txt+'%FILENAME '+filenam+' ;/ (orig ExaB-tape)^'
   j=strpos(filenam,':')
   if strmid(filenam,j+1,1) eq '\' then j=j+2 else j=j+1
   file=mkfilnam(strmid(filenam,j,strlen(filenam)-j))
;  search for last dot in filenam:
   j3=strpos(filenam,'.',j) & j2=strlen(filenam)
   while j3 ge 0 do begin j2=j3 & j3=strpos(filenam,'.',j2+1) & endwhile
;  j2 = pos. of last dot or of last char +1
;  1-4 digits left of last dot or at end of filnam  for "tape-file number": 
   j1=j2 & bf=byte(filenam)
   for i=j2-1,(j2-4)>0,-1 do begin
       if bf(i) ge 48 and bf(i) le 57 then j1=i else goto,jmpfid
   endfor
jmpfid: if j1 lt j2 then idfnam=fix(strmid(filenam,j1,j2-j1)) else idfnam=-9
endif else file=''
if strlen(datemod) gt 0 then txt=txt+'last_modif : %DATE '+datemod+'^'
if strlen(chist) gt 0 then txt=txt+'Processing history: ^'+chist
;
it=itg & i=0
while i ne -1 do begin 
    i=strpos(txt,'^',i) & if i ne -1 then begin it=it+1 & i=i+1 & endif
endwhile ; (i now number of "print lines" in txt)
;
par(46)=nbits
; exposure time assumed format: hh*mm*ss*ddd  (* any char)
par(47)=fix(strmid(tbeg,0,2))
par(48)=fix(strmid(tbeg,3,2))
par(49)=fix(strmid(tbeg,6,2))
itime0=long(par(47))*3600L+long(par(48))*60L+long(par(49))
xt1=double(strmid(tbeg,9,3))*1.d-3 ; decimal fraction of seconds
if xt1 lt 5.d-1 then itime=itime0 else begin ; seconds since midnight (integer)
                     itime=itime0+1 & par(49)=par(49)+1 & endelse
xt1=xt1+double(itime0)
xt2=double(strmid(tend,0,2))*3.6d3 +double(strmid(tend,3,2))*6.d1 $
    +double(strmid(tend,6,2)) +double(strmid(tend,9,3))*1.d-3
expos=float(xt2-xt1)  ; exposure time sec
time=string(par(47),par(48),par(49),form='(i2.2,":",i2.2,".",i2.2)')
;   = start of exposure time (string) without decimal fraction of seconds
if datemod eq '' then datemod=dateobs+' '+time
;
if id lt 0 then id=idfnam  ; take Image-ID from "Filename" if no lable IMG_ID
par(0)=imgtyp & par(1)=imgred
if id ge 0 then par(2)=id else par(2)=idfnam  ; image-ID from "IMG_ID" or
;						from "FILENAM"
par(18)=idfnam ; tape-file-# = <nnnn> of "FILENAME" if = XXXXnnnn.xxx
par(3)=binxorig & par(4)=binyorig
par(5)=xofforig & par(6)=yofforig  ; CCD offset x,y
par(7)=nximg*binx-1 & par(8)=nyimg*biny-1 ; "true image": CCD-pix coord. upp/ri
par(23)=xoff & par(24)=yoff ; "true image": CCD-pix coord. low/left
par(9)=fix(expos*1000+0.5) & par(17)=1
;par(15)=itg & par(16)=it
par(21)=binx & par(22)=biny
par(25)=nximg & par(26)=nyimg  ; actual size "true image" 
;	                         (after scissoring/binning)
par(27)=gain & par(28)=bzero
case strupcase(speed) of
  'SLOW' : par(29)=1
  'FAST' : par(29)=2
  else   : par(29)=0
endcase
;
end

