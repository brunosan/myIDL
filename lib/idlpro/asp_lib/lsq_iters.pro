pro lsq_iters_usage
;+
;
;	procedure:  lsq_iters
;
;	purpose:  non linear least squares driver.
;
;	author:  paul@ncar, 10/94      (minor mod's by rob@ncar)
;
;	routines:  lsq_iters_usage  lsq_fprob  lsq_fmatrix
;		   lsq_iters
;
;==============================================================================
;
if 1 then begin
	print
	print, "usage:	lsq_iters, hard $"
	print, "	, a, sderror $"
	print, "	, itsmax, flevel, dtot $"
	print, "	, iter, cappa0, dchi, probf"
	print
	print, "	Non linear least squares driver."
	print
	print, "	Arguments:"
	print, "		hard	- hard wired application (string)"
	print, "		a	- input/output parameters set"
	print, "		flevel	- input max f-probability"
	print, "			  convergence"
	print, "		dtot	- input total number of data points"
	print, "		itsmax	- input max number of iterations"
	print, "		sderror	- output standard error fitted"
	print, "			  parameters"
	print, "		iter	- number of iterations used"
	print, "		cappa0	- (1+cappa0) factor used for"
	print, "			  Marquardt's algorithm"
	print, "		dchi	- fractional change in chi-square"
	print, "		probf	- f-probability"
	print
	print, "	Keywords:"
	print, "		noprint	- set to prevent printing"
	print, "			  to console"
	print, "		trace	- output structure with convergence"
	print, "			  trace"
	return
endif
;-
end
;-----------------------------------------------------------------------------
;
;	function:  lsq_fprob
;
;	purpose:  compute probablity of exceeding f in an f-distribution
;		  with ss1/ss2 degrees of fredom
;
;	author:  unknown
;
;-----------------------------------------------------------------------------
function lsq_fprob, f, ss1, ss2

if ss1 le 0. or ss2 le 0. or f le 0. then  return, 1.

g	= f^.33333333
s1	= .22222222/ss1
s2	= .22222222/ss2
u	= ((1.-s2)*g-1.+s1)/sqrt(2.*(s2*g^2+s1))
return,	abs(.5*(1.-errorf(u)))

end
;-----------------------------------------------------------------------------
;
;	procedure:  lsq_fmatrix
;
;	purpose:  does matrix inversion for lsq_iters.pro
;
;-----------------------------------------------------------------------------
pro lsq_fmatrix, a

;	DO PARTIAL INVERSION OF MATRIX a(nv,nv)
;
;	INPUT:
;
;	a(nv,nv) ~ matrix of sums of cross-products
;
;	(1) The matrix is assumed to be a sums of
;	    cross-products matrix.  It will be symetric
;	    with all diagonal elements positive or zero.
;	(2) Row and column 1 correspond to the
;	    dependent variable.
;
;	OUTPUT:
;
;	a(nv,nv) ~ partially inverted matrix of sums of cross-products
;
;	(1) This matrix will be symetric.
;	(2) A diagonal element will be negative only
;	    if the corresponding independent variable
;	    was used for matrix inversion.
;	(3) The inverse matrix is negative.
;	(4) The inverse times the 'beta' vector will be in the
;	    first row or column.   The 'beta' vector is the 
;	    sums of cross-products of fit-error vs. derivatives.
;
;	Reference:
;	Jennrich RI, Stepwise Regression;
;	Enslein K, Ralston A, Wilf HS; editors;
;	Statistical Methods for Digital Computers;
;	Volume III of
;	Mathematical Methods for Digital Computers;
;	John Wiley & Sons, 1977, pages 58-75

				    ;Get size of parameter set.
size_a = size(a)
nv     = size_a(1)
				    ;Initialize arrays.
diag = dblarr(nv)
ifused = lonarr(nv)
				    ;Save initial diagonal.
				    ;Get matrix rank.
n=0
for k=0,nv-1 do begin
	diag(k) = a(k,k)
	if diag(k) ne 0. then  n=k
end
				    ;MAIN LOOP THROUGH PIVOTS
for k=1,n do begin
				    ;TEST FOR SINGULAR PIVOT
	if diag(k) ne 0. then begin
	if a(k,k)/diag(k) gt .00001 then begin

				    ;FLAG THAT THIS PIVOT HAS BEEN USED
		ifused(k) = 1
				    ;MOSTLY WILL USE PIVOT AS DEVISOR
		piv = 1./a(k,k)
				    ;DO GAUSSIAN ELLIMINATION
		for j=0,n do begin
		    if j ne k then begin
			zip = a(j,k)*piv
			a(0:n,j) = a(0:n,j)-a(0:n,k)*zip
		    end
		end
				    ;DEVIDE COLUMN CORRESPONDING TO
				    ;DIAGONAL ELEMET BY PIVOT
		a(0:n,k) = a(0:n,k)*piv

				    ;REPLACE PIVOT ROW BY CORRESPONDING COLUMN
		a(k,0:n) = a(0:n,k)
				    ;SET DIAGONAL ELEMENT TO -1./a(k,k)
		a(k,k) = -piv
				    ;LINEARLY DEPENDENT VARIABLES SHOULD
				    ;HAVE ZERO ON DIAGONAL.
				    ;MAKE SURE DIAGONAL HASN'T ROUNDED
				    ;OFF PAST ZERO.
		for j=0,n do begin
		    if ifused(j) eq 0 then begin
			a(j,j) = 0. > a(j,j)
		    end else begin
			a(j,j) = 0. < a(j,j)
		    end
		end

	end
	end

end

end
;------------------------------------------------------------------------------
;
;	procedure:  lsq_iters
;
;	purpose:  non linear least squares driver.
;
;------------------------------------------------------------------------------
pro lsq_iters, hard $
, a, sderror $
, itsmax, flevel, dtot $
, iter, cappa0, dchi, probf $
, noprint=noprint $
, trace=trace
				    ;Check number of parameters.
if n_params() eq 0 then begin
	lsq_iters_usage
	return
end
				    ;Size of parameter set.
size_a = size(a)
nv     = size_a(1)
				    ;Check if console printing
				    ;is prevented.
if n_elements(noprint) eq 0  $
then  ctype = 1  $
else  ctype = noprint eq 0
				    ;Zero iteration story.
iter   = 0
cappa0 = 0.
dchi   = 0.
probf  = 0.
sderror = fltarr(nv)
trace = $
{ iter:		0 $
, csq:		fltarr(itsmax+1) $
, cappa0:	fltarr(itsmax+1) $
, dchi:		fltarr(itsmax+1) $
, probf:	fltarr(itsmax+1) $
}
				    ;Initial fit.
case hard of
'lsq_xt': lsq_xt_delfit, iter, dtot
end
				    ;Sum cross-products matrix from
				    ;residuals & derivatives.
case hard of
'lsq_xt': lsq_xt_sums, alfa
end
				    ;DETERMINE DIMENSION OF SUMS
				    ;OF CROSS-PRODUCTS MATRIX
				    ;ALSO ZERO THE STANDARD ERRORS
nfit = 0
for i=1,nv-1 do  if alfa(i,i) gt 0 then  nfit=i

				    ;FINISHED IF ALL PARAMETERS ARE FIXED
if nfit eq 0 then  return
				    ;MAIN LEAST-SQUARES ITERATION LOOP
for ita=1,itsmax do begin
				    ;SAVE ONGOING PARAMETERS.
	b = a
				    ;SAVE ONGOING INTERATION CONTROL
				    ;INFORMATION AND FITTED ARRAYS.
	itssav  = iter
	capsav  = cappa0
	dchsav  = dchi
	prbsav  = probf
	case hard of
	'lsq_xt': lsq_xt_fitsav
	end
				    ;ITERATION NUMBER
	iter = ita
				    ;ONGOING CHI-SQUARE
	chi = alfa(0,0)
	chid = alfa(0,0)
				    ;SINGULAR MATRIX IS HARD TO DETECT
				    ;USING MARQUARDT'S ALGORITHM.
				    ;A MATRIX INVERSION IS DONE SEPARATELY
				    ;TO ACCOUNT FOR SINGULAR MATRIX.
	array=alfa
	lsq_fmatrix, array
				    ;ZERO LINEARLY DEPENDENT ROWS AND
				    ;COLUMNS OF alfa.
	for j=1,nv-1 do begin
	if array(j,j) ge 0. then begin
		alfa(j,*) = 0.
		alfa(*,j) = 0.
	end
	end
				    ;USE INCREASING VALUES OF cappa0
				    ;UNTIL BETTER FIT IS FOUND
	for ila=0,999 do begin
				    ;RESTORE PARAMETERS
		a = b
				    ;COPY OF CROSS-PRODUCTS MATRIX
				    ;(FROM PRIOR ITERATION)
		array = alfa
				    ;SET cappa0 FOR MARQUARDT'S ALGORITHM
		if ila eq 0 then begin

				    ;DECREASE cappa0 BEGINNING EACH ITERATION
			cappa0 = .000001 > cappa0/2.
			if iter eq 1 then cappa0 = .000512
		end else begin
				    ;INCREASE cappa0 IF PRIOR VALUE
				    ;DIDN'T IMPROVE FIT
			cappa0 = 8.*cappa0
		end
				    ;EXIT ITERATIONS IF cappa0 BECAME
				    ;TOO LARGE
		if cappa0 gt 100. then begin

				    ;RESTORE BEST FIT
			iter   = itssav
			cappa0 = capsav
			dchi   = dchsav
			probf  = prbsav
			case hard of
			'lsq_xt': lsq_xt_fitsav, /restore
			end
				    ;FLAG THAT cappa0 BECAME LARGE
			cappa0 = -cappa0
			goto, brk3001
		end
				    ;APPLY cappa0
		cappa = 1.+cappa0
		array(*,0) = cappa*alfa(*,0)
		array(0,*) = cappa*alfa(0,*)
		for i=0,nv-1 do  array(i,i) = cappa*alfa(i,i)

				    ;MATRIX INVERSION
		lsq_fmatrix, array
				    ;GET DELTA PARAMETERS
		dfit = fltarr(nv)
		for j=1,nv-1 do  if array(j,j) lt 0. then  dfit(j)=array(j,0)

				    ;PUT CONSTRAINTS ON DELTA PARAMETERS
		case hard of
		'lsq_xt': lsq_xt_bound, dfit
		end
				    ;MAKE SURE ONLY PARAMETERS IN
				    ;MATRIX INVERSION CHANGE
		for j=1,nv-1 do  if array(j,j) ge 0. then   dfit(j) = 0.

				    ;ADD DELTA PARAMETERS TO PARAMETERS
		a = a+dfit
				    ;GET TENTATIVE FIT, DERIVATIVES,
		case hard of
		'lsq_xt': begin
			lsq_xt_delfit, iter, dtot
			lsq_xt_sums, alftemp
			end
		end
				    ;TENTATIVE CHI-SQUARE
		csq = alftemp(0,0)
				    ;EXIT cappa0 LOOP IF FIT IS IMPROVED
		if csq lt chid then  goto, brk2001

				    ;END LOOP ON INCREASING VALUES OF cappa0
	end
	brk2001:
				    ;SAVE CROSS PRODUCTS MATRIX FOR NEXT
				    ;ITERATION OR STANTARD ERRORS
	alfa = alftemp
				    ;FRACTIONAL CHANGE IN CHI-SQUARE
	dchid = (chid-csq)/chid
	dchi  = (chid-csq)/chid
				    ;FIND LARGEST F-RATIO
	dfree = dtot
	ratio = 0.
	for i=1,nv-1 do begin
	if array(i,i) lt 0. then begin
		dfree = dfree-1.
		ratio = ratio > (-array(i,0)^2/array(i,i))
	end
	end
				    ;F-PROBABILITY OF LARGEST F-RATIO
	if array(0,0) ne 0. then begin
		fratio = dfree*ratio/array(0,0)
		probf  = lsq_fprob( fratio, 1., dfree )
	end else begin
		probf  = 0.
	end
				    ;PRINT OUT CONVERGENCE INFO.
	if iter eq 1 then begin
		if ctype then $
		print, 'iter   chi        fla        dchi     f-prob'
		if ctype then  print, chi, format='(e14.3)'
		trace.csq(0) = chi
	end
	if ctype then  print, iter, csq, cappa0, dchi, probf $
	, format='(i3,3e11.3,f8.4)'
	trace.iter         = iter
	trace.csq(iter)    = csq
	trace.cappa0(iter) = cappa0
	trace.dchi(iter)   = dchi
	trace.probf(iter)  = probf
				    ;CHECK FOR CONVERGENCE:
	if  iter ge 3  and  dchi lt .01  and  probf gt .1 then begin

				    ;EXIT IF F-PROBABILITY IS TO HIGH
		if    flevel ne 0. $
		and   prbsav gt flevel  $
		and   probf gt flevel  $
		then  goto, brk3001

				    ;EXIT IF CHANGE IN chi IS TO LOW
		if dchid lt 5.e-6 then goto, brk3001
	end
end
brk3001:
				    ;COPY CROSS-PRODUCTS MATRIX
array = alfa
				    ;MATRIX INVERSION
lsq_fmatrix, array
				    ;DEGREES OF FREEDOM
dfree = dtot
for j=1,nv-1 do  if array(j,j) lt 0. then  dfree=dfree-1.

				    ;STANDARD ERRORS
sderror = fltarr(nv)
for j = 1,nv-1 do $
if array(j,j) lt 0. then  sderror(j)=sqrt(-array(0,0)*array(j,j)/dfree)

end
