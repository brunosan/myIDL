function evalflat,fileffin,fileffout=fileffout

data=limits_tip(rfits_im(fileffin,9))
flat_tip,fileffin,ff,data=data
for j=0,3 do ff(j,*,*)=median(reform(ff(j,*,*)),3)
ff=total(ff,1)/4.
ff=long(ff*10000.)

tam=size(ff)
bitpix=32

hdr=bytarr(2880)+byte(32)
hdr(0:29)    = byte('SIMPLE  =                    T')
pos=80
hdr(pos:pos+9)  = byte('BITPIX  = ')
hdr(pos+22:pos+29) = byte(string(bitpix))
hdr(160:169) = byte('NAXIS   = ')
hdr(178:189) = byte(string(tam(0)))
for i=0,tam(0)-1 do begin
   pos=80*(i+3)
   hdr(pos:pos+9) = byte('NAXIS'+strtrim(string(i+1),2)+'  = ')
   hdr(pos+18:pos+29) = byte(string(tam(i+1)))
endfor

bzero=0.
bscale=1.

pos=pos+80
hdr(pos:pos+9) = byte('BSCALE  = ')
str=byte(string(bscale))
nstr=n_elements(str)
hdr(pos+10:pos+nstr+9) = str

pos=pos+80
hdr(pos:pos+9) = byte('BZERO   = ')
str=byte(string(bzero))
nstr=n_elements(str)
hdr(pos+10:pos+nstr+9) = str

pos=pos+80
hdr(pos:pos+9) = byte('FILENAME= ')
str=byte("'"+fileffout+"'")
nstr=n_elements(str)
hdr(pos+10:pos+nstr+9) = str

spawn,"date '+%Y-%m-%d'",date
date=date(n_elements(date)-1)
pos=pos+80
hdr(pos:pos+9) = byte('DATE-OBS= ')
str=byte("'"+date+"'")
nstr=n_elements(str)
hdr(pos+10:pos+nstr+9) = str

spawn,"date '+%H:%M:%S'",time
time=time(n_elements(time)-1)
pos=pos+80
hdr(pos:pos+9) = byte('TIME    = ')
str=byte("'"+time+"'")
nstr=n_elements(str)
hdr(pos+10:pos+nstr+9) = str

pos=pos+80
hdr(pos:pos+9) = byte('END       ')

if(keyword_set(fileffout) ne 0) then begin
   get_lun,unit
   openw,unit,fileffout
   ffb=ff
   byteorder,ffb,/lswap
   writeu,unit,hdr,ffb
   close,unit
   free_lun,unit
endif

return,ff
end   
