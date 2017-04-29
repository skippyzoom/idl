;+
; Read in simulation-specific parameters, determine how many
; time steps are available for simulated quantities (e.g. phi)
; and calculate useful quantities from moments file(s)
;
; TO DO:
; -- Consider changing calc_timesteps, moment_analysis, and 
;    set_grid to procedures or functions.
;-

;;==Store full path of working directory
spawn, 'pwd',curDir
baseLabel = curDir

;------------------------------------;
; Simulation parameters and defaults ;
;------------------------------------;
@ppic3d.i
@params_in.pro
if n_elements(den_out_subcycle1) eq 0 then den_out_subcycle1 = 1
if n_elements(iskip) eq 0 then iskip = 1
if n_elements(istart) eq 0 then istart = 0
if n_elements(iend) eq 0 then iend = -1
if n_elements(hdf_output_arrays) eq 0 then hdf_output_arrays = 0

;------------;
; Time steps ;
;------------;
.r calc_timesteps

;-------------------------------------;
; Temperature, etc. from moment files ;
;-------------------------------------;
make_plots = 1B
.r moment_analysis

;----------------------------;
; Spatial coordinate vectors ;
;----------------------------;
.r set_grid
