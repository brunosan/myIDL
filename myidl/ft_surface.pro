;+
;
; NAME:
;
;       FT_SURFACE
;
;
; PURPOSE:
;
;   	Draw the shaded surface of a Fourier Transform by automatically computing the right
;		frequency axis scaling and writing the right labels and units.
;		The user can choose to draw the modulus, the squared modulus, the real or imaginary part or
;		the phase of the FT.
;		The original z(x,y) function of which FT is the transform can also be drawn
;		if x and y vectors and z array are supplied.
;
;
; DESCRIPTION:
;
;		The FFT is always a bit difficult to graph: man's mind feels not easy to think in Fourier space,
;		so that each time you must think about what means the frequency axis of your FFT plot with
;		respect to your x units. More the IDL FFT vector contains both positive and negative frequencies
;		organized in a complicated format: first nu=0, then +nu_min to +nu_max then again -nu_max to -nu_min.
;		This routine made for you the correct surface plot of your FFT giving an easy to
;		understand graph of it.
;
;
; CALLING SEQUENCE:
;
;		FT_Surface, ft, data_x=data_x, data_y=data_y, data_z=data_z, MODE=MODE, /NORMALIZE, $
;				XY_UNIT=XY_UNIT, NU_FACTOR=NU_FACTOR, NU_TITLE=NU_TITLE, $
;				NU_X_AXIS=NU_X_AXIS, NU_Y_AXIS=NU_Y_AXIS, OUT_ZLABEL=OUT_ZLABEL, $
;				/XY_ISOMETRIC, /SHOW_DATA, /LOG_DATA
;
; INPUTS:
;
;       FT:		The Fourier Transform to be plotted: 2D array of real or complex data.
;				Must be computed before to call FT_SURFACE, e.g. by means of the FFT function.
;
;
; KEYWORDS:
;
;		DATA_X:	Vector of X coordinates of the original data z(X,Y) of which FT is the transform.
;				If not supplied, an integer vector from 0 to x size of z is used for x-axis.
;
;		DATA_X:	Same meaning of DATA_X but for y-axis.
;
;		DATA_Z:	2D array Z values of the original data z(X,Y) of which FT is the transform.
;				If not supplied, the keyword /SHOW_DATA cannot be set.
;
;		MODE:	String that specifies the type of plot as follows:
;				'SQUARED MODULUS': 	the default, plot the squared modulus of FT;
;				'MODULUS':			plot the modulus of FT;
;				'REAL':				plot the real part of FT;
;				'IMAGINARY':		plot the imaginary part of FT;
;				'PHASE':			plot the phase of FT;
;
;		NORMALIZE: if set, the plotted modulus or squared modulus of FT are normalized to the maximum.
;				Does not work in 'real', 'imaginary' or 'phase' modes.
;
;		XY_UNIT: String: units of measure of the X and Y coordinates of the original data Z(X,Y) of which FT
;				is the transform. We suggest to always supply the units of measure of X and Y,
;				so that the routine	can compute the correct scaling of the frequency nu-axis
;				in units of cycles/XY_UNIT.
;				Does not work if DATA_X or DATA_Y are not supplied.
;
;		NU_FACTOR: Float: if you want to draw the FT versus a custom nu-axis with units different
;				than cycles/XY_UNIT, just specify here the multiplying factor:
;				your_nu_unit = NU_FACTOR * (cycles/XY_UNIT).
;				If this keyword is set, we suggest to also set NU_TITLE to the final frequency label and unit.
;
;		NU_TITLE: String: label of the frequency axis with units, useful when NU_FACTOR is different from 1.
;
;		NU_X_AXIS: output array with the nu-x_axis.
;
;		NU_Y_AXIS: output array with the nu-y_axis.
;
;		OUTPUTZ: output 2D-array with the required mode of power spectra.
;
;		OUT_ZLABEL: output the string of the z-axis label with units.
;
;		SHOW_DATA: if set, the original data Z(X,Y) is also drawn. DATA_Z must be supplied.
;
;		LOG_DATA: if set and also SHOW_DATA is set, the data Z(X,Y) are plotted in a /zlog graph.
;
;		_EXTRA:	Any keyword of the SHADE_SURFACE routine can be used in calling this function.
;				Caution in using the keywords xtitle, ytitle and ztitle which will overwrite
;				the automatic titles and the NU_TITLE settings.
;
;
; MODIFICATION HISTORY:
;
;       September 2004, G. Li Causi, Rome Astronomical Observatory
;						licausi@mporzio.astro.it
;						http://www.mporzio.astro.it/~licausi/
;
;-


PRO FT_Surface, ft0, data_x=data_x, data_y=data_y, data_z=data_z, MODE=MODE, NORMALIZE=NORMALIZE, $
			XY_UNIT=XY_UNIT, NU_FACTOR=NU_FACTOR, NU_TITLE=NU_TITLE, $
			NU_X_AXIS=NU_X_AXIS, NU_Y_AXIS=NU_Y_AXIS, OUTPUTZ=OUTPUTZ, $
            SHOW_DATA=SHOW_DATA, LOG_DATA=LOG_DATA, XY_ISOMETRIC=XY_ISOMETRIC, OUT_ZLABEL=OUT_ZLABEL, $
			_EXTRA=EXTRA



;************
;Input Check:
;************

IF n_elements(ft0) EQ 0 THEN Message, 'No FT data has been provided!'

ft = ft0

s = size(ft)
IF s[0] NE 2 THEN Message, 'FT array must be 2-dimensional!'

IF NOT KEYWORD_SET(data_x) THEN data_x = dindgen(s[1])
IF NOT KEYWORD_SET(data_y) THEN data_y = dindgen(s[2])

IF n_elements(data_x) NE s[1] THEN Message, 'X and Y vectors must be have same size of FT array!'
IF n_elements(data_y) NE s[2] THEN Message, 'X and Y vectors must be have same size of FT array!'

IF NOT KEYWORD_SET(NU_FACTOR) THEN NU_FACTOR = 1.

IF KEYWORD_SET(XY_UNIT) THEN data_unit = XY_UNIT ELSE data_unit = 'X'


;**********************
;Show data if required:
;**********************
win = !d.window
IF KEYWORD_SET(SHOW_DATA) THEN BEGIN

	IF NOT KEYWORD_SET(data_z) THEN Message, 'No Z(X,Y) data have been supplied!'

	sz = size(data_z)
	IF sz[0] NE 2 THEN Message, 'Z array must be 2-dimensional!'
	IF sz[1] NE s[1] OR sz[2] NE s[2] THEN Message, 'Z array must the same size as FT!'

	IF win GT 0 THEN window, 0, title='Input Data' ELSE window, 1, title='Input Data'

	zmin = min(data_z)
	IF KEYWORD_SET(LOG_DATA) THEN BEGIN
		zlog=1
		IF zmin LE 0 THEN zmin = min(data_z[where(data_z GT 0)])
	ENDIF

	IF KEYWORD_SET(XY_ISOMETRIC) THEN BEGIN
		x_range = [min(data_x) < min(data_y), max(data_x) > max(data_y)]
		y_range = x_range
	ENDIF ELSE BEGIN
		x_range = [min(data_x), max(data_x)]
		y_range = [min(data_y), max(data_y)]
	ENDELSE

	SHADE_SURF, data_z, data_x, data_y, zlog=zlog, xtitle=data_unit, ytitle=data_unit, zrange=[zmin, max(data_z)], $
			/xstyle, /ystyle, /zstyle, ztitle='Intensity', charsize=3, yrange=y_range, xrange=x_range

ENDIF




;**********
;Draw 2D FT
;**********
n_samples_x = s[1]
n_samples_y = s[2]

;Center the origin:
ft = SHIFT(ft, n_samples_x/2, n_samples_y/2)

;Frequency ranges definition:
n_nu_points_x = n_samples_x				;numero elementi parte positiva e negativa frequenze FT
n_nu_points_y = n_samples_y				;numero elementi parte positiva e negativa frequenze FT

x_range = max(data_x) - min(data_x) 	;total x range of the data
x_range= x_range / NU_FACTOR

y_range = max(data_y) - min(data_y) 	;total y range of the data
y_range= y_range / NU_FACTOR

nu_x = (dindgen(n_nu_points_x)/(n_nu_points_x) - 0.5) / (x_range / n_samples_x)	;x-axis
nu_y = (dindgen(n_nu_points_y)/(n_nu_points_y) - 0.5) / (y_range / n_samples_y)	;y-axis

plot_x_range = [-n_nu_points_x/x_range/2, n_nu_points_x/x_range/2]
plot_y_range = [-n_nu_points_y/y_range/2, n_nu_points_y/y_range/2]



;Axis units and Titles:
IF NOT KEYWORD_SET(XY_UNIT) THEN XY_UNIT = 'units of X'

IF NU_FACTOR EQ 1 THEN nu_fac_string = '' ELSE nu_fac_string = 'units of ' + strtrim(string(NU_FACTOR),2)

IF KEYWORD_SET(NU_TITLE) THEN xtitle = NU_TITLE $
	ELSE xtitle='Frequency (' + nu_fac_string + ' cycles/' + XY_UNIT + ')'
ytitle = xtitle
ztitle = 'Amplitude'

IF NOT KEYWORD_SET(MODE) THEN MODE = 'SQUARED MODULUS'
MODE = strupcase(MODE)

IF KEYWORD_SET(NORMALIZE) AND MODE NE 'MODULUS' AND MODE NE 'SQUARED MODULUS' THEN NORMALIZE = 0
IF KEYWORD_SET(NORMALIZE) THEN ztitle = 'Normalized ' + ztitle



;Preparing plot:
CASE MODE OF

	'REAL': BEGIN
		outputz = FLOAT(ft)
		zrange = [min(outputz), max(outputz)]
		ztitle = ztitle + ' Real Part'
	END

	'IMAGINARY': BEGIN
		outputz = IMAGINARY(ft)
		zrange = [min(outputz), max(outputz)]
		ztitle = ztitle + ' Imaginary Part'
	END

	'MODULUS': BEGIN
		outputz = ABS(ft)
		zrange = [min(outputz), max(outputz)]
		ztitle = ztitle + ' Modulus'
	END

	'SQUARED MODULUS': BEGIN
		outputz = (ABS(ft))^2
		zrange = [min(outputz), max(outputz)]
		ztitle = ztitle + ' Squared Modulus'
	END

	'PHASE': BEGIN
		outputz = ATAN(IMAGINARY(ft), FLOAT(ft))
		zrange=[-!PI, !PI]
		ztitle = 'Phase (radians)'
	END

ENDCASE


;Power normalization:
IF KEYWORD_SET(NORMALIZE) AND (MODE EQ 'MODULUS' OR MODE EQ 'SQUARED MODULUS') THEN BEGIN
	outputz = outputz / MAX(outputz)
	zrange = [min(outputz), 1]
ENDIF



;Plotting and output:
IF win GT 0 THEN BEGIN
	wset, win
	wshow, win
ENDIF ELSE window, 0, title='Fourier Transform'


IF KEYWORD_SET(XY_ISOMETRIC) THEN BEGIN
	x_range = [min(plot_x_range[0]) < min(plot_y_range[0]), max(plot_x_range[1]) > max(plot_y_range[1])]
	y_range = x_range
ENDIF ELSE BEGIN
	x_range = plot_x_range
	y_range = plot_y_range
ENDELSE


SHADE_SURF, outputz, nu_x, nu_y, $
	zrange=zrange, xrange=x_range, yrange=y_range, $
	/xstyle, /ystyle, /zstyle, $
	xtitle=xtitle, ytitle=ytitle, ztitle=ztitle, $
	_EXTRA=EXTRA


nu_x_axis = nu_x
nu_y_axis = nu_y

OUT_ZLABEL = ztitle

END