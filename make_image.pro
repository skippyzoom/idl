;+
; Script for creating EPPIC images with data_image.pro.
; Intended as a subscript to eppic_analysis.pro.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;-

;;==Declare the image file path, base name, and extension
;; save_path = path+path_sep()+'images'
save_path = '~/idl'
save_name = 'eppic_analysis-test'
save_ext = '.pdf'

;;==Convert time steps to strings
time = time_strings(timestep,dt=params.dt,scale=1e3)

;;==Declare an array of filenames
filename = expand_path(save_path)+path_sep()+ $
                       save_name+'-'+time.index+save_ext

;;==Set up graphics preferences
kw = set_graphics_kw(data_name,fdata,params,timestep, $
                     context = 'spectral')
text_pos = [0.05,0.85]
text_string = time.stamp
text_format = 'k'

;;==Create and save a movie
data_image, fdata,xdata,ydata, $
            filename = filename, $
            multi_page = 0B, $
            image_kw = kw.image, $
            colorbar_kw = kw.colorbar, $
            text_pos = text_pos, $
            text_string = text_string, $
            text_format = text_format, $
            text_kw = kw.text
