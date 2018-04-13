;+
; A simple routine for creating multi-panel images from
; EPPIC data.
;
; Created on 07Dec2017 (may)
;-
pro basic_multi_image, data_name, $
                       timestep=timestep, $
                       rgb_table=rgb_table, $
                       min_value=min_value, $
                       max_value=max_value, $
                       fft_direction=fft_direction, $
                       rotate_direction=rotate_direction, $
                       layout=layout, $
                       font_size=font_size, $
                       font_name=font_name, $
                       origin=origin, $
                       path=path, $
                       filepath=filepath, $
                       filename=filename

  ;;==Defaults and guards
  if n_elements(timestep) eq 0 then timestep = 0
  if n_elements(rgb_table) eq 0 then rgb_table = 0
  if n_elements(layout) eq 0 then layout = !NULL
  if n_elements(font_size) eq 0 then font_size = 10
  if n_elements(font_name) eq 0 then font_name = 'Times'
  if n_elements(origin) eq 0 then origin = hash('xy', 0, $
                                                'xz', 0, $
                                                'yz', 0)
  if n_elements(path) eq 0 then path = './'
  if n_elements(filepath) eq 0 then filepath = path
  if n_elements(filename) eq 0 then filename = data_name+'.png'
  in_name = filename
  ext = get_extension(filename)
  if n_elements(fft_direction) eq 0 then fft_direction = 0
  if n_elements(rotate_direction) eq 0 then rotate_direction = 0

  ;;==Read simulation parameters, etc.
  params = set_eppic_params(path=path)
  grid = set_grid(path=path)
  nt_max = calc_timesteps(path=path,grid=grid)
  moments = read_moments(path=path)

  ;;==Construct title strings
  title = string(1e3*params.dt*timestep,format='(f7.2)')
  title = "t = "+strcompress(title,/remove_all)+" ms"
  nt = n_elements(timestep)

  ;;==Construct panel layout array
  if n_elements(layout) ne 0 then begin
     input = layout
     layout = intarr(3,nt)
     for it=0,nt-1 do layout[*,it] = [input[0],input[1],it+1]
  endif

  ;;==Read single data quantity
  data = (load_eppic_data(data_name,path=path,timestep=timestep))[data_name]

  ;;==Get data dimensions
  data_size = size(data)
  n_dims = data_size[0]
  nt = data_size[n_dims]
  switch n_dims-1 of
     3: nz = data_size[3]
     2: ny = data_size[2]
     1: nx = data_size[1]
  endswitch

  ;;==Check data dimensions (space and time)
  case n_dims of
     4: begin

        ;;==Create a list of 2-D planes for 3-D data
        planes = origin.keys()
        n_planes = n_elements(planes)

        ;;==Calculate forward/inverse FFT, if requested
        if keyword_set(fft_direction) then begin
           for it=0,nt-1 do begin
              data[*,*,*,it] = real_part(fft(data[*,*,*,it], $
                                             fft_direction,/overwrite))
           endfor
        endif

        ;;==Loop over planes
        for ip=0,n_planes-1 do begin

           ;;==Modify file name
           filename = strip_extension(filename)+'_'+planes[ip]+'.'+ext

           ;;==Extract appropriate subarray
           case 1B of
              strcmp(planes[ip],'xy'): begin
                 imgdata = reform(data[*,*,origin['xy'],*])
              end
              strcmp(planes[ip],'xz'): begin
                 imgdata = reform(data[*,origin['xz'],*,*])
              end
              strcmp(planes[ip],'yz'): begin
                 imgdata = reform(data[origin['yz'],*,*,*])
              end
           endcase

           ;;==Loop over time steps
           for it=0,nt-1 do begin

              ;;==Create image
              img = image(rotate(imgdata[*,*,it],rotate_direction), $
                          /buffer, $
                          layout = layout[*,it], $
                          rgb_table = rgb_table, $
                          current = (it gt 0), $
                          axis_style = 2, $
                          title = title[it], $
                          font_size = font_size, $
                          font_name = font_name)
              if keyword_set(min_value) then img.min_value = min_value
              if keyword_set(max_value) then img.max_value = max_value

              ;;==Add a colorbar
              clr = colorbar(target = img, $
                             orientation = 1, $
                             textpos = 1, $
                             font_name = 'Times')
              clr.scale, 0.25,0.50
              clr.translate, -0.25,0.0,/normal

              ;;==Add path label
              txt = text(0.50,0.98,path, $
                         alignment = 0.5, $
                         target = img, $
                         font_name = font_name, $
                         font_size = font_size)

           endfor ;;-->Time steps

           ;;==Save the image
           image_save, img,filename = filepath+path_sep()+filename

           ;;==Reset file name to original
           filename = in_name

        endfor ;;-->Planes

     end
     3: begin

        ;;==Remove singleton dimension
        data = reform(data)

        ;;==Calculate forward/inverse FFT, if requested
        if keyword_set(fft_direction) then begin
           for it=0,nt-1 do begin
              data[*,*,it] = real_part(fft(data[*,*,it], $
                                           fft_direction,/overwrite))
           endfor
        endif

        ;;==Loop over time steps
        for it=0,nt-1 do begin

           ;;==Create image
           img = image(rotate(data[*,*,it],rotate_direction), $
                       /buffer, $
                       layout = layout[*,it], $
                       rgb_table = rgb_table, $
                       current = (it gt 0), $
                       axis_style = 2, $
                       title = title[it], $
                       font_size = font_size, $
                       font_name = font_name)
           if keyword_set(min_value) then img.min_value = min_value
           if keyword_set(max_value) then img.max_value = max_value

           ;;==Add a colorbar
           clr = colorbar(target = img, $
                          orientation = 1, $
                          textpos = 1, $
                          font_name = 'Times')
           clr.scale, 0.25,0.50
           clr.translate, -0.25,0.0,/normal

           ;;==Add path label
           txt = text(0.50,0.98,path, $
                      alignment = 0.5, $
                      target = img, $
                      font_name = font_name, $
                      font_size = font_size)

        endfor ;;-->Time steps

        ;;==Save the image
        image_save, img,filename = filepath+path_sep()+filename

     end
     else: print, "[BASIC_MULTI_IMAGE] Incorrect number of dimensions ("+ $
                  strcompress(n_dims,/remove_all)+ $
                  ", including time) to make an image."

  endcase ;;-->Dimensions

end
