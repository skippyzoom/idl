;+
; Top-level batch script for runs in the 
; polar_dust project
;-

;;==Give a short project description
description = 'Electron bite-outs (various geometries) at high/polar latitudes.'

;;==Declare name(s) of data directory/ies
run = list()
run.add, 'run005'

;;==Set project data path(s)
path = set_project_path(get_base_dir(), $
                        'polar_dust', $
                        run)

ct = get_custom_ct(1)

;;==Create project dictionary
prj = load_default_context()
prj['description'] = description
prj.data['ranges'] = [[0.5-1./8,0.5+1./8],[0.5-1./4,0.5+1./4],[0,1]]
prj.graphics['smooth'] = 5
prj.panel['index'] = [0.25,0.50,0.75,1.0]
prj.panel['layout'] = [2,2]
prj.graphics.desc = 'diff_zoom'
prj.graphics['rgb_table'] = dictionary('den1', 5, $
                                       'phi', [[ct.r],[ct.g],[ct.b]], $
                                       'emag', 3, $
                                       'fft', 39)

;;==Run analysis routines
for id=0,n_elements(path)-1 do analyze_project, path[id],prj[*]

