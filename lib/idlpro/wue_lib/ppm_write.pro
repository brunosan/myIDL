;+
; NAME:         PPM_WRITE
; PURPOSE:
;       Write 8 bit color images in ppm format on a file.
; CATEGORY:
;       Input/output.
; CALLING SEQUENCE:
;       PPM_WRITE,Filename,data
;	PPM_WRITE,Filename,red,green,blue
; INPUTS:
;       Filename = string containing the name of file to create and write.
;	data = image array (nx,ny,3) of type byte. If not already a byte array,
;               it is made a byte array using the BYTSCL function.
;	red,green,blue = 3 image arrays (nx,ny)
; OUTPUTS:
;       None
; COMMON BLOCKS:
;       None.
; SIDE EFFECTS:
;       A file is created and written in ppm format.
; RESTRICTIONS:
;       Only the RAWBITS-variant of the ppm format is supported.
; PROCEDURE:
;
; MODIFICATION HISTORY:
;       Written, A. Welz, Univ. Wuerzburg, Germany, Jan. 1992
;-
pro ppm_write,file,data,green,blue
on_error,2

case n_params() of
2: begin
   s=size(data)
   if total(abs(s([0,3])-[3,3])) ne 0 then begin
      print,'%Sorry, 2nd argument must be a (nx,ny,3) array.'
      return
   endif
   nx=s(1) & ny=s(2)
   out=reform(data,3,nx,ny)
   out(0,*,*)=rotate(reform(data(*,*,0)),7)
   out(1,*,*)=rotate(reform(data(*,*,1)),7)
   out(2,*,*)=rotate(reform(data(*,*,2)),7)
   end
4: begin
   sr=size(data) & sg=size(green) & sb=size(blue)
   if total(abs([sr(0:2)-sg(0:2),sr(0:2)-sb(0:2),sr(0)-2])) ne 0 then begin
      print,'%Sorry, 2nd to 4th arguments must be three (nx,ny) arrays'
   endif
   nx=sr(1) & ny=sr(2)
   out=reform([data,green,blue],3,nx,ny)
   out(0,*,*)=rotate(data,7)
   out(1,*,*)=rotate(green,7)
   out(2,*,*)=rotate(blue,7)
   end
else: begin
   print,'%must have one (nx,ny,3) or three (nx,ny) arrays'
   return
   end
endcase
typ=(size(out))(4)

openw,unit,/get_lun,file
printf,unit,'P6'
nxy=strcompress( string([nx,ny]),/remove )
nxy=nxy(0)+' '+nxy(1)
printf,unit,nxy
printf,unit,'255'
if typ eq 1 then begin
; out is already of type byte
   writeu,unit,out
endif else begin
   writeu,unit,bytscl(out)
endelse


free_lun,unit
return
end
