;+
;
; NAME:
;
;       FT_PLOT
;
;
; PURPOSE:
;
;   	Plots the positive frequency part of a Fourier Transform by automatically computing the right
;		frequency axis scaling and writing the right labels and units.
;		The user can choose to plot the modulus, the squared modulus, the real or imaginary part or
;		the phase of the FT.
;		The original y(x) function of which FT is the transform can also be plotted
;		if x and y vectors are supplied.
;
;
; DESCRIPTION:
;
;		The FFT is always a bit difficult to graph: man's mind feels not easy to think in Fourier space,
;		so that each time you must think about what the frequency axis of your FFT plot does mean with
;		respect to your x units. More the IDL FFT vector contains both positive and negative frequencies
;		organized in a complicated format: first nu=0, then +nu_min to +nu_max then again -nu_max to -nu_min.
;		This routine made for you the correct positive frequencies plot of your FFT giving an easy to
;		understand graph of it.
;
;
; CALLING SEQUENCE:
;
;		FT_Plot, FT, DATA_X=DATA_X, DATA_Y=DATA_Y, MODE=MODE, /NORMALIZE, /NO_ZERO_FREQ, $
;				X_UNIT=X_UNIT, NU_FACTOR=NU_FACTOR, NU_TITLE=NU_TITLE, _EXTRA=EXTRA, $
;   	        /PLOT_DATA, /LOG_DATA
;
; INPUTS:
;
;       FT:		The Fourier Transform to be plotted: 1D array of real or complex data.
;				Must be computed before to call FT_PLOT, e.g. by means of the FFT function.
;
;
; KEYWORDS:
;
;		DATA_X:	Vector of X coordinates of the original data y(X) of which FT is the transform.
;				If not supplied, an integer vector from 0 to n_elements(y)-1 is used for x-axis.
;
;		DATA_Y:	Vector of y values of the original data y(X) of which FT is the transform.
;				If not supplied, the keyword /PLOT_DATA cannot be set.
;
;		MODE:	String that specifies the type of plot as follows:
;				'SQUARED MODULUS': 	the default, plot the squared modulus of FT;
;				'MODULUS':			plot the modulus of FT;
;				'REAL':				plot the real part of FT;
;				'IMAGINARY':		plot the imaginary part of FT;
;				'PHASE':			plot the phase of FT;
;
;		NORMALIZE: if set, the plotted modulus or squared modulus of FT are normalized to the maximum.
;				If also /NO_ZERO_FREQ is set, the normalization is made on the non-zero frequencies.
;				Does not work in 'real', 'imaginary' or 'phase' modes.
;
;		NO_ZERO_FREQ: if set, the zero frequency component of FT is not plotted.
;				Does not work in 'phase' mode.
;
;		X_UNIT:	String: units of measure of the X coordinates of the original data y(x) of which FT
;				is the transform. We suggest to always supply the units of measure of X, so that the routine
;				can compute the correct scaling of the frequency nu-axis in units of cycles/X_UNIT.
;
;		NU_FACTOR: Float: if you want to plot the FT versus a custom nu-axis with units different than cycles/X_UNIT,
;				just specify here the multiplying factor: your_nu_unit = NU_FACTOR * (cycles/X_UNIT).
;				If this keyword is set, we suggest to also set NU_TITLE to the final frequency label and unit.
;
;		NU_TITLE: String: label of the frequency axis with units, useful when NU_FACTOR is different from 1.
;
;		OUTPUT: output array of dimension [2, n_elements(FT)], with the nu-axis in [0,*] and the
;				required mode of power spectra in [1,*].
;
;		PLOT_DATA: if set, the original data y(X) is also plotted. DATA_Y must be supplied too.
;
;		LOG_DATA: if set and also PLOT_DATA is set, the data y(X) are plotted in a log-log graph.
;
;		_EXTRA:	Any keyword of the PLOT routine can be used in calling this function.
;				Caution in using the keywords xtitle and ytitle which will overwrite the automatic titles and
;				the NU_TITLE settings.
;
;
; CALLS:
;
;		The function PLOT_LOG is called if /PLOT_DATA is set.
;
; MODIFICATION HISTORY:
;
;       September 2004, G. Li Causi, Rome Astronomical Observatory
;						licausi@mporzio.astro.it
;						http://www.mporzio.astro.it/~licausi/
;
;-


PRO FT_Plot, ft, data_x=data_x, data_y=data_y, MODE=MODE, NORMALIZE=NORMALIZE, NO_ZERO_FREQ=NO_ZERO_FREQ, $
			X_UNIT=X_UNIT, NU_FACTOR=NU_FACTOR, NU_TITLE=NU_TITLE, OUTPUT=OUTPUT, _EXTRA=EXTRA, $
            PLOT_DATA=PLOT_DATA, LOG_DATA=LOG_DATA


;************
;Input Check:
;************
IF NOT KEYWORD_SET(data_x) THEN data_x = dindgen(n_elements(ft))

IF n_elements(data_x) NE n_elements(ft) THEN Message, 'X vector must be have same number of elements as the Fourier Transform!'

IF NOT KEYWORD_SET(NU_FACTOR) THEN NU_FACTOR = 1.

IF KEYWORD_SET(X_UNIT) THEN data_unit = X_UNIT ELSE data_unit = 'X'



;*************************
;Plot of data if required:
;*************************
win = !d.window
IF KEYWORD_SET(PLOT_DATA) THEN BEGIN

	IF NOT KEYWORD_SET(data_y) THEN Message, 'No Y data have been supplied!'
	IF n_elements(data_y) NE n_elements(data_x) THEN Message, 'X and Y data must have same number of elements!'

	IF KEYWORD_SET(LOG_DATA) THEN BEGIN
		xlog=1
		ylog=1
	ENDIF

	IF win GT 0 THEN window, 0 ELSE window, 1
	Plot_Log, data_x, data_y, xtitle=data_unit, /xstyle, /ystyle, $
			title='Input data', ytitle='Intensity', xlog=xlog, ylog=ylog
	oplot, data_x, data_y, color=255
ENDIF



;**********
;Plot of FT
;**********
n_samples = n_elements(ft)
n_nu_points = n_samples/2 + 1			;numero elementi parte positiva frequenze FT

;Frequency axis definition:
x_range = max(data_x) - min(data_x) 	;total x range of the data
x_range= x_range / NU_FACTOR

nu = dindgen(n_nu_points)/(n_nu_points-1) / (x_range / n_samples) / 2	;x-axis
plot_nu_range = [0, n_nu_points/x_range]


;Retain only positive frequencies:
outputx = nu[0:n_nu_points-1]
f_2 = ft[0:n_nu_points-1]				;parte positiva delle frequenze



;Axis units and Titles:
IF NOT KEYWORD_SET(X_UNIT) THEN X_UNIT = 'units of X'
IF NU_FACTOR EQ 1 THEN nu_fac_string = '' ELSE nu_fac_string = 'units of ' + strtrim(string(NU_FACTOR),2)
IF KEYWORD_SET(NU_TITLE) THEN xtitle = NU_TITLE $
	ELSE xtitle='Frequency (' + nu_fac_string + ' cycles/' + X_UNIT + ')'
ytitle = 'Amplitude'

IF NOT KEYWORD_SET(MODE) THEN MODE = 'SQUARED MODULUS'
MODE = strupcase(MODE)
IF KEYWORD_SET(NORMALIZE) AND MODE NE 'MODULUS' AND MODE NE 'SQUARED MODULUS' THEN NORMALIZE = 0
IF KEYWORD_SET(NORMALIZE) THEN ytitle = 'Normalized ' + ytitle

IF KEYWORD_SET(EXTRA) THEN BEGIN
	ind = where(tag_names(EXTRA) EQ 'TITLE', count)
	IF count EQ 0 THEN EXTRA = CREATE_STRUCT(EXTRA, 'TITLE', 'Fourier Transform')
ENDIF ELSE BEGIN
	EXTRA = CREATE_STRUCT('TITLE', 'Fourier Transform')
ENDELSE


;Avoid zero frequency if required:
first_index = 0
IF KEYWORD_SET(NO_ZERO_FREQ) AND MODE NE 'PHASE' THEN BEGIN
	plot_nu_range = [1./x_range, n_nu_points/x_range]
	first_index = 1
ENDIF


;Preparing plot:
CASE MODE OF

	'REAL': BEGIN
		outputy = FLOAT(f_2)
		outp = outputy[first_index:*]
		yrange = [min(outp), max(outp)]
		ytitle = ytitle + ' Real Part'
	END

	'IMAGINARY': BEGIN
		outputy = IMAGINARY(f_2)
		outp = outputy[first_index:*]
		yrange = [min(outp), max(outp)]
		ytitle = ytitle + ' Imaginary Part'
	END

	'MODULUS': BEGIN
		outputy = ABS(f_2)
		outp = outputy[first_index:*]
		yrange = [min(outp), max(outp)]
		ytitle = ytitle + ' Modulus'
	END

	'SQUARED MODULUS': BEGIN
		outputy = (ABS(f_2))^2
		outp = outputy[first_index:*]
		yrange = [min(outp), max(outp)]
		ytitle = ytitle + ' Squared Modulus'
	END

	'PHASE': BEGIN
		outputy = ATAN(IMAGINARY(f_2), FLOAT(f_2))
		ytitle = 'Phase (radians)'
		yrange=[-!PI, !PI]
	END

ENDCASE


;Power normalization:
IF KEYWORD_SET(NORMALIZE) AND (MODE EQ 'MODULUS' OR MODE EQ 'SQUARED MODULUS') THEN BEGIN
	outputy = outputy / MAX(outp)
	yrange = [min(outputy), 1]
ENDIF


;Plotting and output:
IF win GT 0 THEN wset, win ELSE window, 1
PLOT, nu, outputy, xrange=plot_nu_range, yrange=yrange, /xstyle, $
		xtitle=xtitle, ytitle=ytitle,  _EXTRA=EXTRA
OPLOT, nu, outputy, color=255

output = transpose([[nu], [outputy]])


END