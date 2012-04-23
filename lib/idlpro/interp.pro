function INTERP,dat,factor

; interpolacion de Fourier.
; se calcula la TF directa de los datos, que viene dada doblada, con los
; valores a la derecha del origen los primeros, y luego los valores a la
; izquierda, simetricos. Entre ellos se introduce un cierto numero de 0s,
; segun el FACTOR de interpolacion. Luego se calcula la TF-1.

	fftdat=fft(dat,-1)
	nsiz=n_elements(dat)
	fftdat=[fftdat(0:nsiz/2),complexarr((factor-1)*nsiz),fftdat(nsiz/2+1:*)]
	return,abs(fft(fftdat,1))
	end
