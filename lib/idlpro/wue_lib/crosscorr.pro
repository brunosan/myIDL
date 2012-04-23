;
;+ 
; NAME:
;	CROSSCORR
; PURPOSE:
;	Calculates the crosscorrelation of
;	two data-sets in one or two dimensions and returns maximum or minimum
;	of crosscorrelationfunction if required
;	2-dim mini(maxi)mization is done by polyfit2d (external function)
;   1-dim mini(maxi)mization is done by newton-raphson (included)
; CATEGORY:
;	MATHEMATICS 
; CALLING SEQUENCE:
;	Corr=crosscorr(data1,data2,pmax [,/cut,/noshift,/pmin,range=range,
;					degree=degree])
; INPUTS:
;	DATA1,DATA2 = one or two dimensional data
;		      number of elements must be even
;		      in each dimension
; OPTIONAL INPUT PARAMETERS:
;	RANGE: Range for minimum- and maximumfit (from pos-RANGE to pos+RANGE;
;		   default: RANGE=2; should be less then (size(data)-1)/2 )
;	DEGREE: Degree of polynomial fit for evaluating maximum and minimum
;			position. Default value is 4.
; KEYWORDS:
; 	CUT: if set, smooth boundary down to zero
;	     with a cosine-function
;   NOSHIFT: if set, corr is not shifted
;	PMIN: if set, PMAX returns minimum position of correlationfunction
; OUTPUTS:
;	CORR = 	cross-correlation-function with
;		same size as input-data (float-type)
;		corr is shifted so that the origin is
;		centered. On error -1 is returned.
; OPTIONAL OUTPUT PARAMETERS:
;	PMAX = Returns position of maximum (or minimum, if /PMIN ist set) of
;		   crosscorrelationfunction either one- or two-dimensional [x,y],
; SIDE-EFFECTS:
;	Uses polyfit2d for evaluating maximum and minimum for two-dim. data
; HISTORY:
;	Written by: Juergen Hofmann, 12.8.91
;       Last Modification: Juergen Hofmann, 12.2.92
;		
;-
;

	;
	;	Newton-Approximation for 1-dim minimum or maximum search
	;

	FUNCTION _NEWTON,GUESS,ORDER,COEF

	on_error,2

	for j=1,4 do begin

	;
	;	evaluate derivate
	;

	x=double(guess)

	df=0.D
	for i=1,order do df=df+coef(i)*x^(i-1)*i

	d2f=0.D
	for i=2,order do d2f=d2f+coef(i)*x^(i-2)*(i-1)*i

	x=x-df/d2f

	endfor
	
	return,x
	end

;
;
; MAIN MAIN MAIN MAIN MAIN MAIN MAIN MAIN 
;
;

FUNCTION CROSSCORR,DATA1,DATA2,PMAX,cut=cut,noshift=noshift,pmin=pmin,$
	range=range,degree=degree

	on_error,2

;
;Range for Polynom-Fitting
;
if n_elements(range) eq 0 then range=2
if n_elements(degree) eq 0 then degree=4


dat1=reform(data1)
dat2=reform(data2)

;
;Check data:
;

case (size(dat1))(0) of
1: begin

	if(n_elements(dat1) ne n_elements(dat2)) then begin
		print,'Crosscorr: Both data sets should have same size!'
		return,-1
		endif

	if(n_elements(dat1)/2 ne n_elements(dat1)/2.) then begin
		print,'Crosscorr: Number of Elements must be even!'
		return,-1
		endif

	if (size(dat1))(1) le range*2+1 then begin
		print,'Crosscorr: Range must be less then',((size(dat1))(1)-1)/2
		return,-1
		endif
	end

2: begin

	if( (size(dat1))(1) ne (size(dat2))(1)) then begin
		print,'Crosscorr: Both data sets should have same size!'
		return,-1
		endif
	if( (size(dat1))(2) ne (size(dat2))(2)) then begin
		print,'Crosscorr: Both data sets should have same size!'
		return,-1
		endif

	if((size(dat1))(1)/2 ne (size(dat1))(1)/2. or (size(dat1))(2)/2 ne (size(dat1))(2)/2. ) then begin
		print,'Crosscorr: Number of Elements must be even!'
		return,-1
		endif

	if (size(dat1))(1) le range*2+1 then begin
		print,'Crosscorr: Range must be less then',((size(dat1))(1)-1)/2
		return,-1
		endif
	if (size(dat1))(2) le range*2+1 then begin
		print,'Crosscorr: Range must be less then',((size(dat1))(2)-1)/2
		return,-1
		endif
	end

else:begin
	print,'Crosscorr: Data neither 1 nor 2-dimensional'
	return,-1
	end
endcase

;
;Calculate apodisation
;

if keyword_set(cut)  then begin

	case (size(dat1))(0) of

	1: begin
		nel=n_elements(dat1)-1
		n=nel/10
		cosg=sin(indgen(n+1)*!PI/2./n)
		dat1(0:n)=dat1(0:n)*cosg
		dat2(0:n)=dat2(0:n)*cosg
		cosg=reverse(cosg)
		n=nel-n
		dat1(n:nel)=dat1(n:nel)*cosg
		dat2(n:nel)=dat2(n:nel)*cosg

		end
	2: begin
		nel1=n_elements(dat1(*,0))-1
		nel2=n_elements(dat1(0,*))-1
		n=nel1/10
		cosg=fltarr(n+1,nel2+1)
		for	 i=0,nel2 do cosg(*,i)=sin(indgen(n+1)*!PI/2./n)
		dat1(0:n,*)=dat1(0:n,*)*cosg
		dat2(0:n,*)=dat2(0:n,*)*cosg
		cosg=reverse(cosg)
		n=nel1-n
		dat1(n:nel1,*)=dat1(n:nel1,*)*cosg
		dat2(n:nel1,*)=dat2(n:nel1,*)*cosg

		n=nel2/10
		cosg=fltarr(nel1+1,n+1)
		for i=0,nel1 do	cosg(i,*)=sin(indgen(n+1)*!PI/2./n)
		dat1(*,0:n)=dat1(*,0:n)*cosg
		dat2(*,0:n)=dat2(*,0:n)*cosg
		cosg=reverse(cosg,2)
		n=nel2-n
		dat1(*,n:nel2)=dat1(*,n:nel2)*cosg
		dat2(*,n:nel2)=dat2(*,n:nel2)*cosg
		end
	endcase
endif


;
;
;Now calculate Crosscorrelationfunction
;

cdat1=fft(dat1,-1)
cdat2=fft(dat2,-1)


case (size(dat1))(0) of

	1: begin
		cdat1(0)=complex(0.,0.)
		cdat2(0)=complex(0.,0.)

		cdat1(n_elements(cdat1)-1)=complex(0.,0.)
		cdat2(n_elements(cdat2)-1)=complex(0.,0.)
		end
	2: begin 
		nel1=n_elements(cdat1(*,0))-1
		nel2=n_elements(cdat1(0,*))-1
		ca=replicate(complex(0.,0.),nel1+1,nel2+1)
		cdat1(0,*)=ca(0,*)
		cdat2(0,*)=ca(0,*)
		cdat1(*,0)=ca(*,0)
		cdat2(*,0)=ca(*,0)

		cdat1(nel1,*)=ca(0,*)
		cdat2(nel1,*)=ca(0,*)
		cdat1(*,nel2)=ca(*,0)
		cdat2(*,nel2)=ca(*,0)
		end
	else:begin
		print,'Crosscorr: Data neither 1 nor 2-dimensional'
		return,-1
		end
	endcase

p1=0D0
p2=0D0

p1=total(double(abs(cdat1)^2))
p2=total(double(abs(cdat2)^2))

p=sqrt(p1*p2)

cdat1=cdat1*conj(cdat2)/p

out=float(fft(cdat1,1))

;
;Shift OUTPUT:
;

if not keyword_set(noshift) then begin

	case (size(out))(0) of
	1: out=shift(out,(size(out))(1)/2)
	2: out=shift(out,(size(out))(1)/2,(size(out))(2)/2)
	endcase

endif


;
;Calculate Maximum or Minimum if required
;
;Maximum:


if n_params() eq 3 then begin
if not keyword_set(pmin) then begin

	case (size(out))(0) of

	1:begin
		pmax=0.
		m=max(out,pos)
		y=shift(out,-(pos-range))
		y=y(0:2*range)
		coeff=poly_fit(indgen(range*2+1),y,degree)
		pmax=_newton(range,degree,coeff)
		pmax=pmax+(pos-range)
		if pmax gt (size(out))(1)/2 then pmax=pmax-(size(out))(1)
	end

	2:begin
		pmax=fltarr(2)
		m=max(out,pos)
		xpos=pos mod (size(out))(1)
		ypos=pos/(size(out))(1)
		y=shift(out,-(xpos-range),-(ypos-range))
		y=y(0:2*range,0:2*range)
		pmax = polyfit2d(y,degree,/max)
		pmax(0)=pmax(0)+(xpos-range)
		pmax(1)=pmax(1)+(ypos-range)
		if pmax(1) gt (size(out))(2)/2 then pmax(1)=pmax(1)-(size(out))(2)
		if pmax(0) gt (size(out))(1)/2 then pmax(0)=pmax(0)-(size(out))(1)

	end

	endcase

endif else begin
;
;Minimum:
;

	case (size(out))(0) of

	1:begin
		pmin=0.
		m=min(out,pos)
		y=shift(out,-(pos-range))
		y=y(0:2*range)
		coeff=poly_fit(indgen(range*2+1),y,degree)
		pmin=_newton(range,degree,coeff)
		pmin=pmin+(pos-range)
		if pmin gt (size(out))(1)/2 then pmin=pmin-(size(out))(1)
		pmax=pmin
	end

	2:begin
		pmin=fltarr(2)
		m=min(out,pos)
		xpos=pos mod (size(out))(1)
		ypos=pos/(size(out))(1)
		y=shift(out,-(xpos-range),-(ypos-range))
		y=y(0:2*range,0:2*range)
		pmin = polyfit2d(y,degree,/min)
		pmin(0)=pmin(0)+(xpos-range)
		pmin(1)=pmin(1)+(ypos-range)
		if pmin(1) gt (size(out))(2)/2 then pmin(1)=pmin(1)-(size(out))(2)
		if pmin(0) gt (size(out))(1)/2 then pmin(0)=pmin(0)-(size(out))(1)
		pmax=pmin
	end

	endcase
endelse
endif

return,out
end
