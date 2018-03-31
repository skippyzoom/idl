;+
; Make graphics from data array.
;
; This routine calls graphics routines to produce images
; or movies of input data. It produces images if the user
; supplies image_name and it produces movies if the user
; supplies movie_name.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;                                 **PARAMETERS**
; FDATA (required)
;    Either a (2+1)-D array from which to make images,
;    a (1+1)-D array from which to make plots, or a 1-D
;    array of x-axis points for making plots.
; XDATA (optional)
; YDATA (optional)
;-
pro data_graphics, fdata,xdata,ydata, $
                   data_name, $
                   time=time, $
                   image_name=image_name, $
                   image_path=image_path, $
                   image_type=image_type, $
                   image_info=image_info, $
                   movie_name=movie_name, $
                   movie_path=movie_path, $
                   movie_type=movie_type, $
                   movie_info=movie_info, $
                   context=context

  ;;==Get dimensions of data plane
  fsize = size(fdata)
  n_dims = fsize[0]
  nx = fsize[1]
  if n_dims eq 3 then begin
     ny = fsize[2]
     nt = fsize[3]
  endif else nt = fsize[2]

  ;;==Make images
  if n_elements(image_name) ne 0 then begin

     ;;==Defaults and guards
     image_name = strip_extension(image_name)
     if n_elements(image_path) eq 0 then image_path = './'
     if n_elements(image_type) eq 0 then image_type = '.pdf'
     if n_elements(image_info) eq 0 then image_info = ''
     if n_elements(time) eq 0 then time = dictionary()
     if ~isa(time,'dictionary') then time = dictionary(time)
     if ~time.haskey('index') then time['index'] = indgen(nt)
     if n_elements(context) eq 0 then context = 'spatial'

     ;;==Declare an array of filenames
     filename = expand_path(image_path)+path_sep()+ $
                image_name+image_info+'-'+time.index+image_type

     ;;==Set up graphics preferences
     kw = set_graphics_kw(data_name,fdata, $
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
  endif

  ;;==Make a movie
  if n_elements(movie_name) ne 0 then begin

     ;;==Defaults and guards
     movie_name = strip_extension(movie_name)
     if n_elements(movie_path) eq 0 then movie_path = './'
     if n_elements(movie_type) eq 0 then movie_type = '.pdf'
     if n_elements(movie_info) eq 0 then movie_info = ''
     if n_elements(time) eq 0 then time = dictionary()
     if ~isa(time,'dictionary') then time = dictionary(time)
     if ~time.haskey('index') then time['index'] = indgen(nt)
     if n_elements(context) eq 0 then context = 'spatial'

     ;;==Declare the movie file path and name
     filename = expand_path(movie_path)+path_sep()+ $
                movie_name+movie_info+movie_type

     ;;==Set up graphics preferences
     kw = set_graphics_kw(data_name,fdata, $
                          context = context)
     if time.haskey('stamp') then begin
        text_pos = [0.05,0.85]
        text_string = time.stamp
        text_format = 'k'
     endif

     ;;==Create and save a movie
     data_movie, fdata,xdata,ydata, $
                 filename = filename, $
                 image_kw = kw.image, $
                 colorbar_kw = kw.colorbar, $
                 text_pos = text_pos, $
                 text_string = text_string, $
                 text_format = text_format, $
                 text_kw = kw.text
  endif

end
