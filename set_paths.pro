;+
; Return the project path and original path,
; given the name of the project directory
; within ~/projects.
;-
function set_paths, dir,base=base

  if n_elements(base) eq 0 then base = ''

  orig = !PATH
  proj = !PATH+path_sep(/search_path)+expand_path(base+path_sep()+dir)
  ;; proj = expand_path(base+path_sep()+dir)
  ;; if file_test(proj+path_sep()+'ppic3d.i') then proj = !PATH+':'+proj $
  ;; else proj = !PATH+':'+expand_path('~/projects/default/')

  paths = dictionary('orig', orig, $
                     'proj', proj) 
  return, paths
end
