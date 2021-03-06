;+
; Top-level batch script for runs in the 
; quasineutral_static_dust project
;-

;***CHECK fb_flow_angle.bat (08Nov2017)***

;;==Give a short project description
description = 'FBI generated from GDI via parametric instability.'

;;==Declare name(s) of data directory/ies
run = list()

;;==Set project data path(s)
path = set_project_path(get_base_dir(), $
                        'parametric_fbgd', $
                        run)

ct = get_custom_ct(1)

;;==Create project dictionary
prj = dictionary('description', description, $
                 'transpose', [1,0,2,3], $
                 'ranges', [[0.0,1.0],[0.5,1.0],[0,1]], $
                 'rgb_table', dictionary('den1', 5, $
                                         'phi', [[ct.r],[ct.g],[ct.b]], $
                                         'emag', 3), $
                 'scale', dictionary('den1', 1e2, $
                                     'phi', 1e3, $
                                     'emag', 1e3), $
                 'plot_index', [0.25,0.50,0.75,1.0], $
                 'plot_layout', [2,2], $
                 ;; 'plot_index', [1.0], $
                 ;; 'plot_layout', [1,1], $
                 'data_name', list('den1','phi'), $
                 'data_type', ['ph5','ph5'], $
                 ;; 'img_type', '.png', $
                 'img_type', '.pdf', $
                 'mov_type', '.mp4', $
                 'img_desc', 'R_half', $
                 'mov_desc', '', $
                 'make_movies', 0B, $
                 'movie_timestamps', 1B, $
                 'movie_expand', 3.0, $
                 'movie_rescale', 0.8, $
                 'colorbar_type', 'global')

;;==Run analysis routines
for id=0,n_elements(path)-1 do analyze_project, path[id],prj[*]

