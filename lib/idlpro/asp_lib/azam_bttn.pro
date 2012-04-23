pro azam_bttn, aa
;+
;
;	procedure:  azam_bttn
;
;	purpose:  display buttons for 'azam.pro'
;
;	author:  paul@ncar, 6/93	(minor mod's by rob@ncar)
;
;==============================================================================
;
;       Check number of parameters.
;
if n_params() ne 1 then begin
	print
	print, "usage:	azam_bttn, aa"
	print
	print, "	Display buttons for 'azam.pro'."
	print
	print, "	Arguments"
	print, "		aa	- azam data set structure"
	print
	print, "	Keywords"
	print, "		(none)"
	print
	return
endif
;-
				    ;Label image windows.
azam_relabel, aa
				    ;Recall some display parameters.
t      = aa.t
blt    = aa.blt
bwd    = aa.bwd
xdim   = aa.xdim
ydim   = aa.ydim
				    ;Set, erase, and show button window.
wset, aa.winb  &  erase, aa.black  &  wshow, aa.winb

				    ;Form image of button.
common common_bttn, button, mouse, wins
if  n_elements( button ) eq 0  then begin
	xx = lindgen(bwd,bwd)
	yy = xx/bwd
	xx = xx-yy*bwd
	brd = .5*(bwd-1)
	xx = xx-brd
	yy = yy-brd
	dot = replicate(aa.white,bwd,bwd)
	dot(where(round(xx*xx+yy*yy) ge round(brd*brd))) = aa.black
	button = replicate( aa.black, blt, bwd )
	button(0:bwd-1,*) = dot
	button(blt-bwd:blt-1,*) = dot
	button(bwd/2:blt-bwd/2,1:bwd-2) = aa.white
	mouse = replicate( aa.black, 3*blt, bwd )
	mouse(0:bwd-1,*) = dot
	mouse(3*blt-bwd:3*blt-1,*) = dot
	mouse(bwd/2:3*blt-bwd/2,1:bwd-2) = aa.white
	mouse(blt,*) = aa.black
	mouse(2*blt,*) = aa.black
	mouse(where(mouse eq aa.white)) = aa.yellow
	wins = replicate( aa.red, 2*blt, bwd )
	wins(blt,*) = aa.black
end
				    ;Display blank buttons.
tv, mouse,      0,   bwd
tv, wins,   3*blt,   bwd
tv, button,     0, 2*bwd
tv, button,   blt, 2*bwd
tv, button, 3*blt, 2*bwd
tv, button, 4*blt,     0
				    ;Print button names.
xyouts, /device, align=.5, charsize=1.4, color=aa.black $
, [ 0, 1, 2, 0, 1, 4, 3 ]*blt+blt/2 $
, [ 1, 1, 1, 2, 2, 0, 2 ]*bwd+4 $
, [ aa.cri, aa.anti, aa.prime, aa.axa, aa.lock, 'menu', 'set reference' ]

				    ;Print mouse button locations.
xyouts, /device, align=.5, charsize=1.4, color=aa.white $
, [ 0, 1, 2 ]*blt+blt/2 $
, 4 $
, [ 'left', 'center', 'right' ]
				    ;Print mouse drag strings.
xyouts, /device, align=.5, charsize=1.4, color=aa.black $
, [ 3, 4 ]*blt+blt/2 $
, bwd+4 $
, [ aa.drag0, aa.drag1 ]
				    ;Display other op button.
if aa.zoom eq 0 then begin
	tv, button, 5*blt,     0
	tv, button, 5*blt, 2*bwd
	xyouts, 5*blt+blt/2, [ 4, 2*bwd+4 ], [ 'BACKUP', 'other op' ] $
	, /device, align=.5, charsize=1.4, color=aa.black
end
				    ;Wait till no buttons pressed on 
				    ;button window.
repeat  cursor, xx, yy, /device, /nowait  until  !err eq 0

end
