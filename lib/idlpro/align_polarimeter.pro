a=franjas_tip((acum_1+acum_2+acum_3+acum_4)>0)

lim=limits_tip(a)

im1=a(lim(0):lim(1),lim(2):lim(3))
im2=a(lim(4):lim(5),lim(6):lim(7))


;tvscl,-1000>(im1-im2)<1000

mm=mean(im1/im2)
mm1=0.6*mm
mm2=1.4*mm
tvscl,mm1>(im1/im2)<mm2
