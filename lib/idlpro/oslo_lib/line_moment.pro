FUNCTION LINE_MOMENT,X,Y,N, ZERO = zero , FIRST = first
;+
; NAME:
;	LINE_MOMENT
;
; PURPOSE:
;	Compute the centered moment of zero, first and second order
;	of the multidimensional emission line profile Y.
;
; CALLING SEQUENCE:
;	Result = LINE_MOMENT(X,Y,N, [ ZERO =, FIRST =] )
;
; INPUTS:
;	X = spectral position along the line.
;		
;	Y = array of 1, 2 or 3 dimensions. If Y has 3 dimensions, 
;		the third one is taken as line intensities for every 
;		X (wavelengths) value, and the first two dimensions 
;		are spatial. If Y has 2 dimensions, wavelength is assumed
;		to run vertically, and horizontal direction is spatial
;		(e.g. the output of a spectrograph, rotated 90 degrees).
;		If Y is a vector, it must be a single line profile.
;
;	N = order of the moment. N should be 0, 1 or 2.
;
; OPTIONAL INPUTS:
;	ZERO = previously computed zero order moment.
;
;	FIRST = previously computed first order moment.
;
; OUTPUTS:
;	Result = order of line moment. Number of dimensions of Result is number of
;		dimensions of Y minus one.
;
; SIDE EFFECTS:
;	None.
;
; COMMON BLOCKS:
;	None.
;
; RESTRICTIONS:
;	Y values must be given in emission, such that it drops from maximum
;	intensity down to zero. If Ic is the continuum intensity, a
;	convenient normalization will be Y = 1-I/Ic, being I the original
;	intensity along the line profile, for each wavelength X.
;
; PROCEDURE:
;	Straightforward. The trapezoidal rule is used to integrate
;	numerically the line profiles.
;	The moments of a line profile are defined as follows:
;
;	* order N = 0: total line intensity.
;	* order N = 1: net line shift.
;	* order N = 2: square line width (when the profile is gaussian, this
;		is the square of its standard deviation).
;
;	Higher orders have no obvious physical meaning.
;
; EXAMPLES:
;	Let Y be a one-dimensional absorption line profile in the 
;	wavelength range X, and let YC be the intensity of a nearby
;	continuum. To compute the different moments:
;
;	IDL> Z = 1. - Y/YC		;Change of units. The line shape
;					;takes the form of a distribution.
;
;	IDL> print,LINE_MOMENT(X,Z,0)	;Total line intensity.
;
;	IDL> print,LINE_MOMENT(X,Z,1,zero=zero)		;Line shift.
;
;	IDL> print,SQRT(LINE_MOMENT(X,Z,2,zero=zero,first=first));Line width
;
;	Giving arrays ZERO and FIRST which have been calculated before,
;	saves computing time. Otherwise, they must be recomputed again.
;
; REFERENCES:
;	G. Caucci et al., "Some Remarks on the Data Analysis Problems in
;		Solar Two-dimensional Spectroscopy", in Proceedings of the
;		Tenth Sacramento Peak Summer Workshop "High Spatial Resolu-
;		tion Solar Observations", 1989, ed. Oskar von der Luhe.
;
;	J.E.Wiik, K.Dere and B.Schmieder, 1993, A&A, 273, 267
;
; MODIFICATION HISTORY:
;	Written by Roberto Molowny Horas, February 1993.
;	Minor modifications, May 1994, RMH
;-
ON_ERROR,2

	s = SIZE(y)
	m = s(s(0))				;Last dimension is spectral.
	IF N_ELEMENTS(x) NE m THEN MESSAGE,$
		'Spectral line position do not coincide with input array'
	IF n LT 0 OR n GT 2 THEN MESSAGE,'Order must be 0, 1 or 2'

	xx = FLOAT(x)					;Floating point.

	IF N_ELEMENTS(zero) EQ 0 THEN BEGIN		;Zero order is not provided.
		zero = 0.
		FOR i = 0,m-2 DO BEGIN			;Compute zeroth order moment.
			h = (xx(i+1) - xx(i)) / 2.	;For trapezoidal rule.
			CASE 1 OF
				s(0) EQ 1: zero = zero + (y(i+1) + $
					FLOAT(y(i))) * h
				s(0) EQ 2: zero = zero + (y(*,i+1) + $
					FLOAT(y(*,i))) * h
				ELSE: zero = zero + (y(*,*,i+1) + $
					FLOAT(y(*,*,i))) * h
			ENDCASE
		ENDFOR
	ENDIF
	IF n EQ 0 THEN RETURN,zero		;Moment of order 0.

	IF N_ELEMENTS(first) EQ 0 THEN BEGIN	;Computes the centre of grav.
		first = 0.
		FOR i = 0,m-2 DO BEGIN		;Trapezoidal rule.
			h = (xx(i+1) - xx(i)) / 2.	;Increment.
			CASE 1 OF		;More than one dimension?
				s(0) EQ 1: first = first + (y(i+1)*xx(i+1) + $
					y(i)*xx(i)) * h
				s(0) EQ 2: first = first + (y(*,i+1)*xx(i+1)+ $
					y(*,i)*xx(i)) * h
				ELSE: first = first + (y(*,*,i+1)*xx(i+1) + $
					y(*,*,i)*xx(i)) * h
			ENDCASE
		ENDFOR
		first = first / zero
	ENDIF
	IF n EQ 1 THEN RETURN,first		;Moment of order 1.

	second = 0.				;Moment of order 2.
	FOR i = 0,m-2 DO BEGIN
		h = (xx(i+1) - xx(i)) / 2.
		CASE 1 OF			;N-th order moment.
			s(0) EQ 1: second = second + $
				(y(i+1)*(xx(i+1)-first)^2 + $
				y(i)*(xx(i)-first)^2) * h
			s(0) EQ 2: second = second + $
				(y(*,i+1)*(xx(i+1)-first)^2 + $
				y(*,i)*(xx(i)-first)^2) * h
			ELSE: second = second + $
				(y(*,*,i+1)*(xx(i+1)-first)^2 + $
				y(*,*,i)*(xx(i)-first)^2) * h
		ENDCASE
	ENDFOR

	RETURN,second/zero

END