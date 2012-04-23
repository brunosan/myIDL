function limits_tip,im_in

im=reform(im_in)
tam=size(im)

perf=total(median(im(tam(1)/2-50:tam(1)/2+50,*),3),1)
perf(0:10)=0.
;perf=median(perf,3)
perf=smooth(perf,9)
perf(0)=perf(1)
perf(tam(2)-2)=perf(tam(2)-1)
dperf=deriv(perf)

z1=where(dperf eq max(dperf))
z1=z1(0)


i1=(z1-10)>0
i2=(z1+10)<(tam(2)-1)
dperf(i1:i2)=0.

z2=where(dperf eq max(dperf))
z2=z2(0)

if(z1 gt z2) then begin
   dum=z1
   z1=z2
   z2=dum
endif

z3=where(dperf eq min(dperf))
z3=z3(0)


i1=(z3-20)>0
i2=(z3+20)<(tam(2)-1)
dperf(i1:i2)=0.

z4=where(dperf eq min(dperf))
z4=z4(0)

if(z3 gt z4) then begin
   dum=z3
   z3=z4
   z4=dum
endif

nhaz1=z3-z1
nhaz2=z4-z2

z3=z1+min([nhaz1,nhaz2])
z4=z2+min([nhaz1,nhaz2])

z1=z1+2
z2=z2+2
z3=z3-2
z4=z4-2


x1=10  
x2=10 
x3=tam(1)-2
x4=x3
print,[x1,x3,z1,z3,x2,x4,z2,z4]
;stop
return,[x1,x3,z1,z3,x2,x4,z2,z4]
end   
