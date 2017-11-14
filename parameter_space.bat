;+
; Top-level batch script for runs in the
; parameter_space project.
;-

;***CHECK fb_flow_angle.bat (08Nov2017)***

;;==Give a short project description
description = 'Parameter-space study of cell size.'

;;==Declare name(s) of data directory/ies
run = list()
run.add, 'test012'
run.add, 'test013'
run.add, 'test018'
run.add, 'test019'
run.add, 'test020'
run.add, 'test021'
run.add, 'test022'
run.add, 'test023'

;;==Set project data path(s)
path = set_project_path(get_base_dir(), $
                        'parameter_space', $
                        run)

;;==Create project dictionary
prj = dictionary('description', description, $
                 'transpose', [0,1,2,3], $
                 'ranges', [[0,1],[0,1],[0,1]], $
                 'scale', dictionary('den1', 1e2, $
                                     'phi', 1e3, $
                                     'emag', 1e3), $
                 'plot_index', [0.25,0.50,0.75,1.0], $
                 'plot_layout', [2,2], $
                 'data_name', list('den1','phi'), $
                 'data_type', ['ph5','ph5'], $
                 'img_type', '.png', $
                 'mov_type', '.mp4', $
                 'img_desc', 'final', $
                 'mov_desc', '', $
                 'make_movies', 1B, $
                 'movie_timestamps', 1B, $
                 'movie_expand', 3.0, $
                 'movie_rescale', 0.8, $
                 'colorbar_type', 'global')

;;==Run analysis routines
for id=0,n_elements(path)-1 do analyze_project, path[id],prj[*]

