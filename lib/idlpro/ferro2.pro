pro ferro2,ang1,ret1,cambio1,ang2,ret2,cambio2,mat1,invmat1,eps

;cambio1=45.
;cambio2=45.
m1a=retarder(ang2,ret2)
m1b=retarder(ang2+cambio2,ret2)
m2a=retarder(ang1,ret1)
m2b=retarder(ang1+cambio1,ret1)
m=m1a#m2a
mat1=m
mat1(0,*)=m(0,*)+m(1,*)
m=m1a#m2b
mat1(2,*)=m(0,*)+m(1,*)
m=m1b#m2a
mat1(1,*)=m(0,*)+m(1,*)
m=m1b#m2b
mat1(3,*)=m(0,*)+m(1,*)
invmat1=invert(mat1)
; el 4 de abajo es el numero de pasos de un ciclo
;q0=4*invmat1(0,*)#transpose(invmat1(0,*))
;q1=4*invmat1(1,*)#transpose(invmat1(1,*))
;q2=4*invmat1(2,*)#transpose(invmat1(2,*))
;q3=4*invmat1(3,*)#transpose(invmat1(3,*))
;q0=1./q0
;q1=1./q1
;q2=1./q2
;q3=1./q3
;eps=[sqrt(q0),sqrt(q1),sqrt(q2),sqrt(q3),sqrt(q1+q2+q3)]
eps=effic(mat1)

return
end
