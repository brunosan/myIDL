PRO rdtabelle,array,file=file,columns=col,lines=l12,form=form_string, $
              bad_line=bad_val
;+
; NAME:
;	RDTABELLE
; PURPOSE:
;	Reads from ASCII-file selected lines & columns of numeric data
;	and returns the data in a 2-dim array (real).
;*CATEGORY:            @CAT-# 14@
;	I/O
; CALLING SEQUENCE:
;	RDTABELLE,array [,FILE=file] [,COLUMNS=column-vect] [,LINES=line-vect]
;	          [,FORM=format-string] [BAD_LINE=bad_value]
; INPUTS:
;	none
; OPTIONAL INPUT PARAMETER:
;	FILE=file : name of file to be read; if not set, procedure will
;	            request user to enter a filename.
;       COLUMNS=column-vect : single integer value or integer-vector with
;                   indices of data-columns to be read in. "Data-columns" are
;		    numeric sub-strings on an input-line separated by comma,
;		    blank or tab. 
;		    1st column has index =1; the number & values may not
;		    exceed the number of columns in the data file.
;		    in the data file. The read in data will be stored in array
;		    according to the sequence in column-vect;
;		    e.g: COLUMNS=[4,1,2] : there must be at least 4 data-
;		    columns on each line in the data-file; array(*,0) will
;		    store column 4, array(*,1) column 1, and array(*,2) col. 2;
;		    column 3 of the file will not be stored. If column-vect
;		    is a single integer, only one column will be stored.
;		    If no column-vect specified, procedure will request user
;	            to enter column-indices.
;        LINES=line-vect : integer vector of size 2 containing 1st, last line
;	            of data to be read in (1st line =1). 
;		    Reading will stop at "last line or at "EOF"; to ensure that
;		    all data lines will br read in, "last line" is allowed to
;		    exceed the number of data lines in the file.
;		    If not set, procedure will request user to enter a line-
;		    range.
;        FORM=format-string: If specified, formatted input will be performed;
;	            the format-string must obey the IDL-rules for FORMAT and
;		    must be compatible with the data-lines.
;		    If not set: input is done with "Free Format".
;        BAD_LINE=bad_value: If specified, <bad_value> will be stored into
;	            array(k,*) if an I/O-error was encountered for the k-th
;		    input-line; on return, the size of 1st dimension of array
;		    will be identical to the number of lines read in.
;		    If not set: erroneous input-lines are ignored with no
;		    increment of 1st index of array; on return, the size of
;		    1st dimension of array will be shorter than the number of
;		    input-lines read in if errors were detected.
; OUTPUTS:
;	array :     2-dim floating-point array containing the data;
;		    size of 1st dimension = number of (valid) data lines read
;                   in; size of 2nd dimension = number of columns read in.
; OPTIONAL OUTPUTS:
;	none
; COMMON BLOCKS:
;	none
; SIDE EFFECTS:
;	Procedure will report number of valid data-lines read in,  
;	EOF-detection, and line-numbers of invalid data-lines found.
; RESTRICTIONS:
;	All data are interpreted as floating point; if a data-line contains
;       less than expected number of data items, or if an I/O-error occurred
;       when reading an input-line, this line will be ignored, but procedure
;	will continue reading.
; PROCEDURE:
;	Straight
; MODIFICATION HISTORY:
;	nlte, 1991-Aug-08 
;-
on_error,1
if n_params() ne 1 then begin text= $
'Usage: RDTABELLE,array, [FILE=file] [,COLUMNS=column-vect] [,LINES=[from,to]]'
text=text+' [,BAD_LINE=value] [,FORM=format-string]'
message,text
endif
if n_elements(file) lt 1 then begin
   file=''
   print,format='($,"RDTABELLE file? ")'
   read,file
endif
openr,unit,file,/get_lun
;
if n_elements(col) gt 0 then begin
   n=n_elements(col)-1
   goto,jmp1
endif
jmp0:print,format='($,"RDTABELLE columns ?")'
ccol=''
read,ccol
while strpos(ccol,',') ge 0 do strput,ccol,' ',strpos(ccol,',')
ccol=strcompress(ccol)
ccol=strtrim(ccol,2)
lc=strlen(ccol)
if lc lt 1 then goto,jmp0
i1=0
n=-1
jmp:
ib=strpos(ccol,' ',i1)
if ib lt 0 then ib=lc
i2=min([ib,lc])
n=n+1
if n eq 0 then col=fix(strmid(ccol,i1,i2-i1)) else $
                col=[col, fix(strmid(ccol,i1,i2-i1))]
if i2 lt lc then begin i1=i2+1 & goto,jmp & endif
jmp1:ccol=''
nn=max(col)
arr1=fltarr(nn)
;
if n_elements(l12) eq 2 then begin 
   l1=l12(0) & l2=l12(1)
endif else begin
   print,format='($,"RDTABELLE LINES from,to ?")'
   l1=0 & l2=0
   read,l1,l2
endelse
;
if n_elements(form_string) gt 0 then begin
   form_str=strcompress(form_string,/remove)
   if strmid(form_str,0,1) ne '(' then form_str='('+form_str
   lform=strlen(form_str)
   if strmid(form_str,lform-1,1) ne ')' then form_str=form_str+')'
endif else lform=0
;
l1=l1>1
arr=fltarr(l2-l1+1,n+1)
if l1 gt 1 then for line=1,l1-1 do readf,unit,ccol
on_ioerror,jmperr
k=-1
nign=-1
for line=l1,l2 do begin
   if lform eq 0 then readf,unit,arr1 else readf,unit,arr1,format=form_str
   k=k+1
   arr(k,*)=arr1(col-1)
   if eof(unit) then begin print,'RDTABELLE: EOF at line',line & goto,jmpeof
   endif
   goto,jmpnxt
jmperr:
   nign=nign+1
   if nign eq 0 then ignored=line else ignored=[ignored,line] 
   if n_elements(bad_val) gt 0 then begin k=k+1 & arr(k,*)=bad_val & endif
jmpnxt:
endfor
jmpeof:
free_lun,unit
array=arr(0:k,*)
arr=0
print,'RDTABELLE LINES READ IN:',k+1
if nign ge 0 then print,'RDTABELLE ',nign+1,' IGNORED LINES:',ignored
ignored=0
end
