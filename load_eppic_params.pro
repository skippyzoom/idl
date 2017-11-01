;+
; This script will load simulation parameters
; into memory, set up default graphics parameters,
; and calculate other useful quantities.
;-
if n_elements(path) eq 0 then path = '.'
cd, path
params = set_eppic_params(path)
grid = set_grid(path)
nt_max = calc_timesteps(path,grid)
moment_vars = analyze_moments(nt_max)
