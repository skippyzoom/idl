;+
; Top-level batch script for runs in the
; fb_flow_angle project.
;-

;;==Give a short project description
description = 'Farley-Buneman flow angle in 2D or 3D.'

;;==Declare name(s) of data directory/ies
run = list()
;; run.add, 'alt0'
;; run.add, 'alt1'
;; run.add, 'alt2'
run.add, 'test000'
run.add, 'test001'

;;==Set project data path(s)
path = set_project_path(get_base_dir(), $
                        'fb_flow_angle'+path_sep()+ $
                        ;; '2D', $
                        'tests', $
                        run)

;;==Get custom color table(s)
ct = get_custom_ct(1)

;;==Create project dictionary
;; ;; prj = get_context_defaults()
;; prj = dictionary()
prj = load_empty_context()
;; prj['description'] = description
;; ;; prj.panel['index'] = [0.25,0.50,0.75,1.0]
;; ;; prj.panel['layout'] = [2,2]
prj.graphics.note = 'code_dev'
;; prj.graphics['rgb_table'] = dictionary('den1', 5, $
;;                                        'phi', [[ct.r],[ct.g],[ct.b]], $
;;                                        'emag', 3, $
;;                                        'fft', 39)

;;==Run analysis routines
for id=0,n_elements(path)-1 do analyze_project, path[id],prj[*]
;; for id=0,n_elements(path)-1 do analyze_project, path[id]

