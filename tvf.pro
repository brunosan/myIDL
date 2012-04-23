pro tvf,ima,z

ima=reform(ima[*,*,0])
si=size(ima)

tvscl,congrid(ima,si(1)/float(z),si(2)/float(z))

end
