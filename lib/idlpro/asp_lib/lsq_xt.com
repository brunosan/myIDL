;
;	File:  lsq_xt.com
;
;	Purpose:  specifiy common for lsq_xt information
;
;	Author:  paul@ncar, 10/94
;
;------------------------------------------------------------------------------
;
common lsq_xt_ndf, ndf $
, files, iffile, ifnorm, wght, npfile, jfile

common lsq_xt_nv, nv $
, names, iffit, fits, gfit, ptb, stderr

common lsq_xt_np, np $
, obs, pfl, savpfl, iset, isrc, normi $
, az, elev, ta, step $
, ifcallin, callin, sinlin, coslin $
, ifcalret, calret, sinret, cosret $
, azdg, discrim $
, isel, jsel, wgt, wfree $
, derivs

common lsq_xt_com1 $
, neye0, nque0, nyou0, nvee0, noffin0 $
, neyel, nquel, nyoul, nveel, noffinl $
, neyec, nquec, nyouc, nveec, noffinc $
, neye3, nque3, nyou3, nvee3, noffin3 $
, neye4, nque4, nyou4, nvee4, noffin4 $
, neye5, nque5, nyou5, nvee5, noffin5

common lsq_xt_com2 $
, nwinret, nwinang $
, nrn0, nrk0, nrt0 $
, nexret, nexang $
, noffout $
, ntx, nty, nrtda, nrtd $
, nerar, ndlc, nrrsm, nrrdf $
, nbias0, nbiasl, nbiasc, nbias3, nbias4, nbias5 $
, ngain $
, nx11, nx12, nx13, nx14 $
, nx21, nx22, nx23, nx24 $
, nx31, nx32, nx33, nx34 $
, nx41, nx42, nx43, nx44

common lsq_xt_vtt $
, azelrs, azelrp, azelret, azelmtx $
, primrs, primrp, primret, primmtx

common lsq_xt_stuff, utmp, rpd, blank256, ctype

common lsq_xt_iters, flevel, dtot, iter, fla, dchi, probf, trace

common lsq_xt_chi, ssq, chi, pchi
;
;------------------------------------------------------------------------------
