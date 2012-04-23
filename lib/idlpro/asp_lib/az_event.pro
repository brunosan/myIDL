pro az_event, event
;+
;
;	procedure:  az_event
;
;	purpose:  event handler for az_view.pro
;
;	author:  rob@ncar, 2/93
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 1 then begin
	print
	print, "usage:  az_event, event"
	print
	print, "	Event handler for az_view.pro."
	print
	return
endif
;-
;
;	Set common blocks.
;
common az_comm, base, max, index_im
;
;	Get event type.
;
type = tag_names(event, /STRUCTURE)
;
;	Process event.
;
case type of
  'WIDGET_BUTTON':  begin
			widget_control, event.id, get_value=button
			case button of
			 'zoom': begin
					print
					print, '  * Warning - do not' + $
				' change the colormap while zooming. *'
					print
					orig_w = !d.window
					wset, index_im
					zoom
					wset, orig_w
				 end
			 'quit': widget_control, /destroy, base
			   else: print, 'invalid button... ask Rob'
			endcase
		    end
  'WIDGET_SLIDER':  begin
			az_gray, event.value/float(max)
		    end

  else:		    print, 'widget event error... ask Rob'
endcase
;
end
