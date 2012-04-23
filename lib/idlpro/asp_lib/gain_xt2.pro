pro gain_xt2, dummy
;+
;
;	purpose:  run gain_xt in a loop
;
;	usage:  1) edit details of this file as needed
;		2) .r gain_xt2
;		3) gain_xt2
;
;	notes:  we can modify gain_xt later to do this...
;
;==============================================================================
;
;	Check parameters.
;
if n_params() ne 0 then begin
	print
	print, "usage:  gain_xt2"
	print
	print, "	Run gain_xt in a loop."
	print
	print, "	[Must edit file as parameters are hardwired.]"
	print
	return
endif
;-

olist = [48, 49]

nops = sizeof(olist)

for i = 0, nops-1 do begin		; loop for each map

	op = olist(i)

	infile = stringit(op) + '.gainit.old'
	outfile = stringit(op) + '.gainit.new'
	kold = stringit(op) + '.kold'
	knew = stringit(op) + '.knew'

	gain_xt, infile, outfile, 'X.29', 'X.29', kold, knew, 80, 100, 3, 3

endfor

end
