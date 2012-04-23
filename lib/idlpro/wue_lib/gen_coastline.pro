pro gen_coastline,alat,alon,map_file,image=image
;
;+
; ROUTINE:  GEN_COASTLINE
;
; USEAGE:   gen_coastline,alat,alon
;           gen_coastline,alat,alon,map_file,image=image
;
; PURPOSE:  generate coastal outline map for satellite images
;
; INPUTS:   ALAT         2-D array of image latitude values (one value for
;                        each image pixel)
;           ALON         2-D array of image longitude values
;           MAP_FILE     Name of map coordinate data file. If MAP_FILE is
;                        not provided, GEN_COASTLINE queries for an
;                        output file name.
;
; OPTIONAL KEYWORD INPUT:
;           image        Image from which to infer coastline outline.
;                        If an image array is not provided, it is assumed
;                        that an image has already been displayed using
;                        the TVIM procedure.
;           
;
; PROCEDURE:
; Coastline coordinates are input by using the mouse to click on coastal
; features from an image in the default window.  The mouse buttons perform
; the following actions:
;
; 1. left mouse button connects points along coastline
; 2. middle mouse erases most recent point(s)
; 3. right mouse button finishes a coastline segment.
;    
; When the right mouse button is pressed a pop-up menu appears with four
; options:
; 
; 1. NEW SEGMENT                          Start a new coastal outline segment
;
; 2. CLOSE CURVE, START NEW SEGMENT       Complete an island outline and
;                                         prepare to start a new segment
;
; 3. CLOSE CURVE, QUIT                    Complete island outline and quit
;
; 4. QUIT                                 Flush buffers and quit.  
;                                 
;
; The collection of [latitude, longitude] coordinates are written to the
; file MAP_FILE.  This map data file can be used as input for the companion
; procedure,  COASTLINE.PRO which plots the coast line data onto arbitrarily
; oriented image files. 
;
;
; AUTHOR:     Paul Ricchiazzi    oct92 
;             Earth Space Research Group, UCSB
;
;-
;
if keyword_set(image) then tvim,image
px=!x.window*!d.x_vsize
py=!y.window*!d.y_vsize
x0=px(0)
y0=py(0)

sz=size(alat)
nx=sz(1)
ny=sz(2)
xf=(px(1)-px(0))/(nx-1)
yf=(py(1)-py(0))/(ny-1)

if n_elements(map_file) eq 0 then begin
  print,form='($,a,a)','Enter name of map file '
  map_file=''
  read,map_file
endif
print,'Left mouse button adds points'
print,'Middle mouse button deletes points'
print,'Right mouse button stops accumulation'
;
repeat begin
  dummy=trace(alat,xverts,yverts,/nodes,/silent)
  wait,.3
  ix=xverts
  iy=yverts
  nn=n_elements(ix)
  xret=xf*xverts(nn-1)+x0
  yret=yf*yverts(nn-1)+y0
  op=wmenu(['Options','Start new segment','Close curve, start new segment',$
            'Close curve and quit','Quit'],title=0,init=0)
  tvcrs,xret,yret
  if op eq 1 or op eq 2 then print,'Starting a new coastline segment'
  if op eq 2 or op eq 3 then begin
    ix=[ix,ix(0)]
    iy=[iy,iy(0)]
    nn=nn+1
  endif
  llat=reform(alat(ix,iy),nn)
  llon=reform(alon(ix,iy),nn)
  if n_elements(lat) eq 0 then lat=llat else lat=[lat,llat]
  if n_elements(lon) eq 0 then lon=llon else lon=[lon,llon]
  lat=[lat,1000.]
  lon=[lon,1000.]
endrep until op eq 3 or op eq 4
nn=n_elements(lat)

get_lun,lun
openw,lun,map_file
printf,lun,nn
for i=0,nn-1 do printf,lun,lat(i),lon(i)
free_lun,lun
end

