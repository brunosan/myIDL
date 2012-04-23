  function MINIMO,dat,np,sigmin

; function MINIMO,dat,np,sigmin,xx,yaj,datl
; NOTA: la llamada comentada tenia como salida XX= abscisas de los ptos.
; a cada lado del minimo que se usan para el ajuste, YAJ= polinomio aj.
; y DATL= % de la linea usado para el ajuste.
; Actualmente no es necesario que estos parametros salgan de la rutina, 
; por lo que la nueva llamada es la que esta sin comentar.

; se ajusta un polinomio de grado 4 al minimo de la linea. 
; de momento, a los 2*np+1 puntos (np a cada lado) del minimo.
; solo entra el array de datos. La salida es un vector de 4 puntos:
; el (0) es la ordenada del minimo absoluto, el (1) es la posicion
; del minimo absoluto, el (2) es la ordenada del minimo ajustado,
; el (3) es la abscisa del minimo ajustado.

; En los casos en que el espectro no es muy ruidoso esto funciona
; bien. Pero si tiene bollitos cerca del minimo intenta ajustar
; un polinomio pequenyo y encuentra dos raices en el intervalo pro-
; blema. Asi que, si esta rutina da error, se usara la posicion del
; minimo absoluto para el calculo del bisector. Al fin y al cabo, 
; como no vamos a usar el minimo para ninguna otra cosa, da igual.

; se determina el px del minimo de la linea. Debe estar en la zona central 
; del espectro (en el caso del CI, es mas minima la parte final)
	imin=fltarr(4,/nozero)
	imin(0)=min(dat(100:300))
	imin(1)=where(dat(100:300) eq min(dat(100:300)))+100
	pos=indgen(n_elements(dat))
	xx=pos((imin(1)-np):(imin(1)+np))
	yy=dat(xx)

; las abscisas para el ajuste se meten como -np,-(np-1),...,(np-1),np
	xx=xx-imin(1)

; de POLY_FIT sale el vector de coeficientes del ajuste, de dim. 4+1
; coeff(0)+coeff(1)*x+coeff(2)*x**2+...+coeff(4)*x**4
; Ademas salen las ordenadas ajustadas en XX y sus SIGMAS. Me interesa
; guardar la SIGMA de la ordenada correspondiente al minimo (XX=0), que
; considerare mas o menos = a la ordenada del minimo ajustado.
	coeff=poly_fit(xx,yy,4,yfit,yband)
	sigmin=yband(where(xx eq 0))
	
; se genera un vector de dim. 4 para los coeficientes de la 1a. derivada
	coef=fltarr(4)
	coef(0)=coeff(1)
	coef(1)=2*coeff(2)
	coef(2)=3*coeff(3)
	coef(3)=4*coeff(4)

; se calculan las raices de la 1a. derivada = extremos
	zroots,coef,raices

; se toma su modulo si son complejas
	xmin=abs(raices)

; se calcula la 2a. derivada, para ver en que raices es (+) (minimo)
	ymin=12*coeff(4)*xmin*xmin+6*coeff(3)*xmin+2*coeff(2)

; en principio hay 3 raices posibles.
; se selecciona(n) aquella(s) raiz(es) que haga(n) la 2a. derivada (+) 
; y que este(n) en el intervalo imin +/- np

	si=fltarr(3)
	si=where(ymin gt 0 and xmin ge (-np) and xmin le np)

; se guarda la abscisa del minimo ajustado, si solo hay una raiz buena
; imin(3)=xmin(si)
	if n_elements(si) eq 1 then begin
		imin(3)=xmin(si) 
; se calcula y se guarda la ordenada del minimo ajustado
		imin(2)=coeff(4)
		for i=0,3 do imin(2)=imin(2)*imin(3)+coeff(3-i)
		imin(3)=imin(3)+imin(1)
	endif else begin
; si hay mas de 1 minimo en el intervalo problema, se dejan la abscisa
; y la ordenada del minimo absoluto, no las ajustadas
		imin(3)=imin(1)
		imin(2)=imin(0)
	endelse

; se calcula el trozo de linea ajustado
	yaj=fltarr(n_elements(xx))
	yaj=yaj+coeff(4)
	for i=0,3 do yaj=yaj*xx+coeff(3-i)
	xx=xx+imin(1)
	
; se calcula que porcentaje de la linea ha sido usado para el ajuste
	datl=(dat(imin(1)-np)-dat(imin(1)))/(1.-dat(imin(1)))*100.
;	print,datl

; salida
	return,imin
	
	end

