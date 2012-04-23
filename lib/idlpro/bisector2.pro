 function BISECTOR,dat,pos,xmin,nc,cont,sigma,sigprom,sigbis

; se calcula el bisector hasta el 97% de 2 en 2%
; ncotas es el numero de niveles
	ncotas=fix((0.98-xmin(2))/.02)

; COTAS es el bisector. COTAS(*,0) son las posiciones y
; COTAS(*,1) son las ordenadas
	cotas=fltarr(ncotas+1,2)
;	cotas=fltarr(ncotas,2)
; dimensiono a un punto menos porque no voy a incluir el minimo de la linea 
; como punto inferior del bisector, sino que me voy a quedar justo en el 
; nivel entero anterior.
	cotas(0:ncotas-1,1)=.97-.02*indgen(ncotas)
	xbisi=fltarr(ncotas)
	xbisd=xbisi
; Se inicializan a 0 SIGD y SIGI que seran parte del error del bisector.
	sigd=fltarr(ncotas)
	sigi=sigd

; se realiza una interpolacion lineal para encontrar la abscisa
; y la ordenada del espectro justo en los valores del bisector
; deseados.
; La expresion de la ordenada del bisector (dim. NCOTAS+1) es:
; XBISD/I=(X2-X1)*(Y-Y1)/(Y2-Y1)+X1 
; Y la expresion de su error, que depende de Y,Y1 e Y2 (dim. NCOTAS+1) es:
; SIGD/I=(X2-X1)/(Y2-Y1)^2*SQRT((Y2-Y1)^2*sigY+(Y-Y2)^2*sigY1+(Y-Y1)^2*sigY2)
; sigY, sigY1 y sigY2 se escriben en funcion de Y, Y1 e Y2, SIGMA (= para to-
; dos los px.) y SIGMAPROM (sigma de la Ic) con la siguiente expresion formal:
; sigY=1/CONT*SQRT(SIGMA^2+Y^2*SIGPROM^2)
	condi=xbisi
	condd=xbisi
	x=indgen(n_elements(dat))
	for j=0,ncotas-1 do $
   	condi(j)=min(where(x ge pos(1) and x le pos(2) and dat le cotas(j,1)))
	for j=0,ncotas-1 do $
   	condd(j)=max(where(x ge pos(1) and x le pos(2) and dat le cotas(j,1)))

	xbisi=(x(condi)-x(condi-1))*(cotas(0:ncotas-1,1)-dat(condi-1))
	xbisi=xbisi/(dat(condi)-dat(condi-1))+x(condi-1)
	x21i=x(condi)-x(condi-1)
	y21i=dat(condi)-dat(condi-1)
; En vez de considerar SIGMAC=SIGMA/sqrt(NC), considero SIGMAC=SIGMAPROM, es
; decir, la desv. st. de los puntos que se promedian para calcular el contin.
; Hay 3 entradas mas a la rutina: CONT, SIGMA y SIGPROM.
	sig1i=sqrt(sigma^2+dat(condi-1)^2*sigprom^2)/cont	
	sig2i=sqrt(sigma^2+dat(condi)^2*sigprom^2)/cont
	sigi=y21i^2*(sigma^2+cotas(0:ncotas-1,1)^2*sigprom^2)/cont^2
	sigi=sigi+(cotas(0:ncotas-1,1)-dat(condi))^2*sig1i^2
	sigi=sigi+(cotas(0:ncotas-1,1)-dat(condi-1))^2*sig2i^2
	sigi=sqrt(sigi)*(x21i/y21i^2)

	xbisd=(x(condd)-x(condd+1))*(cotas(0:ncotas-1,1)-dat(condd+1))
	xbisd=xbisd/(dat(condd)-dat(condd+1))+x(condd+1)
	x21d=x(condd)-x(condd+1)
	y21d=dat(condd)-dat(condd+1)
	sig1d=sqrt(sigma^2+dat(condd+1)^2*sigprom^2)/cont
	sig2d=sqrt(sigma^2+dat(condd)^2*sigprom^2)/cont
	sigd=y21d^2*(sigma^2+cotas(0:ncotas-1,1)^2*sigprom^2)/cont^2
	sigd=sigd+(cotas(0:ncotas-1,1)-dat(condd))^2*sig1d^2
	sigd=sigd+(cotas(0:ncotas-1,1)-dat(condd+1))^2*sig2d^2
	sigd=sqrt(sigd)*(x21d/y21d^2)

; se calcula el bisector y su error
	cotas(0:ncotas-1,0)=(xbisd+xbisi)/2
	sigbis=fltarr(ncotas+1)
;	sigbis=fltarr(ncotas)
	sigbis(0:ncotas-1)=sqrt(sigd^2+sigi^2)/2.

; el bisector va ordenado de arriba a abajo. Asi que BIS(0,0) es su
; punto mas alto. Y se obliga a que el punto mas bajo sea el minimo
; de la linea, ajustado o no, con error =0.
	cotas(ncotas,0)=xmin(3)
	cotas(ncotas,1)=xmin(2)
	sigbis(ncotas,0)=0.

	return,cotas
	end
