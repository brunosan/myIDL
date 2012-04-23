pro wfits,data,filnam,index=fnum,key_struct=hstruc,outheader=ohd0, $
                      date_obs=date,time_obs=time,history=his,comment=com
;+
; NAME:
;        WFITS
; PURPOSE:
;        Writes an array into a standard FITS file on the disk.
; CATEGORY:
;        Input/Output
; CALLING SEQUENCE:
;        wfits, array, filename
; INPUTS:
;        array = data array (byte, integer, long, float, or double).
;        filename = string containing the file name.
; OPTIONAL (KEYWORD) INPUT PARAMETERS:
;        index = nonnegative integer. If this parameter is present, a period
;            and the index number are appended to the filename (e.g., '.34').
;            This option makes handling of data in the MCCD file naming
;            convention easier.
;        key_struct = structure of optional FITS keyword parameters.
;                     The tag names are used as the keyword.
;                     A particular keyword (if type logical=byte, string,
;                     or float) is only written if its value is not equal
;                     to some default (255b, '', 1e-44, or 1.000001).
;                     A keyword value in the structure takes precedence to
;                     the value of the same keyword in the outheader array.
;        outheader = string vector, containing a full FITS header, or
;                    additional keywords to be included in the output header.
; The following keywords only exist for compatibility with older versions:
;        date_obs = string. A FITS keyword parameter "DATE-OBS= 'string'" is
;                   added to the header.
;        time_obs = string. A FITS keyword parameter "TIME-OBS= 'string'" is
;                   added to the header.
;        history = string. A FITS keyword parameter "HISTORY string" is added
;                  to the header.
;        comment = string. A FITS keyword parameter "COMMENT string" is added
;                  to the header.
; OUTPUTS:
;        No explicit outputs.
; COMMON BLOCKS:
;        None.
; SIDE EFFECTS:
;        A file is created, or overwritten.
; RESTRICTIONS:
;        The data array is not scaled (e.g., according to BSCALE and BZERO)
;        before output.
;        Complex type keywords are not allowed.
; MODIFICATION HISTORY:
;        JPW, Nov, 1989.
;        JPW, Nov, 1991:  added floating point type, header structure,
;                         arbitrary output header
;
;	procedure:  wfits
;
;	purpose:  write an array into a standard FITS file
;
;	author:  JPW, 11/89	(minor mod's by rob@ncar)
;
;==============================================================================
;
;       Check number of parameters.
;
if n_params() ne 2 then begin
	print
	print, "usage:	wfits, array, file"
	print
	print, "	Write an array into a standard FITS file."
	print
	print, "	Arguments"
	print, "		array	- input array to write"
	print, "		file	- name of output FITS file"
	print
	print, "	Keywords"
	print, "		(see code for options)"
	print
	return
endif
;-

; open FITS file

if n_elements(fnum) ne 0 then file = filnam+'.'+string(format='(i0)',fnum) $
   else file = filnam
get_lun,unit
openw,unit,file

; check data type, and make conversion if necessary

type = size(data)
case type(type(0)+1) of
   1 : bitpix = 8
   2 : bitpix = 16
   3 : bitpix = 32
   4 : begin
       bitpix = -32
       print,'Note : FITS image is of floating point type (BITPIX = -32) '
       end
   5 : begin
       bitpix = -64
       print,'Note : FITS image is of floating point type (BITPIX = -64) '
       end
   6 : begin
       bitpix = -32
       print,'Note : complex data converted to real (BITPIX = -32) '
       end
   else : message,'Invalid data type '
endcase

; create header

; mandatory keywords
; SIMPLE
head = string(format='("SIMPLE  = ",19x,a1," ")','T')
; BITPIX
head = [head,string(format='("BITPIX  = ",i20," ")',bitpix)]
; NAXIS
head = [head,string(format='("NAXIS   = ",i20," ")',type(0))]
; NAXISi
for i=1,type(0) do $
   head = [head,string(format='("NAXIS",i1,"  = ",i20," ")',i,type(i))]

; optional keywords
; initialize flags for date and time in structure
d_flag = 0
t_flag = 0
; is hstruc defined and a structure?
hflag = size(hstruc)
hflag = hflag(hflag(0)+1) eq 8

; process keyword structure, if supplied
if hflag then begin
   ; default constants, don't write keyword if set to default
   null = 1e-44                   ; null ne 0.0
   one = 1.000001                 ; one ne 1.0
   tru = 255b                     ; true ne 1 and true ne 0
   n_s =''                        ; null string
   ; make tag-name array
   keynam = tag_names(hstruc)     ; tag names for use as keywords
   keynam = strupcase(keynam)     ; convert to upper case
   ; replace _ by - for FITS header
   asctab = bindgen(256)
   asctab(byte('_')) = byte('-')
   keynam = byte(keynam)
   keynam = asctab(keynam)
   keynam = string(keynam)

   for i=0,n_tags(hstruc)-1 do begin
     hdsiz = size(hstruc.(i))
     if hdsiz(0) eq 0 then begin                            ; simple keyword
          key = strmid(keynam(i)+'        ',0,8)
          case hdsiz(hdsiz(0)+1) of
             1 : begin                ; it's byte, used for logical keyword
                 if hstruc.(i) ne 0 then aux = 'T' else aux = 'F'
                 if hstruc.(i) ne tru then $
                    head = [head,string(format='(a8,"= ",19x,a1," ")',key,aux)]
                 end
             2 : head = [head,string(format='(a8,"= ",i20," ")', $
                        key,hstruc.(i))]
             3 : head = [head,string(format='(a8,"= ",i20," ")', $
                        key,hstruc.(i))]
             4 : if hstruc.(i) ne null and hstruc.(i) ne one then head = $
                    [head,string(format='(a8,"= ",G20.6," ")',key,hstruc.(i))]
             5 : if hstruc.(i) ne null and hstruc.(i) ne one then head = $
                    [head,string(format='(a8,"= ",G20.12," ")',key,hstruc.(i))]
             6 : if hstruc.(i) ne null and hstruc.(i) ne one then $
                    head = [head,string(format='(a8,"= ",G20.6," ")', $
                    key,abs(hstruc.(i)))]
             7 : begin                ; it's a string 
                 ; see if DATE-OBS or TIME-OBS happen to come along
                 if n_elements(date) eq 1 then if key eq 'DATE-OBS' then begin
                    hstruc.(i) = date
                    d_flag = 1
                 endif
                 if n_elements(time) eq 1 then if key eq 'TIME-OBS' then begin
                    hstruc.(i) = time
                    t_flag = 1
                 endif
                 ; force length of string between 8 and 68
                 slen = strlen(hstruc.(i))
                 if slen gt 68 then hstruc.(i) = strmid(hstruc.(i),0,68)
                 if slen lt 8 and slen gt 0 then $
                    hstruc.(i) = strmid(hstruc.(i)+'        ',0,8)
                 ; add if not null string (n_s)
                 if slen gt 0 then head = [head,key+"= '"+hstruc.(i)+"' "]
                 end
          else :
          endcase
     endif else begin              ; indexed keyword, one for each axis
       for j=0,type(0)-1 do begin
          key = strmid(keynam(i)+strtrim(string(j+1),2)+'        ',0,8)
          case hdsiz(hdsiz(0)+1) of
             1 : begin                ; it's byte, used for logical keyword
                 if hstruc.(i)(j) ne 0 then aux = 'T' else aux = 'F'
                 if hstruc.(i)(j) ne tru then $
                    head = [head,string(format='(a8,"= ",19x,a1," ")',key,aux)]
                 end
             2 : head = [head,string(format='(a8,"= ",i20," ")', $
                        key,hstruc.(i)(j))]
             3 : head = [head,string(format='(a8,"= ",i20," ")', $
                        key,hstruc.(i)(j))]
             4 : if hstruc.(i)(j) ne null and hstruc.(i)(j) ne one then $
                    head = [head,string(format='(a8,"= ",G20.6," ")', $
                           key,hstruc.(i)(j))]
             5 : if hstruc.(i)(j) ne null and hstruc.(i)(j) ne one then $
                    head = [head,string(format='(a8,"= ",G20.12," ")', $
                           key,hstruc.(i)(j))]
             6 : if hstruc.(i)(j) ne null and hstruc.(i)(j) ne one then $
                    head = [head,string(format='(a8,"= ",G20.6," ")', $
                    key,abs(hstruc.(i)(j)))]
             7 : begin                ; it's a string 
                 ; force length of string between 8 and 68
                 slen = strlen(hstruc.(i)(j))
                 if slen gt 68 then hstruc.(i)(j) = strmid(hstruc.(i)(j),0,68)
                 if slen lt 8 and slen gt 0 then $
                    hstruc.(i)(j) = strmid(hstruc.(i)(j)+'        ',0,8)
                 ; add if not null string (n_s)
                 if slen gt 0 then head = [head,key+"= '"+hstruc.(i)(j)+"' "]
                 end
          else :
          endcase
       endfor
     endelse
   endfor
endif

; insert DATE-OBS and TIME-OBS if not already in from structure
if n_elements(date) eq 1 and d_flag eq 0 then $
   head = [head,"DATE-OBS= '"+date+"' "]
if n_elements(time) eq 1 and t_flag eq 0 then $
   head = [head,"TIME-OBS= '"+time+"' "]

; process string array of keywords, if supplied
hflag = n_elements(ohd0)
if hflag gt 0 then begin
   ohd = ohd0
   ohsiz = hflag
   hdsiz = n_elements(head)

   ; search END and discard any lines after and including END
   i = -1
   repeat i=i+1 until (strmid(ohd(i),0,8) eq 'END     ' or i eq ohsiz-1)
   if strmid(ohd(i),0,8) eq 'END     ' then ohd = ohd(0:i-1)
   ohsiz = n_elements(ohd)

   ; search mandatory keywords in ohd, and transfer comments to head
   for i=0,type(0)+2 do begin
       key = strmid(head(i),0,8)
       j = -1
       repeat j=j+1 until (strmid(ohd(j),0,8) eq key or j eq ohsiz-1)
       if strmid(ohd(j),0,8) eq key then begin
          head(i) = head(i)+strmid(ohd(j),strlen(head(i)),72)
          ohd(j) = ''
       endif
   endfor

   ; discard any surplus NAXISi keywords in ohd
   for i=0,ohsiz-1 do if strmid(ohd(i),0,5) eq 'NAXIS' then ohd(i) = ''

   ; search optional keywords in head and transfer them to ohd
   if hdsiz gt type(0)+3 then begin
      for i=0,ohsiz-1 do begin
          key = strmid(ohd(i),0,8)
          j = type(0)+2
          repeat j=j+1 until (strmid(head(j),0,8) eq key or j eq hdsiz-1)
          if strmid(head(j),0,8) eq key then begin
             ohd(i) = head(j)+strmid(ohd(i),strlen(head(j)),72)
             head(j) = ''
          endif
      endfor
   endif

   ; remove empty lines in head and ohd, and concatenate them
   head = head(where(head))
   ohd = ohd(where(ohd))
   head = [head,ohd]
endif

; HISTORY
if n_elements(his) eq 1 then $
   head = [head,string(format='("HISTORY ",a)',his)]

; COMMENT
if n_elements(com) eq 1 then $
   head = [head,string(format='("COMMENT ",a)',com)]

; END
head = [head,"END     "]

; add blank lines to fill last FITS header record
i = n_elements(head) mod 36
if i gt 0 then head = [head,strarr(36-i)]

; fill lines with blanks to 80 chars and convert into byte array
head = strmid(head+string(bytarr(80)+32b),0,80)
head = byte(head)

; write the stuff

writeu,unit,head
if type(type(0)+1) eq 6 then writeu,unit,abs(data) else writeu,unit,data
; add null data to fill last FITS data record
i = (n_elements(data)*(abs(bitpix)/8)) mod 2880
i = (2880-i) mod 2880
if i gt 0 then begin
   datb = bytarr(i)
   writeu,unit,datb
endif
free_lun,unit
return
end
