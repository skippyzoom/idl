;;==Declare the simulation run path
run = 'test084'
project = 'parametric_wave'
path = get_base_dir()+path_sep()+project+path_sep()+run

;;==Read simulation parameters
params = set_eppic_params(path=path)

;;==Calculate max number of time steps
nt_max = calc_timesteps(path=path)

;;==Read moments files
moments = analyze_moments(path=path)

;;==Plot moments data
plot_moments, moments, $
              params = params, $
              path = path+path_sep()+'frames'

;;==Declare rotation
rotate = 3

;;==Declare normalized data ranges
ranges = [0.0,1.0,0.0,1.0]

;;==Create the time-step array
timestep = params.nout*[0,nt_max/2,nt_max-1]

;;==Convert time steps to strings
time = time_strings(timestep,dt=params.dt,scale=1e3,precision=2)

@den_images
@phi_images
@efield_images

;;==Clear arrays
delvar, den1,phi

;;==Create the time-step array
timestep = params.nout*lindgen(nt_max)

;;==Convert time steps to strings
time = time_strings(timestep,dt=params.dt,scale=1e3,precision=2)

;; @den_movies
;; @phi_movies
;; @efield_movies
