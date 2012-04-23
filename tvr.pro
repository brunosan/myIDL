pro tvr,ima

si=size(ima)
factor=max([si[1]/700.,si[2]/1200.])
tvwin,congrid(ima,si[1]/factor,si[2]/factor)

end