function lee_ana,file

hdr=bytarr(512)
openr,1,file
readu,1,hdr
n1=hdr(193)*256+hdr(192)
n2=hdr(197)*256+hdr(196)

dat=bytarr(n1,n2)
readu,1,dat
;byteorder,dat
;z=where(dat lt 0)
;if(z(0) ne -1) then begin
;   dat=long(dat)
;   dat(z)=dat(z)+65536l
;endif      


close,1
return,dat
end
