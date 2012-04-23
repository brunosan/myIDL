;fft filter
;make a filter frecuencia for high frecuencies
filter = fltarr(1013)
filter(*)=1.e-10
filter(0:60)=1.0
filter(1012-60:1012)=1.0
f1 = fltarr(100)
absz=findgen(100)
f1 = exp(-(absz/30.)^2)
f1end = reverse(f1)


filter(61:61+100-1) =f1(0:99)
filter(1012-100+1-60:1012-60) =f1end(0:99)
ff=filter*f
fff=float(fft(ff,1))
