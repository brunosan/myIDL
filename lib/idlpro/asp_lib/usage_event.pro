pro usage_event, event
;+
;
;	procedure:  usage_widget
;
;	purpose:  event driver for usage_widget.pro
;
;	author:  rob@ncar, 3/93
;
;	usage:  usage_widget
;
;==============================================================================
;
;	Check parameters.
;
if n_params() ne 1 then begin
	print
	print, "usage:  usage_event, event"
	print
	print, "	Event driver for usage_widget.pro."
	print
	return
endif
;-
;
;	Set common blocks.
;
common usage_com, base, mlist, dir, text_id, file_mode, toggle_but
;
;	Get event type.
;
type= tag_names(event, /STRUCTURE)
;
;-----------------------------------
;
;	PROCESS EVENT.
;
case type of
;
;	Handle list widget (user selected a routine to see usage info on).
;
    'WIDGET_LIST':  begin
			routine = mlist(event.index)
			if (file_mode eq 1) then begin
				spawn, 'cat ' + dir + '/' + routine, text
			endif else begin
				spawn, 'nawk -f get_usage < ' + $
					dir + '/' + routine, text
			endelse
;;			ix = strpos(routine, '.pro')	; blank out '.pro'
;;			strput, routine, '    ', ix
;;			routine = strtrim(routine)
			widget_control, text_id, set_value=text
		    end
;
;	Handle buttons.
;
  'WIDGET_BUTTON':  begin
			widget_control, event.id, get_uvalue=but
			case but of
			  0: begin				; toggle
				file_mode = 1 - file_mode
				v = toggle_but(file_mode)
			        widget_control, event.id, set_value=v
			     end
			  1: widget_control, /destroy, base	; quit
			endcase
		    end
;
;	Handle text widget.
;
    'WIDGET_TEXT':  begin
			print, '---------------------------'
			print, 'widget_text -- should not have events here...'
			help, event, /str
		    end
;
;	Handle event error.
;
  else:             print, 'widget event error... ask Rob'
endcase
;
;-----------------------------------
;
end
