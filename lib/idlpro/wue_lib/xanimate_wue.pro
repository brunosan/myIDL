pro xanimate, set = set, image = image, frame = frame, order = order, $
	close = close, title = title, rate = rate 
;+
; NAME:
;		XANIMATE
; PURPOSE:
;	Display an animated sequence of images using Xwindows Pixmaps,
;		or the SunView display.
; CATEGORY:
;	Image display.
; CALLING SEQUENCE:
;   To initialize:
;	XANIMATE, SET = [ Sizex, Sizey, Nframes, Show_window, Pixmap_window]
;   To load a single image:
;	XANIMATE, IMAGE = Image, FRAME = frame_index
;   After all the images have been loaded, To display:
;	XANIMATE, RATE = Frames_per_second
;   To stop the display, hit any key.
;   Or to display images at the fastest possible rate:
;	XANIMATE
;   To close and deallocate the pixmap / buffer:
;	XANIMATE, /CLOSE
; INPUTS:
;	RATE =  Display the animated sequence.  Rate = the basic rate
;		in frames per second.  Default value = Infinity.
;		Overhead for loading the images,
;		etc, is ignored.  1./RATE is actually the delay between
;		loading successive images.  To stop the animated sequence,
;		hit any key. (The keyboard focus must be in the main
;		text window.)
; KEYWORD PARAMETERS:
;	SET: Initializes XANIMATE.  SET should be set to a
;		3-5 element integer vector containing the following parameters:
;		Sizex, Sizey = the size of the images to be displayed, in
;			pixels.
;		Nframes = number of frames in animated sequence.
;		Show_window = Window number to display sequence.  If omitted
;			window 0 is used.  Ignored for Sun (the current window
;			is used.)
;		Pixmap_window = Window number for the invisible pixmap.
;			If omitted, window 1 is used.  (Ignored for Sun).
;	IMAGE: Loads a single image at the position given by FRAME.
;		FRAME must be in the range of 0 to Nframes-1.
;		The keyword parameter FRAME must also be specified.
;	ORDER: Set if images run from top down, omitted or zero if
;		images go from bottom to top.  Only used when loading
;		images.
;	CLOSE: Deletes pixwin and window, freeing storage.
;	TITLE: String to set the title of the Show_window. (X only).
; OUTPUTS:
;	No explicit outputs.
; COMMON BLOCKS:
;	XANIMATE_COM - private common block.
; SIDE EFFECTS:
;	A pixmap and window are created.
; RESTRICTIONS:
;	FOR X: The maximum pixmap size varies greatly between Xwindow servers.
;	For example, many VAX displays can only create pixmaps as large
;	as the visible screen.  In other machines, the maximum pixmap
;	size is determined by the amount of virtual memory the Xserver
;	can obtain.
;
;	FOR SUN: a large 2D memory array is made to contain the images.
;	For large images or a large number of frames, this can be a
;	real memory hog.  For SunView, faster operation will be obtained
;	by using a non-retained window.
; PROCEDURE:
;	When initialized this procedure creates an approximately square
;	pixmap or memory buffer, large enough to contain Nframes of
;	the requested size.
;	Once the images are loaded, by using the IMAGE and FRAME keywords,
;	they are displayed by copying the images from the pixmap
;	or buffer to the visible window.
; MODIFICATION HISTORY:
;	DMS, April, 1990.
;-
common xanimate_com, pwin, swin, nframes, xs, ys, nfx, buffer

if (!d.name ne 'SUN') and (!d.name ne 'X') then $
	message,'Not a window oriended device.'

if keyword_set(close) then begin
	if !d.name eq 'SUN' then begin
		if n_elements(buffer) gt 1 then buffer = 0
		return
		endif
	if n_elements(pwin) eq 0 then return
	if pwin lt 0 then return
	wdelete, swin, pwin
	pwin = -1
	return
	endif

if keyword_set(set) then begin
	xs = set(0)
	ys = set(1)
	nframes = set(2)
	if n_elements(set) ge 4 then swin = set(3) else swin = 0
	if n_elements(set) ge 5 then pwin = set(4) else pwin = 1
	fx = sqrt(nframes)	;# of frames across
	nfx = fix(fx)
	if fx ne nfx then nfx = nfx + 1
	nfy = (nframes + nfx -1) / nfx

	if !d.name eq 'SUN' then begin
		s = size(buffer)  ;Existing buffer
		new = 1		;Make a new image
		if s(0) eq 2 then begin  ;Will previous window do?
		  if (s(1) ge xs) and (s(2) ge ys * nframes) then new = 0
		endif
		if new then begin	;Make new buffer
		  buffer = 0		;Delete old buffer
		  buffer = bytarr(xs, ys * nframes, /nozero)
		  endif
		return
		endif
	wdelete, swin, pwin   ;Remove previous windows
	if n_elements(title) eq 0 then title = 'Xanimate'
	window,retain=0, swin, xsize = xs, ysize = ys, title= title
	window,/pixmap, pwin, xsize = xs * nfx, ysize = nfy * ys
	wset, swin
	return
	endif

;	Here, windows must exist
if !d.name eq 'X' then begin
	if n_elements(pwin) eq 0 then message,"Not initialized"
	if pwin lt 0 then message,"Not initialized"
endif

if !d.name eq 'SUN' then $
	if n_elements(buffer) le 1 then $
		message, "Not initialized."

if n_elements(image) ne 0 then begin	;Load image?
	s = size(image)
	if (s(0) ne 2) or (s(1) gt xs) or (s(2) gt ys) then $
		message, "Image parameter must be 2D of size" $
		+ string(xs)+ string(ys)
	if (frame lt 0) or (frame ge nframes) then $
		message, "Frame number must be from 0 to nframes -1."
	if n_elements(order) eq 0 then order = 0  ;Default order

	if !d.name eq 'SUN' then begin
		if order eq 0 then buffer(0,frame * ys) = reverse(image,2) $
		else buffer(0, frame * ys) = image
	endif else begin
		xp = (frame mod nfx) * xs
		yp = (frame / nfx) * ys
		old_window = !d.window
		wset, pwin
		tv,image, xp, yp, order = order
		wset, old_window
	endelse
	return
endif
	

if n_elements(rate) ne 0 then delay = 1./rate else delay =0.0
t = systime(1)
j = 0L

if !d.name eq 'SUN' then begin
	while 1 do for i=0,nframes-1 do begin
		y = i * ys
		tv, buffer(*, y : y + ys-1), /order
		j = j + 1
		wait, delay
		if get_kbrd(0) ne '' then goto, done
		endfor
endif

wset, swin
wshow, swin
while 1 do for i=0, nframes-1 do begin
	device, copy = [ (i mod nfx) * xs, (i / nfx) * ys, xs, ys, 0, 0, pwin]
	j = j + 1
	wait, delay
	if get_kbrd(0) ne '' then goto, done
	endfor

done: print,j / (systime(1) - t), ' Frames per second.'
end
