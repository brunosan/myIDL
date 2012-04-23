;+
; NAME:
;       CTBLD
; PURPOSE:
;       Build a color table.
; CATEGORY:
; CALLING SEQUENCE:
;       ctbld
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         XPOS=x screen x position of edit window.
;           0 to 500 (def = 200).
;         YPOS=y screen y position of edit window.
;           0 to 700 (def = 20).
;         SIZE=f edit window text size.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;       R. Sterner, 6 Sep, 1990
;-
 
	pro ctbld, xpos=xpos, ypos=ypos, help=hlp, size=cs
 
	if keyword_set(hlp) then begin
	  print,' Build a color table.'
	  print,' ctbld'
	  print,' Keywords:'
	  print,'   XPOS=x screen x position of edit window.'
	  print,'     0 to 500 (def = 200).'
	  print,'   YPOS=y screen y position of edit window.'
	  print,'     0 to 700 (def = 20).'
	  print,'   SIZE=f edit window text size.'
	  return
	endif
 
	;-------  initialize  ------
	r = 100			; Color patch red.
	g = 100			; Color patch green.
	b = 100			; Color patch blue.
	if n_elements(xpos) eq 0 then xpos = 200	; Window position.
	if n_elements(ypos) eq 0 then ypos = 20
	if n_elements(cs) eq 0 then cs=1.

	tvlct, rr, gr, br, /get		; Get curr CT = right side ct.
	maxc = !d.n_colors - 1
	if maxc lt 255 then begin
	  rr = [rr, bytarr(255-maxc)+rr(maxc)]	; Force to be 256 colors
	  gr = [gr, bytarr(255-maxc)+gr(maxc)]	;   by duplicating last color.
	  br = [br, bytarr(255-maxc)+br(maxc)]
	endif
	rundo = rr
	gundo = gr
	bundo = br
	rmem = rr
	gmem = gr
	bmem = br
	x0 = 8
	zgun = bytarr(256,40)			; Gun indicator blanking.
	rgun = bytarr(256,40)+1b		; Red gun indicator.
	ggun = bytarr(256,40)+2b		; Green gun indicator.
	bgun = bytarr(256,40)+3b		; Blue gun indicator.
	gray = bytarr(300-x0-256, 150) + 64	; All gun numbers blanking.
	gray2 = gray(*,0:49)			; Single gun number blanking.
	mode_on = bytarr(10,10) + 255b		; Show mode on.
	mode_off = bytarr(10,10) + 100b		; Show mode off.
	;-----  Mode Flags  ------
	imode = 3				; Interpolation mode (1-3)
	mmode = 0				; Move colors mode (0,1)
	memflag = 0				; No colors stored yet.
	;-----  Color bar range  ------
	rlo = 128				; Color range limits.
	rhi = 128
	lst_rhi = rhi
	lst_rlo = rlo
	lstins = 128				; Last inserted color.
	lstins2 = 128
	mlo = rlo
	mhi = rhi
	zrange = bytarr(40,300)+100		; Range blanking.
	crange = zrange(0:29,*)-50		; Range indicator.
 
	;-------  Initial screen setup  --------
	wdelete, 2
	window, 2, xsize=600, ysize=300, xpos=xpos, ypos=ypos, $
	  title='Build Color Table'
	rl = indgen(256)			  ; Set up left side CT.
	gl = rl					  ; Start all gray,
	bl = rl
	rl(1) = 255 & gl(1) = 0   & bl(1) = 0	  ; 1 = red
	rl(2) = 0   & gl(2) = 255 & bl(2) = 0	  ; 2 = green
	rl(3) = 0   & gl(3) = 0   & bl(3) = 255	  ; 3 = blue
	rl(4) = r   & gl(4) = g   & bl(4) = b	  ; 4,5,6 = given color.
	rl(5) = r   & gl(5) = g   & bl(5) = b
	rl(6) = r   & gl(6) = g   & bl(6) = b
	topi = 4				  ; Top color index.
	boti = 4				  ; Bottom color index.
	if n_elements(top) gt 0 then begin
	  rl(5) = top(0) & gl(5) = top(1) & bl(5) = top(2)  ; Set top color.
	  topi = 5
	endif
	if n_elements(bot) gt 0 then begin
	  rl(6) = bot(0) & gl(6) = bot(1) & bl(6) = bot(2)  ; Set bottom color.
	  boti = 6
	endif
	tvlct, rl, gl, bl			; Load working color table.
	erase, 64				; Window background (gray).
	;--------  left half  -------------
	tv, bytarr(256,150), x0, 150		; Bar background (black).
	tv, bytarr(300,75)			; Black border.
	tv,bytarr(290,25)+4b,5,25		; Color patch.
	tv,bytarr(290,20)+topi,5,50		; Top color.
	tv,bytarr(290,20)+boti,5,5		; Bottom color.
	xyouts, x0, 140, /dev, align=.5, '0',$	; Labels.
	  size=cs
	xyouts, x0+255, 140, /dev, align=.5, '255', size=cs
	xyouts, 20, 114+10, /dev, 'Left Button: Set color values', $
	  size=1.5*cs
	xyouts, 20, 101+5, /dev, 'Middle Button: Adjust brightness', $
	  size=1.5*cs
	xyouts, 20, 88,  /dev, 'Right Button: quit', size=1.5*cs
	;-------  right half  -------------
	tv,bytarr(300,300)+100, 300, 0
	lay = strarr(17)
	lay(0) = [530,20,565,276,0,255,0,255,0,250,50]
	lay(11) = 'i3'
	lay(13) = [1,1,255,255]
	bar, layout=lay
	xyouts,/dev,310,280,'MODES',size=1.5*cs
	x = [310,330,330,310,310]
	y = [255,255,275,275,255]
	plots,/dev,x,y	    & xyouts,/dev,340,260,'HSV curved', size=1.2*cs
	tv, mode_on, 315, 260
	plots,/dev,x,y-20   & xyouts,/dev,340,240,'HSV straight', size=1.2*cs
	plots,/dev,x,y-40   & xyouts,/dev,340,220,'RGB', size=1.2*cs
	plots,/dev,x,y-60   & xyouts,/dev,340,200,'Move/Slide Colors', $
	  size=1.2*cs
	xyouts,/dev,310,175,'ACTIONS',size=1.5*cs
	plots,/dev,x,y-105  & xyouts,/dev,340,155,'Interpolate range ends', $
	  size=1.2*cs
	plots,/dev,x,y-125  & xyouts,/dev,340,135,'Extract midrange color', $
	  size=1.2*cs
	plots,/dev,x,y-145  & xyouts,/dev,340,115,'Insert color into range', $
	  size=1.2*cs
	plots,/dev,x,y-165  & xyouts,/dev,340,95,'Store range colors', $
	  size=1.2*cs
	plots,/dev,x,y-185  & xyouts,/dev,340,75,'Recall stored colors', $
	  size=1.2*cs
	plots,/dev,x,y-205  & xyouts,/dev,340,55,'Reverse stored colors', $
	  size=1.2*cs
	plots,/dev,x,y-225  & xyouts,/dev,340,35,'Undo last command', $
	  size=1.2*cs
	plots,/dev,x,y-245  & xyouts,/dev,340,15,'Help', size=1.2*cs
	dr = rhi - rlo
	tv, crange(*,0:dr), 498, 20+rlo				; Range bar.
	xyouts, /dev, 513, rhi+25, align=.5, strtrim(rhi,2),size=cs ; Labels.
	xyouts, /dev, 513, rlo+10, align=.5, strtrim(rlo,2), size=cs
	rmd = (rlo+rhi)/2
	xyouts,/dev,495,rmd+20,align=.5,orient=90,strtrim(rmd,2),size=cs
 
	;------- Show starting color  ------
	tv, bgun(0:b,*), x0, 155
	xyouts, x0+255, 165, /dev, align=-.2, strtrim(b,2), size=cs
	tv, ggun(0:g,*), x0, 205
	xyouts, x0+255, 215, /dev, align=-.2, strtrim(g,2), size=cs
	tv, rgun(0:r,*), x0, 255
	xyouts, x0+255, 265, /dev, align=-.2, strtrim(r,2), size=cs
 
;--------  Left side commands  (Color patch adjustment)  ------------
lrd:	tvrdc, x, y, 1, /dev
 
	if x ge 300 then begin		; Right side command?
	  tvlct, rr, gr, br		; Yes, load right side ct.
	  goto, right
	endif
 
	;-----  Quit --------
left:	if !err eq 4 then begin
	  tvlct, rr, gr, br		; Load right side color table.
	  wdelete, 2   			; Delete edit window.
	  return
	end
 
	if y lt 150 then goto, lrd
 
	dx = (x - x0)<255>0
	dy = (y - 150)/50
 
	;------  Adjust brightness  ------
	if !err eq 2 then begin
	  m = r>g>b		; Max gun setting.
	  f = dx/float(m)	; Brightness factor
	  r = fix(.5+r*f)>1	; Adjust gun values.
	  g = fix(.5+g*f)>1
	  b = fix(.5+b*f)>1
	  dy = 3		; Set for case option 3.
	endif
 
	;-----  Adjust r, g, or b  -------
	case dy of
0:	begin				; Blue
	  b = dx			; New blue value.
	  tv, zgun, x0, 155		; Zero old blue bar.
	  tv, bgun(0:b,*), x0, 155	; Display new blue bar.
	  tv, gray2, x0+256, 150	; Blank blue number.
	  xyouts, x0+256, 165, /dev, align=-.2, strtrim(b,2),size=cs
	end
1:	begin				; Green
	  g = dx			; New green value.
	  tv, zgun, x0, 205		; Zero old green bar.
	  tv, ggun(0:g,*), x0, 205	; Display new green bar.
	  tv, gray2, x0+256, 200	; Blank green number.
	  xyouts, x0+256, 215, /dev, align=-.2, strtrim(g,2),size=cs
	end
2:	begin				; Red
	  r = dx			; New red value.
	  tv, zgun, x0, 255		; Zero old red bar.
	  tv, rgun(0:r,*), x0, 255	; Display new red bar.
	  tv, gray2, x0+256, 250	; Blank red number.
	  xyouts, x0+256, 265, /dev, align=-.2, strtrim(r,2),size=cs
	end
else:
	endcase
 
new:	if dy eq 3 then begin
	  tv, gray, x0+256, 150		; Blank all gun numbers.
	  tv, zgun, x0, 155		; Zero old blue bar.
	  tv, bgun(0:b,*), x0, 155	; Dislpay new blue bar.
	  xyouts, x0+256, 165, /dev, align=-.2, strtrim(b,2),size=cs
	  tv, zgun, x0, 205		; Zero old green bar.
	  tv, ggun(0:g,*), x0, 205	; Display new green bar.
	  xyouts, x0+256, 215, /dev, align=-.2, strtrim(g,2),size=cs
	  tv, zgun, x0, 255		; Zero old red bar.
	  tv, rgun(0:r,*), x0, 255	; Display new red bar.
	  xyouts, x0+256, 265, /dev, align=-.2, strtrim(r,2),size=cs
	endif 
	rl(4) = r		; Load new color into left side color table.
	gl(4) = g
	bl(4) = b
	tvlct, rl, gl, bl	; Load updated left side color table.
 
	goto, lrd
 
;---------  Right side commands  ---------
rrd:	tvrdc, x, y, 1, /dev
	wait,.2		; Avoid multiple hits.
 
	;---------  side switch  ----------
	if x lt 300 then begin		; Left side command?
	  tvlct, rl, gl, bl		; Yes, load left side ct.
	  goto, left
	endif
	
	;--------  Soft buttons  ----------
right:	if (x ge 310) and (x le 330) then begin		; Soft buttons.
	  ;-------  MODES  -----------
	  if (y ge 195) and (y le 275) then begin	; Modes.
	    num = (y-195)/20
	    case num of
0:	    begin	; Move colors.
	      mmode = (mmode + 1) mod 3
	      tv, bytarr(133,15)+100b, 339, 196	; Erase text.
	      if mmode gt 0 then begin
	        tv, mode_on,315,200
		if mmode eq 1 then xyouts,/dev,340,200,'Move Colors', $
		  size=1.2*cs
		if mmode eq 2 then xyouts,/dev,340,200,'Slide Colors', $
		  size=1.2*cs
	      endif else begin
	        tv, mode_off,315,200
		xyouts,/dev,340,200,'Move/Slide Colors', size=1.2*cs
	      endelse
	      lst_rhi2 = lst_rhi		; Start remembering now.
	      lst_rlo2 = lst_rlo
	      lst_rhi = rhi
	      lst_rlo = rlo
	    end
1:	    begin	; RGB interp.
	      imode = 1
	      tv, mode_off, 315, 260
	      tv, mode_off, 315, 240
	      tv, mode_on, 315, 220
	    end
2:	    begin	; HSV straight interp.
	      imode = 2
	      tv, mode_off, 315, 260
	      tv, mode_on, 315, 240
	      tv, mode_off, 315, 220
	    end
3:	    begin	; HSV curved interp.
	      imode = 3
	      tv, mode_on, 315, 260
	      tv, mode_off, 315, 240
	      tv, mode_off, 315, 220
	    end
	    endcase
	    goto, rrd
	  endif   ; Modes
	  ;-------  ACTIONS  -----------
	  if (y ge 10) and (y le 170) then begin	; Actions.
	    num = (y-10)/20
;	    print,' Action ',num,' selected'
	    case num of
0:	    begin	; Help
	      print,' '
	      print,' The Build Color Table window has two sides.'
	      print,' Each side is enabled by clicking the mouse '+$
	        'anywhere in that side.'
	      print,' The LEFT side is used to adjust a single color '+$
	        'value, or quit.'
	      print,'   LEFT side button actions are listed in the window.'
	      print,' The RIGHT side is used to modify the color table.'
	      print,'   RIGHT side button actions:'
	      print,'   Any button may be used to select modes or actions.'
	      print,'   The Left button adjusts upper or lower ends '+$
	        'of color bar range.'
	      print,'   The Middle button moves the color bar range '+$
	        'without changing its size.'
	      print,'   The Right button does a debug stop if outside '+$
	        'the range bar.'
	      print,'     Inside the range bar it toggles between a '+$
	        'range of 1 and the last two'
	      print,'     inserted colors (to make interpolation easier).'
	      print,'   Color interpolation modes:'
	      print,'     HSV curved interpolates along arcs in Hue, '+$
	        'Saturation, Value space,'
	      print,'     giving more saturated colors.  HSV straight '+$
	        'interpolates straight'
	      print,'     between points in Hue, Saturation, Value space, '+$
	        'passing through'
	      print,'     less saturated colors.  RGB interpolates '+$
	        'straight bewteen points in'
	      print,'     Red, Green, Blue color space.'
	      print,'  Move colors will move the colors in the selected '+$
	        'color range as that'
	      print,'    range is moved.  Colors may be lost off the ends '+$
	        'of the bar.
	      print,'  Slide colors slides the colors in the range '+$
	        'non-destructively up and down'
	      print,'    the table.  Insert colors with Slide Colors off, '+$
	        'turn Slide Colors on to'
	      print,'    position color.
	      print,' '
;	      goto, rrd
	    end
1:	    begin	; Undo
	      print,' Undo last color table change.'
	      rr = rundo
	      gr = gundo
	      br = bundo
	      tvlct, rr, gr, br
;	      goto, rrd
	    end
2:	    begin	; Reverse colors.
	      t = mlo
	      mlo = mhi
	      mhi = t
	      print,' Stored colors reversed.'
	    end
3:	    begin	; Recall
	      rundo = rr  & gundo = gr  & bundo = br	; Save before change.
	      n = rhi - rlo + 1
	      indin = fix(0.5 + maken(mlo, mhi, n))	; Indices into memory.
	      rr(rlo) = rmem(indin)
	      gr(rlo) = gmem(indin)
	      br(rlo) = bmem(indin)
	      tvlct, rr, gr, br
	      print,' Color range recalled from memory.'
;	      goto, rrd
	    end
4:	    begin	; Store
	      rmem = rr
	      gmem = gr
	      bmem = br
	      mlo = rlo
	      mhi = rhi
	      print,' Color range stored.'
	    end
5:	    begin	; Insert
	      if mmode ne 2 then begin
	        rundo = rr  & gundo = gr  & bundo = br	; Save before change.
	      endif
	      rr(rlo:rhi) = r				; Insert new color.
	      gr(rlo:rhi) = g
	      br(rlo:rhi) = b
	      tvlct, rr, gr, br
	      rmd = (rhi+rlo)/2			; Remember insertion midpoint.
	      lstins2 = lstins
	      lstins = rmd
	      print,' Color inserted into range.'
	    end
6:	    begin	; Extract
	      r = fix(rr(rmd))
	      g = fix(gr(rmd))
	      b = fix(br(rmd))
	      dy = 3
	      print,' Midrange color extracted.'
	      goto, new
	    end
7:	    begin	; Interp
	      rundo = rr  & gundo = gr  & bundo = br	; Save before change.
	      ctint, rr, gr, br, rlo, rhi, imode
	      print,' Interpolation complete.'
	    end
	    endcase
	    goto, rrd
	  endif   ; Actions.
	endif   ; Soft buttons.
 
	;--------  Adjust range bar  -------------
	if (x ge 498) and (x le 528) then begin		; Range adjust.
	  lst_rhi = rhi					; Save last range ends.
	  lst_rlo = rlo
	  y = y - 20					; Curs color bar index.
	  ;-------  Set range = 1  ------------
	  if !err eq 4 then begin			; Rt Bt: range to 1.
	    if rlo eq rhi then begin
	      rlo = lstins<lstins2
	      rhi = lstins>lstins2
	    endif else begin
	      rmd = (rlo+rhi)/2
	      rlo = rmd
 	      rhi = rmd
	    endelse
	    !err = 0
	  endif
	  ;-------  Range endpoints  ----------
	  if !err eq 1 then begin			; Lft bttn,rng endpts.
	    dhi = abs(rhi-y)				; Curs dist from hi.
	    dlo = abs(rlo-y)				; Curs dist from lo.
	    ;-----  Allow for a range of 1  -------
	    if (abs(rhi-rlo) le 2) and $		; Allw range of 1 or 2.
	       ((rlo lt y) and (y le rhi)) then begin
	      if y eq rhi then rlo = y<rhi else rhi = y>rlo
	    endif else begin
	      ;-----  dhi eq dlo  --------
	      if dhi eq dlo then begin			; Range = 1.
	        if y gt rhi then rhi = y
	        if y le rlo then rlo = y
	      endif
	      ;-----  dhi lt dlo  -----
	      if dhi lt dlo then begin			; Move closest.
	        rhi = y<255
	      endif
	      ;-----  dhi gt dlo  -----
	      if dhi gt dlo then begin
	        rlo = y>0
	      endif
	    endelse
	  endif						; End left button.
	  rhi = rhi<255
	  rlo = rlo>0
	  ;--------  Move range  ---------
	  if !err eq 2 then begin			; Mid bttn, slide rnge.
	    rmd = (rlo+rhi)/2				; Range midpoint.
	    dr = y - rmd				; Desired range shift.
	    if (rhi+dr) gt 255 then dr = 255-rhi	; Don't mv rnge off tp,
	    if (rlo+dr) lt 0   then dr = -rlo		; or off the bottom.
	    rlo = rlo + dr				; Compute new range.
	    rhi = rhi + dr
	  endif						; End middle button.
	  ;-------  Display range  ---------
	  tv, zrange, 488, 0				; Blank old range bar.
	  dr = rhi - rlo + 1
	  tv, crange(*,0:dr), 498, 20+rlo		; New bar.
	  xyouts,/dev,513,rhi+25,align=.5,strtrim(rhi,2),size=cs ; New labels.
	  xyouts,/dev,513,rlo+10,align=.5,strtrim(rlo,2),size=cs
	  rmd = (rlo+rhi)/2				;    Range midpoint.
	  xyouts,/dev,495,rmd+20,orient=90,align=.5,strtrim(rmd,2),size=cs
 
	  ;---------  Process move colors mode  ------------
	  if mmode eq 1 then begin
	    rlst = rr			; Save current ct before modifying.
	    glst = gr
	    blst = br
	    ;--------  Below range bar  ------
	    ind = fix(.5+maken(0,(lst_rlo-1)>0,rlo))
	    rr(0) = rlst(ind)
	    gr(0) = glst(ind)
	    br(0) = blst(ind)
	    ;--------  Inside range nar  -------
	    ind = fix(.5 + maken(lst_rlo, lst_rhi, rhi-rlo+1))
	    rr(rlo) = rlst(ind)
	    gr(rlo) = glst(ind)
	    br(rlo) = blst(ind)
	    ;--------  Above range bar  --------------
	    maxc = 255
	    ind = fix(.5 + maken((lst_rhi+1)<maxc, maxc, maxc-rhi))
	    rr((rhi+1)<maxc) = rlst(ind)
	    gr((rhi+1)<maxc) = glst(ind)
	    br((rhi+1)<maxc) = blst(ind)
	    ;------  Load new table  --------
	    tvlct, rr, gr, br
	    print,' Color range moved.'
	  endif   ; Move colors.
 
	  ;---------  Process Slide colors  ----------
	  if mmode eq 2 then begin
	    rlst = rr			; Save current ct before modifying.
	    glst = gr
	    blst = br
	    rr = rundo			; Get original color table.
	    gr = gundo
	    br = bundo
	    ;--------  Inside range nar  -------
	    ind = fix(.5 + maken(lst_rlo, lst_rhi, rhi-rlo+1))
	    rr(rlo) = rlst(ind)
	    gr(rlo) = glst(ind)
	    br(rlo) = blst(ind)
	    ;------  Load new table  --------
	    tvlct, rr, gr, br
	    print,' Color range slid.'
	  endif   ; Slide colors
 
	endif   ; Range bar adjust.
 
	;--------- Debug stop ---------
	if !err eq 4 then begin
	  stop,' Debug stop.  Do .con to continue.'
	endif
 
	goto, rrd
 
	end
