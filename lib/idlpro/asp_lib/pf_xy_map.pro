pro pf_xy_map, unit, map, x, y, n, scat
;+
;
;	procedure:  pf_xy_map
;
;	purpose:  compute map of file pointers for a *.pf file.
;
;	author:  paul@ncar, 11/94	(minor mod's by rob@ncar)
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() eq 0 then begin
	print
	print, "usage:	pf_xy_map, unit, map, x, y, n, scat"
	print
	print, "	Compute 2D map of file pointers for a *.pf file"
	print
	print, "	Arguments"
	print, "		unit	- input unit open to *.pf file"
	print, "		map	- output vector offile pointers"
	print, "			  (set -1 for none)"
	print, "		x	- x locations in map"
	print, "		y	- y locations in map"
	print, "		n	- n number of (x,y) locations"
	print, "		scat	- output 0 if scat light present;"
	print, "			  -1 if not present"
	print
	return
endif
;-
				    ;Save file pointer.
point_lun, -unit, ptrsav
				    ;Set file pointer start.
point_lun, unit, 0
				    ;Initialize for no scat light.
scat = -1
				    ;Set for no raster points return.
map = -1
x   = -1
y   = -1
n   =  0
				    ;Loop over *.pf file.
while eof(unit) eq 0 do begin
				    ;Get file pointer.
	point_lun, -unit, position
				    ;Read first six characters of line.
	cccccc = 'cccccc'
	readf, unit, cccccc, format='(a6)'

				    ;Check for first line of a profile set.
	if cccccc eq 'point:' then begin

				    ;Reposition to header line.
		point_lun, unit, position

				    ;Read info from header line.
		xp=0L & yp=0L & rgt=0. & dec=0. & ut=0.
		readf, unit, format = '(6x,2i5,13x,2f12.0,6x,f12.0)' $
		, xp, yp, rgt, dec, ut

				    ;Check for scattered light profile.
		if  position eq 0 and xp eq 0 and yp eq 0 $
		and rgt eq 0 and dec eq 0 and ut eq 0 then begin

				    ;Set that file has scattered light.
			scat = 0

		end else begin
				    ;Set file pointer in map.
			if n eq 0 then begin
				map = position
				x   = xp
				y   = yp
			end else begin
				map = [map, position ]
				x   = [  x,       xp ]
				y   = [  y,       yp ]
			end
				    ;Increment count.
			n = n+1
		end
	end
end
				    ;Restore file pointer.
point_lun, -unit, ptrsav

end
