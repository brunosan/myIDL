;FUNCTION POLYFIT2D, surface,degree,fit_surface,min=min,max=max,fret=fret
;+
; NAME:
;	POLYFIT2D
; PURPOSE:
;	Determine polynomial fit to a surface: uses POLYWARP to determine
;	coefficients of the polynomial, then evaluates the polynomial to
;	yield the fit surface. The minimum or maximum position is then
;	evaluated by FLETCHER-REEVES (or POLAK-RIBIERE).
; CATEGORY:
;	E2 - Surface fitting and mathetamics
; CALLING SEQUENCE:
;	extrema = POLYFIT2D (data_surface,degree,/min|/max [,fit_surface,fret=fret])
; INPUTS:
;	data_surface = two-dimensional array of data to be fit to.  Sizes of
;	               each dimension may be unequal.
;	degree       = degree of polynomial fit
; INPUT KEYWORDS:
;   min,max      = determins what kind of extrema should be evaluated
;				   (you must specify one of the two keywords!)
; OUTPUTS:
;	extrema      = vector containing x and y coordinates of extrema
; OPTIONAL OUTPUT PARAMETERS:
;	fit_surface  = two-dimensional array of values from the evaluation of
;	               the polynomial fit.
;	fret         = function value of fit at evaluated minimum or maximum 
;				   position
; COMMON BLOCKS:
;	none.
; SIDE EFFECTS:
;	none.
; RESTRICTIONS:
;	The number of data points in data_surface must be greater or equal to 9.
; PROCEDURE:
;	Generate coordinate arrays for POLYWARP using the indices as
;	coordinates.  The yi and ky arrays for POLYWARP are, in this usage,
;	redundant, so they are sent as dummies.  The coefficients returned
;	from POLYWARP are then used in evaluating the polynomial fit to give
;	the surface fit. Then the fit is used to evaluate the derivatives 
;	for root finding by Newton-Raphson method to get the coordinates
;	of the maximum or minimum position.
; MODIFICATION HISTORY:
;	Written by: Leonard Sitongia, LASP University of Colorado,
;		April, 1984.
;	Modified by Mike Jone, LASP, Sept. 1985.
;	Changed an extended to POLYFIT2D by Juergen Hofmann, Feb. 1992
;	Fletcher-Reeves-Polak-Ribiere minimazition added 
;									by Juergen Hofmann, Feb. 1992
;
;-

;
;	FIRST OFF ALL: THE MINIMIZATION - SUBROUTINES AND FUNCTIONS
;		Fletcher-Reeves (Polak-Ribiere) minimization
;		adapted from NUMERICAL RECIPIES
;

		FUNCTION FRPR_FUNC,P

		on_error,2

		COMMON COEF,C
		COMMON DEGREE,DEGREE
		;
		;this function f(P) returns the function-value for variable vector P
		;	
		x=p(0)
		y=p(1)
		f=0.D
		FOR ix = 0,degree DO $
			FOR iy = 0,degree DO $
				f = f + c (ix,iy)*x^ix*y^iy

		return,f
		end

		PRO FRPR_DFUNC,P,DF

		on_error,2

		COMMON DEGREE,DEGREE
		COMMON COEF,C
		;
		;this procedure return the vector gradient DF evaluated at the input
		;point P

		x=p(0)
		y=p(1)

		fx = 0.D       ;  evaluates fx
		FOR ix = 1,degree DO $
			FOR iy = 0,degree DO $
				fx = fx + c(ix,iy)*x^(ix-1)*y^iy*ix

		fy = 0.D        ;  evaluates fy
		FOR ix = 0,degree DO $
			FOR iy = 1,degree DO $
				fy = fy + c(ix,iy)*y^(iy-1)*x^ix*iy


		df=dblarr(2)
		df(0)=fx
		df(1)=fy
		return
		end

		FUNCTION FRPR_SIGN,X,Y

		on_error,2

		if y le 0 then return,abs(x) else return,-abs(x)
		end


		FUNCTION FRPR_F1DIM,X

		COMMON F1COM,ncom,pcom,xicom

		on_error,2

		xt=double(pcom+x*xicom)
		return,FRPR_FUNC(xt)
		end


		FUNCTION FRPR_DF1DIM,X

		COMMON F1COM,ncom,pcom,xicom

		on_error,2

		xt=double(pcom+x*xicom)
		FRPR_DFUNC,xt,df
		return,total(df*xicom)
		end


		FUNCTION FRPR_DBRENT,AX,BX,CX,TOL,XMIN

		on_error,2

;Given a function FUNC and its derivatives DFUNC, and given a bracketing 
;triblet of abscissas AX,BX,CX (such that BX is between AX and CX, and F(BX)
;is less then both F(AX) and F(CX)), this function isolates the minimum to
;a fractional precision of about TOL using a modification of Brent's method
;that uses derivatives. The abscissa of the minimum is returned as XMIN, and
; the minimum function value is returned as the function value.

		;init

		itmax=100
		zeps=1.D-10

		a=double(min(ax,cx))
		b=double(max(ax,cx))
		v=double(bx)
		w=v
		x=v
		e=0.D
		fx=FRPR_F1DIM(x)
		fv=fx
		fw=fx
		dx=FRPR_DF1DIM(x)
		dv=dx
		dw=dx
		for iter = 1,itmax do begin
			xm=.5*(a+b)
			tol1=tol*abs(x)+zeps
			tol2=2.*tol1
			if(abs(x-xm) le (tol2-.5*(a+b)))then goto,lab3
			if(abs(e) gt tol1) then begin
				d1=2.*(a-b)
				d2=d1
				if(dw ne dx)then d1=(w-x)*dx/(dx-dw)
				if(dv ne dx)then d2=(v-x)*dx/(dx-dv)
		;which of these two estimates of d shall we take? We will insist that they be
		;within the bracket, and on the side pointed to by the derivative at x:
				u1=x+d1
				u2=x+d2
				ok1=((a-u1)*(u1-b) gt 0) and (dx*d1 le 0)
				ok2=((a-u2)*(u2-b) gt 0) and (dx*d2 le 0)
				olde=e 		;Movement on the step before last
				e=d
				if(not (ok1 and ok2))then begin
					goto,lab1
				endif else begin
					if(ok1 and ok2)then begin
						if(abs(d1) lt abs(d2))then d=d1 $
							else d=d2
					endif else begin
						if(ok1)then d=d1 else d=d2
					endelse
				endelse
				if(abs(d) gt abs(0.5*olde))then goto,lab1
				u=x+d
				if(u-a lt tol2 or b-u lt tol2) then d=frpr_sign(tol1,xm-x)
				goto,lab2
			endif
		lab1:
			if(dx ge 0)then e=a-x else e=b-x
			d=0.5*e
		lab2:
			if(abs(d) ge tol1)then begin
				u=x+d
				fu=FRPR_F1DIM(u)
			endif else begin
				u=x+frpr_sign(tol1,d)
				fu=FRPR_F1DIM(u)
				if(fu gt fx)then goto,lab3
			endelse
			du=FRPR_DF1DIM(u)
			if(fu le fx) then begin
				if(u ge x)then a=x else b=x
				v=w
				fv=fw
				dv=dw
				w=x
				fw=fx
				dw=dx
				x=u
				fx=fu
				dx=du
			endif else begin
				if(u lt x)then a=u else b=u
				if((fu le fw) or (w eq x)) then begin
					v=w
					fv=fw
					dv=dw
					w=u
					fw=fu
					dw=du
				endif else begin
					if((fu le fv) or (v eq x) or (v eq w))then begin
						v=u
						fv=fu
						dv=du
					endif
				endelse
			endelse
		endfor
;		print,"DBRENT(Polyfit2d) exceeded maximum iterations."
		lab3:
		xmin=x
		return,fx
		end


							
		PRO FRPR_MNBRAK,AX,BX,CX,FA,FB,FC

		on_error,2

	;Given a function FUNC, and given distinct initial points AX and BX, this 
	;routine searches in the downhill direction (defined by the function as 
	;evaluated at the initial points) and returns new points AX,BX,CX which
	;bracket a minimum of the function. Also returned are the function values
	;at the three points FA,FB,FC.

		;init

		gold=1.618034 ;default ratio by which successive intervals are magnified
		glimit=100.   ;maximum magnification allowed for parabolic-fit step
		tiny=1.D-20

		fa=FRPR_F1DIM(ax)
		fb=FRPR_F1DIM(bx)
		if(fb gt fa)then begin
			dum=ax
			ax=bx
			bx=dum
			dum=fa
			fa=fb
			fb=dum
		endif
		cx=bx+gold*(bx-ax)	;first guess for cx
		fc=FRPR_F1DIM(cx)
		lab1:
		if(fb ge fc) then begin
						;Compute u by parabolic extrapolation from A,B,C.
			    		;tiny is used to prevent any possible division by 0.
			r=(bx-ax)*(fb-fc)
			q=(bx-cx)*(fb-fa) 
			u=bx-((bx-cx)*q-(bx-ax)*r)/(2.*frpr_sign(max([abs(q-r),tiny]),q-r))
			ulim=bx+glimit*(cx-bx) ;we won't go farther than this
									;Now to test various pssibilities:
			if((bx-u)*(u-cx) gt 0)then begin 
									 ;parabolic u is between b and c: try it.
				fu=FRPR_F1DIM(u)
				if(fu lt fc) then begin 	;got a minimum between b and c
					ax=bx
					fa=fb
					bx=u
					fb=fu
					goto,lab1
				endif else begin
					if(fu gt fb)then begin	;got a minimum between a and u
						cx=u
						fc=fu
						goto,lab1
					endif
				endelse
						;parabolic fit was no use. use default magnification
				u=cx+gold*(cx-bx)
				fu=FRPR_F1DIM(u)
			endif else begin
				if((cx-u)*(u-ulim) gt 0)then begin
							;parabolic fit is between c and its allowed limit
					fu=FRPR_F1DIM(u)
					if(fu lt fc) then begin
						bx=cx
						cx=u
						u=cx+gold*(cx-bx)
						fb=fc
						fc=fu
						fu=FRPR_F1DIM(u)
					endif
				endif else begin
					if((u-ulim)*(ulim-cx) ge 0)then begin 
											 ;limit parab. u to max. value
						u=ulim
						fu=FRPR_F1DIM(u)
					endif else begin 
								 ;reject parabolic u, use default magnification
						u=cx+gold*(cx-bx)
						fu=FRPR_F1DIM(u)
					endelse
				endelse
			endelse
			ax=bx
			bx=cx
			cx=u
			fa=fb
			fb=fc
			fc=fu
			goto,lab1
		endif
		return
		end


		PRO FRPR_LINMIN,P,XI,N,FRET

;Given an N dimensional point P an an N dimensional direction XI, moves and
;resets P to where the function FUNC(P) takes on a minimum along the direction
;XI from P, and replaces XI by the actual vector displacement that P was moved.
;Also returns as FRET the value of FUNC at the returned location P. This is
;actually all accomplished by calling the procedures MNBRAK and DBRENT.

		;init

		COMMON F1COM,ncom,pcom,xicom

		on_error,2

		nmax=50
		tol=1.D-4

		ncom=n
		pcom=double(p)
		xicom=double(xi)
		ax=0.D
		xx=1.D
		frpr_mnbrak,ax,xx,bx,fa,fx,fb
		fret=frpr_dbrent(ax,xx,bx,tol,xmin)
		xi=xmin*xi
		p=p+xi
		return
		end



		;
		;the real minimization-program:
		;fletcher-reeves-polak-ribiere minimization
		;

		PRO FRPRMN,P,N,FTOL,ITER,FRET

		;Given a starting point p that is is a vector of length N, Fletcher-
		;Reeves-Polak-Ribiere minimization is performed on a function FUNC
		;using its gradient as calculated by a routine DFUNC. The convergence
		;tolerance on the function value is input as FTOL. Returned quantities
		;are P (the location of the minimum), ITER (number of iterations that
		;were performed), and fret (the minimum value of the function). The
		;routine LINMIN is called to perform line minimizations.

		; init:

		on_error,2

		nmax=50			; maximum anticipated value of N
		itmax=200		; maximum allowed number of iterations
		eps=1.d-10      ; small number to rectify special case of converging
						; to exactly zero function value

		fp=FRPR_FUNC(p)
		FRPR_DFUNC,p,xi
		g=-xi
		h=g
		xi=h
		for its=1,itmax do begin
			iter=its
			frpr_linmin,p,xi,n,fret
			if 2.*abs(fret-fp) le ftol*(abs(fret)+abs(fp)+eps) then return
			fp=FRPR_FUNC(p)
			FRPR_DFUNC,p,xi
			gg=total(g^2)
		;	dgg=total(xi^2)        ; this statement for Fletcher-Reeves
			dgg=total((xi+g)*xi)   ; this statement for Polak-Ribiere
								   ; that's what I prefere
			if gg eq 0 then return
			gam=dgg/gg
			g=-xi
			h=g+gam*h
			xi=h
			endfor
		print,"FRPRMN(Polyfit2d): Maximum iterations exceeded!"
		return
		end

;
;     M A I N     M A I N    M A I N    M A I N    M A I N
;
;	THIS IS THE MAIN FIT-PROCEDURE
;	THIS IS THE MAIN FIT-PROCEDURE
;	THIS IS THE MAIN FIT-PROCEDURE
;

FUNCTION POLYFIT2D, surface,degree,fit_surface,min=min,max=max,fret=fret

;
;	Common-Blocks for Minimization with Fletcher-Reeves
;

	COMMON DEGREE,C_DEGREE
	COMMON COEF,C
	c_degree=degree
;
;				sizes of dimensions of surface
;
	on_error,2                      ;Return to caller if an error occurs
	sizes = SIZE (surface)
	size_x = sizes (1)
	size_y = sizes (2)
;
;				initialize
;
	coord_x = indgen(size_x, size_y) mod size_x	;X coords.
	coord_y = indgen(size_x, size_y) / size_x	; & y.
	fit     = FLTARR (size_x,size_y)
	re_surf = FLTARR (size_x,size_y)
	if n_elements(step) eq 0 then step = 4
	if step lt 4 then step = 4
;
;				compute fit coefficients
;
;
	POLYWARP, surface,re_surf,coord_x,coord_y,degree,c,re_coef
	c = double(TRANSPOSE (c) )

;
;				compute fit surface from coefficients
;
	FOR ix = 0,degree DO $
		FOR iy = 0,degree DO $
			fit = fit + c (ix,iy)*coord_x^ix*coord_y^iy

	fit_surface = fit

;
;			compute maximum or minimum
;
	if n_elements(max) eq 1 then a=max(fit,pos) $
	else if n_elements(min) eq 1 then a=min(fit,pos) $
	else begin
		print,"Polyfit2d: Kind of extrema was not specified ... returning [0,0]!"
		return,[0,0]
	endelse
	if n_elements(max) eq 1 then c=-c

	x=double(pos mod (size(fit))(1))
	y=double(pos/(size(fit))(1))

	iter=0
	fret=0.
	p=double([x,y])
;
;	evaluating minimum-position
;
	frprmn,p,2,1.d-10,iter,fret
	x=p(0)
	y=p(1)
	if n_elements(max) eq 1 then fret=-fret

;				return coordinates 
;
	RETURN,[x,y]
	END
