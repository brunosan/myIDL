pro azam_help, dummy
;+
;
;	procedure:  azam_help
;
;	purpose:  print help info about azam procedure
;
;	author:  paul@ncar, 7/93	(minor mod's by rob@ncar)
;
;==============================================================================
;
;       Check number of parameters.
;
if n_params() ne 0 then begin
	print
	print, "usage:	azam_help"
	print
	print, "	Print help info about azam procedure."
	print
	return
endif
;-
print
print, '======================================================================'
print, 'MOUSE DRAG BUTTON'
print, '( up down )		Pick field most normal to surface.'
print, '( horizontal )		Pick field most tangent to surface.'
;print, '( up )			Pick field most away from sun core.'
;print, '( down )		Pick field most toward sun core.'
print, '( azimuth )		Pick field most away from azimuth center.'
print, '( anti azimuth )	Pick field most toward azimuth center.'
print, '( original )		Pick from program start image.'
print, '( unoriginal )		Pick opposite of program start image.'
print, '( reference )		Pick from reference image.'
print, '( anti reference )	Pick opposite of reference image.'
;print, '( singles )		Flip points ambiguous compared to 4 neighbors.'
print, '( wads )		Flip points ambiguous in an area.'
print, '( ongoing )		Drag on updated local azimuth & inclination.'
print, '( continuum )		Drag on continuum.'
print, '( field )		Drag on field strength.'
print, '( doppler )		Drag on doppler.'
print, '======================================================================'
print, 'To quit click on ( -EXIT- ) in ( menu )'
end
