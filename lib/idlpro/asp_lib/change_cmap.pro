function change_cmap, dummy, special=special
;+
;
;	function:  change_cmap
;
;	purpose:  allow user to modify colormap in various ways (aspview.pro)
;
;	author:  rob@ncar, 1/92
;
;	notes:  1 is returned if the user selects to exit the application
;	        (or if an error occurred); else 0 is returned
;
;==============================================================================
;
;	Check number of parameters.
;
if (n_params() ne 0) then begin
	print
	print, "usage:  ret = change_cmap()"
	print
	print, "	Allow user to modify colormap in various ways."
	print, "	If user requests to exit application, 1 is returned;"
	print, "	else 0 is returned."
	print
	print, "	Arguments"
	print, "		(none)"
	print
	print, "	Keywords"
	print, "		special	- if set, put special colors at end"
	print, "			  of colormap and in newct common"
	print, "			  (def=no special colors)"
	print
	return, 1
endif
;-
;
;	Set general variables.
;
true = 1
false = 0
done = false
ans = string(' ',format='(a1)')
;
;	Set common block for special colors (see newct_special.pro).
;	[Assumption if "doing special":  newct.set was invoked beforehand.]
;
@newct.com
do_special = keyword_set(special)
;
;	Loop to modify colormap.
;
repeat begin
;
;	Get users selection.
	selected = false
	repeat begin
		print
		print, 'Select option:'
		print
		print, '	[Note:  special colors at end of color'
		print, '		table cannot be overridden.]'
		print
		print, '	a) adjct   - interactively adjust color table'
		print, '	p) palette - interactively adjust color table'
		print, '	l) loadct  - load RSI predefinded color table'
		print, '	n) newct   - load HAO predefinded color table'
		print

;;		print, '	g) gray    - load regular grayscale'
;;		print, '	r) reverse - load inverted grayscale'
;;		print

		print, '	q) quit    - quit modifying colors'
		print, '	x) exit    - exit the entire application'
		print
		read, ans
		if (ans eq 'a') or (ans eq 'l') or (ans eq 'n') or $
		   (ans eq 'q') or (ans eq 'x') or (ans eq 'p') then $
			selected = true

;;		   (ans eq 'q') or (ans eq 'x') or (ans eq 'g') or $
;;		   (ans eq 'r') or (ans eq 'p') then selected = true

	endrep until selected
;
;	Perform selection.
	case ans of
		'a':  begin
			adjct
			if do_special then newct_special
		      end

		'p':  begin
			palette
			if do_special then newct_special
		      end

		'l':  begin
			loadct
			if do_special then newct_special
		      end

		'n':  if do_special then newct,     /special	else newct

;;		'g':  if do_special then newct, 10, /special	else newct, 10
;;		'r':  if do_special then newct, 11, /special	else newct, 11

		'q':  done = true

		'x':  return, 1
	endcase
endrep until done
;
;	Done.
;
return, 0
end
