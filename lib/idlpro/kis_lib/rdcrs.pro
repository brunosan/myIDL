PRO RDCRS,xc,yc
;+
; NAME: 
;	RDCRS	
; PURPOSE:
; 	prints and optionally returns accumulated user-coordinates of graphic
;	cursor if located in graphic window.
;*CATEGORY:            @CAT-# 26@
; 	Plotting (interactive on screen)
; CALLING SEQUENCE:
;	RDCRS[,xc][,yc]
; INPUTS:
; 	none	
; OPTIONAL OUTPUTS:
; 	xc, yc = vectors containing coordinates of all cursor positions
;	         where a mouse button was clicked.	
; SIDE EFFECTS:
;       cursor coordinates are printed in command window:
;         "continuously" if no parameters specified on call, else on
;	  down-click of mouse button;
;	clicking middle button forces a new print line;
;	clicking right button will exit procedure. 
; RESTRICTIONS:
; 	none
; PROCEDURE:
; 	calls IDL procedure CURSOR	
; MODIFICATION HISTORY:
;	nlte (KIS), 1990-02-19 
;	nlte (KIS), 1992-02-24 cursor mode /CHANGE if argument(s) specified,
;		               else /DOWN; 
;			       avoiding multiple output of identical positions.
;-
npar=n_params()
i=0
jmp1:!err=0
if npar eq 0 then cursor,x,y,/change else cursor,x,y,/down
if !err le 1 then cr=string("15b) else cr=string("12b)
if n_elements(xp) lt 1 or npar gt 0 then $
     print,format='($,"x=",G," y=",G,a)',x,y,cr else $
     if (x ne xp or y ne yp) then print,format='($,"x=",G," y=",G,a)',x,y,cr
if !err gt 1 then begin xp=x & yp=y & endif
if i eq 0 then begin
  case npar of
     0: if !err ge 4 then goto,jmp2 else goto,jmp1
     1: xc=x
     2: begin xc=x & yc=y & end
  endcase 
  i=1
endif else begin
  case npar of
     1: xc=[xc,x]
     2: begin xc=[xc,x] & yc=[yc,y] & end
  endcase     
endelse
if !err ge 4 then goto,jmp2 else goto,jmp1
;
jmp2:
return
end









