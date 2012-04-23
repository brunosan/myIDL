;
;	File:  op_hdr.com
;
;	Purpose:  specifiy operation header common block  (see op_hdr.set)
;
;	Date:  11/92
;
;------------------------------------------------------------------------------
;
common op_hdr,							$
	command, head_type, year, month, day,			$
	hour, min, sec, det, demod,				$
	wavelen, optype, opnum, dem1, dem2,			$
	det1, det2, det3, det4, modhex,				$
	modix, sgain_i, sgain_p, sgain_v, sset,			$
	hexad, macro, mstepsz, nmstep, fstepsz,			$
	nfstep, cconfigs, wavelen2, activecams, tapename,	$
	accnum, dhoff, dvoff, dnumx, dnumy,			$
	bmode, dlsb, detwin,					$
	orig_nscan, input_x1, input_y1, merged,			$ ;added by Rob
	ofiller
