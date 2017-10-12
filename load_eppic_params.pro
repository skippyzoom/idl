;+
; This script will load simulation parameters
; into memory, set up default graphics parameters,
; and calculate other useful quantities.
;
; NOTES
; -- set_eppic_params plays the role of 
;    @eppic_defaults with a functional interface, 
;    so the user can call it from a directory other 
;    than the data directory.
;-
if n_elements(path) eq 0 then path = '.'
cd, path
@eppic_defaults.pro
params = set_eppic_params(path)
grid = set_grid(path)
nt_max = calc_timesteps(path,grid)
moment_vars = analyze_moments(nt_max)
