pro avgprof, infile, fscan, lscan, thold, ii, qq, uu, vv, $
	x1=x1, x2=x2, y1=y1, y2=y2, xe1=xe1, xe2=xe2, title=title, v101=v101
;+
;
;	procedure:  avgprof
;
;	purpose:  calculate average profile in a spot
;
;	author:  rob@ncar, 9/92
;
;	ex:  avgprof, '48.gainit.rob', 7, 25, 660.0, i, q, u, v, xe1=200,
;	   xe2=250, x1=0, x2=254, y1=85, y2=155, title='48.gainit.rob'
;
;	notes for 6149 data:
;
;		- try 6151 line for extremum [defined in xe1,xe2 below]
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 8 then begin
	print
	print, "usage:  avgprof, infile, fscan, lscan, thold, $"
	print, "	ii, qq, uu, vv"
	print
	print, "	Calculate average profile in a spot."
	print
	print, "	Arguments"
	print, "		infile	 - input file"
	print, "		fscan	 - first seq. scan to consider"
	print, "		lscan	 - last seq. scan to consider"
	print, "		thold	 - profiles with [(mean of V extrema"
	print, "			   in range xe1 to xe2) > thold] will"
	print, "			   be averaged"
	print, "		ii-vv	 - output average I, Q, U, V profiles"
	print
	print, "	Keywords"
	print, "		x1	 - starting column index (def=0)"
	print, "		x2	 - ending column index (def=last one)"
	print, "		y1	 - starting row index (def=0)"
	print, "		y2	 - ending row index (def=last one)"
	print, "		xe1	 - starting col. for extremum (def=x1)"
	print, "		xe2	 - ending col. for extremum (def=x2)"
	print, "		title	 - window title (def=let IDL choose)"
	print, "		v101	 - set to force version 101"
	print, "			   (def=use version # in op hdr)"
	print
	return
endif
;-
;
;	Read operation header.
;	Get dnumx and dnumy into common.
;
true = 1
false = 0
@op_hdr.com			; set common blocks
@op_hdr.set
stdout_unit = -1
openr, infile_unit, infile, /get_lun
if read_op_hdr(infile_unit, stdout_unit, false) eq 1 then return
free_lun, infile_unit
;
;	Set version number ('get_version' uses operation header).
;
if keyword_set(v101) then version = 101  else  version = get_version()
;
;	Set X and Y ranges.
;	(uses dnumx and dnumy from op header common block)
;
if n_elements(x1) eq 0 then x1 = 0
if n_elements(y1) eq 0 then y1 = 0
if n_elements(x2) eq 0 then x2 = dnumx - 1
if n_elements(y2) eq 0 then y2 = dnumy - 1
nx = x2 - x1 + 1
ny = y2 - y1 + 1
ny1 = y2 - y1
if (x1 gt x2) or (y1 gt y2) or $
   (x1 lt 0) or (y1 lt 0) or $
   (x2 gt dnumx-1) or (y2 gt dnumy-1) then begin
	print
	print, 'Error in specifying x1,y1,x2,y2.'
	print
	return
endif
;
;	Set extremum range.
;
if n_elements(xe1) eq 0 then xe1 = x1
if n_elements(xe2) eq 0 then xe2 = x2
if (xe1 gt xe2) or (xe1 lt x1) or (xe2 gt x2) then begin
	print
	print, 'Error in specifying xe1,xe2.'
	print
	return
endif
xxe1 = xe1 - x1
xxe2 = xe2 - x1
;
;	Set more parameters.
;
nsumy = 0
avgscan = 0L
print
;
;	Initialize average profiles.
;
ii = dblarr(nx)			; is zero'ed
qq = ii
uu = ii
vv = ii
;
;--------------------------------------------------
;
;	LOOP FOR EACH SCAN IN SPOT.
;
for iscan = fscan, lscan do begin
;
;	Read a scan.
	readscan, infile, iscan, i, q, u, v, $
		x1=x1, x2=x2, y1=y1, y2=y2, /nohead, v101=do_v101
;
;	Initialize counter of summed profiles.
	nsy = 0
;
;	Sum in profile if mean of V extrema is greater than threshold.
	for y = 0, ny1 do begin
		minv = min( v(xxe1:xxe2,y) , max=maxv)
		meanv = 0.5 * (abs(minv) + abs(maxv))

		if meanv gt thold then begin
			nsy = nsy + 1
			ii = ii + i(*, y)
			qq = qq + q(*, y)
			uu = uu + u(*, y)
			vv = vv + v(*, y)
		endif
	endfor
;
;	Increment grand sum.
	print, 'Scan ' + stringit(iscan) + ':  ' + stringit(nsy) + ' summed'
	nsumy = nsumy + nsy
;
;	Increment average scan sum.
	avgscan = avgscan + nsy * iscan
;
endfor
;--------------------------------------------------
;
;	Check number of profiles averaged.
;
if nsumy eq 0 then begin
	print
	print, '	No profiles found above threshold.'
	print
	return
endif
;
;	Print status information.
;
avgscan = fix(avgscan/float(nsumy) + 0.5)
print
print, 'Total of ' + stringit(nsumy) + ' profiles summed.'
print, 'Center of spot (average scan) is ' + stringit(avgscan) + '.'
print
;
;	Divide to get average profile.
;
ii = ii / nsumy
qq = qq / nsumy
uu = uu / nsumy
vv = vv / nsumy
;
;	Open a window.
;
if keyword_set(title) then begin
	window, /free, title=title
endif else begin
	window, /free
endelse
;
;	Plot profiles.
;
!p.multi = [0, 2, 2, 0, 0]		; set to 2x2 plots
plot, ii, title='Average I'
plot, qq, title='Average Q'
plot, uu, title='Average U'
plot, vv, title='Average V'
!p.multi = 0				; reset to one plot per page
;
;	Done.
;
end
