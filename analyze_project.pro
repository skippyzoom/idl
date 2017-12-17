pro analyze_project, path=path,directory=directory,context=context,verbose=verbose

  ;;==Make sure the graphics directory exists
  if n_elements(directory) eq 0 then directory = './'
  filepath = path+path_sep()+directory
  spawn, 'mkdir -p '+filepath

  ;;==Fill in context defaults

  ;;==Call the graphics routines
  project_graphics, context,filepath=filepath

end
