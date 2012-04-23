;+
; NAME:
;	SAVEDEF
; PURPOSE:
;	Save or restore the system variables !P,!X,!Y and !Z .
; CATEGORY:
;	Easy living
; CALLING SEQUENCE:
;	savedef ,/save    [,/quiet]
;	savedef ,/restore [,/quiet]
; INPUTS:
;	None.
; KEYWORD PARAMETERS:
;	/save    : if set , system variables are saved in COMMON defsave
;	/restore : if set , system variables are restored from COMMON defsave
;	/quiet   : if set , no message (except error) is printed.
; OUTPUTS:
;	No explicit outputs.
; COMMON BLOCKS:
;	common defsave,sav_first,sav_x,sav_y,sav_z,sav_p
; SIDE EFFECTS:
;	System variables !P,!X,!Y and !Z are changed.
;	A message about what is done is printed on the screen.
; RESTRICTIONS:
;	None.
; PROCEDURE:
; MODIFICATION HISTORY:
;	Written, A. Welz, Univ. Wuerzburg, Germany, March 1992
;-
pro savedef,save=save,restore=restore,quiet=quiet
on_error,2
common defsave,sav_first,sav_x,sav_y,sav_z,sav_p  

if n_elements(sav_first) eq 0 or keyword_set(save) then begin
   sav_first=1
   sav_x=!x
   sav_y=!y
   sav_z=!z
   sav_p=!p
   if not keyword_set(quiet) then print,   $
     'SAVEDEF: System variables !X,!Y,!Z and !P  saved in COMMON defsave'
   return
endif

if keyword_set(restore) then begin
   !x=sav_x
   !y=sav_y
   !z=sav_z
   !p=sav_p
   if not keyword_set(quiet) then print,   $
     'SAVEDEF: System variables !X,!Y,!Z and !P  restored from COMMON defsave'
  return
endif

print,'SAVEDEF: Error ; one of the keywords /SAVE or /RESTORE must be set.'

return
end
