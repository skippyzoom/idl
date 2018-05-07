;+
; Common default values for <name>_raw_movies.pro routines.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;-
if n_elements(path) eq 0 then path = './'
if n_elements(params) eq 0 then params = set_eppic_params(path=path)
if n_elements(nt_max) eq 0 then nt_max = calc_timesteps(path=path)
if ~params.haskey('nt_max') then params['nt_max'] = nt_max
if n_elements(x0) eq 0 then x0 = 0
if n_elements(xf) eq 0 then xf = nx
if n_elements(y0) eq 0 then y0 = 0
if n_elements(yf) eq 0 then yf = ny
if n_elements(name_info) eq 0 then name_info = ''
if n_elements(time) eq 0 then $
   time = time_strings(params.nout*lindgen(params.nt_max), $
                       dt=params.dt,scale=1e3,precision=2)
if n_elements(filename) eq 0 then $
   filename = path+path_sep()+'movies'+ $
              path_sep()+'eppic_data.mp4'
