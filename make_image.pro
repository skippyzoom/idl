;+
; Make images from EPPIC data with data_image.pro.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;-
pro make_image, fdata,xdata,ydata, $
                data_name, $
                time=time, $
                file=file, $
                context=context

  ;;==Get dimensions of data plane
  fsize = size(fdata)
  nx = fsize[1]
  ny = fsize[2]
  nt = fsize[3]

  ;;==Defaults and guards
  if n_elements(file) eq 0 then file = dictionary()
  if ~isa(file,'dictionary') then file = dictionary(file)
  if ~file.haskey('path') then file['path'] = './'
  if ~file.haskey('name') then file['name'] = 'data_image'
  if ~file.haskey('type') then file['type'] = '.pdf'
  if ~file.haskey('info') then file['info'] = ''
  if n_elements(time) eq 0 then time = dictionary()
  if ~isa(time,'dictionary') then time = dictionary(time)
  if ~time.haskey('index') then time['index'] = indgen(nt)
  if n_elements(context) eq 0 then context = 'spatial'

  ;;==Declare an array of filenames
  filename = expand_path(file.path)+path_sep()+ $
             file.name+file.info+'-'+time.index+file.type

  ;;==Set up graphics preferences
  kw = set_graphics_kw(data_name,fdata,params, $
                       context = context)
  if time.haskey('stamp') then begin
     text_pos = [0.05,0.85]
     text_string = time.stamp
     text_format = 'k'
  endif

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
