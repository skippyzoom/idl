;+
; Select appropriate 2-D axes for a given plane
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; PATH (default: './')
;    Path in which to search for the parameter file.
; PARAMS (default: read-in)
;    Dictionary of simulation parameters.
; <return>
;    Array of data ranges.
;-
function default_ranges, axes,path=path,params=params

  ;;==Defaults
  if n_elements(path) eq 0 then path = './'
  if n_elements(params) eq 0 then params = set_eppic_params(path=path)

  ;;==Select ranges based on axes
  case 1B of 
     strcmp(axes,'xy') || strcmp(axes,'yx'): $
        ranges = [0,params.nx*params.nsubdomains, $
                  0,params.ny]/params.nout_avg
     strcmp(axes,'xz') || strcmp(axes,'zx'): $
        ranges = [0,params.nx, $
                  0,params.nz]/params.nout_avg
     strcmp(axes,'yz') || strcmp(axes,'zy'): $
        ranges = [0,params.ny, $
                  0,params.nz]/params.nout_avg
  endcase

  ;;==Return ranges array
  return, ranges
end
