pro plot_keywords, $
	BACKGROUND=back, CHANNEL=chan, CHARSIZE=chsiz, $
	CHARTHICK=chthck, COLOR=color, DATA=data, DEVICE=device, $
	FONT=font, LINESTYLE=linestyle, NOCLIP=noclip, NODATA=nodata, $
	NOERASE=noerase, NORMAL=normal, NSUM=nsum, PSYM=psym, $
	SUBTITLE=subtit, SYMSIZE=symsize, T3D=t3d, THICK=thick, $
        TICKLEN=ticklen, TITLE = title, $
	XCHARSIZE=xchsiz, XMARGIN=xmargn, XMINOR=xminor, XRANGE=xrange, $
        XSTYLE=xstyle, XTHICK = XTHICK, XTICKLEN=xtickln, XTICKNAME=xticknm, $
	XTICKS=xticks, XTICKV=xtickv, XTITLE=xtitle, XTYPE=xtype, $
	YCHARSIZE=ychsiz, YMARGIN=ymargn, YMINOR=yminor, YNOZERO = ynozero, $
	YRANGE=yrange, YSTYLE=ystyle, YTHICK = ythick, YTICKLEN=ytickln, $ 
        YTICKNAME=yticknm, YTICKS=yticks, YTICKV=ytickv, YTITLE=ytitle,  $
        YTYPE=ytype
;+
; NAME:
;	PLOT_KEYWORDS
; PURPOSE:
;	Return default value(s) of plotting keywords.    Useful inside of
;	a plotting procedure.
;
; CALLING SEQUENCE:
;	plot_keywords, [BACKGROUND =, CHANNEL =, CHARSIZE =, CHARTHICK =,
;		COLOR = , DATA = , DEVICE = , FONT = , LINESTYLE =, NOCLIP = ,
;		NODATA = , NOERASE = , NORMAL =, NSUM = , PSYM =, SUBTITLE =,
;		SYMSIZE = , T3D = , THICK = , THICKLEN = , TITLE = , XCHARSIZE=,
;		XMARGIN =, XMINOR =, XRANGE =, XSTYLE = , XTICKLEN =, 
;		XTHICK = ,XTICKNAME =, XTICKS = , XTICKV = , XTITLE =, XTYPE =, 
;		YCHARSIZE = , YMARGIN = ,YMINOR = , YNOZERO = , YRANGE = , 
;		YSTYLE =, YTHICK =, YTICKLEN = ,YTICKNAME =, YTICKS =,  
;		YTICKV =, YTITLE = , YTYPE = ]
;
; INPUT - OUTPUTS:
;	None.
;
; OPTIONAL OUTPUT KEYWORDS:
;	Any of the plotting keywords above.   These keywords are all recognized 
;	by the PLOT procedure, and listed in Appendix D.2 of the IDL manual.
;	PLOT_KEYWORDS does *not* include any of the Z axis keywords used
;	for 3-d plotting.
;
;	An undefined variable assigned to the keyword will be returned with the 
;	default value, usually from the correpsonding system variable.
;
; EXAMPLE:
;	Suppose that one has a procedure PLOT_PROC that will make a call
;	to the IDL PLOT procedure.    One wishes to include the optional 
;	plot keywords XRANGE and YRANGE in PLOT_PROC and pass these to PLOT
;
;	pro plot_proc, XRANGE = xrange, YRANGE = yrange
;	......
;	plot_keywords, XRANGE = xran, $      ;Get default values if user did
;			YRANGE = yran         ;not supply any values
;	plot,.... XRANGE = xran, YRANGE = yran         ;Pass to PLOT procedure
;
; NOTES:
;	Plotting keywords that return values (such as XTICK_GET) are not 
;	included since there is no need to specify a default.
;
;	The default of XTYPE is 0 and not !X.TYPE
;
; MODIFICATION HISTORY:
;	Written    Wayne Landsman                January, 1991
;	Modified default for XTYPE and YTYPE
;	Switched from keyword_set to N_elements.  Corrected a LINESTYLE error.
;		Michael R. Greason, Hughes STX, 24 March 1993.
;-
 On_error, 2

;                                      General plotting keywords

 if N_elements( BACK )  EQ 0 then back = !P.background
 if N_elements( CHAN )  EQ 0 then chan = !P.channel
 if N_elements( CHSIZ ) EQ 0 then chsiz = !P.charsize
 if N_elements( CHTHCK ) EQ 0 then chthck = !P.charthick
 if N_elements( CLIP ) EQ 0 then clip = !P.clip
 if N_elements( COLOR ) EQ 0 then color = !P.color
 if N_elements( DATA ) EQ 0 then data = 0
 if N_elements( DEVICE ) EQ 0 then device = 0
 if N_elements( FONT ) EQ 0 then font = !P.font
 if N_elements( LINESTYLE ) EQ 0 then linestyle = !P.linestyle
 if N_elements( NOCLIP ) EQ 0 then noclip = 0
 if N_elements( NODATA ) EQ 0 then nodata = 0
 if N_elements( NOERASE ) EQ 0 then noerase = 0
 if N_elements( NORMAL ) EQ 0 then normal = 0
 if N_elements( NSUM ) EQ 0 then nsum = !P.nsum
 if N_elements( POSITION ) EQ 0 then position = !P.position
 if N_elements( PSYM ) EQ 0 then psym = !P.psym
 if N_elements( SUBTIT ) EQ 0 then subtit = !P.subtitle
 if N_elements( SYMSIZE ) EQ 0 then symsize = 1.0
 if N_elements( T3D )  EQ 0 then t3d = 0
 if N_elements( THICK ) EQ 0 then thick = !P.thick
 if N_elements( TICKLEN ) EQ 0 then ticklen = !P.ticklen
 if N_elements( TITLE ) EQ 0 then title = !P.title

;				X-axis keywords.

 if N_elements( XCHSIZ ) EQ 0 then xchsiz = !X.charsize
 if N_elements( XMARGN ) EQ 0 then xmargn = !X.margin
 if N_elements( XMINOR ) EQ 0 then xminor = !X.minor
 if N_elements( XRANGE ) EQ 0 then xrange = !X.range
 if N_elements( XSTYLE ) EQ 0 then xstyle = !X.style
 if N_elements( XTHICK ) EQ 0 then xthick = !X.thick
 if N_elements( XTICKLN ) EQ 0 then xtickln = !X.ticklen
 if N_elements( XTICKNM ) EQ 0 then xticknm = !X.tickname
 if N_elements( XTICKS ) EQ 0 then xticks = !X.ticks
 if N_elements( XTICKV ) EQ 0 then xtickv = !X.tickv
 if N_elements( XTITLE ) EQ 0 then xtitle = !X.title
 if N_elements( XTYPE ) EQ 0 then xtype = 0

;                              Y-axis keywords

 if N_elements( YCHSIZ ) EQ 0 then ychsiz = !Y.charsize
 if N_elements( YMARGN ) EQ 0 then ymargn = !Y.margin
 if N_elements( YMINOR ) EQ 0 then yminor = !Y.minor
 if N_elements( YNOZERO ) EQ 0 then ynozero = (!Y.STYLE and 16)
 if N_elements( YRANGE ) EQ 0 then yrange = !Y.range
 if N_elements( YSTYLE ) EQ 0 then ystyle = !Y.style
 if N_elements( YTHICK ) EQ 0 then ythick = !Y.thick
 if N_elements( YTICKLN ) EQ 0 then ytickln = !Y.ticklen
 if N_elements( YTICKNM ) EQ 0 then yticknm = !Y.tickname
 if N_elements( YTICKS ) EQ 0 then yticks = !Y.ticks
 if N_elements( YTICKV ) EQ 0 then ytickv = !Y.tickv
 if N_elements( YTITLE ) EQ 0 then ytitle = !Y.title
 if N_elements( YTYPE ) EQ 0 then ytype = 0
;
 return
 end
