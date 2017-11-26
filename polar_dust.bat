;+
; Top-level batch script for runs in the 
; polar_dust project
;-

;;==Give a short project description
description = 'Electron bite-outs (various geometries) at high/polar latitudes.'

;;==Declare name(s) of data directory/ies
run = build_run_list(expand_path('~/idl/batch/polar_dust.lst'))

;;==Set project data path(s)
path = set_project_path(get_base_dir(), $
                        'polar_dust', $
                        run)

;;==Get custom color table(s)
ct = get_custom_ct(1)

;;==Create project dictionary
prj = load_empty_context()
prj['description'] = description
prj.data['ranges'] = [[0.25,0.75],[0,1],[0,1]]
prj.data['transpose'] = [1,0,2,3]
prj.panel['index'] = [0.25,0.50,0.75,1.0]
prj.panel['layout'] = [2,2]
prj.graphics['note'] = 'mid'
prj.graphics['rgb_table'] = dictionary('den1', 5, $
                                       'phi', [[ct.r],[ct.g],[ct.b]], $
                                       'emag', 3, $
                                       'fft', 39)

;;==Run analysis routines
for id=0,n_elements(path)-1 do analyze_project, path[id],prj[*]

