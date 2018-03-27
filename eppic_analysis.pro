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
timestep = params.nout*lindgen(nt_max)

;;==Extract a data plane
plane = eppic_data_plane(data_name, $
                         timestep = timestep, $
                         axes = 'xy', $
                         data_type = 4, $
                         data_isft = 0B, $
                         ranges = [0.0,1.0,0.25,0.75], $
                         rotate = 3, $
                         fft_direction = -1, $
                         info_path = path, $
                         data_path = path+path_sep()+'parallel')

;;==Extract arrays
fdata = plane.remove('f')
xdata = plane.remove('x')
ydata = plane.remove('y')

;; ;;==Declare the movie file name
;; ;; save_path = path+path_sep()+'images'
;; save_path = '~/idl'
;; save_name = 'eppic_analysis-test.mp4'
;; filename = expand_path(save_path+path_sep()+save_name)

;; ;;==Set up graphics preferences
;; kw = set_graphics_kw(data_name,fdata,params,timestep, $
;;                      fft_direction = fft_direction, $
;;                      data_isft = data_isft)
;; text_pos = [0.05,0.85]
;; text_string = time_stamps
;; text_format = 'k'

;; ;;==Create and save a movie
;; data_movie, fdata,xdata,ydata, $
;;             filename = filename, $
;;             image_kw = kw.image, $
;;             colorbar_kw = kw.colorbar, $
;;             text_pos = text_pos, $
;;             text_string = text_string, $
;;             text_format = text_format, $
;;             text_kw = kw.text
