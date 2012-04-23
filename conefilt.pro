PRO conefilt, mov, dx, dt, vel, VERBOSE=verbose
;+
; NAME:
;       CONEFILT
; PURPOSE:
;       k-w filtering of a 2D time series (in memory)
; CALLING SEQUENCE:
;       Conefilt, data, dx, dt, Vel
; INPUTS:
;       Data:     3-D datacube (x,y,t) with images.  Will be
;                 overwritten by result!
;       dx, dt:   (spatial and temporal) stepwidth of data
;       vel:      cutoff Velocity in km/s 
; OPTIONAL PARAMETERS:
;       
; KEYWORDS:
;       
; OUTPUTS:
;       
; RESTRICTIONS:
;       
; PROCEDURE:
;       
; MODIFICATION HISTORY:
;       20-Oct-1999  P.Suetterlin, SIU
;       26-Oct-1999  First and last image are somehow "smeared". Try
;                    to put an artificial interpolated image before
;                    and after the series.
;       08-Feb-2001  Rewrite: more general, fix bugs
;-

on_error, 2

IF n_params() LT 4 THEN BEGIN
    message, "Use: Conefilt, data, dx, dt, Vel", /informal
    return
ENDIF

s = size(mov)
IF s(0) NE 3 THEN BEGIN
    message, "Input data must be a 3d data cube (x,y,t)!"
    return
ENDIF

sx = s(1)
sy = s(2)
num = s(3)
dtype = s(4)
memuse = (sx*sy*(num+2))*8

  ;;; stop if the data cube needs more than 500MB

IF memuse GT 500*1024l^2 THEN BEGIN
    message, "Data cube exceeds 500MB - use conefilt_file instead!"
    return
ENDIF

  ;;; create an array with the radial wavenumbers.
  ;;; horizontal and vertical binsize are assumed to be equal.
  ;;; code taken from IDL routine dist.

kr = fltarr(sx, sy, /nozero)
k_ny = 0.5/dx
x = findgen(sx)
x = (x < (sx-x))
x = ((x/max(x))*k_ny)^2

sy2 = float(sy/2)
tmp = k_ny/sy2

FOR i=0., sy2 DO BEGIN
    y = sqrt(x + (tmp*i)^2)
    kr(0, i) = y
    IF i NE 0 THEN kr(0, sy-i) = y
ENDFOR


  ;;; temporal boundary conditions: Insert an additional (identical)
  ;;; frame at the beginning and end
  ;;; ?? Or use apodisation ??

sm = (mov(*, *, 0) + mov(*, *, num-1))/2
mov = [[[sm]], [[temporary(mov)]], [[sm]]]
n = num+2
n2 = n/2

  ;;; Do the FFT
mov = fft(temporary(mov), -1)

  ;;; temporal frequency points
f = findgen(n2+1)/n2*(0.5/dt)

  ;;; take out the cone with kr < f/Vel

FOR i=1, n/2 DO BEGIN
    mask = kr GT (f(i)/Vel)
    mov(*, *, i) = mov(*, *, i) * mask
    mov(*, *, n-i) = mov(*, *, n-i) * mask
ENDFOR

  ;;; FFT back, convert to float and cut off first and last image

mov = fft(mov, 1, /over)
mov = float(temporary(mov))
mov = (temporary(mov))(*, *, 1:n-2)

  ;;; Convert to original data type if not float

IF dtype EQ 1 THEN mov = byte(mov < 255 > 0)
IF dtype EQ 2 THEN mov = fix(mov < 32767 > (-32767))

END



