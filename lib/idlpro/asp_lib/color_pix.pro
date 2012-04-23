pro color_pix, ann, ix, iy, type, theta, kflag
;+
;
;	procudure:  color_pix
;
;	purpose:  color a pixel for routine "wrap_key"
;
;	author:  rob@ncar, 8/92
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 6 then begin
	print
	print, "usage:  color_pix, ann, ix, iy, type, theta"
	print
	print, "	Color a pixel for routine 'wrap_key'."
	print
	print, "	Arguments"
	print, "		ann	     - annulus array"
	print, "		ix, iy	     - indices into array"
	print, "		type	     - see wrap_scale.pro 'type'"
	print, "		theta	     - angle at which to get color"
	print, "		kflag	     - key flag"
	print, "				1 = 180 degrees"
	print, "				2 = 360 degrees"
	print
	return
endif
;-
;
;	Specify common block.
;
@wrap.com
;
;	Insert appropriate color.
;
;-------------------------------- 180 degrees ---------------------------------
;

;;
;;  THIS WAS A FUDGE FOR USE IN pltibpg.pro.
;;  The 'if kflag eq 1 then begin' line below was commented out, and kflag
;;  of 2 was used.
;;
;;fudge = 1
;;if kflag eq 2 then if theta gt 180.0 then theta = theta - 180.0
;;if fudge eq 1 then begin

if kflag eq 1 then begin

; get in 0 to 180

case type of
  0: begin						; BLACK-AND-WHITE
	print
	print, 'Value "type" not currently supported.'
	print
	return
     end
;
  1: begin						; GRAYSCALE
	ann(ix, iy) = byte(fixr(ix_gray + theta * (num_gray / 180.)))
     end
;
  2: begin						; REVERSE GRAYSCALE
	ann(ix, iy) = $
		byte(fixr(ix_gray + num_gray - 1 + theta * (num_gray / 180.)))
     end
;
  3: begin						; COLORSCALE
	ann(ix, iy) = byte(fixr(ix_color2 + theta * (num_color2 / 180.)))
     end
;
  4: begin						; WRAPPED COLOR
	ann(ix, iy) = byte(fixr(ix_color + theta * (num_color / 180.)))
     end
;
  5: begin						; DISJOINT COLORSCALE
	if theta le 90.0 then begin
		ann(ix, iy) = $
			byte(fixr(ix_color3a + theta * (num_color3h / 91.0)))
	endif else begin
		ann(ix, iy) = $
			byte(fixr(ix_color3b + (theta - 91.0) * $
			(num_color3h / 90.0)))
	endelse
     end
;
  else: begin						; ERROR
	print
	print, 'Value "type" must be in range 0 - 5.'
	print
	return
	end
endcase
;
;-------------------------------- 360 degrees ---------------------------------
;
endif else begin

; get in 0 to 360

case type of
  0: begin						; BLACK-AND-WHITE
	print
	print, 'Value "type" not currently supported.'
	print
	return
     end
;
  1: begin						; GRAYSCALE
	ann(ix, iy) = byte(fixr(ix_gray + theta * (num_gray / 360.)))
     end
;
  2: begin						; REVERSE GRAYSCALE
	ann(ix, iy) = $
		byte(fixr(ix_gray + num_gray - 1 + theta * (num_gray / 360.)))
     end
;
  3: begin						; COLORSCALE
	ann(ix, iy) = byte(fixr(ix_color2 + theta * (num_color2 / 360.)))
     end
;
  4: begin						; WRAPPED COLOR
	ann(ix, iy) = byte(fixr(ix_color + theta * (num_color / 360.)))
     end
;
  5: begin						; DISJOINT COLORSCALE
	if theta le 180.0 then begin
		ann(ix, iy) = $
			byte(fixr(ix_color3a + theta * (num_color3h / 181.0)))
	endif else begin
		ann(ix, iy) = $
			byte(fixr(ix_color3b + (theta - 180.0) * $
			(num_color3h / 180.0)))
	endelse
     end
;
  else: begin						; ERROR
	print
	print, 'Value "type" must be in range 0 - 5.'
	print
	return
	end
endcase


endelse
;
;	Done.
;
end
