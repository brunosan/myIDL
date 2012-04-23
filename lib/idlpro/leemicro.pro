function LEEMICRO,filein,objeto,n,m,dx,dy

ffff=-1
objeto='                                        '
n=1
m=1
dx=long(1)
dy=long(1)
ix=long(0)
iy=long(0)

get_lun,unit
openr,unit,filein

readu,unit,ffff,objeto,n,ix,iy,dx

command = 'ls -l '+filein
spawn,command,ans
length=long(strtrim(strmid(ans(1),20,11),2))
m=length/(2*n+56)
objeto=strtrim(objeto,2)

dat=intarr(n+28,m)
point_lun,unit,0
readu,unit,dat

dx1=long(dat(27,1))
dy=abs(dat(25,0)-dat(25,1))
dat=ishft(dat(28:*,*),-4)
if(dx1/dx lt 0) then begin
   for j=1,m-1,2 do dat(*,j)=reverse(dat(*,j))
endif

dx=abs(dx)

free_lun,unit

return,dat
end
