pro run_shg, doplot
;+
;
;	file:  run_shg.pro
;
;	purpose:  produce I,V spectroheliogram plots (runs shg, shgplot, lp)
;
;==============================================================================
;
;	Check parameters.
;
if n_params() ne 1 then begin
	print
	print, "usage:  1) copy 'run_shg.pro' to your directory"
	print
	print, "        2) do the following for each map to process"
	print, "           a. use 'aspview' to find center scan of spot"
	print, "           b. read it with 'readscan'"
	print, "           c. do 'tvwinp' on the I and V images and set"
	print, "              'EDIT THESE' (in run_shg) accordingly"
	print
	print, "        3) run_shg, 1       ; plots I and V shg's"
	print, "           run_shg, 0       ; no plotting"
	print
	print, "	Produce I,V spectroheliogram plots"
	print, "	(runs shg, shgplot, and lp)."
	print
	return
endif
;-

;
;	EDIT THESE
;
tape = 'W920612A1'	; name of working tape
ops = ['09', '10']	; operation numbers of maps to process
x1i= 80			; wavelength range for I continuum
x2i= 90
x1vs = [120, 122]	; wavelength ranges for one lobe of V line
x2vs = [129, 134]
;
;--------------------
;
;	These can probably be left as they are.
;
map_end = '.fa.map'
plot_end = '.shg.ps'
isave = 'i.save'
vsave = 'v.save'
y2 = 229
;
;
true = 1
false = 0
if doplot eq 1 then noplot = false   else noplot = true
;
;---------------------------------------------------------
;
;	LOOP FOR EACH OPERATION.
;
for seq = 0, n_elements(ops)-1 do begin
;
;	Set variables.
	op = ops(seq)
	map = op + map_end
	fileps = op + plot_end
;
;	Calc I shg.
	shg, map, d, x1=x1i, x2=x2i, y2=y2, sav=isave, noplot=noplot
;
;	Calc V shg.
	shg, map, d, x1=x1vs(seq), x2=x2vs(seq), y2=y2, sav=vsave, ityp='v', $
		noplot=noplot
;
;	Plot shg's.
	shgplot, tape, isave, vsave, fileps=fileps
	spawn, 'lp ' + fileps
;
endfor
;---------------------------------------------------------
;
;	Done.
;
end
