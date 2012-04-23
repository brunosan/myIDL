;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; NAME:
;       COS_FIT
;       COSI
; PURPOSE:
;       Simplified call to CURVEFIT to fit a cosine
;	f= a0 * cos(x-a1) + a2
; CATEGORY:
;       Curve fitting
; CALLING SEQUENCE:
;       COS_FIT,x,y,par,nostart=nostart,yfit=yfit
;       COSI,x,par,f [,pder]
; INPUTS:
;       x - vector with independent data values
;       y - vector with dependent data values
; OPTIONAL INPUT PARAMETERS:
;       par - if keyword NOSTART is specified, 'par' should
;             be of proper dimension and  contain start values
;             for the iteration
; KEYWORDS:
;       nostart - if present and non-zero, do not calculate
;                 starting values for parameters, but use
;                 user supplied values in 'par'.
;       yfit    - if given, return fitted values for data in
;                 input vector x.
; OUTPUTS:
;       par     - fit parameters, for use as input in  COSI
;       f       - fittet values for x (in COSI) using parameters 'par'
;       pder    - if given, calculate partial derivates and store
;                 in 'pder'
;
; MODIFICATION HISTORY:
;       written JAN 93, Reinhold Kroll
;
;-----------------------------------------------------------------------
;
; simplified call to curvefit
; to evaluate a cosine
;
pro cosi,x,a,f,pder
on_error,2
pname='COSI'

np=n_params()
if np lt 3 or np gt 4 then begin
        txt='calling sequence: '+pname+',x,par,f[,pder]'
        message,txt
        endif

arg=x-a(1)
cosx=cos(arg)
f=a(0)*cosx+a(2)
;
; derivatives?
;
if np le 3 then return
pder=fltarr(n_elements(x),3)
pder(*,0)=cosx
pder(*,1)=a(0)*sin(arg)
pder(*,2)=1.
return
end
;
;
pro cos_fit,x,y,par,nostart=nostart,yfit=yfit
on_error,2
pname='COS_FIT'
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
        message,'aborted with error'
        endif

if (keyword_set(nostart)) and (n_elements(par) ne 3) then begin
        print,mess,'you must supply a 3-element vector'
        print,mess,'for parameters with starting values' 
        print,mess,'your parameter vector has ',n_elements(par) 
        message,'aborted with error'
        endif


maxy=max(y,pymax)
miny=min(y,pymin)
maxx=max(x,pxmax)
minx=min(x,pxmin)
;
; starting values, if not suppressed
;
if not keyword_set(nostart) then begin
	par=fltarr(3)
        par(0)=(maxy-miny)/2.
        par(1)=pymax
        par(2)=total(y)/(nely+1)
        endif

w=fltarr(n_elements(x)) + 1. ; equal weights for all data
yfit=curvefit(x,y,w,par,sig,funct='cosi')
return
end
