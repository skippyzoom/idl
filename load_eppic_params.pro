;+
; This script loads simulation parameters and sets up
; quantities useful for analysis.
;
; PATH: Fully qualified path to the directory containing
;   simulation data and parameter input file.
; PARAMS: A dictionary containing the input parameters
;   as specified in the input file in path.
; GRID: A structure containing grid-related information.
;   See set_grid.pro for more information.
; NT_MAX: The maximum available time step.
;   See calc_timesteps.pro for information on how it
;   calculates this value.
; MOMENT_VARS: A structure containing quantities calculated
;   from the moments*.out files available in path.
;   See analyze_moments.pro for more information on which
;   quantities it calculates and how it does so.
;-
if n_elements(path) eq 0 then path = './'
cd, path
params = set_eppic_params(path=path)
nt_max = calc_timesteps(path=path)
moment_vars = analyze_moments(path=path)
