pro WFITS,file,dat,objeto=objeto,iop=iop

if keyword_set(objeto) eq 0 then objeto ='      '
if keyword_set(iop) eq 0 then iop=0

; escribe ficheros en formato FITS

;on_ioerror, error

tam=size(dat)
type=tam(tam(0)+1)
tam=size(dat)
NAXIS=tam(0)
idim=tam(1:NAXIS)

if type ne 1 and type ne 2 and type ne 3 then begin
   dmin=min(dat)
   dmax=max(dat)

   if dmin ne dmax then begin
	bscale=double((dmax-dmin)/65535.)
	bzero=double(dmin)
   endif else begin
	bscale=double(dmax)
	bzero=double(0.)
   endelse
endif else begin
   bscale=1.d0
   bzero = 0.d0
endelse
   bscale=1.
   bzero = 0.

;if iop eq 0 then bzero=bzero+32768*bscale
 
hdr=bytarr(2880)+byte(32)

hdr(0:29)    = byte('SIMPLE  =                    T')
if type eq 1 then bitpix=8 $
   else if type eq 2 then bitpix=16 $
   else if type eq 3 then bitpix=32 $
   else bitpix=16
pos=80
hdr(pos:pos+9)  = byte('BITPIX  = ')
hdr(pos+22:pos+29) = byte(string(bitpix))
hdr(160:169) = byte('NAXIS   = ')
hdr(178:189) = byte(string(NAXIS))
for i=0,NAXIS-1 do begin
   pos=80*(i+3)
   hdr(pos:pos+9) = byte('NAXIS'+strtrim(string(i+1),2)+'  = ')
   hdr(pos+18:pos+29) = byte(string(idim(i)))
endfor
;spawn,"date '+%d/%m/%y'",date
pos=80*(NAXIS+3)
hdr(pos:pos+9) = byte('DATE    = ')
;hdr(pos+10:pos+19) = byte("'"+date+"'")
pos=80*(NAXIS+4)
hdr(pos:pos+14) = byte("ORIGIN  = 'IAC'")
pos=80*(NAXIS+5)
hdr(pos:pos+9) = byte('OBJECT  = ')
tam=size(byte(objeto))
hdr(pos+10:pos+10+tam(1)+1) = byte("'"+objeto+"'")
pos=80*(NAXIS+6)
hdr(pos:pos+9) = byte('BSCALE  = ')
FORMAT='(1x,e17.10)'
hdr(pos+12:pos+29) = byte(string(bscale,format=FORMAT))
pos=80*(NAXIS+7)
hdr(pos:pos+9) = byte('BZERO   = ')
hdr(pos+12:pos+29) = byte(string(bzero,format=FORMAT))
pos=80*(NAXIS+8)
hdr(pos:pos+17) = byte("BUNIT   = 'COUNTS'")
for i=0,NAXIS-1 do begin
   pos=80*(NAXIS+9+i)
   hdr(pos:pos+9) = byte('CDELT'+strtrim(string(i+1),2)+'  = ')
   hdr(pos+17:pos+29) = byte(string(1.0))
endfor

pos=80*(2*NAXIS+9)
hdr(pos:pos+2)=byte('END')

print,bzero,bscale
get_lun,unit
openw,unit,file
writeu,unit,hdr
datb=dat
byteorder,datb,/lswap
writeu,unit,datb
;if type eq 1 or type eq 2 or type eq 3 then writeu,unit,fix(dat-bzero) $  
;   else writeu,unit,fix((dat-bzero)/bscale)
close,unit
free_lun,unit
end


