;+
; NAME:         PGM_WRITE
; PURPOSE:
;       Write 8 bit images in pgm format on a file.
; CATEGORY:
;       Input/output.
; CALLING SEQUENCE:
;       PGM_WRITE,Filename,data
; INPUTS:
;       Filename = string containing the name of file to create and write.
;	data = 2-dim image array of type byte. If not already a byte array,
;               it is transformed using the BYTSCL function.
; OUTPUTS:
;       None
; COMMON BLOCKS:
;       None.
; SIDE EFFECTS:
;       A file is created and written in pgm format.
; RESTRICTIONS:
;       Only the RAWBITS-variant of the pgm format is supported.
; PROCEDURE:
;
; MODIFICATION HISTORY:
;       Written, A. Welz, Univ. Wuerzburg, Germany, Jan. 1992
;-
pro pgm_write,file,data
on_error,2

s=size(data)
if s(0) ne 2 then begin
   print,'%Sorry, 2nd argument must be a 2-dim array.'
   return
endif

openw,unit,/get_lun,file
printf,unit,'P5'
nxy=strcompress( string(s([1,2])),/remove )
nxy=nxy(0)+' '+nxy(1)
printf,unit,nxy
printf,unit,'255'
if s(3) eq 1 then begin
; data is already of type byte
   writeu,unit,rotate(data,7)
endif else begin
; data has to be transformed to type byte
   writeu,unit,rotate(bytscl(data),7)
endelse


free_lun,unit
return
end
