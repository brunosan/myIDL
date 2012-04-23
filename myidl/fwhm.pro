function fwhm,dat
data=dat
ma=max(data/2.)
data=data<ma
foo=where(data EQ ma)
val=float(max(foo)-min(foo))

return,val
end