;+
; NAME:
;       MAKE_SCALE
; PURPOSE:
;       Plot circular scales on the laser printer.
; CATEGORY:
; CALLING SEQUENCE:
;       make_scale, file
; INPUTS:
; KEYWORD PARAMETERS:
;       Keywords:
;         PRINTER = postscript printer number (1=def or 2).
;         /LIST to list control files lines as processed.
;         XOFFSET=xn.  Scale center X shift in norm. coord.
;         YOFFSET=yn.  Scale center Y shift in norm. coord.
;           View page in portrait mode, +x to right, +y up.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes:
;         Control file format:
;         * in column 1 for comment lines.
;         A = a1, a2
;           Defines start and stop angles (deg) for arcs.
;           Not needed for circles.
;           a1, a2 = arc start & stop angles (deg) CCW from X axis.
;         R = r1, r2, r3, ..., rn
;           Draws arcs or circles of specified radius.
;           r1, r2, ... = list of radii (cm) to plot.
;         TICS = a1, a2, da,r1, r2
;           Draws tic marks.
;           a1, a2, da = tic angle start, stop, step (degrees).
;           r1, r2 = tic start, stop radii.
;         LABELS = L1, L2, dL, r, s, flg
;           Sets up labels to be used on next TICS command.
;           L1, L2, dL = label start, stop, step values.
;           r = label radial position (cm), s = label size.
;           flg = 0: to be read from outside the circle (def),
;                 1: to be read from inside the circle.
;         TEXT = r, a, flag, size, text
;           r = radius of text bottom in cm.
;           a = start angle of text in degrees CCW from X axis.
;           flag = 0 to read CW, 1 to read CCW.
;           size = text size.
;           text = text string to write.
; MODIFICATION HISTORY:
;       R. Sterner. 15 July, 1988.
;       Johns Hopkins University Applied Physics Laboratory.
;       RES 15 Sep, 1989 --- converted to SUN.
;-
 
	PRO MAKE_SCALE, F, help=hlp, list=lst, printer=prntr, $
	  xoffset=xoff, yoffset=yoff
 
	IF (N_PARAMS(0) LT 1) or keyword_set(hlp) THEN BEGIN
	  PRINT,' Plot circular scales on the laser printer.'
	  PRINT,' make_scale, file'
	  PRINT,'   file = Control file name.'
	  print,' Keywords:'
	  print,'   PRINTER = postscript printer number (1=def or 2).'
	  print,'   /LIST to list control files lines as processed.'
	  print,'   XOFFSET=xn.  Scale center X shift in norm. coord.'
	  print,'   YOFFSET=yn.  Scale center Y shift in norm. coord.'
	  print,'     View page in portrait mode, +x to right, +y up.'
	  print,' Notes:'
	  PRINT,'   Control file format:'
	  PRINT,'   * in column 1 for comment lines.'
	  PRINT,'   A = a1, a2'
	  PRINT,'     Defines start and stop angles (deg) for arcs.'
	  PRINT,'     Not needed for circles.'
	  PRINT,'     a1, a2 = arc start & stop angles (deg) CCW from X axis.'
	  PRINT,'   R = r1, r2, r3, ..., rn'
	  PRINT,'     Draws arcs or circles of specified radius.'
	  PRINT,'     r1, r2, ... = list of radii (cm) to plot.'
	  PRINT,'   TICS = a1, a2, da,r1, r2'
	  PRINT,'     Draws tic marks.'
	  PRINT,'     a1, a2, da = tic angle start, stop, step (degrees).'
	  PRINT,'     r1, r2 = tic start, stop radii.'
	  PRINT,'   LABELS = L1, L2, dL, r, s, flg'
	  PRINT,'     Sets up labels to be used on next TICS command.'
	  PRINT,'     L1, L2, dL = label start, stop, step values.'
	  PRINT,'     r = label radial position (cm), s = label size.'
	  PRINT,'     flg = 0: to be read from outside the circle (def),'
	  PRINT,'           1: to be read from inside the circle.'
	  print,'   TEXT = r, a, flag, size, text
	  print,'     r = radius of text bottom in cm.
	  print,'     a = start angle of text in degrees CCW from X axis.
	  print,'     flag = 0 to read CW, 1 to read CCW.
	  print,'     size = text size.
	  print,'     text = text string to write.
	  RETURN
	ENDIF
 
	ON_IOERROR, ERR
	GET_LUN, LUN
	OPENR, LUN, F
	ON_IOERROR, NULL
 
	num = 0
	if keyword_set(prntr) then num = prntr
	psinit, num, /full
	xsize = 19.08		; Full page x size in cm.
	ysize = 25.34		; Full page y size in cm.
	xoffset = 0.
	yoffset = 0.
	if keyword_set(xoff) then xoffset = xoff*xsize
	if keyword_set(yoff) then yoffset = yoff*ysize
	set_window, -xsize/2.-xoffset, xsize/2.-xoffset, $
	  -ysize/2.-yoffset, ysize/2.-yoffset
 
	;-------  Initial values  --------
	A1 = 0.		; Arc start angle.
	A2 = 360.	; Arc stop angle.
	LFLG = 0	; No labels defined.
 
	PRINT,'Plotting scale . . .'
	PLOTS, [0,0], [0,0], psym=1	; Mark center.
 
;=========  Loop through control file  ============
LOOP:	ITEM = NEXTITEM(LUN, TXT0)	; Get next command from control file.
	item = strupcase(item)
	if keyword_set(lst) then begin
	  print,' Control file line: ', txt0	; List control file lines.
	endif
	IF ITEM EQ '' THEN GOTO, DONE0	; At end of file?
	TXT = REPCHR(TXT0,'=')		; delete =.
	CASE ITEM OF
'A':	BEGIN				; Arc angle limits.
	  IF NWRDS(TXT) LT 3 THEN BEGIN
	    PRINT,'Error in A command.  Must give 2 values.'
	    PRINT,'A = a1, a2'
	    PRINT,'Processing aborted.'
	    RETURN
	  ENDIF
	  A1 = GETWRD(TXT,1) + 0	; Arc start angle.
	  A2 = GETWRD(TXT,2) + 0	; Arc stop angle.
	  IF A2 LE A1 THEN BEGIN
	    PRINT,'Error in angles: a1, a2 = ', a1, a2
	    PRINT,'  a1 must be less then a2.  Processing aborted.''
	    RETURN
	  ENDIF
	  PRINT,'  Scale start and stop angles set to ',A1, A2
	END
'R':	BEGIN
	  PRINT,'  Drawing arcs or circles.'
	  FOR I = 1, NWRDS(TXT)-1 DO BEGIN
	    R = GETWRD(TXT, I)
	    ARCS, R, A1, A2
	  ENDFOR
	END
'LABELS': BEGIN
	  IF NWRDS(TXT) LT 5 THEN BEGIN
	    PRINT,'Error in LABELS command.  Must give at least 4 values.'
	    PRINT,'LABELS = l1, l2, dl, rl, sz'
	    PRINT,'Processing aborted.'
	    RETURN
	  ENDIF
	  PRINT,'  Setting up labels.'
	  L1 = GETWRD(TXT,1) + 0.	; First label value.
	  L2 = GETWRD(TXT,2) + 0.	; Last label value.
	  DL = GETWRD(TXT,3) + 0.	; Label step size.'
	  RL = GETWRD(TXT,4) + 0.	; Label position radius.
	  SZ = 1.			; Default size.
	  T = GETWRD(TXT,5)		; Try to get size.
	  IF T NE '' THEN SZ = T+0.	; Got size.
	  LRV = 0			; Set for normal labels.
	  T = GETWRD(TXT,6)		; Try to get reverse flag.
	  IF T NE '' THEN LRV = T+0	; Got reverse flag.
	  T = MAKEI(L1, L2, DL)		; Labels must be integers.
	  NT = N_ELEMENTS(T)		; Number of labels
;	  LB = STRARR(20,NT)		; Setup array for labels.
	  LB = STRARR(NT)		; Setup array for labels.
	  FOR I = 0, NT-1 DO LB(I)=STRTRIM(T(I),2)	; Make labels.
	  LFLG = 1			; Set label flag.
	END
'TICS':	BEGIN
	  IF NWRDS(TXT) LT 6 THEN BEGIN
	    PRINT,'Error in TICS command.  Must give 5 values.'
	    PRINT,'TICS = a1, a2, da, r1, r2'
	    PRINT,'Processing aborted.'
	    RETURN
	  ENDIF
	  PRINT,'  Plotting tic marks.'
	  TA1 = GETWRD(TXT,1) + 0.	; Tics start angle.
	  TA2 = GETWRD(TXT,2) + 0.	; Tics stop angle.
	  DTA = GETWRD(TXT,3) + 0.	; Tics angle step.
	  TR1 = GETWRD(TXT,4) + 0.	; Tics start radius.
	  TR2 = GETWRD(TXT,5) + 0.	; Tics stop radius.
	  IF LFLG EQ 1 THEN BEGIN
	    RTICS, TA1, TA2, DTA, TR1, TR2, RL, LB, SZ, LRV
	    LFLG = 0
	  ENDIF ELSE BEGIN
	    RTICS, TA1, TA2, DTA, TR1, TR2
	  ENDELSE
	END
'TEXT':	begin
	  if nwrds(txt) lt 6 then begin
	    print,' Error in TEXT command. Must give at 5 values.'
	    print,' TEXT = r, a, flag, size, text
	    print,' Processing aborted.'
	    return
	  endif
	  print,'  Writing text.'
	  r = getwrd(txt,1) + 0.
	  a = getwrd(txt,2) + 0.
	  flag = getwrd(txt,3) + 0
	  sz = getwrd(txt, 4) + 0.
	  text = getwrd(txt0, 6, location=ll)
	  text = strmid(txt0, ll, 99)
	  raout, r, a, text, flag, size=sz, color=0
	end
ELSE:	BEGIN
	  PRINT,'Unknown command in control file: ' + ITEM
	END
	ENDCASE
 
	GOTO, LOOP
 
DONE0:	PSTERM
	PRINT,'Processing complete.'
 
DONE:	CLOSE, LUN
	FREE_LUN, LUN
	RETURN
 
ERR:	PRINT,'Could not open file ' + F
	GOTO, DONE
 
	END
