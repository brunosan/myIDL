pro usage_widget, dummy, new=new
;+
;
;	procedure:  usage_widget
;
;	purpose:  X Windows interface for usage.pro
;
;	author:  rob@ncar, 3/93
;
;	usage:  usage_widget
;
;==============================================================================
;
;       Check number of parameters.
;
if n_params() ne 0 then begin
	print
	print, "usage:  usage_widget"
	print
	print, "	X Windows interface for usage.pro."
	print
	print, "	Arguments"
	print, "		(none)"
	print
	print, "	Keywords"
	print, "		new	- if set, use Rob's new idl directory"
	return
endif
;-
;
;	Return to caller if error.
;
on_error, 2
;
;	Set common blocks.
;
common usage_com, base, mlist, dir, text_id, file_mode, toggle_but
;
;	Set general parameters.
;
file_mode = 0		; default = show usage info rather than whole file
true = 1
false = 0
title =	'A  S  P     I  D  L     R  o  u  t  i  n  e  s' + $
	'             -- click once on a routine name --'
ysize_list = 20
;xsize_text = 65
xsize_text = 83
ysize_text = 37
toggle_but = ["Showing Usage", "Showing File"]
;
;	Set list of IDL routines.
;
dir = '/home/hao/stokes/src/idl'
if keyword_set(new) then dir = '/home/hao/stokes/src/idl-new'
cd, dir
mlist = findfile('*.pro')
;
;	Set parent base widget.
;
base = widget_base(title=title, /row)
;
;	Set child base widgets.
;
lside = widget_base(base, /column)
rside = widget_base(base, /column)
;
tside = widget_base(lside, /row)
bside = widget_base(lside, /row)
;
;-------------------------------------
;
;	Set list widget -- choices of routines to see usage info on.
;
list_id = widget_list(tside, uvalue=mlist, value=mlist, ysize=ysize_list)
;
;	Set text widget -- output window of usage info.
;
text_id = widget_text(rside, xsize=xsize_text, ysize=ysize_text, /scroll)
;
;	Set menu widget -- quit button.
;
xmenu, [toggle_but(0), "Quit"], bside
;
;-------------------------------------
;
;	Realize the widgets.
;
widget_control, /realize, base
;
;	Start the X manager.
;
xmanager, "usage", base 
;
end
