;+
; Perform setup and initial analysis.
;
; This function constructs the fully qualified path for a specified
; run, builds the parameter dictionary, and performs moments analysis.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; RUN (required)
;    A string specifying the relative directory containing data from
;    the run to analyze. This function will prefix the pre-defined
;    base directory appropriate for the current machine. The user is 
;    resonsible for passing a viable directory name.
; <return>
;    A struct containing the fully qualified run path and the
;    parameter dictionary.
;-

function initialize_run, run

  ;;==Construct full path
  path = get_base_dir()+path_sep()+run

  ;;==Read simulation parameters
  params = set_eppic_params(path=path)

  ;;==Calculate max number of time steps
  nt_max = calc_timesteps(path=path)
  params['nt_max'] = nt_max

  ;;==Read moments files
  moments = read_moments(path=path)

  ;;==Plot moments data
  plot_moments, moments, $
                params = params, $
                save_path = path+path_sep()+'frames'

  return, {path:path, params:params}
end
