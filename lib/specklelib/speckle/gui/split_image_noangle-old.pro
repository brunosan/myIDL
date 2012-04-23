PRO split_image, NOSHIFT=noshift, SKIP_NOISE=skip_noise, INMEM=inmem

;+
; NAME:
;       SPLIT_IMAGE
; PURPOSE:
;       Speckle-Code: Divide the raw images into small subimage series
; CALLING SEQUENCE:
;       Split_Image
; INPUTS:
;       none
; KEYWORDS:
;       NOSHIFT: (Flag) if set and not zero, no additional tracking of
;                the subimage-series will be done.
; COMMON BLOCKS:
;       
; SIDE EFFECTS:
;       
; RESTRICTIONS:
;       
; PROCEDURE:
;       
; MODIFICATION HISTORY:
;         -   -199   P.Suetterlin, USG
;       16-Dec-1996  Pit  Option: No additional tracking for subimages
;                         Use dynamic unit allocation.
;       27-May-1997  Pit  Moved computation of noise power here, to
;                         use exactly the same positions.
;                         Scale noise power within each subimage
;                         (additional variable partnorm)
;       03-Jul-1997  Pit  Save startpoint of subimaging together with
;                         stepwidth.
;       21-Jul-1998  Pit  division by zero errors for stepwidth if number 
;                         of subimages in one direction is 1
;       07-Jan-1999  Pit  New keyword SKIP_NOISE to omit computation
;                         of noise power spectra (must be computed
;                         elswhere!)
;       28-Jun-1999  Pit  Computation of averaged parts, needed 
;                         automatic checking in check_images
;       29-Jun-1999  Pit  Partial rewrite to reduce disk seek time:
;                         first compute all shifts (makes the first
;                         reads sequential).
;                         safety edge at the rim to prevent bad shifts.
;       11-Sep-1999  Pit  Error in boundary check of subimage shift
;       09-Mar-2000  Pit  Adapt for new, rms-sorted images
;       28-Mar-2000  Pit  keyword IN_MEM to keep whole burst in memory
;                         - speeds up writing by a factor of ~6-10
;       27-Sep-2000  Pit  adaption to 8-bit raw data
;       28-Sep-2000  Pit  re-arrange writing loop if not using IN_MEM
;       28-June-2004 Klaus Possibility of Visualisation  
;       17-July-2004       Introducing possible correction of the angular 
;                          dependency of the correction of adaptive optics
;                          requires CENTERPOS.PRO


;bruno for limb
;DO NOT ROTATE, just check if only sky
;calculates %for each subfield < given threshold.
;%sky< 10 sun, save number of subfield as sun
;%sky> 90 sky, save number of subfield as sky
;rest is limb, save number of subfield as limb.
;
;take one limb subfield and call te pro. limbextra to generate extra subfields of horizontally aligned subfields.

@~/idl_lib/specklelib/speckle/gui/commoninc

;BRUNO FOR LIMB
	;arbitrary chosen
	sky=0.25
;Bruno end	

;;; triple shift left to overwrite text on the screen
sl = string(byte([27, 91, 68, 27, 91, 68, 27, 91, 68]))

IF S_n GE 100 THEN ndigit = 3 ELSE ndigit = 2

breite = 0
hoehe = 0


kontrast = fltarr(N_Image, /nozero)
partnorm = fltarr(S_n, /nozero)
xvector = intarr(N_Image, S_n)
yvector = intarr(N_Image, S_n)

;;; Number of digits in filenames

;ndigit = fix(alog10(S_n))+1

get_lun, unit1
get_lun, unit2
get_lun, unit3
;;; Read size of tracked images

openr, unit2, HelpDir + restdim
readf, unit2, breite
readf, unit2, hoehe
close, unit2



winx=breite/4
winy=hoehe/4
winy=fix(winy)
;;; Read rms values, find best image (used as reference)
;;; No longer needed - images are sorted with descending rms.
;;; Image 0 is the best.

maxindex = 0
;;;
;;; Now the sub-imaging.  These get additional correction for
;;; relative image shifts.

;;; Stepwidth for sub-imaging based on the number of parts
;;; But save some more pixels at the rim (here:6)

IF S_nx GT 1 THEN $
xstep = fix((breite-S_Size-6)/(S_nx-1)) $
ELSE $
xstep = S_Size

IF S_ny GT 1 THEN $
ystep = fix((hoehe-S_Size-6)/(S_ny-1))$
ELSE $
ystep = S_Size

case resolution of
		1024:begin
			windowx=breite/6
			windowy=hoehe/6
			end
		1200:begin
			windowx=breite/5
			windowy=hoehe/5
			end
		1600:begin
			windowx=breite/4
			windowy=hoehe/4
			end
		endcase


;;; Center the used image part in main image

xoffset = (breite - (S_nx-1)*xstep - S_Size) / 2
yoffset = (hoehe - (S_ny-1)*ystep - S_Size) / 2

;goto,eo        ;goto a part of code (developing phase)



;;; Save stepwidth and startpoint for later use

openw, unit1, ResDir + stepname ; schrittweite
printf, unit1, xstep
printf, unit1, ystep
printf, unit1, xoffset
printf, unit1, yoffset
close, unit1

IF NOT quiet THEN begin
widget_control,text_311,set_value='Subimaging to '+string(S_nx, format="(i3)")+'x'+ $
string(S_ny, format="(i3)")+' images using stepwidth ('+string(xstep,format="(i3)") +','+ $
string(ystep,format="(i3)") +') starting at ('+string(xoffset,format="(i3)") +','+ $
string(yoffset,format="(i3)") +')'
endif

;IF NOT quiet THEN print, S_nx, S_ny, xstep, ystep, xoffset, yoffset, $
;  format="('Subimaging to ',i2,'x',i2,' images using stepwidth ('," + $
;  "i2, ',', i2, ') starting at (',i2,',',i2,')')"

;;; new apodisation mask for fft-correlation: a simple cosquad

filter = (cos((dist(S_Size)/(S_Size-1) < 1)*!pi/2.))^2
filter = shift(filter, S_Size/2, S_Size/2)

;;; We use the centered images as a start

openr, unit1, HelpDir + trackname
IF keyword_set(inmem) THEN BEGIN
bild = fltarr(breite, hoehe, N_Image)
readu, unit1, bild
ENDIF ELSE BEGIN
bild = assoc(unit1, fltarr(breite, hoehe))
ENDELSE


if limb eq 1 then begin
;open image prior limb darkening removal for cheking if it is limb
openr, unit9, HelpDir + 'imald',/get
xw=X_Size_E-X_Size_S+1
yw=Y_Size_E-Y_Size_S+1
bildld = fltarr(xw, yw)
readu, unit9, bildld
IF Endian EQ 1 THEN byteorder,bildld,/lswap
bildld=congrid(bildld,breite+1, hoehe+1,/inter)

endif



IF keyword_set(noshift) THEN GOTO, split

;;; again: image with best contrast is reference
;;; precompute the fft's of the subimages in the reference frame

tmp = bild(*, *, maxindex)
IF Endian EQ 1 THEN byteorder, tmp, /lswap
tmp = tmp-smooth(tmp, 23, /edge)   ;vielleicht 46???? fuer 128 pixel grosses subimage
ref = complexarr(S_Size, S_Size, S_n)
FOR i=0, S_nx-1 DO BEGIN
FOR j=0, s_ny-1 DO BEGIN
	x0 = xstep*i+xoffset
	y0 = ystep*j+yoffset
	ii = s_nx*j+i
	ref(*, *, ii) = conj(fft(tmp(x0:x0+S_Size-1, $
				Y0:y0+S_size-1)*filter, -1))
ENDFOR
ENDFOR

;;; now find the shifts for the subframes within each image

FOR k=0, N_Image-1 DO BEGIN
IF NOT quiet THEN begin
widget_control,text_311,set_value='Computing subimage shifts: '+string(k+1, format="(i3)")
endif
;;; but only if it's not the reference frame!
IF k NE maxindex THEN BEGIN
	p = bild(*, *, k)
	IF Endian EQ 1 THEN byteorder, p, /lswap
	p = p - smooth(p, 23, /edge)
	FOR i=0, S_nx-1 DO BEGIN
	FOR j=0, s_ny-1 DO BEGIN
		x0 = xstep*i+xoffset
		y0 = ystep*j+yoffset
		ii = s_nx*j+i
		tmp1 = fft(p(x0:x0+S_Size-1, y0:y0+S_size-1)*filter, -1)
		tmp1 = float(fft(tmp1*ref(*, *, ii), 1))
		m = max(tmp1, index)
		xvector(k, ii) = index MOD S_Size
		yvector(k, ii) = index / S_Size
	ENDFOR
	ENDFOR
ENDIF
ENDFOR

;;; Values larger than half the size are really negative!

xvector = xvector - S_Size*(xvector GT (S_Size/2))
yvector = yvector - S_Size*(yvector GT (S_Size/2))

;;; Get shifts to zero mean
;;; This puts the image at the position of the averaged image 

limbsubfield=0 ;take one limb subfield for an extra set of limb-aligned subfields

FOR i=0, S_n-1 DO BEGIN
xvector(*, i) = xvector(*, i) - fix(avg(xvector(*, i)))
yvector(*, i) = yvector(*, i) - fix(avg(yvector(*, i)))
ENDFOR
subframeld=intarr(2,S_N)

case aocorrect of
0:
1:begin
;bruno limb

case limb of
0: subframeld[0,*]=subframeld[0,*]+1  ;all subframes work
1: begin
	nxvector=xvector
	nyvector=xvector
	ix = indgen(S_ny)*S_nx            ;;; left vertical
	nxvector(*, ix) = xvector(*, ix) > (-xoffset)
	ix = indgen(S_ny)*S_nx+S_nx-1     ;;; right vertical
	nxvector(*, ix) = xvector(*, ix) < (breite-xoffset-xstep*(S_nx-1)-S_Size)
	ix = indgen(S_nx)                 ;;; lower horizontal
	nyvector(*, ix) = yvector(*, ix) > (-yoffset)
	ix = indgen(S_nx)+s_nx*(s_ny-1)   ;;; upper horizontal
	nyvector(*, ix) = yvector(*, ix) < (hoehe-yoffset-ystep*(S_ny-1)-S_Size)
	
	FOR j=0, S_ny-1 DO BEGIN
	FOR i=0, S_nx-1 DO BEGIN
	ii = s_nx*j+i
	x0 = xstep*i+xoffset
	y0 = ystep*j+yoffset
	nr = nnumber(ii+1, ndigit)
	flaeche = fltarr(S_Size, S_Size)
	a=bild(*,*,0)
	IF Endian EQ 1 THEN byteorder, a, /lswap
	;FOR k=0, N_Image-1 DO BEGIN
	; only one frame	
k=0
pic = bildld(x0+nxvector(k, ii):x0+nxvector(k, ii)+S_Size-1,y0+nyvector(k, ii):y0+nyvector(k, ii)+S_Size-1)
widget_control,text_311,set_value='looking for limb subframes in subframe serie with limb darkening: '+string(ii+1, format="(i3)")
	;IF Endian EQ 1 THEN byteorder, pic, /lswap
	if k/15 EQ k/15. then begin
		apic=pic
		apic(*,s_size-1)=max(a)
		apic(*,0)=max(a)
		apic(0,*)=max(a)
		apic(s_size-1,*)=max(a)
		apic(0,0)=min(a)
		tvscl,apic,x0+nxvector(0, ii),y0+nyvector(0, ii)
	endif
	
	;percentage of sky (up to "skylevel") in subframe
	percent=fix(n_elements(where(pic LT sky))/(64.*64.)*100)

	type=0
	CASE 1 OF
		(percent EQ 0): begin
			;sun
			type=1
			end
		(percent GT 0) and (percent LT 90):begin
			;limb
			type=2
			end
		(percent GE 90)and (percent LE 100): begin
			;print,'>90, sky'
			type=3
			end
		else:stop
	ENDCASE
	;save info for k=0 (fist frame) and for k>0 compare with it
	case k of
	0:subframeld[0,ii]=type
	else: begin
		if subframeld[0,ii] eq 0 then stop
		if type ne 1 then if subframeld[0,ii] eq 1 then begin
			print,'Subframe num:'+strtrim(string(ii),2)+'is SUN at 0 but not ('+strtrim(string(percent),2)+'% sky) in frame ',strtrim(string(k),2),' setting not as sun.'
			subframeld[0,ii]=type
		endif
		end
	endcase
	if k EQ N_Image-1 then begin
		case subframeld[0,ii] of
		1:xyouts,x0+nxvector(0, ii),y0+nyvector(0, ii)+S_size/2.,'sun',/dev
		2:xyouts,x0+nxvector(0, ii),y0+nyvector(0, ii)+S_size/2.,'limb',/dev
		3:xyouts,x0+nxvector(0, ii),y0+nyvector(0, ii)+S_size/2.,'sky',/dev
		endcase
	endif
	;endfor
	endfor
	endfor
end	
endcase


;Calculation of the varianz of the subframes of each subimage to find the      
;AO log point

varianzao=total(xvector^2+yvector^2,1)/(S_nx*S_ny-1)
;set to MEAN variance in not sky,to every subframe not sun
ssubframeld=reform(subframeld[0,*])
if limb eq 1 then varianzao(where(ssubframeld NE 1))=mean(varianzao(where(ssubframeld NE 3)))
;BRUNO. smooth image to avoid local irregularities.
varianzao=reform(smooth(reform(varianzao,S_nx,S_ny),2,/edge),S_nx*S_ny,1)
v_2d=reform(varianzao,S_nx,S_ny)
v_2dfit=sfit(v_2d,4)

;Search subimage with smallest variance -> log point (index of subimage) 
;only in the sun frames (where subframeld is 1)
;set values of non sun to max of array of sun
;BRUNO. USE fitting surface to locate minimun

vval=min(varianzao,logpoint)
vvalfit=min(v_2dfit,logpointfit)
;widget_control,text_311,set_value='minimun variance subframe is: '+string(logpoint, format="(i3)")+' But we are using the fittin minimun: '+string(logpointfit, ;format="(i3)")
;logpoint=logpointfit



plotps=0 ; PLOT PS   
                                                               ;NOFUNCIONA CON PLOT PS = 1   <<<<<<<<<--------------------!!!!!!!!

case lockp of
0:begin

v_2dplot=(v_2d/max(v_2d))*(-1)
v_2dfitplot=(v_2dfit/max(v_2dfit))*(-1.)
;       v_2d(logpoint)=min(v_2d)
;       v_2dfit(logpointfit)=min(v_2dfit)
;       v_2dplot(logpoint)=min(v_2dplot)
	v_2dfitplot1=v_2dfitplot
	v_2dfitplot1(logpointfit)=1
	v_2dfitplot=congrid(v_2dfitplot,winx,fix(winy))
	v_2dfitplot1=congrid(v_2dfitplot1,winx,fix(winy))

yyy=where (v_2dfitplot1 eq 1)
xxx1=yyy mod winx
yyy1=yyy/winx
valnuevo=min(v_2dfitplot)
;pintar cuadrado negro en el logpoint
v_2dfitplot(min(xxx1),min(yyy1):max(yyy1))=valnuevo
v_2dfitplot(max(xxx1),min(yyy1):max(yyy1))=valnuevo
v_2dfitplot(min(xxx1):max(xxx1),min(yyy1))=valnuevo
v_2dfitplot(min(xxx1):max(xxx1),max(yyy1))=valnuevo



case plotps of
	0:
	1:begin
	set_plot,'ps'
	loadct,0
	device,filename='varianz.ps',encapsulated=1,/color,bits_per_pixel=8, $
											xs=14.98,ys=10.02
	tvscl,v_2dplot,xs=14980,ys=10020,/device
	device,/close
	device,filename='varianzfit.ps',encapsulated=1,/color, $
			bits_per_pixel=8, xs=14.98,ys=10.02
	tvscl,v_2dfitplot,xs=14980,ys=10020,/device
	xyouts,0.025,0.025,'1',color=min(v_2dfitplot),/normal
	xyouts,0.955,0.025,'17',color=min(v_2dfitplot),/normal
	xyouts,0.015,0.12,'18',color=min(v_2dfitplot),/normal
	xyouts,0.955,0.12,'34',color=min(v_2dfitplot),/normal
	xyouts,0.005,0.945,'171',color=min(v_2dfitplot),/normal
	xyouts,0.945,0.945,'187',color=min(v_2dfitplot),/normal
	device,/close
	set_plot,'x'
	loadct,13
	end
	endcase
case showaocorrection of
	0:
	1:begin
	Widget_Control,draw1,get_value=win_num
	wset, win_num
	erase
		case resolution of 
		1600:begin
			tvscl,congrid(v_2d,winx,winy),5,windowy*2+15
			tvscl,congrid(v_2dfit,winx,winy), winx+10,winy*2+15
			end
		1200:begin
			tvscl,congrid(v_2d,S_nx*18,S_ny*18),0, windowy*2+15
			tvscl,congrid(v_2dfit,S_nx*18,S_ny*18),S_nx*18,windowy*2+15
			end
		ENDCASE
	xyouts,0.15,0.55,'AO lockpoint',charsize=1.4,charthick= 1.4,/norm  
	xyouts,0.35,0.55,'AO lockpoint (4nd order fit)',charsize=1.4, charthick= 1.4,/norm 
	
	end       
	endcase

	IF NOT quiet THEN begin
	widget_control,text_311,set_value='Log point at subimage: '+ string(logpoint, format="(i3)")
	endif
end

else:begin
logpoint=lockp  ;!!!!! set by eye 93 sst 82 VTT
logpointfit=lockp  ;!!!!! set by eye 93s sst
end
endcase
;Definition of the meanposition matrix where the center position of each 
;subimage will have the value of the index of the subimage; rest=0 
MM=intarr(breite,hoehe)
MMplot=congrid(MM,winx,winy,cubic=-0.5); to be defined before winx winy

v_2d=0b & v_2dfit=0b & vval=0b & vvalfit=0b
end
endcase
;;; But stay within the main image!  Only important at the
;;; boundaries

ix = indgen(S_ny)*S_nx            ;;; left vertical
xvector(*, ix) = xvector(*, ix) > (-xoffset)
ix = indgen(S_ny)*S_nx+S_nx-1     ;;; right vertical
xvector(*, ix) = xvector(*, ix) < (breite-xoffset-xstep*(S_nx-1)-S_Size)
ix = indgen(S_nx)                 ;;; lower horizontal
yvector(*, ix) = yvector(*, ix) > (-yoffset)
ix = indgen(S_nx)+s_nx*(s_ny-1)   ;;; upper horizontal
yvector(*, ix) = yvector(*, ix) < (hoehe-yoffset-ystep*(S_ny-1)-S_Size)

Split:

dima=size(bild(*,*,0))
;introduced by klaus
case showsplitimage of
	0:
	1:begin
	y_ratio=(dima(2)*100.)/dima(1)
	winx=scale_x
	winy=(scale_x*y_ratio)/100.
	end
	endcase
;stop introduced by klaus

IF keyword_set(inmem) THEN BEGIN

rawsum = fltarr(S_Size, S_Size, S_n)

FOR j=0, S_ny-1 DO BEGIN
	FOR i=0, S_nx-1 DO BEGIN
	ii = s_nx*j+i
	x0 = xstep*i+xoffset
	y0 = ystep*j+yoffset
	nr = nnumber(ii+1, ndigit)
	flaeche = fltarr(S_Size, S_Size)
	;openw, unit2, HelpDir + splitname + nnumber(nr, ndigit), /xdr
	openw, unit2, HelpDir + splitname + nr, /xdr ;teilbildserie
	IF NOT quiet THEN begin
		widget_control,text_311,set_value='Writing subimage series: '+string(ii+1, format="(i3)")
	endif

	FOR k=0, N_Image-1 DO BEGIN
		;old limb bruno place
		pic = bild(x0+xvector(k, ii):x0+xvector(k, ii)+S_Size-1, $
			y0+yvector(k, ii):y0+yvector(k, ii)+S_Size-1, k)

		IF Endian EQ 1 THEN byteorder, pic, /lswap

;introduced by klaus

case showaocorrection of
	0:
	1:begin
	if (k eq 0) then begin
		picpres=bild(*,*,0)
		IF Endian EQ 1 THEN byteorder, picpres, /lswap
		openw,unit3,HelpDir + 'picpres', /xdr
		writeu,unit3,picpres
		close,unit3
		picpres=0b
	endif
	end
endcase 
case showsplitimage of
	0:
	1:begin
	picpres=bild(*,*,k) 
		IF Endian EQ 1 THEN byteorder, picpres, /lswap
	tvscl, congrid(picpres,winx,winy,cubic=-0.5),5,windowy+10
	scale_xs=(winx*100.)/dima(1)
	scale_ys=(winy*100.)/dima(2)
	winxs=(S_size*scale_xs)/100.
	winys=(S_size*scale_ys)/100.
	x0s=(x0*scale_xs)/100.
	y0s=(y0*scale_ys)/100.
	tvscl,congrid(pic,winxs,winxy,cubic=-0.5),x0s+5,y0s+windowy+10
	picpres=0b  
	
	end
	endcase
;end added by klaus for presentation

		fit = regressi(pic)
		flaeche = flaeche + fit
		pic = float(pic - fit)
		writeu, unit2, pic
		rawsum(*, *, ii) = rawsum(*, *, ii)+pic
		case aocorrect of
		0:
		1:begin                
		IF (k eq maxindex) THEN BEGIN
;Storing indexnumber+1 of each subfield as the value of its center position
			MM(x0+xvector(k, ii) + S_Size/2, y0+yvector(k, ii) + $
			S_Size/2, k)=ii+1 
			case showaocorrection of
			0:   
			1:begin
			scale_xs=(winx*100.)/dima(1)
			scale_ys=(winy*100.)/dima(2)
			x0s=(x0*scale_xs)/100.
			y0s=(y0*scale_ys)/100.
			xvecplot=xvector(k, ii)
			yvecplot=yvector(k,ii)
			xvecplot=(xvecplot*scale_xs)/100.
			yvecplot=(xvecplot*scale_xs)/100.
			S_Sizeplot=S_Size
			S_Sizeplot=(S_Sizeplot*scale_xs)/100. 
			MMplot(x0s+xvecplot + S_Sizeplot/2, y0s+yvecplot + $
			S_Sizeplot/2, k)=ii+1 
			end
			endcase
		ENDIF 
		end    
		endcase
	ENDFOR

	close, unit2
	
	;;; Store the overall linear fit
	
	flaeche = flaeche / N_Image
	
	openw, unit2, HelpDir + regname + nr, /xdr ;flaeche
	writeu, unit2, flaeche
	close, unit2
	
	partnorm(ii) = avg(flaeche)
	ENDFOR
ENDFOR


ENDIF ELSE BEGIN

rawsum = fltarr(S_Size, S_Size, S_n)
flaeche = fltarr(S_Size, S_Size, S_n)


;window,1,retain=2
FOR k=0, N_Image-1 DO BEGIN

	IF NOT quiet THEN begin
		widget_control,text_311,set_value='Writing subimage series. Image '+ $
											string(k+1, format="(i3)")
	endif

;picpres=bild(*,*,k)
;IF Endian EQ 1 THEN byteorder, picpres, /lswap
;tvscl,picpres
showaocorrection=1          ;borrar esto
	
	FOR j=0, S_ny-1 DO BEGIN
	FOR i=0, S_nx-1 DO BEGIN

		ii = s_nx*j+i
		x0 = xstep*i+xoffset
		y0 = ystep*j+yoffset
		nr = nnumber(ii+1, ndigit)
		openw, unit2, HelpDir + splitname + nr, /xdr, /append
		pic = bild(x0+xvector(k, ii):x0+xvector(k, ii)+S_Size-1, $
			y0+yvector(k, ii):y0+yvector(k, ii)+S_Size-1, k)
	IF Endian EQ 1 THEN byteorder, pic, /lswap
;introduced by klaus
case showaocorrection of
	0:
	1:begin
	if (k eq 0) then begin
		picpres=bild(*,*,0)
		IF Endian EQ 1 THEN byteorder, picpres, /lswap
		openw,unit3,HelpDir + 'picpres', /xdr
		writeu,unit3,picpres
		close,unit3
		picpres=0b
	endif
	end
endcase 



case showsplitimage of
	0:
	1:begin
	tvscl, congrid(picpres,winx,winy,cubic=-0.5),5,5
	scale_xs=(winx*100.)/dima(1)
	scale_ys=(winy*100.)/dima(2)
	winxs=(S_size*scale_xs)/100.
	winys=(S_size*scale_ys)/100.
	x0s=(x0*scale_xs)/100.
	y0s=(y0*scale_ys)/100.
	tvscl,congrid(pic,winxs,winys,cubic=-0.5),x0s+5,y0s+5
	xyouts,0.22,0.29,'Split image',charsize=1.4,charthick=1.4,/norm
	picpres=0b
	end
	endcase
;end added by klaus for presentation

		fit = regressi(pic)
		flaeche(*, *, ii) = flaeche(*, *, ii)+fit
		pic = float(pic - fit)
		writeu, unit2, pic
		close, unit2
		rawsum(*, *, ii) = rawsum(*, *, ii)+pic
		case aocorrect of
		0:
		1:begin                       
		IF (k eq maxindex) THEN BEGIN
;Storing indexnumber+1 of each subfield as the value of its center position
			MM(x0+xvector(k, ii) + S_Size/2, y0+yvector(k, ii) + $
			S_Size/2, k)=ii+1 
			case showaocorrection of
			0:   
			1:begin
			scale_xs=(winx*100.)/dima(1)
			scale_ys=(winy*100.)/dima(2)
			x0s=(x0*scale_xs)/100.
			y0s=(y0*scale_ys)/100.
			xvecplot=xvector(k, ii)
			yvecplot=yvector(k,ii)
			xvecplot=(xvecplot*scale_xs)/100.
			yvecplot=(xvecplot*scale_xs)/100.
			S_Sizeplot=S_Size
			S_Sizeplot=(S_Sizeplot*scale_xs)/100. 
			MMplot(x0s+xvecplot + S_Sizeplot/2, y0s+yvecplot + $
			S_Sizeplot/2, k)=ii+1 
			end
			endcase
		ENDIF
		end
		endcase
	ENDFOR
	ENDFOR
	;loop for all frames
ENDFOR

flaeche = flaeche / N_Image

FOR i=0, S_n-1 DO BEGIN
	nr = nnumber(i+1, ndigit)
	openw, unit2, HelpDir + regname + nr, /xdr
	writeu, unit2, flaeche(*, *, i)
	close, unit2
	partnorm(i) = avg(flaeche(*, *, i))
ENDFOR
ENDELSE


case aocorrect of
0:
1:begin     

;Calculation of the logpoint position in MM
logp_1D=where (MM eq logpoint+1) & logp_x = logp_1D MOD breite
logp_y = logp_1D / breite

;Ereugung der Kreismatrix (2 mal so gross wie Bild)
if (breite ge hoehe) then KMdim=breite
if (breite lt hoehe) then KMdim=hoehe
if (odd(KMdim) eq 1) then KMdim=KMdim+1
distmatrix = shift(dist(KMdim*2+1), KMdim, KMdim)
distvector=findgen(KMdim)+1
KMstart=interpolate([1.,distvector],distmatrix,missing=0)
KMmid=centerpos(KMstart,plotres=plotres)
Kmidpos_1D=KMmid(0) & KMmidpos_x=kMmid(1) & KMmidpos_y=kMmid(2)
KM=Kmstart & KM(*,*)=0
Kinterval=fix(max(distvector)/float(S_size))
startval=0 & endval=S_size/2
for ida=0,Kinterval do begin
	pointsring= where ((KMstart gt startval) and (KMstart le endval))
	KM(pointsring)=1*(ida+1)
	startval=endval & endval=endval+S_size
endfor
untenl_x=(KMmidpos_x-logp_x) & untenl_y=(KMmidpos_y-logp_y)
KM=KM(untenl_x(0):untenl_x(0)+breite-1,untenl_y(0):untenl_y(0)+hoehe-1) 
; joining the two most outer circles
colormax=max(KM)
col1=where(km eq colormax)
KM(col1)=colormax-1
; changing ot actual number of intervals
colormax=colormax-1
; plot of the resuls
	case showaocorrection of
	0:
	1:begin
	KMstart=KMstart(untenl_x(0):untenl_x(0)+breite-1, $
			untenl_y(0):untenl_y(0) + hoehe-1)
	picpres=fltarr(breite,hoehe)
	openr,unit3,HelpDir + 'picpres', /xdr
	readu,unit3,picpres
	close,unit3
	KMplot=KM
	dima=size(KMplot)
	y_ratio=(dima(2)*100.)/dima(1)
	KMplot=congrid(KMplot,winx,winy,cubic=-0.5) 
	KMplot=KMplot*(-1.)
	KMplot(where(MMplot ne 0))=0
	KMplot(0,0)=-8

	valmax=max(picpres)
	valmin=min(picpres)
	picpres=congrid(picpres,winx,winy,cubic=-0.5) 
	;picpres(where((KMplot eq 1)))=1.0
	picpres(where(MMplot ne 0))=valmax+0.2
	tvscl,KMplot,5,windowy+10
	tvscl,picpres,windowx+10,windowy+10

	case plotps of
	0:
	1:begin
	set_plot,'ps'
	numerito=where (mmplot eq 1)
	numeritox=numerito MOD winx
	numeritoy=numerito / winx 
	prozent=winx*100./breite
	plotsize=s_size*prozent/100.
	plotsizeh=fix(plotsize/2)
	factred=float(breite)/float(winx)
	factred=fix(factred)
	KMplot(numeritox-plotsizeh:numeritox+plotsizeh,numeritoy-plotsizeh)=0
	KMplot(numeritox-plotsizeh:numeritox+plotsizeh,numeritoy+plotsizeh)=0
	KMplot(numeritox-plotsizeh,numeritoy-plotsizeh:numeritoy+plotsizeh)=0
	KMplot(numeritox+plotsizeh,numeritoy-plotsizeh:numeritoy+plotsizeh)=0
	picpres(numeritox-plotsizeh:numeritox+plotsizeh,numeritoy-plotsizeh)=valmax
	picpres(numeritox-plotsizeh:numeritox+plotsizeh,numeritoy+plotsizeh)=valmax
	picpres(numeritox-plotsizeh,numeritoy-plotsizeh:numeritoy+plotsizeh)=valmax
	picpres(numeritox+plotsizeh,numeritoy-plotsizeh:numeritoy+plotsizeh)=valmax
	picpres(500/factred,250/factred:749/factred)=valmax
	picpres(999/factred,250/factred:749/factred)=valmax
	picpres(500/factred:999/factred,250/factred)=valmax
	picpres(500/factred:999/factred,749/factred)=valmax
	picpres(709/factred:*,400/factred)=valmax
	picpres(709/factred:*,599/factred)=valmax
	picpres(709/factred,400/factred:599/factred)=valmax
	picpres(winx-1,400/factred:599/factred)=valmax
	device,filename='KMplot.ps',encapsulated=1,/color,bits_per_pixel=8, $
	xs=14.98,ys=10.02
	tvscl,kmplot,xs=14980,ys=10020,/device
	device,/closey
	device,filename='picpres.ps',encapsulated=1,/color, $
	bits_per_pixel=8, xs=14.98,ys=10.02
	tvscl,picpres,xs=14980,ys=10020,/device
	xyouts,0.06,0.08,'1',/norm,color=255,charthick=1.5,charsize=1.1
	xyouts,0.63,0.7,'2',/norm,color=255,charthick=1.5,charsize=1.1
	xyouts,0.97,0.55,'3',/norm,color=255,charthick=1.5,charsize=1.1
	device,/close
	set_plot,'x'
	end
endcase
end
endcase

picpres=0b
nrings=colormax ; number of isoplantic rings (including ring around logp)
	IF NOT quiet THEN BEGIN
	widget_control,text_311,set_value='Number of isoploanar rings for AO correction: '+ string(nrings, format="(i3)")   
	ENDIF
	
openw,unit3,HelpDir + 'nrings'
printf,unit3,nrings
close,unit3

; Now we look wich subfields are inside which ring
for ida=1,nrings do begin
	pointsring= where(KM eq ida)  ; Positions of all subfields inside one ring 
	maskindex=where(MM(pointsring) gt 0) ;total number of subfields per ring
	subfindices=MM(pointsring(maskindex))  ; Indices of all subfields inside one ring are given 
	nsubf=n_elements(subfindices) ; number of subfields per ring
	IF NOT quiet THEN BEGIN
	widget_control,text_311,set_value='Number of subfields for ring '+ $
	string(ida, format="(i3)")+': ' +string(nsubf, format="(i3)")
	ENDIF
	openw,unit3,HelpDir + 'nsubf'+strtrim(ida,2)
	printf,unit3,nsubf
	close,unit3
	openw,unit3,HelpDir + 'subfindices'+strtrim(ida,2)
	printf,unit3,subfindices
	close,unit3
endfor
end
endcase





;remove from these files indexes of sky (and limb) subimages.
;and store in new files the sky and limb (with ring number) indexes
;bruno
case limb of
0:
1:begin
;store sky indexes
skyin=0
skynum=0  ;counter of sky in image
for nu=1,S_n do begin
	if subframeld[0,nu-1] EQ 3 then begin
	;is sky
	skyin=[skyin,nu-1]
	skynum=skynum+1
	endif
endfor

if skynum gt 0 then skyin=skyin[1:*]

;save results
openw,unit3,HelpDir + 'skynum'
printf,unit3,skynum
close,unit3

openw,unit3,HelpDir + 'skyin'
printf,unit3,skyin
close,unit3


;remove limb and sky indexes for each ring

FOR caesar=1,nrings DO BEGIN

nsubf=0
openr,unit3,HelpDir + 'nsubf'+strtrim(caesar,2)
readf,unit3,nsubf
close,unit3

subfindices=intarr(nsubf)
openr,unit3,HelpDir + 'subfindices'+strtrim(caesar,2)
readf,unit3,subfindices
close,unit3
newsubfindices=[0] ;inizializate array, then I have to remove this zero
newsubfindiceslimb=[0]
existslimb=0
for num=0,nsubf-1 do begin
	;print,'subframe ',subfindices(num),' of ring ',caesar,' is type ',subframeld[0,subfindices(num)-1]
	if (subframeld[0,subfindices(num)-1] eq 1) then newsubfindices=[newsubfindices,subfindices(num)]  ;add to array ONLY if sun
	if (subframeld[0,subfindices(num)-1] eq 2) then begin
		newsubfindiceslimb=[newsubfindiceslimb,subfindices(num)]  ;add to array ONLY if limb
		existslimb=1
		if limbsubfield EQ 0 then limbsubfield=subfindices(num)+1 ; limb for limbextra
		;de 1 a 165, first ocurrence, supposed to be nearest to lockpoint.
	endif
endfor
newsubfindices=newsubfindices[1:*] ;remove first 0
case  existslimb of
1 : begin
	newsubfindiceslimb=newsubfindiceslimb[1:*] ;remove first 0
	newnsubflimb=sizeof(newsubfindiceslimb)
	end
0:newnsubflimb=0
endcase

newnsubf=sizeof(newsubfindices)
;save results


openw,unit3,HelpDir + 'nsubf'+strtrim(caesar,2)
printf,unit3,newnsubf
close,unit3

openw,unit3,HelpDir + 'subfindices'+strtrim(caesar,2)
printf,unit3,newsubfindices
close,unit3

openw,unit3,HelpDir + 'nsubflimb'+strtrim(caesar,2)
printf,unit3,newnsubflimb
close,unit3
if  existslimb EQ 1 then begin
	openw,unit3,HelpDir + 'subfindiceslimb'+strtrim(caesar,2)
	printf,unit3,newsubfindiceslimb
	close,unit3
endif
endfor
end
endcase
eo:
case limb of 
0:
1:begin
;use it to rotate the image and get the subfields in both sides
;to have a set of horizontal limb subframes with the same overlapping
;after normal reconstruction limbextraconnect will paste all to avoid dark lines in limb

openr, unit5, HelpDir + trackname,/get
bild = fltarr(breite, hoehe, N_Image)
bild = assoc(unit5, fltarr(breite, hoehe))

margen=5
container=fltarr(s_size,s_size,s_nx*2,n_image)
vacio=intarr(2*s_nx,N_Image) ;check if there is limb in the subfield
for in=0,N_Image-1 do begin
widget_control,text_311,set_value='getting limb rotated limb subfields  '+string(in+1, format="(i3)")
ima=bild(*,*,in)
byteorder,ima,/lswap



imas=size(ima)

;calculate angle,only for first frame, the rotation to put limb horizontal
if in EQ 0 then begin
	p=0
	for i=0,imas(2)-1 do begin 
		line=ima(*,i)
		pi=min(where((line LE sky) NE (line(0) LE sky)))    ;point where trantition sun-sky occurs, '->' or '<-'
		p=[p,pi] 
	endfor
	p=p[1:*]  ;remove leading zero
	;now remove all the (-1), no limb in row (should be only in the sides of the array)
	p=p(where(p NE (-1)))

	px=indgen(n_elements(p))
	fit=linfit(px,p) ;fit results to line, to get the slope
	angle=atan(fit(1))*360/float(2*!PI)
	angle=angle-90  ;I HAVE TO MAKE THIS TO PUT LIMB HORIZONTAL, as the frame is rectangular, is wider in this direction
endif

	imar=fltarr(imas(1)*2,imas(2)*2) ;expand rotated image, to not crop frame.
	imar(imas(1)*0.5:imas(1)*0.5+imas(1)-1,imas(2)*0.5:imas(2)*0.5+imas(2)-1)=ima
	imar=rot(imar,-angle,missing=0)     ;imar has the image, 0 out of image
;DO NOT ROTATE WITH INTERPOLATION
	imars=size(imar)

;create the succesive cuts
;each cut is in direcion DIR from edge

;get starting point x,y close to limb in the side (horizontal) part
;SUN TO THE LOWER!!!!!!!!!
x=0
y=0 ;initializate
for x=1,imars(1)-1 do begin
;if total(imar(x,*)) NE 0 then begin
line=imar(x,*)
y=[y,min(where((line LT sky) AND (line GT 0 )))]
;endif
endfor
y=y[1:*] ;remove leading zero
y(where(y EQ (-1)))=max(y) ;avoid -1 ocurrences from where function
y=mean(y)+margen  ;starting y
x=min(where(total(imar,2) NE 0)) ; start from edge of image
;if in eq 0 then tvwin,imar else tvscl,imar
;tvscl,imar
;go until edge
sentido=-1  ;where is the sun, down or up? down=-1  up=0

apodisation = apodisate(A_wid, S_Size)      ;;; Compute apodisation window


for shi=0,s_size/2,s_size/2 do begin
;run it once and then again with half shift, for the overlap
for n=0,s_nx do begin   ;sn_x is the maximun (as the frame is longer than high, in the best case n will go until sn_x
indi=n+((shi NE 0)*s_nx)
inix=x+s_size*n+shi
finx=x+s_size*(n+1) -1+shi
iniy=y+s_size*sentido
finy=y+s_size*(sentido+1) -1
;comprobar si es el final del frame:
borde=(inix LT 0) OR (iniy LT 0) OR (finx GT imars[1]) OR (finy GT imars[2]) $
      (finx LE 0) OR (finy LE 0) OR (inix GT imars[1]) OR (iniy GT imars[2])  ;los raros

;crear imagen y guardar
case borde of 
0: begin 
	trozo=imar(inix:finx,iniy:finy)
	if total(total(trozo,1),1) EQ 0 then goto,sigi  ;if out of image (is fixed)
	if total(total(trozo GT 0 AND trozo LT sky,1),1) NE 0 then vacio(indi,in)=1  ;if with limb
	;tvscl,trozo,s_size*n,0
	;xyouts,inix,iniy,'|_',/dev
	;xyouts,inix,finy,'|"',/dev
	;xyouts,inix+(finx-inix)/2.,iniy+(finy-iniy)/2.,strtrim(string(indi),2),/dev
	;xyouts,finx,finy,'"|',/dev
	;xyouts,finx,iniy,'_|',/dev
	container(*,*,indi,in)=trozo*apodisation
	end
1: goto,findeframe
endcase
sigi:
endfor
findeframe:
endfor
endfor
;some frames in container can be equal ZERO,crop array
container=container(*,*,where(vacio(*,0) EQ 1),*)


;save all
;save container as if it were a set of normal subframes in an outer ring
openw,unit3,HelpDir + 'nrings'
printf,unit3,nrings+1
close,unit3



cont=size(container)
cont=cont(3)
for i=0,cont-1 do begin
widget_control,text_311,set_value='Saving data '+nnumber (i, 2)
if exists(HelpDir + splitname +nnumber (s_n+i+1, 3)) then stop
openw, unit3, HelpDir + splitname +nnumber (s_n+i+1, 3), /xdr 
writeu, unit3, reform(container(*,*,i,*))
close, unit3
endfor
;fake an outer ring
openw,unit3,HelpDir + 'nsubf'+strtrim(fix(nrings+1),2)
printf,unit3,cont
close,unit3
subfindices=indgen(cont)
openw,unit3,HelpDir + 'subfindices'+strtrim(fix(nrings+1),2)
printf,unit3,s_n+indgen(cont)+1
close,unit3
openw,unit3,HelpDir + 'nsubflimb'+strtrim(fix(nrings+1),2)
printf,unit3,0
close,unit3

;save other stuff for pasting
openw,unit3,HelpDir + 'limbcontainerdata'
printf,unit3,[cont,angle]
close,unit3
close, unit5
close,unit1
end
endcase


close,unit1



rawsum = rawsum/N_Image
openw, unit1, HelpDir + rawsumname, /xdr
writeu, unit1, rawsum
close, unit1

openw, unit1, HelpDir + partsclnam, /xdr
writeu, unit1, partnorm
close, unit1



bild = 0b
;ima= 0b


IF keyword_set(skip_noise) THEN GOTO, nonoise

dark = fltarr(X_Width, Y_Width, /nozero)
flat = fltarr(X_Width, Y_Width, /nozero)
rauschpower = fltarr(S_Size, S_Size, S_n)
xvector = intarr(N_Image, /nozero)
yvector = intarr(N_Image, /nozero)

openr, unit1, HelpDir + darkname, /xdr
readu, unit1, dark
close, unit1

openr, unit1, HelpDir + flatname, /xdr
readu, unit1, flat
close, unit1

openr, unit1, HelpDir + motionname, /xdr
readu, unit1, xvector
readu, unit1, yvector
close, unit1
xvector = xvector-min(xvector)
yvector = yvector-min(yvector)
x0 = fix(avg(xvector))
y0 = fix(avg(yvector))


openr, unit1,RawDir + df_raw
;openr, unit4, RawDir + d_raw,/get

IF Bitpix EQ 16 THEN BEGIN
	rohdaten = assoc(unit1, intarr(X_Size_0, Y_Size_0), FlatOffset)
	;rohbild = assoc(unit4, intarr(X_Size_0, Y_Size_0), FileOffset)
ENDIF ELSE BEGIN
	rohdaten = assoc(unit1, bytarr(X_Size_0, Y_Size_0), FlatOffset)
	;rohbild = assoc(unit4, bytarr(X_Size_0, Y_Size_0), FileOffset)
ENDELSE

gain = flat - dark
apodisation = apodisate(A_wid, S_Size)      ;;; Compute apodisation window

dada=numdf;315;100


;stop introduced by klaus

;introduced by Klaus
case shownoisepower of
	0:
	1:begin
	case sst of
	0:begin
	windowx=breite
	windowy=hoehe
	end
	1:begin
		case resolution of
		1024:begin
			windowx=breite/6
			windowy=hoehe/6
			end
		1200:begin
			windowx=breite/5
			windowy=hoehe/5
			end
		1600:begin
			windowx=breite/4
			windowy=hoehe/4
			end
		endcase
		end
	endcase
	end
endcase
	;end introduced by klaus

FOR i=0, dada-1 DO  BEGIN 
	;;; flat single image
	bild = rohdaten(X_Size_S:X_Size_E, Y_Size_S:Y_Size_E, i)
	;ima  = rohbild(X_Size_S:X_Size_E, Y_Size_S:Y_Size_E, i)
	IF (Endian XOR FileEndian) EQ 1 AND Bitpix EQ 16 THEN byteorder, bild
	;IF (Endian XOR FileEndian) EQ 1 AND Bitpix EQ 16 THEN byteorder, ima
	;ima = (temporary(ima) - dark) / gain
	bild = (temporary(bild) - dark) / gain
	bild = bild(x0:*, y0:*)

;bruno. make limb darkening in calculation of noise
;if limb eq 1 then begin
;	ld=fltarr(x_size_0,y_size_0)
;	openr, unit3, ResDir + resultname + 'fit',/xdr
;	readu, unit3,ld
;	close,unit3
;	sizes=size(bild)
;	ld=congrid(ld,sizes(1),sizes(2))
;noise is photonic noise, so it is lower in limb where we have less intensity
;bild=bild/mean(imar(where(imar GT sky)))/mean(bild)/ld
;print,'noise rectification'
;endif

	;ima = ima(x0:*, y0:*)
	;stop
	Widget_Control,draw1,get_value=win_num
	wset, win_num

;;; Compute the power spectra, loop over all sub-images

unten = yoffset
oben = unten + S_Size-1

FOR l=0, S_ny-1 do BEGIN
	
	links = xoffset
	rechts = links + S_Size-1
	FOR k=0, S_nx-1 DO BEGIN           
	teilbild = bild(links:rechts, unten:oben)
	teilbild = (teilbild - avg(teilbild)) * apodisation
;introduced by Klaus
	case shownoisepower of
	0:
	1:begin
		tvscl, bild 
		case resolution of
			1024:tvscl,congrid(teilbild,S_size/6.,S_size/6.,cubic=-0.5),links/6.,unten/6.
			1200:tvscl,congrid(teilbild,S_size/5.,S_size/5.,cubic=-0.5),links/5.,unten/5.
			1600:tvscl,congrid(teilbild,S_size/4.,S_size/4.,cubic=-0.5),links/4.,unten/4.
		endcase
	end
	endcase
;end introduced by klaus
	teilbild = fft(temporary(teilbild), -1)
	rauschpower(*, *, S_nx*l+k) = $
	rauschpower(*, *, S_nx*l+k) + float(teilbild * conj(teilbild))

;introduced by Klaus
	case shownoisepower of
	0:
	1:begin
	shade_surf,shift(float(teilbild * conj(teilbild)),S_size/2.,S_size/2.),position=[0.5,0,0.9,0.4],/noerase
	end                 
	endcase
;end introduced by klaus

	links = links + xstep
	rechts = rechts + xstep
	ENDFOR

	unten = unten + ystep
	oben = oben + ystep
ENDFOR

IF NOT quiet THEN BEGIN
	widget_control,text_311,set_value='Calculating noise power. Image '+string(i+1, format="(i3)")  
ENDIF
ENDFOR
close, unit1

;;; normalize noise-power

;rauschpower = rauschpower / N_Flat
rauschpower = rauschpower / dada
;;; store away


;bruno limb
;add the calculation of limb rotated subfields and add them to the calculation of the powerspectrumarray.
limbi=0
case limbi of
0:
1:begin
;XXXXXXXXXXXXXXXXXXXXXXXXXXx
;FOR ;all the new frames

;can be multiplication of dflat en limb EQ rotated, i.e. a portion near limb where you take the rotted subfileds

;OR just make one more rauchpower taking in consideration ALL the subframes in the limb position...


	teilbild = bild(links:rechts, unten:oben)
	teilbild = (teilbild - avg(teilbild)) * apodisation
	case shownoisepower of
	0:
	1:begin
		tvscl, bild 
		case resolution of
			1024:tvscl,congrid(teilbild,S_size/6.,S_size/6.,cubic=-0.5),links/6.,unten/6.
			1200:tvscl,congrid(teilbild,S_size/5.,S_size/5.,cubic=-0.5),links/5.,unten/5.
			1600:tvscl,congrid(teilbild,S_size/4.,S_size/4.,cubic=-0.5),links/4.,unten/4.
		endcase
	end
	endcase
;end introduced by klaus
	teilbild = fft(temporary(teilbild), -1)
	rauschpower(*, *, S_nx*l+k) = $
	rauschpower(*, *, S_nx*l+k) + float(teilbild * conj(teilbild))

;introduced by Klaus
	case shownoisepower of
	0:
	1:begin
	shade_surf,shift(float(teilbild * conj(teilbild)),S_size/2.,S_size/2.),position=[0.5,0,0.9,0.4],/noerase
	end                 
	endcase
;end introduced by klaus
;	ENDFOR
;xxxxxxxxxxxx
	unten = unten + ystep
	oben = oben + ystep
;ENDFOR

IF NOT quiet THEN BEGIN
	widget_control,text_311,set_value='Calculating noise power. Image '+string(i+1, format="(i3)")  
ENDIF
;ENDFOR
close, unit1

;;; normalize noise-power


rauschpower = rauschpower / dada



end
endcase



openw, unit1, HelpDir + noisename, /xdr
writeu, unit1, rauschpower
close, unit1

Nonoise:
;;;
;;; Close and delete temporary file: Not needed any further
;;;
free_lun, unit1
free_lun, unit2
free_lun, unit3
END

