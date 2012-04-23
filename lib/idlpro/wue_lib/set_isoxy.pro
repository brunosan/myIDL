;+
; NAME:
;       SET_ISOXY
; PURPOSE:
;       Set data window with equal x & y scales.
; CATEGORY:
; CALLING SEQUENCE:
;       set_isoxy, xmn, xmx, ymn, ymx
; INPUTS:
;       xmn, xmx = desired min and max X.        in
;       ymn, ymx = desired min and max Y.        in
; KEYWORD PARAMETERS:
;       Keywords:
;         /LIST = list actual window that is set.
;         XLOCK = position where position is one of
;                 'xmn' to extend window upward from the min x.
;                 'xmd' to extend window outward from the mid x.
;                 'xmx' to extend window downward from the max x.
;         YLOCK = position where position is one of
;                 'ymn' to extend window upward from the min y.
;                 'ymd' to extend window outward from the mid y.
;                 'ymx' to extend window downward from the max y.
;         NXRANGE = [nx_min, nx_max] sets x pos. in norm. coord.
;                 Min and max normalized x.  Def = [0., 1.]
;         NYRANGE = [ny_min, ny_max] sets y pos. in norm. coord.
;                 Min and max normalized y.  Def = [0., 1.]
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes:
;         Either xmn, xmx or ymn, ymx will be adjusted to force
;         equal scaling in X and Y in the current screen window.
;         At least the specified range will be covered in both X
;         and Y, but a greater range will be covered in one.
;         The window middle or corners may be fixed.
;         set_isoxy, 0, 0, 0, 0 resets autoscaling.
; MODIFICATION HISTORY:
;       R. Sterner.  3 Sep, 1986.
;       Johns Hopkins University Applied Physics Laboratory.
;       RES 10 Sep, 1989 --- converted to SUN.
;-
 
	PRO SET_ISOXY, XMN0, XMX0, YMN0, YMX0, xlock=xlck, ylock=ylck, $
	  list=lst, help=hlp, nxrange=nxr, nyrange=nyr
 
	IF (N_PARAMS(0) lt 4) or keyword_set(hlp) THEN BEGIN
	  PRINT,' Set data window with equal x & y scales.'
	  PRINT,' set_isoxy, xmn, xmx, ymn, ymx'
	  PRINT,'   xmn, xmx = desired min and max X.        in'
	  PRINT,'   ymn, ymx = desired min and max Y.        in'
	  print,' Keywords:'
	  print,'   /LIST = list actual window that is set.'
	  print,"   XLOCK = position where position is one of"
	  print,"           'xmn' to extend window upward from the min x."
	  print,"           'xmd' to extend window outward from the mid x."
	  print,"           'xmx' to extend window downward from the max x."
	  print,"   YLOCK = position where position is one of"
	  print,"           'ymn' to extend window upward from the min y."
	  print,"           'ymd' to extend window outward from the mid y."
	  print,"           'ymx' to extend window downward from the max y."
	  print,'   NXRANGE = [nx_min, nx_max] sets x pos. in norm. coord.'
	  print,'           Min and max normalized x.  Def = [0., 1.]'
	  print,'   NYRANGE = [ny_min, ny_max] sets y pos. in norm. coord.'
	  print,'           Min and max normalized y.  Def = [0., 1.]'
	  print,' Notes:'
	  PRINT,'   Either xmn, xmx or ymn, ymx will be adjusted to force'
	  print,'   equal scaling in X and Y in the current screen window.'
	  print,'   At least the specified range will be covered in both X'
	  print,'   and Y, but a greater range will be covered in one.'
	  print,'   The window middle or corners may be fixed.'
	  print,'   set_isoxy, 0, 0, 0, 0 resets autoscaling.'
	  RETURN
	ENDIF 
 
	IF N_ELEMENTS(XLCK) EQ 0 THEN XLCK = 'XMD'	; defaults.
	IF N_ELEMENTS(YLCK) EQ 0 THEN YLCK = 'YMD'
	xlck = strupcase(xlck)
	ylck = strupcase(ylck)
 
	XMN = XMN0				; copy so changing values
	XMX = XMX0				; won't change them in caller.
	YMN = YMN0
	YMX = YMX0
 
	if total(abs([xmn,xmx,ymn,ymx])) eq 0.0 then begin  ; Set to autoscale.
	  !x.range = 0
	  !y.range = 0
	  return
	endif
 
	plotwin, xx, yy, x_size, y_size			; True plot window.
	if n_elements(nxr) eq 0 then nxr = [0., 1.]	; Force norm window to
	if n_elements(nyr) eq 0 then nyr = [0., 1.]	;   be defined.
	x_size = x_size*(nxr(1)-nxr(0))			; Size of norm. window.
	y_size = y_size*(nyr(1)-nyr(0))
 
	IDX = float(x_size)			; screen window side lengths.
	IDY = float(y_size)
 
	DX = FLOAT(XMX - XMN)			; data window side lengths.
	DY = FLOAT(YMX - YMN)
	YMD = .5*(YMN + YMX)			; data window midpoint.
	XMD = .5*(XMN + XMX)
 
	IF (DX/DY) GE (IDX/IDY) THEN BEGIN    ; adjust Y range.
	  DY2 = .5*DX*IDY/IDX			; half new Y range.
	  DX2 = .5*DX				; half old X range.
	ENDIF ELSE BEGIN		      ; adjust X range.
	  DX2 = .5*DY*IDX/IDY			; half new X range.
	  DY2 = .5*DY				; half old Y range.
	ENDELSE
 
;---------  lock window  -----------------
	CASE XLCK OF		  ; lock x.
'XMN':	XMX = XMN + DX2 + DX2	  ; lock x min.
'XMD':	BEGIN			  ; lock x mid.
	  XMN = XMD - DX2
	  XMX = XMD + DX2
	END
'XMX':	XMN = XMX - DX2 - DX2	  ; lock x max.
	ENDCASE
	CASE YLCK OF		  ; lock y.
'YMN':	YMX = YMN + DY2 + DY2	  ; lock y min.
'YMD':	BEGIN			  ; lock y mid.
	  YMN = YMD - DY2
	  YMX = YMD + DY2
	END
'YMX':	YMN = YMX - DY2 - DY2	  ; lock y max.
	ENDCASE
 
	set_window, xmn, xmx, ymn, ymx, nxrange=nxr, nyrange=nyr  ; full win.
	if keyword_set(lst) then begin
	  print,' Window set to:'
	  print,' xmn, xmx = ', xmn, xmx
	  print,' ymn, ymx = ', ymn, ymx
	endif
 
	RETURN
	END
