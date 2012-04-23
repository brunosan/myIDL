a=franjas_tip(acum_1>0)

lim=limits_tip(a)

im1=a(lim(0):lim(1),lim(2):lim(3))
im2=a(lim(4):lim(5),lim(6):lim(7))

im1r=im1-reverse(im1,2)
im2r=im2-reverse(im2,2)

tvscl,-1000>[im1r,im2r]<1000
