;+
; This script will load simulation parameters
; into memory, set up default graphics parameters,
; and calculate other useful quantities.
;-
@default.prm
grid = set_grid()
ntMax = calc_timesteps(grid)
moment_vars = analyze_moments(ntMax)
