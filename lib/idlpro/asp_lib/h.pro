pro h, v1,  v2,  v3,  v4,  v5,  v6,  v7,  v8,  v9,  v10, $
       v11, v12, v13, v14, v15, v16, v17, v18, v19, v20
;+
;
;	procedure:  h
;
;	purpose:  run 'helps' on 1 to 20 values
;
;	author:  rob@ncar, 5/92
;
;	notes:  - can't run help on no values because won't
;	          see variables that are not passed in
;		- limited to 20 inputs
;
;==============================================================================
;
;	Check number of parameters.
;
np = n_params()
if np lt 1 then begin
	print
	print, "usage:  h, v1 [, v2 [, v3 [...]]]"
	print
	print, "	Run 'helps' on 1 to 20 values."
	print
	return
endif
;-
;
;	Run help.
;
print
if np eq 1 then begin
	helps, v1
	print
endif else begin
	line = '-----------------'
	if np ge 1  then begin & helps, v1  & print, line & endif
	if np ge 2  then begin & helps, v2  & print, line & endif
	if np ge 3  then begin & helps, v3  & print, line & endif
	if np ge 4  then begin & helps, v4  & print, line & endif
	if np ge 5  then begin & helps, v5  & print, line & endif
	if np ge 6  then begin & helps, v6  & print, line & endif
	if np ge 7  then begin & helps, v7  & print, line & endif
	if np ge 8  then begin & helps, v8  & print, line & endif
	if np ge 9  then begin & helps, v9  & print, line & endif
	if np ge 10 then begin & helps, v10 & print, line & endif
	if np ge 11 then begin & helps, v11 & print, line & endif
	if np ge 12 then begin & helps, v12 & print, line & endif
	if np ge 13 then begin & helps, v13 & print, line & endif
	if np ge 14 then begin & helps, v14 & print, line & endif
	if np ge 15 then begin & helps, v15 & print, line & endif
	if np ge 16 then begin & helps, v16 & print, line & endif
	if np ge 17 then begin & helps, v17 & print, line & endif
	if np ge 18 then begin & helps, v18 & print, line & endif
	if np ge 19 then begin & helps, v19 & print, line & endif
	if np ge 20 then begin & helps, v20 & print, line & endif
endelse
;
end
