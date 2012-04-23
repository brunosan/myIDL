PRO Profiles_fft, image, kontinuum=ikont

on_error, 2                     ;Return to caller if an error occurs

s = size(image)
IF s(0) NE 3 THEN BEGIN
    message, 'Dim(data) is not 3.', /inf
    message, 'This routine is for use with volume data, use profiles instead.'
ENDIF

IF NOT keyword_set(ikont) THEN ikont = total(image, 3)

maxv = max(image)               ;Get extrema
minv = min(image)
orig_w = !d.window
;nx = s[1]				;Cols in image
;ny = s[2]				;Rows in image
nx = s(1)				;Cols in image
ny = s(2)				;Rows in image

device, get_screen_size=s_size
window, /free, xs=640, ys=512, xpos=0, ypos=s_size(1)-512, title='Profiles'
plotwin = !d.Window

plot, [-1, s(3)], [minv, maxv], /xsty, /ysty, /nodat, title='Profile'
vecx = findgen(s(3))
vecy = image(nx/2, ny/2, *)
value = strmid(nx/2, 8, 4)+strmid(ny/2, 8, 4)
plots, vecx, vecy
xyouts, .1, 0, /norm, value	;Text of locn

window, /free, xs=nx, ys=ny, xpos=640, ypos=s_size(1)-512, tit='Kontinuum'
datwin = !d.Window
tvscl, ikont

;print,'Right mouse button to Exit.'
;window,/free ,xs=wsize*640, ys=wsize*512,title='Profiles' ;Make new window
;new_w = !d.window
;old_mode = -1				;Mode = 0 for rows, 1 for cols
old_font = !p.font			;Use hdw font
!p.font = 0
;mode = 0
;if n_elements(order) eq 0 then order = !order	;Image order

WHILE 1 DO BEGIN 
    wset, datwin		;Image window
    cursor, x, y, 2, /dev	;Read position
    wset, plotwin 		;Graph window
    

    IF !err EQ 4 THEN BEGIN     ;Quit
        wset, orig_w
        wdelete, datwin
        wdelete, plotwin
        !p.Font = old_font
        return
    ENDIF
    
    IF (x LT nx) AND (y LT ny) AND $
      (x GE 0) AND (y GE 0) THEN BEGIN ;Draw it
        ;;if order then y = (ny-1)-y ;Invert y?
        
        ;plots, vecx, vecy, col=0 ;Erase graph
        xyouts, .1, 0, /norm, value, col=0 ;Erase text
        empty

        value = strmid(x, 8, 4)+strmid(y, 8, 4)
        vecy = reform(image(x, y, *))
        
        xyouts, .1, 0, /norm, value ;Text of locn
        ft_plot,fft(vecy),/no_zero       ;Graph
    ENDIF
    
ENDWHILE 
END

