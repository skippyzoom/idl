;;==Declare the simulation run path
run = 'run007'
;; project = 'parametric_wave'
;; path = get_base_dir()+path_sep()+project+path_sep()+run

;; ;;==Prompt for run and read
;; if n_elements(run) eq 0 then run = ''
;; if strcmp(run,'') then read, run,prompt='Enter run name: '

;; ;;==Read simulation parameters
;; params = set_eppic_params(path=path)

;; ;;==Calculate max number of time steps
;; nt_max = calc_timesteps(path=path)

;; ;;==Read moments files
;; moments = analyze_moments(path=path)

;; ;;==Plot moments data
;; plot_moments, moments, $
;;               params = params, $
;;               path = path+path_sep()+'frames'

;;==Declare project name and perform initial analysis
project = 'parametric_wave'
init = initialize_run(project+path_sep()+run)

;;==Extract initialized variables
path = init.path
params = init.params

;;==Declare rotation
rotate = 3

;;==Declare normalized data ranges
ranges = [0.0,1.0,0.0,1.0]

;;==Create the time-step array
timestep = params.nout*[0,params.nt_max/2,params.nt_max-1]

;;==Convert time steps to strings
time = time_strings(timestep,dt=params.dt,scale=1e3,precision=2)

den_images, time,ranges,path,axes,rotate,data_out=plane
fsize = size(plane.f)
nx = fsize[1]
ny = fsize[2]
fft_images, plane.f,'den1',time,path,nx,ny,params.dx,params.dy
;; phi_images, time,ranges,path,axes,rotate,data_out=plane
;; fsize = size(plane.fdata)
;; nx = fsize[1]
;; ny = fsize[2]
;; fft_images, plane.fdata,'phi',path,nx,ny,params.dx,params.dy
;; ;; @fft_images
;; efield_images, plane.fdata,plane.xdata,plane.ydata, $
;;                time,ranges,path,axes,rotate,params.dx,params.dy
;; ;; @efield_images

;; ;;==Clear arrays
;; delvar, den,phi

;; ;;==Create the time-step array
;; timestep = params.nout*lindgen(params.nt_max)

;; ;;==Convert time steps to strings
;; time = time_strings(timestep,dt=params.dt,scale=1e3,precision=2)

;; @den_movies
;; @phi_movies
;; @efield_movies
