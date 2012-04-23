;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; NAME:
;	GS_FIT
;	GS
; PURPOSE:
;	Simplified call to CURVEFIT to fit a gaussian with 
;	constant background.
;	f = a0 * exp( ((x-a1)/a2)**2/2.) + a3
; CATEGORY:
;	Curve fitting
; CALLING SEQUENCE:
;	GS_FIT,x,y,par,nostart=nostart,yfit=yfit	
;	GS,x,par,f [,pder]
; INPUTS:
;	x - vector with independent data values
;	y - vector with dependent data values
; OPTIONAL INPUT PARAMETERS:
;	par - if keyword NOSTART is specified, 'par' should 
;	      be of proper dimension and  contain start values
;	      for the iteration
; KEYWORDS:
;	nostart	- if present and non-zero, do not calculate
;		  starting values for parameters, but use
;		  user supplied values in 'par'.
;	yfit	- if given, return fitted values for data in 
;		  input vector x.
; OUTPUTS:
;	par	- fit parameters, for use as input in  GS
;	f	- fittet values for x (in GS) using parameters 'par'
;	pder	- if given, calculate partial derivates and store
;		  in 'pder'
;
; MODIFICATION HISTORY:
;	written JAN 93, Reinhold Kroll
;
;-----------------------------------------------------------------------
;
;
pro gs,x,a,f,pder
on_error,2
pname='GS'

np=n_params()
if np lt 3 or np gt 4 then begin
        txt='calling sequence: '+pname+',x,par,f[,pder]'
        message,txt
        endif

arg=(x-a(1))/a(2)
arg2=arg*arg 
; next two lines hardware dependent!
if datatype(x,2) lt 5 then minnum=alog(1.2e-38) 	; int, long or float
if datatype(x,2) eq 5 then minnum=alog(2.3d-308)	; double
rarg= -arg2/2. > minnum 	; avoid underflow errors
exarg=exp(rarg)
f=a(0)*exarg+a(3)
;
; derivatives?
;
if np le 3 then return
pder=fltarr(n_elements(x),4)
pder(*,0)=exarg
pder(*,1)=a(0)*pder(*,0)*arg/a(2)
pder(*,2)=pder(*,1)*arg
pder(*,3)=1.
return
end
;
; 
;
pro gs_fit,x,y,par,nostart=nostart,yfit=yfit
on_error,2
pname='GS_FIT'
mess=!msg_prefix+pname+': '

if n_params() ne 3 then begin
        txt='calling sequence: '+pname+',x,y,par'
        message,txt
        endif

nelx=n_elements(x)-1
nely=n_elements(y)-1
if nelx ne nely then begin
	print,mess,'x,y must be of same dimension!'
	print,mess,'you have ',nelx+1,' , ',nely+1
	message,' aborted with error'
	endif

if (keyword_set(nostart)) and (n_elements(par) ne 4) then begin
        print,mess,'you must supply a 4-element vector'
        print,mess,'for parameters with starting values' 
        print,mess,'your parameter vector has ',n_elements(par)
	message,' aborted with error'
        endif


maxy=max(y,pymax)
miny=min(y,pymin)
maxx=max(x,pxmax)
minx=min(x,pxmin)
;
; starting values, if not suppressed
;
if not keyword_set(nostart) then begin
	par=fltarr(4)
	par(0)=maxy-miny
	par(1)=(x(nelx)-x(0))/2.
	par(2)=(maxx-minx)/4.
	par(3)=(y(0)+y(nelx))/2.
	if y(nelx/2) lt par(3) then par(0)=-par(0)
	endif

w=fltarr(nelx+1) + 1. ; equal weights for all data
yfit=curvefit(x,y,w,par,sig,funct='gs')
return
end
