run = 'run007'
project = 'parametric_wave'
path = get_base_dir()+path_sep()+project+path_sep()+run

data_name = 'den1'
eppic_movie, data_name, $
             axes = 'xy', $
             data_type = 4, $
             data_isft = 0B, $
             rotate = 3, $
             info_path = path, $
             data_path = path+path_sep()+'parallel', $
             save_path = path+path_sep()+'movies', $
             save_name = data_name+'.mp4'

run = 'run009'
project = 'parametric_wave'
path = get_base_dir()+path_sep()+project+path_sep()+run

data_name = 'den1'
eppic_movie, data_name, $
             axes = 'xy', $
             data_type = 4, $
             data_isft = 0B, $
             rotate = 3, $
             info_path = path, $
             data_path = path+path_sep()+'parallel', $
             save_path = path+path_sep()+'movies', $
             save_name = data_name+'.mp4'

;; data_name = 'den1'
;; eppic_movie, data_name, $
;;              axes = 'xy', $
;;              data_type = 4, $
;;              data_isft = 0B, $
;;              rotate = 3, $
;;              fft_direction = -1, $
;;              info_path = path, $
;;              data_path = path+path_sep()+'parallel', $
;;              save_path = path+path_sep()+'movies', $
;;              save_name = data_name+'fft.mp4'

;; data_name = 'phi'
;; eppic_movie, data_name, $
;;              axes = 'xy', $
;;              data_type = 4, $
;;              data_isft = 0B, $
;;              rotate = 3, $
;;              info_path = path, $
;;              data_path = path+path_sep()+'parallel', $
;;              save_path = path+path_sep()+'movies', $
;;              save_name = data_name+'.mp4'

;; data_name = 'efield_x'
;; eppic_movie, data_name, $
;;              axes = 'xy', $
;;              data_type = 4, $
;;              data_isft = 0B, $
;;              rotate = 3, $
;;              info_path = path, $
;;              data_path = path+path_sep()+'parallel', $
;;              save_path = path+path_sep()+'movies', $
;;              save_name = data_name+'.mp4'

;; data_name = 'efield_y'
;; eppic_movie, data_name, $
;;              axes = 'xy', $
;;              data_type = 4, $
;;              data_isft = 0B, $
;;              rotate = 3, $
;;              info_path = path, $
;;              data_path = path+path_sep()+'parallel', $
;;              save_path = path+path_sep()+'movies', $
;;              save_name = data_name+'.mp4'

;; data_name = 'efield_r'
;; eppic_movie, data_name, $
;;              axes = 'xy', $
;;              data_type = 4, $
;;              data_isft = 0B, $
;;              rotate = 3, $
;;              info_path = path, $
;;              data_path = path+path_sep()+'parallel', $
;;              save_path = path+path_sep()+'movies', $
;;              save_name = data_name+'.mp4'

;; data_name = 'efield_t'
;; eppic_movie, data_name, $
;;              axes = 'xy', $
;;              data_type = 4, $
;;              data_isft = 0B, $
;;              rotate = 3, $
;;              info_path = path, $
;;              data_path = path+path_sep()+'parallel', $
;;              save_path = path+path_sep()+'movies', $
;;              save_name = data_name+'.mp4'
