function ferro,delta1,ang1,delta2,ang2

uno=[1,1,0,0]

mat=fltarr(4,4)
alpha1=[ang1(0),ang1(1),ang1(0),ang1(1)]
alpha2=[ang2(0),ang2(0),ang2(1),ang2(1)]

for j=0,3 do mat(j,*)=uno#retarder(alpha2(j),delta2)#retarder(alpha1(j),delta1)

return,mat
end
