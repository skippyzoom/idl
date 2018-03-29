;+
; Make movies from EPPIC data with data_movie.pro.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;-

pro make_movie, fdata,xdata,ydata, $
                data_name,time, $
                file=file, $
                context=context

  ;;==Defaults and guards
  if ~isa(file,'dictionary') then file = dictionary(file)
  if ~file.haskey('path') then file['path'] = './'
  if ~file.haskey('name') then file['name'] = 'data_movie'
  if ~file.haskey('type') then file['type'] = '.mp4'
  if ~file.haskey('info') then file['info'] = ''
  if n_elements(context) eq 0 then context = 'spatial'

  ;;==Declare the movie file path and name
  filename = expand_path(file.path)+path_sep()+ $
             file.name+file.info+file.type

  ;;==Set up graphics preferences
  kw = set_graphics_kw(data_name,fdata,params, $
                       fix(time.index), $
                       context = context)
  text_pos = [0.05,0.85]
  text_string = time.stamp
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
