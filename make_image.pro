;+
; Make images from EPPIC data with data_image.pro.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;-
pro make_image, fdata,xdata,ydata, $
                data_name,time, $
                file=file, $
                context=context

  ;;==Defaults and guards
  if ~isa(file,'dictionary') then file = dictionary(file)
  if ~file.haskey('path') then file['path'] = './'
  if ~file.haskey('name') then file['name'] = 'data_image'
  if ~file.haskey('type') then file['type'] = '.pdf'
  if ~file.haskey('info') then file['info'] = ''
  if n_elements(context) eq 0 then context = 'spatial'

  ;;==Declare an array of filenames
  filename = expand_path(file.path)+path_sep()+ $
             file.name+file.info+'-'+time.index+file.type

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
