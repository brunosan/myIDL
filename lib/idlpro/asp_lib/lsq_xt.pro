pro lsq_xt_usage
;+
;
;	procedure:  lsq_xt
;
;	purpose:  do least squares fit of ASP X & T matrix.
;
;	author:  paul@ncar, 10/94      (minor mod's by rob@ncar)
;
;	routines:  lsq_xt_usage  lsq_xt_set
;		   lsq_xt_iline  lsq_xt_inn
;                  lsq_xt_readf  lsq_xt_gen
;		   lsq_xt_bound  lsq_xt_fitsav
;		   lsq_xt_sums   lsq_xt_delfit
;		   lsq_xt_chisq
;		   lsq_xt_oline  lsq_xt_out
;		   lsq_xt
;
;==============================================================================
;
if 1 then begin
	print
	print, "usage:	lsq_xt, ifile [,ofile]"
	print
	print, "	Do least squares fit of ASP X & T matrix."
	print
	print, "	Arguments:"
	print, "		ifile	- input control file (string)"
	print, "		ofile	- output control file"
	print, "			  (string; def=ifile+'.out')"
	print, "	Keywords:"
	print, "		noprint	- set to prevent printing"
	print, "			  to console"
	print, "		tfile	- output file suitable to"
	print, "			  be read by get_t.pro"
	print, "			  (def: not output)"
	print, "		xfile	- output file suitable to"
	print, "			  be read by aspcal.pro"
	print, "			  (def: not output)"
	return
endif
;-
end
;------------------------------------------------------------------------------
;
;	procedure:  lsq_xt_set
;
;	purpose:  set common for lsq_xt.
;
;------------------------------------------------------------------------------
pro lsq_xt_set
				    ;Specify common.
@lsq_xt.com
				    ;Set blank 256 character string.
bb = '                                '
bb = bb+bb & bb=bb+bb
blank256 = bb+bb
				    ;Radians per degree.
rpd = (!pi/180.)
				    ;Reasonable perturbation for
				    ;derivatives wrt angles.
da = .0001*rpd
				    ;Parameter locations in arrays.
				    ;
				    ;Order usually does not change
				    ;the answer. 
				    ;
				    ;If paramaters that are held constant
				    ;appear last the rank for matrix
				    ;inversion is reduced.
				    ;
				    ;If the matrix is singular parameter
				    ;order determines which redundant
				    ;parameter is fit.
				    ;
				    ;Names and perturbations for numerical
				    ;derivatives are also set here.
ptb = fltarr(1000)
names = strarr(1000)
n=0
n=n+1 &   nquec=n & ptb(n)= .0001   &  names(n)='quec'
n=n+1 &   nveec=n & ptb(n)= .0001   &  names(n)='veec'
n=n+1 &   nque4=n & ptb(n)= .0001   &  names(n)='que4'
n=n+1 &   nvee4=n & ptb(n)= .0001   &  names(n)='vee4'
n=n+1 &   nque5=n & ptb(n)= .0001   &  names(n)='que5'
n=n+1 &   nvee5=n & ptb(n)= .0001   &  names(n)='vee5'
n=n+1 &    nrn0=n & ptb(n)= .000001 &  names(n)='rn0'
n=n+1 &    nrk0=n & ptb(n)= .00001  &  names(n)='rk0'
n=n+1 &    nrt0=n & ptb(n)= .001    &  names(n)='rt0'
n=n+1 & noffinc=n & ptb(n)= da      &  names(n)='offinc'
n=n+1 & noffin4=n & ptb(n)= da      &  names(n)='offin4'
n=n+1 & noffin5=n & ptb(n)= da      &  names(n)='offin5'
n=n+1 & noffout=n & ptb(n)= da      &  names(n)='offout'
n=n+1 & nwinret=n & ptb(n)= da      &  names(n)='winret'
n=n+1 & nwinang=n & ptb(n)= da      &  names(n)='winang'
n=n+1 &  nexret=n & ptb(n)= da      &  names(n)='exret'
n=n+1 &  nexang=n & ptb(n)= da      &  names(n)='exang'
n=n+1 &   nquel=n & ptb(n)= .0001   &  names(n)='quel'
n=n+1 &   nveel=n & ptb(n)= .0001   &  names(n)='veel'
n=n+1 & noffinl=n & ptb(n)= da      &  names(n)='offinl'
n=n+1 &   ngain=n & ptb(n)= .0001   &  names(n)='gain'
n=n+1 &    nx11=n & ptb(n)= .0001   &  names(n)='x11'
n=n+1 &    nx21=n & ptb(n)= .0001   &  names(n)='x21'
n=n+1 &    nx31=n & ptb(n)= .0001   &  names(n)='x31'
n=n+1 &    nx41=n & ptb(n)= .0001   &  names(n)='x41'
n=n+1 &    nx12=n & ptb(n)= .0001   &  names(n)='x12'
n=n+1 &    nx22=n & ptb(n)= .0001   &  names(n)='x22'
n=n+1 &    nx32=n & ptb(n)= .0001   &  names(n)='x32'
n=n+1 &    nx42=n & ptb(n)= .0001   &  names(n)='x42'
n=n+1 &    nx13=n & ptb(n)= .0001   &  names(n)='x13'
n=n+1 &    nx23=n & ptb(n)= .0001   &  names(n)='x23'
n=n+1 &    nx33=n & ptb(n)= .0001   &  names(n)='x33'
n=n+1 &    nx43=n & ptb(n)= .0001   &  names(n)='x43'
n=n+1 &    nx14=n & ptb(n)= .0001   &  names(n)='x14'
n=n+1 &    nx24=n & ptb(n)= .0001   &  names(n)='x24'
n=n+1 &    nx34=n & ptb(n)= .0001   &  names(n)='x34'
n=n+1 &    nx44=n & ptb(n)= .0001   &  names(n)='x44'
n=n+1 &  nbias0=n & ptb(n)= .0001   &  names(n)='bias0'
n=n+1 &  nbiasl=n & ptb(n)= .0001   &  names(n)='biasl'
n=n+1 &  nbiasc=n & ptb(n)= .0001   &  names(n)='biasc'
n=n+1 &   nyouc=n & ptb(n)= .0001   &  names(n)='youc'
n=n+1 &   neyec=n & ptb(n)= .0001   &  names(n)='eyec'
n=n+1 &   nyoul=n & ptb(n)= .0001   &  names(n)='youl'
n=n+1 &   neyel=n & ptb(n)= .0001   &  names(n)='eyel'
n=n+1 & noffin0=n & ptb(n)= da      &  names(n)='offin0'
n=n+1 &   nvee0=n & ptb(n)= .0001   &  names(n)='vee0'
n=n+1 &   nyou0=n & ptb(n)= .0001   &  names(n)='you0'
n=n+1 &   nque0=n & ptb(n)= .0001   &  names(n)='que0'
n=n+1 &   neye0=n & ptb(n)= .0001   &  names(n)='eye0'
n=n+1 &   neye4=n & ptb(n)= .0001   &  names(n)='eye4'
n=n+1 &   nyou4=n & ptb(n)= .0001   &  names(n)='you4'
n=n+1 &   neye5=n & ptb(n)= .0001   &  names(n)='eye5'
n=n+1 &   nyou5=n & ptb(n)= .0001   &  names(n)='you5'
n=n+1 &  nbias4=n & ptb(n)= .0001   &  names(n)='bias4'
n=n+1 &  nbias5=n & ptb(n)= .0001   &  names(n)='bias5'
n=n+1 &     ntx=n & ptb(n)= .0001   &  names(n)='tx'
n=n+1 &     nty=n & ptb(n)= .0001   &  names(n)='ty'
n=n+1 &   nrtda=n & ptb(n)= da      &  names(n)='rtda'
n=n+1 &    nrtd=n & ptb(n)= da      &  names(n)='rtd'
n=n+1 &   nerar=n & ptb(n)= da      &  names(n)='erar'
n=n+1 &    ndlc=n & ptb(n)= da      &  names(n)='dlc'
n=n+1 &   nrrsm=n & ptb(n)= .0001   &  names(n)='rrsm'
n=n+1 &   nrrdf=n & ptb(n)= .0001   &  names(n)='rrdf'
n=n+1 &   neye3=n & ptb(n)= .0001   &  names(n)='eye3'
n=n+1 &   nque3=n & ptb(n)= .0001   &  names(n)='que3'
n=n+1 &   nyou3=n & ptb(n)= .0001   &  names(n)='you3'
n=n+1 &   nvee3=n & ptb(n)= .0001   &  names(n)='vee3'
n=n+1 & noffin3=n & ptb(n)= da      &  names(n)='noffin3'
n=n+1 &  nbias3=n & ptb(n)= .0001   &  names(n)='bias3'

				    ;Number of parameters.
				    ;This includes 0 location which
				    ;is reserved for residuals.
nv = n+1
				    ;Truncate names & perturbatin array.
ptb = ptb(0:nv-1)
names = names(0:nv-1)
				    ;Create some arrays that span 
				    ;fitted parameter space.
iffit = lonarr(nv)
fits  = fltarr(nv)
gfit  = fltarr(nv)

end
;------------------------------------------------------------------------------
;
;	procedure:  lsq_xt_iline
;
;	purpose: read one parameter line from input control file.
;
;------------------------------------------------------------------------------
pro lsq_xt_iline, npar, ixon
				    ;Specify common.
@lsq_xt.com
				    ;Read line from file.
a='' & readf, utmp, a

jfit = 0L
parm = 0.
ixon = 0L
				    ;Return if has no parameter number.
case n_params() of
0: return
1: reads, a, format='(11x,i1,f16.0)', jfit, parm
2: reads, a, format='(5x,i1,i6,f16.0)', ixon, jfit, parm
end

				    ;Move data to arrays.
iffit(npar)=jfit &  fits(npar)=parm

end
;------------------------------------------------------------------------------
;
;	procedure:  lsq_xt_inn
;
;	purpose:  read input control file for lsq_xt
;
;------------------------------------------------------------------------------
pro lsq_xt_inn, ifile
				    ;Specify common.
@lsq_xt.com
				    ;Open input control file.
openr, /get_lun, utmp, ifile, error=error
if error ne 0 then begin
	print, !err_string
	stop
end
				    ;Maximum number of data files.
ndf = 6
				    ;File names.
files = strarr(ndf)
				    ;Flags if file is fitted.
iffile = lonarr(ndf)
				    ;Flags if is to be normalized.
ifnorm = lonarr(ndf)
				    ;File fitting weights.
wght = fltarr(ndf)
				    ;Read flevel
flevel=0.  &  readf, utmp, format='(f5.2)', flevel

				    ;Read data file paths with flags to fit.
a='' &  for i=0,2 do  readf, utmp, a
wt=0. & fi=0L & fl=''
fmt='(f10.0,1x,i1,1x,a )'
for i=0,5 do begin
	readf, utmp , format=fmt, wt, fi, fl
	wght(i)=wt  &  iffile(i)=fi  &  files(i)=strcompress(fl,/remove_all)
end
				    ;Read initial guess for parameters
				    ;and iffit flags.
lsq_xt_iline
lsq_xt_iline
lsq_xt_iline
lsq_xt_iline, neye0, ixon  &  ifnorm(0) = ixon
lsq_xt_iline, nque0
lsq_xt_iline, nyou0
lsq_xt_iline, nvee0
lsq_xt_iline
lsq_xt_iline, noffin0
lsq_xt_iline
lsq_xt_iline, neyel, ixon  &  ifnorm(1) = ixon
lsq_xt_iline, nquel
lsq_xt_iline, nyoul
lsq_xt_iline, nveel
lsq_xt_iline
lsq_xt_iline, noffinl
lsq_xt_iline
lsq_xt_iline, neyec, ixon  &  ifnorm(2) = ixon
lsq_xt_iline, nquec
lsq_xt_iline, nyouc
lsq_xt_iline, nveec
lsq_xt_iline
lsq_xt_iline, noffinc
lsq_xt_iline
lsq_xt_iline, neye3, ixon  &  ifnorm(3) = ixon
lsq_xt_iline, nque3
lsq_xt_iline, nyou3
lsq_xt_iline, nvee3
lsq_xt_iline
lsq_xt_iline, noffin3
lsq_xt_iline
lsq_xt_iline, neye4, ixon  &  ifnorm(4) = ixon
lsq_xt_iline, nque4
lsq_xt_iline, nyou4
lsq_xt_iline, nvee4
lsq_xt_iline
lsq_xt_iline, noffin4
lsq_xt_iline
lsq_xt_iline, neye5, ixon  &  ifnorm(5) = ixon
lsq_xt_iline, nque5
lsq_xt_iline, nyou5
lsq_xt_iline, nvee5
lsq_xt_iline
lsq_xt_iline, noffin5
lsq_xt_iline
lsq_xt_iline, nwinret
lsq_xt_iline, nwinang
lsq_xt_iline
lsq_xt_iline, nrn0
lsq_xt_iline, nrk0
lsq_xt_iline, nrt0
lsq_xt_iline
lsq_xt_iline, nexret
lsq_xt_iline, nexang
lsq_xt_iline
lsq_xt_iline, noffout
lsq_xt_iline
lsq_xt_iline, ntx
lsq_xt_iline, nty
lsq_xt_iline, nrtda
lsq_xt_iline, nrtd
lsq_xt_iline
lsq_xt_iline, nerar
lsq_xt_iline, ndlc
lsq_xt_iline, nrrsm
lsq_xt_iline, nrrdf
lsq_xt_iline
lsq_xt_iline, nbias0
lsq_xt_iline, nbiasl
lsq_xt_iline, nbiasc
lsq_xt_iline, nbias3
lsq_xt_iline, nbias4
lsq_xt_iline, nbias5
lsq_xt_iline
lsq_xt_iline, ngain
lsq_xt_iline
lsq_xt_iline, nx11
lsq_xt_iline, nx21
lsq_xt_iline, nx31
lsq_xt_iline, nx41
lsq_xt_iline
lsq_xt_iline, nx12
lsq_xt_iline, nx22
lsq_xt_iline, nx32
lsq_xt_iline, nx42
lsq_xt_iline
lsq_xt_iline, nx13
lsq_xt_iline, nx23
lsq_xt_iline, nx33
lsq_xt_iline, nx43
lsq_xt_iline
lsq_xt_iline, nx14
lsq_xt_iline, nx24
lsq_xt_iline, nx34
lsq_xt_iline, nx44
				    ;Convert degrees to radians.
whr = $
[ noffin0, noffinl, noffinc, noffin3, noffin4, noffin5 $
, nwinret, nwinang, nexret,  nexang,  noffout, nrtda   $
, nrtd,    nerar,   ndlc ]
fits(whr) = (!pi/180.)*fits(whr)
				    ;Free input utmp.
free_lun, utmp

end
;-----------------------------------------------------------------------------
;
;	procedure:  lsq_xt_readf
;
;	purpose:  read data files for lsq_xt
;
;-----------------------------------------------------------------------------
pro lsq_xt_readf
				    ;Specify common.
@lsq_xt.com
				    ;Initialize stokes vector count and
				    ;related arrays.
np       = 0
lots     = 100000L
iset     = lonarr(lots)
isrc     = lonarr(lots)
normi    = lonarr(lots)
obs      = fltarr(4,lots)
az       = fltarr(lots)
elev     = fltarr(lots)
ta       = fltarr(lots)
step     = fltarr(lots)
ifcallin = lonarr(lots)
callin   = fltarr(lots)
sinlin   = fltarr(lots)
coslin   = fltarr(lots)
ifcalret = lonarr(lots)
calret   = fltarr(lots)
sinret   = fltarr(lots)
cosret   = fltarr(lots)
azdg     = fltarr(lots)
discrim  = fltarr(lots)
isel     = lonarr(lots)
wgt      = fltarr(4,lots)

npfile   = lonarr(ndf)
jfile    = lonarr(ndf)
				    ;Loop over input data files.
for infile=0,ndf-1 do begin
				    ;Initial count and start for this file. 
	npfile(infile) = 0
	jfile(infile) = np
				    ;Check for missing file.
	if files(infile) ne '' then begin
		if ctype then  print, files(infile)

				    ;Open data file
		openr, /get_lun, utmp, files(infile), error=error
		if error ne 0 then begin
			print, !err_string
			stop
		end
				    ;Skip header line.
		aline='' & readf, utmp, aline

				    ;Read data (all angles in degrees)
		while eof(utmp) eq 0 do begin

				    ;Read next vector; two lines.
			aline='' & readf, utmp, aline
			vline='' & readf, utmp, vline

				    ;Decode first line
			idark=0L & ibulb=0L & iline=0L & ipolar=0L
			elevnp=0. & aznp=0. & tanp=0. & stepnp=0. & discnp=0.
			reads, aline+blank256, format='(4i1,5f10.3)' $
			, idark, ibulb, iline, ipolar $
			, elevnp, aznp, tanp, stepnp, discnp

				    ;Save optical setup.
			iset(np) = 1000*idark+100*ibulb+10*iline+ipolar

				    ;Save VTT angles, radians.
			az(np)    = rpd*aznp
			elev(np)  = rpd*elevnp
			ta(np)    = rpd*tanp
			step(np)  = rpd*stepnp

				    ;Set light source number.
			isrc(np) = infile

				    ;Decode observed stokes vector.
			v4 = fltarr(4)
			reads, vline, v4

				    ;Set normalization flag & normalize vector.
			normi(np) = ifnorm(infile)
			if ifnorm(infile) eq 1 then  v4=v4/v4(0)

				    ;Save stokes vector in array.
			obs(*,np) = v4

				    ;Calibration linear polarizer configuration.
			ifcallin(np) = 1 < iline
			callin(np)   = ifcallin(np)*rpd*((iline-1)*45.)
			sinlin(np)   = sin(2.*callin(np))
			coslin(np)   = cos(2.*callin(np))

				    ;Calibration linear polarizer configuration.
			ifcalret(np) = 1 < ipolar
			calret(np)   = ifcalret(np)*rpd*((ipolar-1)*45.+90.)
			sinret(np)   = sin(2.*calret(np))
			cosret(np)   = cos(2.*calret(np))

				    ;Save some info for plots.
			azdg(np) = aznp
			discrim(np) = discnp

				    ;Set select and weight arrays.
			isel(np) = 1 and iffile(infile)
			wgt(*,np) = wght(infile)
			if ifnorm(infile) eq 1 then  wgt(0,np) = 0.

				    ;Increment counts.
			np = np+1
			npfile(infile) = npfile(infile)+1
		end
				    ;Free input file unit.
		free_lun, utmp
				    ;Save number of points in the file.

		if ctype then  $
		print, iffile(infile), ' fit flag;' $
		, wght(infile), ' weight;', npfile(infile), ' vectors'
	end
end
				    ;Print total number of stokes vectors.
if ctype then  print, 'total number of vectors:', np

				    ;Truncate input arrays.
iset     =     iset(0:np-1)
isrc     =     isrc(0:np-1)
normi    =    normi(0:np-1)
obs      =      obs(*,0:np-1)
az       =       az(0:np-1)
elev     =     elev(0:np-1)
ta       =       ta(0:np-1)
step     =     step(0:np-1)
ifcallin = ifcallin(0:np-1)
callin   =   callin(0:np-1)
sinlin   =   sinlin(0:np-1)
coslin   =   coslin(0:np-1)
ifcalret = ifcalret(0:np-1)
calret   =   calret(0:np-1)
sinret   =   sinret(0:np-1)
cosret   =   cosret(0:np-1)
azdg     =     azdg(0:np-1)
discrim  =  discrim(0:np-1)
isel     =     isel(0:np-1)
jsel     =     isel(0:np-1)
wgt      =      wgt(*,0:np-1)

end
;------------------------------------------------------------------------------
;
;	procedure:  lsq_xt_gen
;
;	purpose:  compute fitted stokes vector.
;
;------------------------------------------------------------------------------
pro lsq_xt_gen, n, vecout
				    ;Specify common.
@lsq_xt.com
				    ;Apply instrument model.
lsq_xt_brew $
, [[fits(neye0), fits(nque0), fits(nyou0), fits(nvee0)] $
,  [fits(neyel), fits(nquel), fits(nyoul), fits(nveel)] $
,  [fits(neyec), fits(nquec), fits(nyouc), fits(nveec)] $
,  [fits(neye3), fits(nque3), fits(nyou3), fits(nvee3)] $
,  [fits(neye4), fits(nque4), fits(nyou4), fits(nvee4)] $
,  [fits(neye5), fits(nque5), fits(nyou5), fits(nvee5)]] $
, [fits(noffin0), fits(noffinl), fits(noffinc) $
,  fits(noffin3), fits(noffin4), fits(noffin5)] $
, [fits(nbias0), fits(nbiasl), fits(nbiasc) $
,  fits(nbias3), fits(nbias4), fits(nbias5)] $
, fits(nrt0), fits(nrn0), fits(nrk0) $
, isrc(n), elev(n), step(n), ta(n), az(n), normi(n) $
, ifcallin(n), sinlin(n), coslin(n) $
, ifcalret(n), sinret(n), cosret(n) $
, fits(noffout) $
, fits(nwinret), fits(nwinang) $
, fits(nexret), fits(nexang) $
, azelrs, azelrp, azelret, azelmtx $
, primrs, primrp, primret, primmtx $
, fits(ntx), fits(nty), fits(nrtda), fits(nrtd) $
, fits(nerar), fits(ndlc), fits(nrrsm), fits(nrrdf) $
, setmtx( $
   fits(nx11), fits(nx12), fits(nx13), fits(nx14) $
,  fits(nx21), fits(nx22), fits(nx23), fits(nx24) $
,  fits(nx31), fits(nx32), fits(nx33), fits(nx34) $
,  fits(nx41), fits(nx42), fits(nx43), fits(nx44) ) $
, fits(ngain) $
, vecout

end
;-----------------------------------------------------------------------------
;
;	procedure:  lsq_xt_bound
;
;	purpose:  put physical constraints on changes to parameters.
;
;-----------------------------------------------------------------------------
pro lsq_xt_bound, dfit
				    ;Specify common.
@lsq_xt.com
				    ;Transmitance must be ge 0.
dfit(nty) = ( 0. > fits(nty)+dfit(nty) ) - fits(nty)

end
;-----------------------------------------------------------------------------
;
;	procedure:  lsq_xt_fitsav
;
;	purpose:  save/restore fitted stokes vectors for lsq_xt.
;
;-----------------------------------------------------------------------------
pro lsq_xt_fitsav, restore=restore
				    ;Specify common.
@lsq_xt.com
				    ;Save/restore fitted vecotrs.
if n_elements(restore) eq 0 then  savpfl=pfl  else  pfl=savpfl

end
;------------------------------------------------------------------------------
;
;	procedure:  lsq_xt_sums
;
;	purpose:  sum cross produxts matrix for lsq_xt
;
;------------------------------------------------------------------------------
pro lsq_xt_sums, alfa
				    ;Specify common.
@lsq_xt.com
				    ;Initial cross products matrix.
alfa = dblarr(nv,nv)
				    ;Set weights array.
wwww = double(wfree)
for iquv=0,3 do wwww(iquv,*)=wwww(iquv,*)*isel*jsel

				    ;Outer loop over parameters.
for k=0,nv-1 do begin
if iffit(k) then begin
				    ;Weighted derivatives for parameter k.
	wtder = wwww*derivs(*,*,k)
				    ;Inner loop over parameters.
	for j=0,k do begin
	if iffit(j) then begin

		sum = total(wtder*derivs(*,*,j))
		alfa(j,k) = sum
		alfa(k,j) = sum
	end
	end
end
end

end
;------------------------------------------------------------------------------
;
;	procedure:  lsq_xt_delfit
;
;	purpose:  compute fit vectors, derivatives, residuals for lsq_xt
;
;------------------------------------------------------------------------------
pro lsq_xt_delfit, iteration, degs_freedom
				    ;OUTPUT
				    ;pfl(4,np)       ~ CALCULATED PROFILES
				    ;derivs(4,np,nv) ~ DERIVATIVES WRT
				    ;                  VARIABLE n (n ne 0)
				    ;derivs(4,np, 0) ~ RESIDUAL ERRORS

				    ;Specify common.
@lsq_xt.com
				    ;Constraints.
if fits(nwinret) lt 0. then begin
	fits(nwinret) = -fits(nwinret)
	fits(nwinang) = fits(nwinang)+!pi/2.
end
if fits(nwinret) gt 2.*!pi then fits(nwinret) = fits(nwinret) - 2.*!pi
if fits(nwinang) gt !pi    then fits(nwinang) = fits(nwinang) - !pi
if fits(nwinang) lt 0.     then fits(nwinang) = fits(nwinang) + !pi

if fits(nexret) lt 0. then begin
	fits(nexret) = -fits(nexret)
	fits(nexang) = fits(nexang)+!pi/2.
end
if fits(nexret) gt 2.*!pi then fits(nexret) = fits(nexret) - 2.*!pi
if fits(nexang) gt !pi    then fits(nexang) = fits(nexang) - !pi
if fits(nexang) lt 0.     then fits(nexang) = fits(nexang) + !pi

				    ;Initialize some arrays.
pfl = fltarr(4,np)
derivs = fltarr(4,np,nv)
				    ;Save ongoing parameter set.
savfit = fits
				    ;Loop over stokes vectors.
for n=0,np-1 do begin
				    ;Compute and save fitted vector.
	lsq_xt_gen, n, vecout
	pfl(*,n) = vecout
				    ;Compute residual.
	derivs(*,n,0) = obs(*,n)-vecout

				    ;Loop over and take derivative
				    ;wrt fitted parameters.
	for npar=1,nv-1 do begin
	if iffit(npar) then begin
				    ;Perturb parameter high.
		delta = ptb(npar)
		fits(npar) = fits(npar)+delta
		parhi = fits(npar)
				    ;Compute perturbed vector.
		lsq_xt_gen, n, vechi
				    ;Restore ongoing parameter set.
		fits = savfit
				    ;Perturb parameter low.
		fits(npar) = fits(npar)-delta
		if npar eq nty then  fits(npar)=0.>fits(npar)
		parlw = fits(npar)
				    ;Compute perturbed vector.
		lsq_xt_gen, n, veclw
				    ;Restore ongoing parameter set.
		fits = savfit
				    ;Set derivative.
		derivs(*,n,npar) = (vechi-veclw)/(parhi-parlw)
	end
	end
end
			    ;Initial select array for final chi**2
jsel = replicate(1L,np)
			    ;Set polarization fraction.
pfrc = isel*sqrt( $
(obs(1,*)-pfl(1,*))^2+(obs(2,*)-pfl(2,*))^2+(obs(3,*)-pfl(3,*))^2)

;                                                        8/9/94
;
;Code ~stokes/src/xt and object ~stokes/bin/xt has been revised.
;
;Cabiration data from may 94 apparently has some bad stokes vectors.
;The bad data always has the calibration retarder present.
;Likely cause is the device is not in the beam right.
;
;Revised xt is hard wired to try to reject bad vectors.
;Let's say the observed and calculated vectors are (1,Oq,Ou,Ov) and
;(1,cq,cu,cv).   The criteria to reject a vector are
;
;    (1).  The vector is in a file fitted by least squares.
;    (2).  Least-squares is in the third or higher iteration.
;    (3).  sqrt( (Oq-cq)**2+(Ou-cu)**2+(Ov-cv)**2 ) > 0.01  (about 1%)
;    (4).  No more than 10 vectors are rejected.
;    (5).  Rejected vectors have the highest polarization residuals.
;
;A table of the rejected vectors is printed to standard output.
;Observed, calculated, and residual vectors are printed to output
;file fort.12 .
;
;Most of the data has a polarization residual form about 0.0001 to 0.005
;which is well below th 0.01 maximum.  Bad vectors with the calibration
;retarder only present have residuals of about 0.03 .  Bad vectors
;with both linear polarizer and retarder present have residuals of
;about 0.7 .
;
;Polarization residuals are slightly high when the optics take settings
;x065 (x is table position).  A residual of 0.015 is common.   These
;vectors have both linear polarizer and retarder present.  The revised
;xt will reject up to 10 of these vectors.  I have no explanation
;of why the x065 vectors have higher residuals.  I have tried slight
;rotations of both devices but things only be improved to about
;0.014 residuals.
;
			    ;Set flags for rejected vectors.
ibad = 0
if iteration gt 2 then begin
while ibad lt 10 do begin
	mxpfrc = max(jsel*pfrc)
    	if pfrc(!C) ge .01 then begin
		jsel(!C) = 0
		ibad=ibad+1
	end else begin
		ibad = 10
	end
end
end
			    ;Find where weights are not zero.
wij = wgt
for iquv=0,3 do wij(iquv,*)=wij(iquv,*)*isel*jsel
whr = where( wij ne 0., nwhr )

			    ;Degrees of freedom.
degs_freedom = 1.*nwhr
			    ;Sum of weights.
if nwhr gt 0 $
then  wtot=total(double(wij(whr))) $
else  wtot=1.
			    ;Weights scaled to degrees of freedom.
wfree = wgt*degs_freedom/wtot

end
;-----------------------------------------------------------------------------
;
;	procedure:  lsq_xt_chisq
;
;	purpose:  compute chi squares of lsq_xt fit.
;
;-----------------------------------------------------------------------------
pro lsq_xt_chisq
				    ;Specify common.
@lsq_xt.com
				    ;Residuals and observations squared.
error = (obs-pfl)^2
bass  = obs^2
				    ;Initialize chi squares to zero.
ssq  = fltarr(4,ndf+1)
chi  = fltarr(ndf+1)
pchi = fltarr(ndf+1)
				    ;Loop over each file and over combined
				    ;data set.
for infile=0,ndf do begin
				    ;Select arry for one stokes component.
	if infile eq ndf $
	then  selt = (jsel ne 0) and (isel ne 0) $
	else  selt = (jsel ne 0) and (isrc eq infile)
	ksel = lonarr(4,np)
				    ;Select arry for four stokes component.
	for iquv=0,3 do  ksel(iquv,*)=selt

				    ;Sum residuals and observation for
				    ;each stokes component.
	errm = total( error*wfree*ksel, 2 )
	summ = total(  bass*wfree*ksel, 2 )

				    ;Chi square for each stokes component.
	for iquv=0,3 do $
	if summ(iquv) ne 0. then  ssq(iquv,infile)=errm(iquv)/summ(iquv)

				    ;Total chi squares.
	errs = total(errm)
	snrm = total(summ)
	if snrm ne 0. then  chi(infile)=errs/snrm

				    ;Polarization chi squares.
	errs = total(errm(1:3))
	snrm = total(summ(1:3))
	if snrm ne 0. then  pchi(infile)=errs/snrm

end

end
;------------------------------------------------------------------------------
;
;	procedure:  lsq_xt_oline
;
;	purpose:  output one parameter line to input control file.
;
;------------------------------------------------------------------------------
pro lsq_xt_oline, npar, ixon
				    ;Specify common.
@lsq_xt.com
				    ;If no parameter output blank line.
narg = n_params()
if narg eq 0 then begin
	printf, utmp, '                             #'
	return
end
				    ;Get fitted parameter, initial guess,
				    ;and standard error of parameter.
fpar = fits(npar)
gpar = gfit(npar)
epar = stderr(npar)
				    ;Convert radians to degrees.
whr = where( npar eq $
[ noffin0, noffinl, noffinc, noffin3, noffin4, noffin5 $
, nwinret, nwinang, nexret,  nexang,  noffout, nrtda   $
, nrtd,    nerar,   ndlc ] $
, nwhr )
if nwhr ne 0 then begin
	fpar=(180./!pi)*fpar
	gpar=(180./!pi)*gpar
	epar=(180./!pi)*epar
end
				    ;Write new control line.
if narg eq 1 then begin

	spar = strmid( names(npar)+'                ',0,11)
	fmt='(a11,i1,f16.7,'' #'',2f16.7)'
	printf, utmp, format=fmt, spar, iffit(npar), fpar, gpar, epar

end else begin

	spar = strmid( names(npar)+'                ',0,5)
	fmt='(a5,i1,i6,f16.7,'' #'',2f16.7)'
	printf, utmp, format=fmt, spar, ixon, iffit(npar), fpar, gpar, epar
end

end
;------------------------------------------------------------------------------
;
;	procedure:  lsq_xt_out
;
;	purpose:  output control file for lsq_xt
;
;------------------------------------------------------------------------------
pro lsq_xt_out, ifile, ofile, xfile, tfile
				    ;Specify common.
@lsq_xt.com

dpr = 180./!pi
				    ;Open output file.
if n_elements(ofile) eq 0 $
then  ofle=ifile+'.out' $
else  ofle=ofile
openw, /get_lun, utmp, ofle, error=error
if error ne 0 then begin
	print, !err_string
	stop
end
				    ;Write flevel
printf, utmp, format='(f5.2,a)', flevel, ' flevel (format f5.2)'

				    ;Write some user info.
printf, utmp
printf, utmp, format='(a)' $
, 'FORMAT(f10.0,1x,i1,1x,a)'
printf, utmp
				    ;Write data file paths with flags to fit.
for i=0,5 do $
printf, utmp, format='(f10.0,1x,i1,1x,a )' $
, wght(i), iffile(i), files(i)
				    ;Write solution and iffit flags.
printf, utmp
printf, utmp $
, 'FORMAT(11x,i1,f16.0)         #########################################'
lsq_xt_oline
lsq_xt_oline, neye0, ifnorm(0)
lsq_xt_oline, nque0
lsq_xt_oline, nyou0
lsq_xt_oline, nvee0
lsq_xt_oline
lsq_xt_oline, noffin0
lsq_xt_oline
lsq_xt_oline, neyel, ifnorm(1)
lsq_xt_oline, nquel
lsq_xt_oline, nyoul
lsq_xt_oline, nveel
lsq_xt_oline
lsq_xt_oline, noffinl
lsq_xt_oline
lsq_xt_oline, neyec, ifnorm(2)
lsq_xt_oline, nquec
lsq_xt_oline, nyouc
lsq_xt_oline, nveec
lsq_xt_oline
lsq_xt_oline, noffinc
lsq_xt_oline
lsq_xt_oline, neye3, ifnorm(3)
lsq_xt_oline, nque3
lsq_xt_oline, nyou3
lsq_xt_oline, nvee3
lsq_xt_oline
lsq_xt_oline, noffin3
lsq_xt_oline
lsq_xt_oline, neye4, ifnorm(4)
lsq_xt_oline, nque4
lsq_xt_oline, nyou4
lsq_xt_oline, nvee4
lsq_xt_oline
lsq_xt_oline, noffin4
lsq_xt_oline
lsq_xt_oline, neye5, ifnorm(5)
lsq_xt_oline, nque5
lsq_xt_oline, nyou5
lsq_xt_oline, nvee5
lsq_xt_oline
lsq_xt_oline, noffin5
lsq_xt_oline
lsq_xt_oline, nwinret
lsq_xt_oline, nwinang
lsq_xt_oline
lsq_xt_oline, nrn0
lsq_xt_oline, nrk0
lsq_xt_oline, nrt0
lsq_xt_oline
lsq_xt_oline, nexret
lsq_xt_oline, nexang
lsq_xt_oline
lsq_xt_oline, noffout
lsq_xt_oline
lsq_xt_oline, ntx
lsq_xt_oline, nty
lsq_xt_oline, nrtda
lsq_xt_oline, nrtd
lsq_xt_oline
lsq_xt_oline, nerar
lsq_xt_oline, ndlc
lsq_xt_oline, nrrsm
lsq_xt_oline, nrrdf
lsq_xt_oline
lsq_xt_oline, nbias0
lsq_xt_oline, nbiasl
lsq_xt_oline, nbiasc
lsq_xt_oline, nbias3
lsq_xt_oline, nbias4
lsq_xt_oline, nbias5
lsq_xt_oline
lsq_xt_oline, ngain
lsq_xt_oline
lsq_xt_oline, nx11
lsq_xt_oline, nx21
lsq_xt_oline, nx31
lsq_xt_oline, nx41
lsq_xt_oline
lsq_xt_oline, nx12
lsq_xt_oline, nx22
lsq_xt_oline, nx32
lsq_xt_oline, nx42
lsq_xt_oline
lsq_xt_oline, nx13
lsq_xt_oline, nx23
lsq_xt_oline, nx33
lsq_xt_oline, nx43
lsq_xt_oline
lsq_xt_oline, nx14
lsq_xt_oline, nx24
lsq_xt_oline, nx34
lsq_xt_oline, nx44
lsq_xt_oline
printf, utmp, '##############################'

				    ;Output responce matrix.
printf, utmp
printf, utmp, 'X matrix format to be read by aspcal.pro:'
for pass=0,(n_elements(xfile) ne 0) do begin
	luo = utmp
	if pass then begin
		openw, /get_lun, luo, xfile, error=error
		if error ne 0 then begin
			print, !err_string
			stop
		end
	end
	printf, luo, 'response matrix:'
	printf, luo, format='(f11.5,'' cL '',f11.5,'' yL'')' $
	, fits(ntx), fits(nty)
	printf, luo, format='(f11.5,'' cD '',f11.5,'' yD'')' $
	, (fits(nrrsm)+fits(nrrdf))/2., (fits(nrrsm)-fits(nrrdf))/2.
	printf, luo $
	, format='( f11.5,'' retardance'',f15.4,'' mount error'')' $
	, fits(ndlc)*dpr, fits(nerar)*dpr
	printf, luo, format='(4f9.5)' $
	, fits(nx11), fits(nx12), fits(nx13), fits(nx14)
	printf, luo, format='(4f9.5)' $
	, fits(nx21), fits(nx22), fits(nx23), fits(nx24)
	printf, luo, format='(4f9.5)' $
	, fits(nx31), fits(nx32), fits(nx33), fits(nx34)
	printf, luo, format='(4f9.5)' $
	, fits(nx41), fits(nx42), fits(nx43), fits(nx44)

				    ;Output standard errors of responce matrix.
	printf, luo
	printf, luo,'standard error:'
	printf, luo, format='(f11.5,'' cL '',f11.5,'' yL'')' $
	, stderr(ntx), stderr(nty)
	printf, luo, format='(f11.5,'' cD+yD '',f11.5,'' cD-yD'')' $
	, stderr(nrrsm), stderr(nrrdf)
	printf, luo $
	, format='( f11.5,'' retardance'',f15.4,'' mount error'')' $
	, stderr(ndlc)*dpr, stderr(nerar)*dpr
	printf, luo, format='(4f9.5)' $
	, stderr(nx11), stderr(nx12), stderr(nx13), stderr(nx14)
	printf, luo, format='(4f9.5)' $
	, stderr(nx21), stderr(nx22), stderr(nx23), stderr(nx24)
	printf, luo, format='(4f9.5)' $
	, stderr(nx31), stderr(nx32), stderr(nx33), stderr(nx34)
	printf, luo, format='(4f9.5)' $
	, stderr(nx41), stderr(nx42), stderr(nx43), stderr(nx44)
	if pass then  free_lun, luo
end
				    ;Output file to be read by get_t.pro
printf, utmp
printf, utmp, 'T matrix format to be read by get_t.pro:'
for pass=0,(n_elements(tfile) ne 0) do begin
	luo = utmp
	if pass then begin
		openw, /get_lun, luo, tfile, error=error
		if error ne 0 then begin
			print, !err_string
			stop
		end
	end
	printf, luo, format='(f16.7)', fits(nwinret)*dpr
	printf, luo, format='(f16.7)', fits(nwinang)*dpr
	printf, luo, format='(f16.7)', fits(nexret)*dpr
	printf, luo, format='(f16.7)', fits(nexang)*dpr
	printf, luo, format='(f16.7)', fits(noffout)*dpr
	printf, luo, format='(f16.7)', azelrs
	printf, luo, format='(f16.7)', azelrp
	printf, luo, format='(f16.7)', azelret*dpr
	printf, luo, format='(f16.7)', primrs
	printf, luo, format='(f16.7)', primrp
	printf, luo, format='(f16.7)', primret*dpr
	if pass then  free_lun, luo
end
				    ;Print rejected vector settings.
printf, utmp
printf, utmp, 'reject vectors:'
whr = where( jsel eq 0 and isel eq 1, nwhr )
if nwhr ne 0 then begin
	printf, utmp, '                polarization'
	printf, utmp, '   vec  optics  residual'
	for i=0,nwhr-1 do begin
		n = whr(i)
		pfrc = sqrt( total((obs(1:3,n)-pfl(1:3,n))^2) )
		printf, utmp, format='(i6,i8,f10.6)', n, iset(n), pfrc
	end
end
				    ;Print convergence trace.
if trace.iter ne 0 then begin
	printf, utmp
	printf, utmp, 'iter   chi        fla        dchi     f-prob'
	printf, utmp, format='(e14.3)', trace.csq(0)
	for itr=1,trace.iter do $
	printf, utmp, format='(i3,3e11.3,f8.4)' $
	, itr, trace.csq(itr), trace.cappa0(itr) $
	, trace.dchi(itr), trace.probf(itr)
end
				    ;Output chi squares.
printf, utmp
printf, utmp $
, '     ii        qq        uu        vv       chs        pp'
printf, utmp, format='(4f10.5,2g12.4)' $
, ssq(*,ndf), chi(ndf), pchi(ndf)
printf, utmp
nms = '  file'+['0','1','2','3','4','5']
for id=0,ndf-1 do $
printf, utmp, format='(4f10.5,2g12.4,a)' $
, ssq(*,id), chi(id), pchi(id), nms(id)

				    ;Output vectors and residuals.
;	write(12,'(26x,a,34x,a,32x,a)')
;     .	'observed','calculated','residual'
;	write(12,'(12x,3(8x,''Q'',9x,''U'',9x,''V'',7x,''total'',1x)))')
;	write(12,'(2i6,2x,4f10.6,2x,4f10.6,2x,4f10.6)')
;     .	( n,iset(n)
;     .	, ( obs(iquv,n), iquv=2,4 )
;     .	, sqrt( obs(2,n)**2.+obs(3,n)**2.+obs(4,n)**2. )
;     .	, ( pfl(iquv,n), iquv=2,4 )
;     .	, sqrt( pfl(2,n)**2.+pfl(3,n)**2.+pfl(4,n)**2. )
;     .	, (obs(iquv,n)-pfl(iquv,n),iquv=2,4)
;     .	, sqrt(
;     .	  (obs(2,n)-pfl(2,n))**2.
;     .	+ (obs(3,n)-pfl(3,n))**2.
;     .	+ (obs(4,n)-pfl(4,n))**2. )
;     .	, n = 1,np )

;      call vttmtx
;     .( 0., 0., 0.
;     ., rt0, rn0, rk0
;     ., winret, winang
;     ., exret, exang
;     ., offout
;     ., aselrs, azelrp, azelret
;     ., primrs, primrp, primret
;     ., tmat
;     .)
;
;Output to fort.8 in format to be read by tmtx.f
;      write( 8, '(''vttaz  ='',f16.7)' ) 0.
;      write( 8, '(''vttel  ='',f16.7)' ) 0.
;      write( 8, '(''tblpos ='',f16.7)' ) 0.
;      write( 8, '(''rt0    ='',f16.7)' ) rt0
;      write( 8, '(''rn0    ='',f16.7)' ) rn0
;      write( 8, '(''rk0    ='',f16.7)' ) rk0
;      write( 8, '(''winret ='',f16.7)' ) winret*dpr
;      write( 8, '(''winang ='',f16.7)' ) winang*dpr
;      write( 8, '(''exret  ='',f16.7)' ) exret*dpr
;      write( 8, '(''exang  ='',f16.7)' ) exang*dpr
;      write( 8, '(''offout ='',f16.7)' ) offout*dpr
;      write( 8, '(''rs     ='',f16.7)' ) azelrs
;      write( 8, '(''rp     ='',f16.7)' ) azelrp
;      write( 8, '(''ret    ='',f16.7)' ) azelret*dpr
;      write( 8, '(''prirs  ='',f16.7)' ) primrs
;      write( 8, '(''prirp  ='',f16.7)' ) primrp
;      write( 8, '(''priret ='',f16.7)' ) primret*dpr
;
;      write(6,'(a,f11.5)') 't(1,1) =', tmat(1,1)
;
;      write(6,'(a,2f11.6,f12.5)')
;     .'el az (rs rp ret):', azelrs, azelrp, azelret*dpr
;
;      write(6,'(a,2f11.6,f12.5)')
;     .'main  (rs rp ret):', primrs, primrp, primret*dpr
				    ;Plots.
;	do 768 infile = 1,ndf
;	    if( npfile(infile).ne.0 ) then
;		call plot
;     .		( files(infile), iffile(infile)
;     .		, obs(1,jfile(infile))
;     .		, pfl(1,jfile(infile))
;     .		, azdg(jfile(infile))
;     .		, discrim(jfile(infile))
;     .		, npfile(infile)
;     .		)
;	    endif
;768	continue
				    ;Free input utmp.
free_lun, utmp

end
;------------------------------------------------------------------------------
;
;	procedure:  lsq_xt
;
;	purpose:  do least squares fit of asp X & T matrix.
;
;------------------------------------------------------------------------------
pro lsq_xt, ifile, ofile $
, noprint=noprint, tfile=tfile, xfile=xfile

				    ;Specify and set common.
@lsq_xt.com
lsq_xt_set
				    ;Check number of arguments.
if n_params() eq 0 then begin
	lsq_xt_usage
	return
end
				    ;Check if console printing
				    ;is prevented.
if n_elements(noprint) eq 0  $
then  ctype = 1  $
else  ctype = noprint eq 0
				    ;Read input control file.
lsq_xt_inn, ifile
				    ;Type flevel
if ctype then print, 'flevel:', flevel

				    ;Renormalize some perturbations.
ptb(ngain) = ptb(ngain)*fits(ngain)
ptb(nx11:nx44) = ptb(nx11:nx44)*fits(nx11)

				    ;Read stokes vector files.
lsq_xt_readf
				    ;Save initail guess.
gfit = fits
				    ;For code to work iffit(0) must be one.
iffit(0) = 1
				    ;Fit data by least-squares.
lsq_iters, 'lsq_xt' $
, fits, stderr $
, 30, flevel, dtot $
, iter, fla, dchi, probf $
, noprint=noprint $
, trace=trace
				    ;Compute chi-squares.
lsq_xt_chisq
				    ;Output updated control file.
lsq_xt_out, ifile, ofile, xfile, tfile

end
