;+
; Common default values for *_read_plane.pro scripts
;-
if n_elements(axes) eq 0 then axes = 'xy'
if n_elements(ranges) eq 0 then ranges = [0,1,0,1,0,1]
if n_elements(rotate) eq 0 then rotate = 0
if n_elements(path) eq 0 then path = './'
if n_elements(params) eq 0 then params = set_eppic_params(path=path)
if n_elements(nt_max) eq 0 then nt_max = calc_timesteps(path=path)
if ~params.haskey('nt_max') then params['nt_max'] = nt_max
if n_elements(time) eq 0 then $
   time = time_strings(params.nout*lindgen(params.nt_max), $
                       dt=params.dt,scale=1e3,precision=2)
