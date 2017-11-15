;+
; Top-level batch script for runs in the
; parameter_space project.
;-

;;==Give a short project description
description = 'Parameter-space study of cell size.'

;;==Declare name(s) of data directory/ies
run = list()
;; run.add, 'test012'
;; run.add, 'test013'
;; run.add, 'test018'
;; run.add, 'test019'
;; run.add, 'test020'
;; run.add, 'test021'
;; run.add, 'test022'
;; run.add, 'test023'
;; run.add, 'test024'
;; run.add, 'test025'
;; run.add, 'test026'
;; run.add, 'test027'
;; run.add, 'test028'
;; run.add, 'test029'
;; run.add, 'test030'
run.add, 'test031'

;;==Set project data path(s)
path = set_project_path(get_base_dir(), $
                        'parameter_space', $
                        run)

;;==Get custom color table(s)
ct = get_custom_ct(1)

;;==Create project dictionary
prj = dictionary()
prj['description'] = description
prj['panel'] = dictionary('index', [0.25,0.50,0.75,1.0], $
                          'layout', [2,2], $
                          'show', 1B)
prj['data'] = dictionary('transpose', [0,1,2,3], $
                         'ranges', [[0,1],[0,1],[0,1]], $
                         'scale', dictionary('den1', 1e2, $
                                             'phi', 1e3, $
                                             'emag', 1e3), $
                         'name', list('den1','phi'), $
                         'type', ['ph5','ph5'])
prj['graphics'] = dictionary()
prj.graphics['rgb_table'] = dictionary('den1', 5, $
                                       'phi', [[ct.r],[ct.g],[ct.b]], $
                                       'emag', 3, $
                                       'fft', 39)
prj.graphics['desc'] = ''
prj.graphics['image'] = dictionary('type', '.png')
prj.graphics['movie'] = dictionary('type', '.mp4', $
                                   'make', 1B, $
                                   'timestamps', 0B, $
                                   'expand', 3.0, $
                                   'rescale', 0.8)
prj.graphics['colorbar'] = dictionary('type', 'global')

;;==Run analysis routines
for id=0,n_elements(path)-1 do analyze_project, path[id],prj[*]

