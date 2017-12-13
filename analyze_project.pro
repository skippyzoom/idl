pro analyze_project, path=path,directory=directory,context=context,verbose=verbose

  ;;==Make sure the graphics directory exists
  if n_elements(directory) eq 0 then directory = './'
  spawn, 'mkdir -p '+directory
  filepath = path+path_sep()+directory

  ;;==Fill in context defaults

  ;;==Call the graphics routines
  project_graphics, context

end
