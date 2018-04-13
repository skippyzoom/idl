;+
; Set up parameters for a given EPPIC simulation run, given the path.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; PATH (default: './')
;    Full path to a simulation run.
; PROJECT (default: '')
;    String name of the project. This function will check this string
;    against known project names and set project-specific parameters
;    if it finds a match.
; <return>
;    Dictionary containing global project parameters.
;-
function project_setup, path=path,project=project

  ;;==Default path
  if n_elements(path) eq 0 then path = './'
  if n_elements(project) eq 0 then project = ''

  ;;==Initialize project dictionary
  pd = dictionary()

  ;;==Fill in project dicionary defaults
  pd['path'] = path
  params = set_eppic_params(path=path)
  nt_max = calc_timesteps(path=path)
  params['nt_max'] = nt_max
  pd['params'] = params
  moments = read_moments(path=path)
  pd['moments'] = moments
  pd['ranges'] = [0,1,0,1,0,1]
  pd['rotate'] = 0

  ;;==Update values for a specific project
  if strcmp(project,'parametric_wave') then begin
     pd['rotate'] = 3
  endif

  ;;==Return the project dictionary
  return, pd

end
