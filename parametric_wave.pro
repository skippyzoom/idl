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

;; plane_images, 'den1', $
;;               axes = 'xy', $
;;               time = time, $
;;               ranges = ranges, $
;;               rotate = rotate, $
;;               path = path, $
;;               data_out = plane
;; fft_images, plane.f,plane.name, $
;;             time = time, $
;;             path = path, $
;;             nkx = n_elements(plane.x), $
;;             nky = n_elements(plane.y), $
;;             dx = plane.dx, $
;;             dy = plane.dy
;; plane_images, 'phi', $
;;               axes = 'xy', $
;;               time = time, $
;;               ranges = ranges, $
;;               rotate = rotate, $
;;               path = path, $
;;               data_out = plane
;; fft_images, plane.f,plane.name, $
;;             time = time, $
;;             path = path, $
;;             nkx = n_elements(plane.x), $
;;             nky = n_elements(plane.y), $
;;             dx = plane.dx, $
;;             dy = plane.dy
;; efield_images, plane.f,plane.x,plane.y, $
;;                time = time, $
;;                ranges = ranges, $
;;                path = path, $
;;                axes = axes, $
;;                rotate = rotate, $
;;                dx = plane.dx, $
;;                dy = plane.dy

;;==Create the time-step array
timestep = params.nout*lindgen(params.nt_max)

;;==Convert time steps to strings
time = time_strings(timestep,dt=params.dt,scale=1e3,precision=2)


;; @den_movies
;; @phi_movies
;; @efield_movies

plane_movies, 'den1', $
              axes = 'xy', $
              time = time, $
              ranges = ranges, $
              rotate = rotate, $
              path = path, $
              data_out = plane
fft_movies, plane.f,plane.name, $
            time = time, $
            path = path, $
            nkx = n_elements(plane.x), $
            nky = n_elements(plane.y), $
            dx = plane.dx, $
            dy = plane.dy
