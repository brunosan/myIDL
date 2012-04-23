PRO CORK_MAP,VX,VY,NSTEP,INTERVAL,NX,NY,CX,CY
;+
; NAME:
;	CORK_MAP
;
; PURPOSE:
;	Computes a "cork" map from the flow map given by VX,VY.
;
; CALLING SEQUENCE:
;	CORK_MAP,VX,VY,NSTEP,INTERVAL,NX,NY,CX,CY
;
; INPUTS:
;	VX & VY = 2-D arrays with the X and Y components of the velocity
;		vector.
;
;	NSTEP = number of steps to compute.
;
;	INTERVAL = time interval for each cork map.
;
;	NX & NY = number of corks in X and Y.
;
; OUTPUTS:
;	CX & CY = The position of the corks after a time NSTEP * INTERVAL.
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;	None.
;
; PROCEDURE:
;	It uses the nearest neighbour velocity vector to "move" the cork.
;	An explanation of the cork algorithm can be found in Z.Yi, 1992,
;	Ph.D. Thesis, University of Oslo.
;
; EXAMPLE:
;	Let Vx,Vy be a horizontal velocity field. Then the position of a
;	cork that initially is located at (Xi,Yi) will be:
;
;		Xi+1 = Xi + Vx(Xi,Yi)*INTERVAL
;		Yi+1 = Yi + Vy(Xi,Yi)*INTERVAL
;
;	where the velocities are evaluated at the pixel nearest to Xi,Yi.
;	This will be repeated NSTEP times on the Nx times Ny corks. If
;	INTERVAL is very short, the corks will barely move at every iteration.
;	If it is too long, the corks will go jumping from one position to
;	the next.
;
; MODIFICATION HISTORY:
;	Roberto Molowny Horas, Sept. 1991.
;	Added some comments, April 1994, RMH.
;-
;
ON_ERROR,2

	IF N_PARAMS(0) LT 6 THEN MESSAGE,'Wrong number of parameters.'
	IF nstep LT 1 THEN MESSAGE,'Number of steps must be larger than 1'

	s = SIZE(vx)

	cx = LINDGEN(nx,ny) MOD nx
	cx = FLOAT(cx) / nx * s(1)
	cx = RFIX(cx)
	cy = LINDGEN(nx,ny) / nx
	cy = FLOAT(cy) / ny * s(2)
	cy = RFIX(cy)

	cx = cx + vx(cx,cy) * interval			;Moves X.
	cx = cx > 0 < (s(1)-1)				;Matches to zero.
	cy = cy + vy(cx,cy) * interval			;Moves Y.
	cy = cy > 0 < (s(2)-1)

	IF nstep GT 1 THEN FOR i = 2,nstep DO BEGIN
		ix = RFIX(cx)				;Nearest neighbour.
		iy = RFIX(cy)
		cx = cx + vx(ix,iy) * interval		;Moves X.
		cx = cx > 0 < (s(1)-1)			;Matches them to zero.
		cy = cy + vy(ix,iy) * interval		;Moves Y.
		cy = cy > 0 < (s(2)-1)
	ENDFOR
	cx = cx > 0.
	cy = cy > 0.

END
