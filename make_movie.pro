;;==Declare the movie file path and name
;; save_path = path+path_sep()+'images'
save_path = '~/idl'
save_name = 'eppic_analysis-test.mp4'
filename = expand_path(save_path+path_sep()+save_name)

;;==Set up graphics preferences
kw = set_graphics_kw(data_name,fdata,params,timestep, $
                     context = 'spatial')
text_pos = [0.05,0.85]
text_string = time_stamps
text_format = 'k'

;;==Create and save a movie
data_movie, fdata,xdata,ydata, $
            filename = filename, $
            image_kw = kw.image, $
            colorbar_kw = kw.colorbar, $
            text_pos = text_pos, $
            text_string = text_string, $
            text_format = text_format, $
            text_kw = kw.text
