;+
; Return the project path and original path,
; given the name of the project directory
; within ~/projects.
;-
function source_project, dir

  orig = !PATH
  proj = expand_path('~/projects/'+dir)
  if file_test(proj+'/project.eppic') then proj = !PATH+':'+proj $
  else proj = !PATH+':'+expand_path('~/projects/default/')

  paths = dictionary('orig', orig, $
                     'proj', proj) 
  return, paths
end
