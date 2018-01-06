;+
; Graphics output for an EPPIC run.
; This routine contains more complicated
; analysis than eppic_basic.pro, and may
; expand or contract as necessary.
;
; Created on 18Dec2017 (may)
;-
pro eppic_full, path=path, $
                directory=directory, $
                target=target

  ;;==Defaults and guards
  ;; if n_elements(target) eq 1 && strcmp(target,'all',3) then $
  ;;    target = ['moments','emag','phi','den0','den1','denft0','denft1']

  ;;==Navigate to working directory
  if n_elements(path) eq 0 then path = './'
  cd, path

  ;;==Echo working directory
  print, "[EPPIC_FULL] In ",path

  ;;==Set up global graphics options
  font_name = 'Times'
  font_size = 10

  ;;==Make sure the graphics directory exists
  if n_elements(directory) eq 0 then directory = './'
  spawn, 'mkdir -p '+directory
  filepath = expand_path(path+path_sep()+directory)

  ;;==Read in simulation parameters
  params = set_eppic_params(path=path)
  grid = set_grid(path=path)
  nt_max = calc_timesteps(path=path,grid=grid)

                                ;-------------------------------;
                                ; 1-D plots of velocity moments ;
                                ;-------------------------------;
  if keyword_set(moments) then begin

     ;;==Read in data
     moments = analyze_moments(path=path)

     ;;==Create plots
     plot_moments, moments,params=params, $
                   path=filepath, $
                   font_name=font_name,font_size=font_size

  endif

                                ;--------------------;
                                ; 2-D images of data ;
                                ;--------------------;

  ;;==Choose time steps for images
  nt = 9
  timestep = params.nout*(nt_max/(nt-1))*lindgen(nt)
  layout = [3,3]

  ;;==Set global graphics preferences
  axis_style = 2

  ;;==Create a list of 2-D planes for 3-D data
  planes = ['yz']               ;DEV
  n_planes = n_elements(planes)

  ;;==Declare panel positions for spatial data
  position = multi_position(layout[*], $
                            edges = [0.12,0.10,0.80,0.80], $
                            buffer = [0.00,0.10])

  ;;==Declare data ranges for spatial data
  rngs = [[0,grid.nx-1], $
            [grid.ny/2,grid.ny-1], $
            [0,grid.nz-1]]
  ctrs = [grid.nx/2,grid.ny/2,grid.nz/2]
  vecs = {x:grid.x, y:grid.y, z:grid.z}
  xyz = [1,0,2]

  ;;==Pack info dictionary
  info = dictionary()
  info['xrng'] = rngs[*,xyz[0]]
  info['yrng'] = rngs[*,xyz[1]]
  info['zrng'] = rngs[*,xyz[2]]
  info['xctr'] = ctrs[xyz[0]]
  info['yctr'] = ctrs[xyz[1]]
  info['zctr'] = ctrs[xyz[2]]
  info['xvec'] = vecs.(xyz[0])
  info['yvec'] = vecs.(xyz[1])
  info['zvec'] = vecs.(xyz[2])
  info['xyz'] = xyz
  info['params'] = params
  info['position'] = position
  info['font_name'] = font_name
  info['path'] = path
  info['filepath'] = filepath
  info['planes'] = planes
  info['timestep'] = timestep

  ;-->Ignore target for now. Make all images. (DEV)

  ;;==Create images of electrostatic potential
  eppic_phi_images, info

IF 0 THEN BEGIN
  ;;==Create images of density
  if string_exist(target,'den',3) then begin
     rgb_table = 5
     n_dist = params.ndist
     for id=0,n_dist-1 do begin
        dist_name = 'dist'+strcompress(id,/remove_all)
        if ~keyword_set(den_exists) then begin
           data_name = 'den'+strcompress(id,/remove_all)
           data = (load_eppic_data(data_name,path=path,timestep=timestep))[data_name]
           ;; den_exists = 1B
        endif
        for ip=0,n_planes-1 do begin
           case 1B of
              strcmp(planes[ip],'xy'): begin
                 imgdata = data[xrng[0]:xrng[1],yrng[0]:yrng[1],zctr,*]
                 xdata = grid.x[xrng[0]:xrng[1]]
                 ydata = grid.y[yrng[0]:yrng[1]]
                 grad_dx = grid.dx
                 grad_dy = grid.dy
              end
              strcmp(planes[ip],'xz'): begin
                 imgdata = data[xrng[0]:xrng[1],yctr,zrng[0]:zrng[1],*]
                 xdata = grid.x[xrng[0]:xrng[1]]
                 ydata = grid.z[zrng[0]:zrng[1]]
                 grad_dx = grid.dx
                 grad_dy = grid.dz
              end
              strcmp(planes[ip],'yz'): begin
                 imgdata = data[xctr,yrng[0]:yrng[1],zrng[0]:zrng[1],*]
                 ydata = grid.y[yrng[0]:yrng[1]]
                 xdata = grid.z[zrng[0]:zrng[1]]
                 grad_dx = grid.dy
                 grad_dy = grid.dz
              end
           endcase
           imgdata = reform(imgdata)
           min_value = -max(abs(imgdata))
           max_value = +max(abs(imgdata))
           img = multi_image(imgdata,xdata,ydata, $
                             position = position, $
                             axis_style = axis_style, $
                             rgb_table = rgb_table, $
                             min_value = min_value, $
                             max_value = max_value)
           img = multi_colorbar(img,'global', $
                                width = 0.0225, $
                                height = 0.40, $
                                buffer = 0.03, $
                                orientation = 1, $
                                textpos = 1, $
                                tickdir = 1, $
                                ticklen = 0.2, $
                                major = 7, $
                                font_name = font_name, $
                                font_size = 8.0)
           txt = text(0.00,0.05,path, $
                      alignment = 0.0, $
                      target = img, $
                      font_name = font_name, $
                      font_size = 5.0)
           filename = data_name+'_'+planes[ip]+'.pdf'
           image_save, img[0],filename=filepath+path_sep()+filename
        endfor ;;n_planes
        data = !NULL
     endfor ;;n_dist
  endif ;;den

  ;;==Declare panel positions for spectral data
  position = multi_position(layout[*], $
                            edges = [0.12,0.10,0.80,0.80], $
                            buffer = [0.10,0.10])

  ;;==Declare data ranges for spectral data
  xrng = [0,grid.nx*params.nout_avg-1]
  yrng = [0,grid.ny*params.nout_avg-1]
  zrng = [0,grid.nz*params.nout_avg-1]
  xctr = 0
  yctr = 0
  zctr = 0

  ;;==Create images of Fourier-transformed density
  if string_exists(target,'denft') then begin
     rgb_table = 39
     n_dist = params.ndist
     for id=0,n_dist-1 do begin
        dist_name = 'dist'+strcompress(id,/remove_all)
        if ~keyword_set(denft_exists) then begin
           data_name = 'denft'+strcompress(id,/remove_all)
           data = (load_eppic_data(data_name,path=path,timestep=timestep))[data_name]
           ;; denft_exists = 1B
        endif
        for ip=0,n_planes-1 do begin
           case 1B of
              strcmp(planes[ip],'xy'): begin
                 imgdata = data[xrng[0]:xrng[1],yrng[0]:yrng[1],zctr,*]
                 len = grid.nx*params.nout_avg
                 tmp = findgen(len)-0.5*len
                 xdata = (2*!pi/(grid.dx*len))*tmp[xrng[0]:xrng[1]]
                 len = grid.ny*params.nout_avg
                 tmp = findgen(len)-0.5*len
                 ydata = (2*!pi/(grid.dy*len))*tmp[yrng[0]:yrng[1]]
              end
              strcmp(planes[ip],'xz'): begin
                 imgdata = data[xrng[0]:xrng[1],yctr,zrng[0]:zrng[1],*]
                 len = grid.nx*params.nout_avg
                 tmp = findgen(len)-0.5*len
                 xdata = (2*!pi/(grid.dx*len))*tmp[xrng[0]:xrng[1]]
                 len = grid.nz*params.nout_avg
                 tmp = findgen(len)-0.5*len
                 ydata = (2*!pi/(grid.dz*len))*tmp[zrng[0]:zrng[1]]
              end
              strcmp(planes[ip],'yz'): begin
                 imgdata = data[xctr,yrng[0]:yrng[1],zrng[0]:zrng[1],*]
                 len = grid.ny*params.nout_avg
                 tmp = findgen(len)-0.5*len
                 xdata = (2*!pi/(grid.dy*len))*tmp[yrng[0]:yrng[1]]
                 len = grid.nz*params.nout_avg
                 tmp = findgen(len)-0.5*len
                 ydata = (2*!pi/(grid.dz*len))*tmp[zrng[0]:zrng[1]]
              end              
           endcase
           tmp = !NULL
           len = !NULL
           imgdata = reform(imgdata)
           imgdata = real_part(imgdata)
           imgdata = 10*alog10((imgdata/max(imgdata))^2)
           imgsize = size(imgdata,/dim)
           imgdata = shift(imgdata,imgsize[0]/2,imgsize[1]/2,0)
           min_value = min(imgdata,/nan)
           max_value = max(imgdata,/nan)
           ;; min_value = -40
           ;; max_value = 0
           img = multi_image(imgdata,xdata,ydata, $
                             ;; xrange = [-2*!pi,2*!pi], $
                             ;; yrange = [0,2*!pi], $
                             position = position, $
                             axis_style = axis_style, $
                             rgb_table = rgb_table, $
                             min_value = min_value, $
                             max_value = max_value)
           img = multi_colorbar(img,'global', $
                                width = 0.0225, $
                                height = 0.40, $
                                buffer = 0.03, $
                                orientation = 1, $
                                textpos = 1, $
                                tickdir = 1, $
                                ticklen = 0.2, $
                                major = 7, $
                                font_name = font_name, $
                                font_size = 8.0)
           txt = text(0.00,0.05,path, $
                      alignment = 0.0, $
                      target = img, $
                      font_name = font_name, $
                      font_size = 5.0)
           filename = data_name+'_'+planes[ip]+'.pdf'
           image_save, img[0],filename=filepath+path_sep()+filename
        endfor ;;n_planes
        data = !NULL
     endfor ;;n_dist
  endif ;;denft

ENDIF ;SKIP

end
