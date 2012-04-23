;+
; NAME:         PNM_READ
; PURPOSE:
;       Read images in one of the pnm (Portable Anymap) formats :
;       pbm = Portable Bitmap
;       pgm = Portable Greymap (8 bit greyscale image)
;       ppm = Portable Pixmap (3x8 bit color image)
; CATEGORY:
;       Input/output.
; CALLING SEQUENCE:
;       PNM_READ ,Filename,Data
;       PNM_READ ,Filename,Red,Green,Blue
; INPUTS:
;       Filename = string containing the name of file to read.
; KEYWORD PARAMETERS:
;       /verbose : If set, comment lines from the file header,
;                  and a short information message are printed.
;       /jpeg    : If set, the file is assumed to be in JFIF/JPEG format
;                  It will be uncompressed via the djpeg command.
;       /gif     : If set, the file is assumed to be in GIF format
;                  It will be uncompressed via the giftoppm command.
; OUTPUTS:
;       Data = array containing the image data.
;               pbm : bytarr(nx,ny) , values 0 or 1
;               pgm : bytarr(nx,ny)
;               ppm : bytarr(nx,ny,3)
;       If 3 parameters Red,Green,Blue are given to read in a ppm-file :
;               Red   = bytarr(nx,ny)
;               Green = bytarr(nx,ny)
;               Blue  = bytarr(nx,ny)
; COMMON BLOCKS:
;       None.
; SIDE EFFECTS:
;       A file is read. Eventually a message is printed on the screen.
; RESTRICTIONS:
;       Only the RAWBITS-variants of the pnm formats are supported.
; SEE ALSO:
;       PGM_WRITE , PPM_WRITE 
;
; MODIFICATION HISTORY:
;       Written, A. Welz, Univ. Wuerzburg, Germany, Jan. 1992
;       Modified to allow comments in the header: A.W., Nov. 1992
;       Keywords /jpeg and /gif added: A.W., Jan. 1993
;-

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; file definitions for PBM,PGM,PPM (from the corresponding man-pages)
;
; PBM:
;    - A "magic number" for identifying the  file  type.   A  pbm
;      file's magic number is the two characters "P4".
;    - Whitespace (blanks, TABs, CRs, LFs).
;    - A width, formatted as ASCII characters in decimal.
;    - Whitespace.
;    - A height, again in ASCII decimal.
;    - A single  character  of  whitespace  (typically a newline).
;    - Image data:
;       Width * height bits, starting  at the  top-left  corner of
;       the bitmap, proceeding in normal English reading order.
;       The bits are stored eight per byte, high bit first low bit
;       last.
;    - Characters from a "#" to the next end-of-line are  ignored
;      (comments).
;
; PGM:
;    - A "magic number" for identifying the  file  type.   A  pgm
;      file's magic number is the two characters "P5".
;    - Whitespace (blanks, TABs, CRs, LFs).
;    - A width, formatted as ASCII characters in decimal.
;    - Whitespace.
;    - A height, again in ASCII decimal.
;    - Whitespace.
;    - The maximum gray value, again in ASCII decimal.
;    - A single  character  of  whitespace  (typically a newline).
;    - Image data:
;       Width * height   gray   values,  stored  as  plain  bytes,
;       between 0 and the specified maximum value, starting at the
;       top-left  corner of  the  graymap,  proceeding  in  normal
;       English  reading order.  A value of 0 means black, and the
;       maximum value means white.
;    - Characters from a "#" to the next end-of-line are  ignored
;      (comments).
;
; PPM:
;    - A "magic number" for identifying the  file  type.   A  ppm
;      file's magic number is the two characters "P6".
;    - Whitespace (blanks, TABs, CRs, LFs).
;    - A width, formatted as ASCII characters in decimal.
;    - Whitespace.
;    - A height, again in ASCII decimal.
;    - Whitespace.
;    - The maximum color-component value, again in ASCII decimal.
;    - A single  character  of  whitespace  (typically a newline).
;    - Image data:
;       Width * height pixels,  each  three stored as plain  bytes
;       between 0 and the specified maximum value, starting at the
;       top-left  corner  of  the  pixmap,  proceeding  in  normal
;       English  reading  order.   The three values for each pixel
;       represent red, green, and blue, respectively; a value of 0
;       means  that color is off, and the maximum value means that
;       color is maxxed out.
;    - Characters from a "#" to the next end-of-line are  ignored
;      (comments).
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

pro pnm_read,file,data,grn,blu,verbose=verbose,jpg=jpg,jpeg=jpeg,gif=gif
on_error,2

data = 0b
grn  = 0b
blu  = 0b
if n_params() ne 2 and n_params() ne 4 then begin
     print,"% PNM_READ: wrong number of parameters."
     print,"% use  pnm_read,'filename',data"
     print,"%  or  pnm_read,'filename',red,green,blue"
     return
endif

if keyword_set(jpg) or keyword_set(jpeg) then conv='djpeg '+file
if keyword_set(gif) then conv='giftoppm '+file
conversion=keyword_set(jpg) or keyword_set(jpeg) or keyword_set(gif)

if conversion then begin
   spawn,/sh,'f=/var/tmp/$USER$$_idl.pnm;echo $f;'+conv+' > $f',file
   file=file(0)
endif

; read the whole file into a byte array
on_ioerror,ioerr
openr,unit,/get_lun,file
stat=fstat(unit)
size=stat.size>1l
data=bytarr(size)

on_ioerror,ioerrf
readu,unit,data
free_lun,unit
if conversion then begin
   spawn,/sh,'rm -f '+file
endif

; extract the identifier (Magic number)
if data(2) gt 32 then len=3 else len=2
magic=string(data(0:len-1))

; find out, how many numbers the header is expected to contain.
CASE magic OF
'P4': nnum=2
'P5': nnum=3
'P6': nnum=3
ELSE: begin
      print,'% PNM_READ: Unknown magic number '+magic
      print,'%  no data read.'
      return
      end
ENDCASE


; extract header information

num=strarr(nnum)
i=1l
FOR n=0,nnum-1 DO BEGIN          ; get nnum numbers in ascii format
   flag=0
   REPEAT BEGIN            ; skip over whitespace and comments
      i=i+1
      IF data(i) EQ 35 THEN BEGIN           ; skip a comment line
         j=i
         REPEAT i=i+1 UNTIL (data(i) EQ 10) OR data(i) EQ 13
         if keyword_set(verbose) then print,string(data(j:i-1))
      ENDIF
   ENDREP UNTIL (data(i) GT 32)
   j=i
   REPEAT i=i+1 UNTIL data(i) LE 32       ; find end of number
   num(n)=string(data(j:i-1))
ENDFOR
i=i+1  ;skip the final CR
; now i points to the begin of image data

nx=long(num(0))
ny=long(num(1))
IF nnum eq 3 THEN maxval=long(num(2)) ELSE maxval=1



; put image data into the right form

CASE magic OF
'P4': begin                     ;pbm bitmap in RAWBITS format.
        bt=transpose( rebin(bindgen(256),256,8) )
        tb=rebin(byte([128,64,32,16,8,4,2,1]),8,256)
        bb=([0b,1b])((bt and tb) ge 1b)
        nxx=fix(nx/8.+.9375)
        data=data(i:i+nxx*ny-1)
        data=rotate( ( reform(bb(*,data),8*nxx,ny) )(0:nx-1,*) ,7)
        if keyword_set(verbose) then begin
           nxny='     '+strcompress(nx,/rem)+'x'+strcompress(ny,/rem)
           print,nxny,' Bitmap (PBM) read from file  ',file
        endif
        end
'P5': begin                     ;pgm greyscale image in RAWBITS format.
        data=rotate( reform( data(i:i+nx*ny-1) ,nx,ny) ,7)
        if keyword_set(verbose) then begin
           nxny='     '+strcompress(nx,/rem)+'x'+strcompress(ny,/rem)
           print,nxny,' Greyscale image (PGM) read from file  ',file
        endif
        end
'P6': begin                     ;ppm color image in RAWBITS format.
        data=reform( data(i:i+3*nx*ny-1) ,3,nx,ny)
        red =rotate(reform(data(0,*,*)),7)
        grn =rotate(reform(data(1,*,*)),7)
        blu =rotate(reform(data(2,*,*)),7)
        if n_params() eq 4 then begin
           data=red
           red=0b
        endif else begin
           data=reform([[[red]],[[grn]],[[blu]]],nx,ny,3)
           red=0b
           grn=0b
           blu=0b
        endelse
        if keyword_set(verbose) then begin
           nxny='     '+strcompress(nx,/rem)+'x'+strcompress(ny,/rem)
           print,nxny,'x3 Color image (PPM) read from file  ',file
        endif
        end
ELSE: begin
         print,'% PNM_READ: Unknown magic number '+magic
         print,'%  no data read.'
         end
ENDCASE

return

ioerrf: free_lun,unit
ioerr: ; print,!err_string
  print,'% PNM_READ: cannot open or read file ',file
  print,'%  no data read.'
  return

end
