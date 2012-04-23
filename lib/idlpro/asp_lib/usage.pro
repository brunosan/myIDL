pro usage, routine
;+
;
;	procedure:  usage
;
;	purpose:  print usage info for routines (incl. ASP) written in IDL
;
;	author:  rob@ncar, 12/92
;
;	notes:  1) this routine must be updated for each new routine
;		2) some ASP routines do not have "complete" usage statements
;
;==============================================================================
;
;	Check number of parameters.
;
if n_params() ne 1 then begin
usage:
	print
	print, "usage:  usage, routine"
	print
	print, "	Print usage information for an ASP routine"
	print, "	(also works for RSI routines written in IDL)."
	print
	print, "	Arguments"
	print, "		routine	 - name of routine"
	print
	print, "   ex:  usage, 'aspview'"
	print
	return
endif
;-
;
;	Print usage information.
;
case routine of
	'abmerge': abmerge
	'alias': alias
	'ambigs': void, ambigs()
	'apod': apod
	'ary_div_row': void, ary_div_row()
	'asp_trunc': asp_trunc
	'aspcal': aspcal
	'aspcomp': aspcomp
	'aspedit': aspedit
	'asplist': asplist
	'aspmeanv': void, aspmeanv()
	'aspprofile': aspprofile
	'aspview': aspview
	'avg_col': void, avg_col()
	'avg_row': void, avg_row()
	'avgprof': avgprof
	'avgprof_st': avgprof_st
	'avgscans_i': avgscans_i
	'az_event': az_event
	'az_gray': az_gray
	'az_view': az_view
	'azam': azam, 1, 1
	'azam_azam': azam_alien, 1, 1, 1
	'azam_blink': azam_blink
	'azam_bttn': azam_bttn
	'azam_bulk': azam_bulk
	'azam_dir': void, azam_dir(1)
	'azam_help': azam_help, 1
	'azam_op': azam_op
	'azimuth_flip': azimuth_flip
	'b_field': b_field, 1, 1
	'b_image': void, b_image()
	'badcol': badcol
	'bell': bell, 1, 1
	'buildgn': buildgn
	'c_field': c_field, 1, 1
	'c_image': void, c_image()
	'ca': ca, 1
	'calave': calave
	'calc_rms': void, calc_rms()
	'calcross': calcross
	'calibrate': calibrate
	'calib_gain': calib_gain
	'calib_res': calib_res
	'calib_xmat': calib_xmat
	'calib_xt': calib_xt
	'calmerge': calmerge
	'cct_min_max': cct_min_max
	'change_cmap': void, change_cmap(1)
	'check_rec': check_rec, 1
	'color_pix': color_pix
	'colorw': colorw, 1
	'cont': void, cont()
	'cormax': cormax
	'corsh1': void, corsh1()
	'corshft': void, corshft()
	'd': d, 1
	'delwin': delwin, 1
	'displayct': displayct
	'displayctn': displayctn
	'equal': void, equal()
	'extend': void, extend()
	'ffterpol': void, ffterpol()
	'fftrp': fftrp
	'field_cursor': field_cursor
	'field_plot': field_plot
	'field_scale': field_scale
	'filt': filt
	'filtavg': filtavg
	'fits_idl': void, fits_idl()
	'fix_rec': fix_rec
	'fixr': void, fixr()
	'flat_filtd': flat_filtd
	'flatav': flatav
	'flatavg': flatavg
	'flatavg2': flatavg2
	'flicker': flicker
	'flipx': flipx
	'flipy': flipy
	'float2i': void, float2i()
	'float_str': void, float_str()
	'fshft': void, fshft()
	'g1': g1
	'g2': g2
	'g3': g3
	'g4': g4
	'g6': g6
	'gain_check': gain_check
	'gain_merge_xt3': gain_merge_xt3
	'gain_xt': gain_xt
	'gain_xt2': gain_xt2, 1
	'gain_xt3': gain_xt3
	'gainit': gainit
	'gauss1': gauss1
	'genfiltd': genfiltd
	'genibfz': genibfz
	'genibpg': genibpg
	'geniebb': geniebb
	'genivdd': genivdd
	'get_imat': void, get_imat()
	'get_ncolor': void, get_ncolor(1)
	'get_nmap': void, get_nmap(1)
	'get_nscan': void, get_nscan(1)
	'get_optype': void, get_optype(1)
	'get_st': get_st
	'get_st2': get_st2
	'get_t': void, get_t()
	'get_version': void, get_version(1)
	'get_words': void, get_words()
	'getiiii': getiiii
	'gncorr': void, gncorr()
	'grabps': grabps, 1, 1
	'graph1': graph1
	'graph2': graph2
	'graph3': graph3
	'graph4': graph4
	'graph6': graph6
	'h': h
	'hair': hair
	'helplist': helplist, 1
	'helps': helps
	'hist': hist
	'float2i': void, float2i()
	'i2float': void, i2float()
	'icross': icross
	'idl_fits': idl_fits
	'iquv_fits': iquv_fits
	'in_set': void, in_set()
	'insert_wrap': insert_wrap
	'insert_wrapm': insert_wrapm
	'interp4x4': void, interp4x4()
	'is_raw': void, is_raw(1)
	'iv_fits': iv_fits
	'label_iquv': label_iquv
	'laser_sl': laser_sl
	'listop': listop
	'ls': ls, 1
	'maxit': maxit
	'mean': void, mean()
	'mean_col': void, mean_col()
	'medfilt': medfilt
	'minit': minit
	'minmaxpro': minmaxpro
	'mk_asp_help': mk_asp_help
	'mm': mm
	'newct': newct, 1, 1
	'newwct': newwct
	'notch_p': void, notch_p()
	'ofstc2': ofstc2
	'ofstc3': ofstc3
	'ofstcn': ofstcn
	'p': p
	'path': path, 1
	'pause': pause, 1, 1
	'plot_4': plot_4
	'plot_cbars': plot_cbars
	'plot_hval': plot_hval
	'plot_m4': plot_m4
	'plot_meansc': plot_meansc
	'plot_ps3': plot_ps3
	'plot_st2': plot_st2
	'pltibfz': pltibfz
	'pltibpg': pltibpg
	'pltiebb': pltiebb
	'pltiiii': pltiiii
	'pltiiiix': pltiiiix
	'pltivdd': pltivdd
	'pop_cult': void, pop_cult()
	'prof4': prof4
	'profile1': profile1
	'profile4': profile4
	'profilep': profilep
	'ps_asp': ps_asp, 1, 1, 1, 1
	'puff': void, puff()
	'put_nmap': put_nmap
	'put_nscan': put_nscan
	'put_optype': put_optype
	'put_version': put_version
	'pwspec': pwspec
	'q': q, 1
	'r': r, 1
	'rabin': rabin, 1
	'rca': rca, 1
	'read_floats': void, read_floats()
	'read_line': void, read_line()
	'read_op_hdr': void, read_op_hdr()
	'read_sc_data': void, read_sc_data()
	'read_sc_hdr': void, read_sc_hdr()
	'read_t': void, read_t()
	'read_x': void, read_x()
	'readscan': readscan
	'rem_clouds': rem_clouds
	'rem_index': void, rem_index()
	'rev_scans': rev_scans
	'reversal': void, reversal()
	'roundit': void, roundit()
	'row_div_ary': void, row_div_ary()
	'run_shg': run_shg
	'scalew': void, scalew()
	'set_iquv': set_iquv, 1
	'set_sub': void, set_sub()
	'setmtx': void, setmtx()
	'shftquv': shftquv
	'shg': shg
	'shg_darks': shg_darks
	'shgplot': shgplot
	'shgview': shgview
	'shsl': shsl
	'shslit': shslit
	'sign': void, sign()
	'sizeof': void, sizeof()
	'skew': void, skew()
	'skip_scan': skip_scan
	'split_spec': split_spec
	'str2int': void, str2int()
	'strcam': void, strcam(1)
	'strdate': void, strdate(1)
	'stringit': void, stringit()
	'strsub': void, strsub()
	'strip_q': void, strip_q()
	'template': template
	'terpol': terpol
	'timer': void, timer(1, 1)
	'traceback': traceback, 1
	'tvasp': tvasp
	'tvwin': tvwin
	'tvwinp': tvwinp
	'usage': usage
	'usage_event': usage_event
	'usage_widget': usage_widget, 1
	'void': void, 1, 1
	'vttmtx': void, vttmtx()
	'wfits': wfits
	'wlcross': wlcross
	'wrap_key': wrap_key
	'wrap_key2': wrap_key2
	'wrap_scale': void, wrap_scale()
	'wrap_scalew': void, wrap_scalew()
	'writ_op_hdr': void, writ_op_hdr()
	'writ_sc_data': void, writ_sc_data()
	'writ_sc_hdr': void, writ_sc_hdr()
	'write_floats': void, write_floats()
	'writscan': writscan
	'xshift': void, xshift()
	else: begin
		doc_library, routine
	      end
endcase
;
;	Done.
;
end
