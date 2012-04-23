PRO Profiles3tip, image, image1, image2, image3, kontinuum=ikont

on_error, 2                     ;Return to caller if an error occurs

s = size(image)
IF s(0) NE 3 THEN BEGIN
    message, 'Dim(data) is not 3.', /inf
    message, 'This routine is for use with volume data, use profiles instead.'
ENDIF

IF NOT keyword_set(ikont) THEN ikont = total(image, 3)

maxv = max(image)               ;Get extrema
minv = min(image)

maxv1 = max(image1)               ;Get extrema
minv1 = min(image1)

maxv2 = max(image2)               ;Get extrema
minv2 = min(image2)

maxv3 = max(image3)               ;Get extrema
minv3 = min(image3)

orig_w = !d.window
;nx = s[1]                              ;Cols in image
;ny = s[2]                              ;Rows in image
nx = s(1)                               ;Cols in image
ny = s(2)                               ;Rows in image

device, get_screen_size=s_size
window, /free, xs=600, ys=960, xpos=0, ypos=s_size(1)-960, title='Profiles'
plotwin = !d.Window
!P.Multi=[0,1,4]
plot, [-1, s(3)], [minv, maxv], /xsty, /ysty, /nodat, title='Profile'
vecx = findgen(s(3))
vecy = image(nx/2, ny/2, *)
value = strmid(nx/2, 8, 4)+strmid(ny/2, 8, 4)
oplot, vecx, vecy

plot, [-1, s(3)], [minv1, maxv1], /xsty, /ysty, /nodat, title='Profile1'
 vecy1 = image1(nx/2, ny/2, *)
; lines=find_lines(vecy1)
oplot, vecx, vecy1

plot, [-1, s(3)], [minv2, maxv2], /xsty, /ysty, /nodat, title='Profile2'
 vecy2 = image2(nx/2, ny/2, *)
; lines=find_lines(vecy1)
oplot, vecx, vecy2

plot, [-1, s(3)], [minv3, maxv3], /xsty, /ysty, /nodat, title='Profile3'
 vecy3 = image3(nx/2, ny/2, *)
; lines=find_lines(vecy1)
oplot, vecx, vecy3

xyouts, .1, 0, /norm, value     ;Text of locn

window, /free, xs=nx, ys=ny, xpos=600, ypos=s_size(1)-960, tit='Kontinuum'
datwin = !d.Window
tvscl, ikont

;print,'Right mouse button to Exit.'
;window,/free ,xs=wsize*640, ys=wsize*512,title='Profiles' ;Make new window
;new_w = !d.window
;old_mode = -1                          ;Mode = 0 for rows, 1 for cols
old_font = !p.font                      ;Use hdw font
!p.font = 0
;mode = 0
;if n_elements(order) eq 0 then order = !order  ;Image order

WHILE 1 DO BEGIN
    wset, datwin                ;Image window
    cursor, x, y, 2, /dev       ;Read position
    wset, plotwin               ;Graph window

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
        plot, [-1, s(3)], [minv, maxv], /xsty, /ysty, /nodat, title='Profile'
        oplot, vecx, vecy, col=0 ;Erase graph
        xyouts, .1, 0, /norm, value, col=0 ;Erase text

        ;lines_old=lines

        ;oplot, [lines_old(0),lines_old(0)],[minv, maxv], col=0
        ;oplot, [lines_old(1),lines_old(1)],[minv, maxv], col=0

        ;empty

        value = strmid(x, 8, 4)+strmid(y, 8, 4)
        vecy = image(x, y, *)
        vecy1 = image1(x, y, *)
        vecy2=image2(x,y,*)
        vecy3=image3(x,y,*)
;       lines=find_lines(vecy1)

        xyouts, .1, 0, /norm, value ;Text of locn
        oplot, vecx, vecy       ;Graph
;        oplot, [lines(0),lines(0)],[minv, maxv]
;       oplot, [lines(1),lines(1)],[minv, maxv]

    plot, [-1, s(3)], [minv1, maxv1], /xsty, /ysty, /nodat, title='Profile1'
    oplot, vecx, vecy1, col=0 ;Erase graph
;    oplot, vecx, vecy1, psym=2, col=0       ;Graph
;       oplot, [lines_old(0),lines_old(0)],[minv1, maxv1], col=0
;       oplot, [lines_old(1),lines_old(1)],[minv1, maxv1], col=0

    oplot, vecx, vecy1       ;Graph
;    oplot, vecx, vecy1,psym=2
;       oplot, [lines(0),lines(0)],[minv1, maxv1]
;       oplot, [lines(1),lines(1)],[minv1, maxv1]

    plot, [-1, s(3)], [minv2, maxv2], /xsty, /ysty, /nodat, title='Profile2'
    oplot, vecx, vecy2, col=0 ;Erase graph
    oplot, vecx, vecy2       ;Graph
    
    plot, [-1, s(3)], [minv3, maxv3], /xsty, /ysty, /nodat, title='Profile3'
    oplot, vecx, vecy3, col=0 ;Erase graph
    oplot, vecx, vecy3       ;Graph

    ENDIF

ENDWHILE
!P.Multi=[0,1,1]

;!p.multi=0
print,'finito'

END
