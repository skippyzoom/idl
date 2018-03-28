;+
; Make images from EPPIC data with data_image.pro.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;-

pro make_image, fdata,xdata,ydata, $
                data_name,time, $
                save_info=save_info, $
                context=context

  ;;==Defaults and guards
  if ~isa(save_info,'dictionary') then save_info = dictionary(save_info)
  if ~save_info.haskey('path') then save_info['path'] = './'
  if n_elements(context) eq 0 then context = 'spatial'

  ;;==Declare an array of filenames
  filename = expand_path(save_info.path)+path_sep()+ $
             save_info.name+'-'+time.index+save_info.ext

  ;;==Set up graphics preferences
  kw = set_graphics_kw(data_name,fdata,params, $
                       fix(time.index), $
                       context = context)
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
end
