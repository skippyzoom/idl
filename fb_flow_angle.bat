;+
; Top-level batch script for runs in the
; fb_flow_angle project.
;-

;;==Give a short project description
description = 'Farley-Buneman flow angle in 2D or 3D.'

;;==Declare name(s) of data directory/ies
run = build_run_list(expand_path('~/idl/batch/fb_flow_angle.lst'))

;;==Set project data path(s)
path = set_project_path(get_base_dir(), $
                        'fb_flow_angle', $
                        run)

;;==Get custom color table(s)
ct = get_custom_ct(1)

;;==Create project dictionary
prj = load_empty_context()
prj['description'] = description
prj.data['name'] = list('den1','denft1')
prj.data['transpose'] = [2,1,0,3]
prj.graphics['note'] = 'code_dev'
prj.graphics['rgb_table'] = dictionary('den1', 5, $
                                       'phi', [[ct.r],[ct.g],[ct.b]], $
                                       'emag', 3, $
                                       'fft', 39)

;;==Run analysis routines
for id=0,n_elements(path)-1 do analyze_project, path[id],prj[*]

