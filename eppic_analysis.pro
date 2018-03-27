;+
; A script to analyze EPPIC data
;-
;;==Declare the simulation run path
run = 'run007'
project = 'parametric_wave'
path = get_base_dir()+path_sep()+project+path_sep()+run

;;==Declare the data quantity to analyze
data_name = 'den1'

;;==Read simulation parameters
params = set_eppic_params(path=path)

;;==Calculate max number of time steps
nt_max = calc_timesteps(path=path)

;;==Create the time-step array
;; timestep = params.nout*lindgen(nt_max)
timestep = params.nout*[0,1,nt_max/2,nt_max-1]

;;==Extract a data plane
plane = eppic_data_plane(data_name, $
                         timestep = timestep, $
                         axes = 'xy', $
                         data_type = 4, $
                         data_isft = 0B, $
                         ranges = [0.0,1.0,0.25,0.75], $
                         rotate = 3, $
                         info_path = path, $
                         data_path = path+path_sep()+'parallel')

;;==Extract arrays
fdata = plane.remove('f')
xdata = plane.remove('x')
ydata = plane.remove('y')

;;==Get dimensions of data plane
fsize = size(fdata)
nx = fsize[1]
ny = fsize[2]
nt = fsize[3]

;;-->TO DO: Put spectral analysis stuff here
;; fdata = plane_spectrum(fdata,/overwrite)

@make_image
;; @make_movie
