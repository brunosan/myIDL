function pop_cult, labels, nget, title=title 
;+
;
;	procedure:  pop_cult
;
;	purpose:  Return WHERE array for labels in a pop up window.
;		  A scalar is returned if only one click is requested.
;		  Uses colors 0 & !d.n_colors-1 which are the first
;		  and last of the available colors.
;
;	author:  paul@ncar, 5/93	(minor mod's by rob@ncar)
;
;==============================================================================
;
;       Check number of parameters.
;
if n_params() eq 0  then begin
	print
	print, "usage:	ret = pop_cult( labels [, nget] )"
	print
	print, "	Return WHERE array for labels in a pop up window."
	print, "	A scalar is returned if only one click is requested."
	print, "	If 'continue' clicked, return is immediate with all"
	print, "	remaining array elements pointing to 'continue'."
	print, "	(Uses colors 0 & !d.n_colors-1 which are the first"
	print, "	and last of the available colors.)"
	print
	print, "	Arguments:"
	print, "		labels	- string array of labels"
	print, "		nget	- number of buttons to click"
	print, "			  (def=1)"
	print, "	Keywords:"
	print, "		title	- title of pop up window."
	print, "			  (def='click on choice')"
	print
	print, "	examples:"
	print, "		;chose between cats dogs and mice"
	print, "		labels = ['cats','dogs','mice']"
	print, "		choice = pop_cult(labels)"
	print, "		print, labels(choice)"
	print
	print, "		;print 4 yes/no clicks"
	print, "		yn = [ 'yes ', 'no ']"
	print, "		print,yn( pop_cult(yn,4,title='click 4') )"
	print
	return, 0
endif
;-
				    ;Save active window and mouse status.
empty
wsav = !d.window
xsav = -1
ysav = -1
if wsav ge 0 then  cursor, xsav, ysav, /nowait, /device

				    ;Get the number of labels.
ndim = n_dims( labels, nlbls )
half = (nlbls+1)/2
				    ;Button size.
mrg = 28
blt = 200
				    ;Open window for buttons.
window, /free, xsize=2*blt, ysize=(half+1)*mrg $
, xpos=0, ypos=900-(half+1)*mrg
				    ;Print title.
if  n_elements(title) eq 0  then  ttl='click on choice' else ttl=title
xyouts, blt, half*mrg+8, ttl $
, /device, align=.5, charsize=1.4, color=!d.n_colors-1


				    ;Move cursor to middle of window.
if xsav ge 0 then  tvcrs, blt, half*mrg/2

				    ;Form image of a button.
rad = .5*(mrg-1)
rgt = blt-1-rad
button = lonarr(blt,mrg)
button(*,1:mrg-2) = !d.n_colors-1
xtmp = lindgen(blt,mrg)
ytmp = xtmp/blt
xtmp = xtmp-ytmp*blt
button( where( ( xtmp lt rad+1 and (xtmp-rad)^2+(ytmp-rad)^2 gt rad^2 ) $
            or ( xtmp gt rgt+1 and (xtmp-rgt)^2+(ytmp-rad)^2 gt rad^2 ) $
      ) ) = 0
				    ;Display buttons.
for i = 0,2*half-1  do begin
	ix = (i mod 2)*blt
	iy = i/2
	tv, button, ix, mrg*iy
	xyouts, ix+blt/2, iy*mrg+8, labels( i < (nlbls-1) ) $
	, /device, align=.5, charsize=1.4, color=0
end

				    ;Read nget clicks.
if  n_elements(nget) eq 0  then  nget=1
if  nget le 1  then  nget = 1
if  nget eq 1  then  bts = 0  else  bts = lonarr(nget)
dwn = lonarr(2*half)
i = 0
while  i lt nget  do begin

	repeat  cursor, cx, cy, /device , /up  $
	until   cx ge 0  and  cy lt half*mrg

	bt = 2*(cy/mrg)
	if  cx gt blt  then  bt=bt+1
	ix = (bt mod 2)*blt
	iy = bt/2
	dwn(bt) = (dwn(bt)+1) mod 2
	if dwn(bt) then begin
		tv, (!d.n_colors-1)-button, ix, mrg*iy
		xyouts, ix+blt/2, iy*mrg+8, labels( bt < (nlbls-1) ) $
		, /device, align=.5, charsize=1.4, color=!d.n_colors
	end else begin
		tv, button, ix, mrg*iy
		xyouts, ix+blt/2, iy*mrg+8, labels( bt < (nlbls-1) ) $
		, /device, align=.5, charsize=1.4, color=0
	end

	bts(i) = bt < (nlbls-1)

	if  labels(bts(i)) eq 'continue'  then begin
		bts(i:nget-1) = bts(i)
		i = nget
	end

	i = i+1
end
				    ;Delete pop up window.
wdelete, !d.window
				    ;Activate window number saved on entry.
if  wsav ge 0  then begin
	wset, wsav
	if xsav ge 0 then  tvcrs, !d.x_size/2, !d.y_size/2
end

return, bts

end
