;+
; NAME: 
;     READFOR
; PURPOSE:
;     search file README in given directory and display it in a widget
; CALLING SEQUENCE:
;     readfor,directory
; INPUTS: 
;     directory=directory to search for README
; KEYWORD PATAMETERS:
; OUTPUTS:
;     display README in a widget
; COMMON BLOCKS:
; NOTES:
; MODIFICATION HISTORY:
;     A. Klein & G.Jung, 15 Feb 1993
;-

 pro readfor,dir
  name=dir+'/README'
  exist=findfile(name)
  a=lonarr(1)
  a(0)=strlen(exist)
  if a(0) eq 0 then begin
                 print,'no existing of '+name
               endif else begin
                 xdisplayfile,name
               endelse
  return
 end
