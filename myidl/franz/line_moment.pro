FUNCTION LINE_MOMENT,X,Y,N, BCENT
;+
; NAME:
;	LINE_MOMENT
;
; PURPOSE:
;	Compute the centered moment of N-th order of the multidimensional
;	line profile Y.
;
; CALLING SEQUENCE:
;	Result = LINE_MOMENT(X,Y,N, [ BCENT ] )
;
; INPUTS:
;	X = positions along the line. Units can be given in
;		km/s, Angstroms,...
;	Y = array of 1, 2 or 3 dimensions. If Y has 3 dimensions, 
;		the third one is taken as line intensities for every 
;		X (wavelengths) value, and the first two dimensions 
;		are spatial. If Y has 2 dimensions, the columns are assumed
;		to be line intensities, and the rows are spatial positions,
;		e.g. along the slit. If Y is a vector, it will have to
;		be a single line profile.
;
;	N = order of the moment. If N has a negative value, output will
;		be the centre of gravity of Y; N = 0 is the equivalent
;		width; N = 1, the net line shift (again the centre of
;		gravity); N = 2, the full half-width; N = 3, the global 
;		line asymmetry. Higher orders have no physical meaning.
;
; OPTIONAL INPUTS:
;	BCENT = previously computed centre of gravity of Y.
;
; OUTPUTS:
;	Result = N-th order of Y. Number of dimensions of Result is number of
;		dimensions of Y minus one. If N less than zero, output 
;		will be the centre of gravity. If N = 0 the result if 
;		the moment of order zero. If N > 0, the result is the 
;		n-th order normalized to the zero order.
;
; SIDE EFFECTS:
;	None.
;
; COMMON BLOCKS:
;	None.
;
; RESTRICTIONS:
;	Y values must be normalized, i.e. Y = 1 - Ic/I, where
;	Ic is the continuum intensity in every spatial position,
;	and I is the intensity along the line profile, for each
;	wavelength X.
;
; PROCEDURE:
;	Straightforward. The trapezoidal rule is used for the
;	numerical integration of line profiles.
;
; EXAMPLES:
;	Let Y be a one-dimensional absorption line profile in the 
;	wavelength range X, and let YC be the intensity of a nearby
;	continuum. To compute the different moments:
;
;	IDL> Z = 1. - Y/YC		;Change of units. The line shape
;					;takes the form of a distribution.
;
;	IDL> print,LINE_MOMENT(X,Z,-1)	;Centre of gravity (line shift).
;
;	IDL> print,LINE_MOMENT(X,Z,0)	;Equivalent width.
;
;	IDL> print,LINE_MOMENT(X,Z,2)	;Line width (if Z is a gaussian,
;					;this is the square of st. deviat.).
;
; REFERENCES:
;	G. Caucci et al., "Some Remarks on the Data Analysis Problems in
;		Solar Two-dimensional Spectroscopy", in Proceedings of the
;		Tenth Sacramento Peak Summer Workshop "High Spatial Resolu-
;		tion Solar Observations", 1989, ed. Oskar von der Luhe.
;
; MODIFICATION HISTORY:
;	Written by Roberto Molowny Horas, February 1993.
;
;-
ON_ERROR,2

	s = SIZE(y)
	m = s(s(0))
	IF N_ELEMENTS(x) NE m THEN MESSAGE,$
		'Spectral line position do not coincide with input array'
	xx = FLOAT(x)

	zorder = 0.
	FOR i = 0,m-2 DO BEGIN			;Compute zeroth order moment.
		h = (xx(i+1) - xx(i)) / 2.	;For trapezoidal rule.
		CASE 1 OF
			s(0) EQ 1: zorder = zorder + (y(i+1) + $
				FLOAT(y(i))) * h
			s(0) EQ 2: zorder = zorder + (y(*,i+1) + $
				FLOAT(y(*,i))) * h
			ELSE: zorder = zorder + (y(*,*,i+1) + $
				FLOAT(y(*,*,i))) * h
		ENDCASE
	ENDFOR

	IF N_PARAMS(0) LT 4 THEN BEGIN		;Compute the centre of grav.
		bcent = 0.
		FOR i = 0,m-2 DO BEGIN		;Trapezoidal rule.
			h = (xx(i+1) - xx(i)) / 2.	;Increment.
			CASE 1 OF		;More than one dimension?
				s(0) EQ 1: bcent = bcent + (y(i+1)*xx(i+1) + $
					y(i)*xx(i)) * h
				s(0) EQ 2: bcent = bcent + (y(*,i+1)*xx(i+1)+ $
					y(*,i)*xx(i)) * h
				ELSE: bcent = bcent + (y(*,*,i+1)*xx(i+1) + $
					y(*,*,i)*xx(i)) * h
			ENDCASE
		ENDFOR
		bcent = bcent / zorder
	ENDIF

	IF N LT 0 THEN RETURN,bcent	;Only want centre of gravity.

	norder = 0.
	IF n EQ 0 THEN RETURN,zorder ELSE FOR i = 0,m-2 DO BEGIN
		h = (xx(i+1) - xx(i)) / 2.
		CASE 1 OF			;N-th order moment.
			s(0) EQ 1: norder = norder + $
				(y(i+1)*(xx(i+1)-bcent)^n + $
					y(i)*(xx(i)-bcent)^n) * h
			s(0) EQ 2: norder = norder + $
				(y(i+1)*(xx(i+1)-bcent)^n + $
					y(*,i)*(xx(i)-bcent)^n) * h
			ELSE: norder = norder + $
				(y(*,*,i+1)*(xx(i+1)-bcent)^n + $
					y(*,*,i)*(xx(i)-bcent)^n) * h
		ENDCASE
	ENDFOR

	RETURN,norder/zorder		;Normalized to zeroth order moment.

END