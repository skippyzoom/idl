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
                log=log

  ;;==Navigate to working directory
  if n_elements(path) eq 0 then path = './'
  cd, path

  ;;==Open a log file
  if keyword_set(log) then begin
     if isa(log,/number) then log = 'eppic_full.log'
     openw, wlun,path+log,/get_lun
  endif $
  else wlun = -1

  ;;==Echo working directory
  printf, wlun,"[EPPIC_FULL] In ",path

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
  ;;==Read in data
  moments = analyze_moments(path=path)

  ;;==Create plots
  plot_moments, moments,params=params, $
                path=filepath, $
                font_name=font_name,font_size=font_size

                                ;----------------------------;
                                ; 2-D images of spatial data ;
                                ;----------------------------;

  ;;==Choose time steps for images
  ;; nt = 9
  ;; timestep = params.nout*(nt_max/(nt-1))*lindgen(nt)
  ;; layout = [3,3]
  ;; timestep = params.nout*[1,nt_max/4,nt_max/2,3*nt_max/4,nt_max-1]
  ;; timestep = params.nout*[nt_max/2,nt_max-1]
  tmp_nt_max = 143
  timestep = params.nout*[0,tmp_nt_max/2,tmp_nt_max-1]
  nt = n_elements(timestep)
  layout = [1,nt]
  string_time = string(1e3*params.dt*timestep,format='(f8.2)')
  string_time = "t = "+strcompress(string_time,/remove_all)+" ms"

  ;;==Set global graphics preferences
  axis_style = 2

  ;;==Create a list of 2-D planes for 3-D data
  if params.ndim_space eq 3 then planes = ['xy','xz','yz'] $
  else planes = 'xy'

  ;;==Declare the plane perpendicular to B
  perp_to_B = 'xy'
  ;; perp_to_B = 'yz'

  ;==Build unrotated, untransposed E0 vector
  E0 = dictionary('x',params.Ex0_external, $
                  'y',params.Ey0_external, $
                  'z',params.Ez0_external)

  ;;==Declare rotation direction for images
  rot = dictionary('xy',270, $
                   'xz',  0, $
                   'yz',  0)
  ;; rot = dictionary('xy',0, $
  ;;                  'xz',0, $
  ;;                  'yz',0)

  ;;==Choose EPPIC spatial output quantities to analyze
  ;; data_names = list('phi','den0','den1')
  data_names = list('den1')

  ;;==Declare panel positions for spatial data
  position = multi_position(layout[*], $
                            edges = [0.12,0.10,0.80,0.80], $
                            buffer = [0.00,0.10])

  ;;==Declare data ranges for spatial data image panels
  ranges = {x:[0,grid.nx-1], $
            ;; y:[grid.ny/2,grid.ny-1], $
            y:[0,grid.ny-1], $
            z:[0,grid.nz-1]}
  center = {x:grid.nx/2, $
            y:grid.ny/2, $
            z:grid.nz/2}
  vectors = {x:grid.x, $
             y:grid.y, $
             z:grid.z}

  ;;==Build info dictionary
  info = dictionary()
  info['wlun'] = wlun
  info['ranges'] = ranges
  info['center'] = center
  info['vectors'] = vectors
  info['rot'] = rot
  info['perp_to_B'] = perp_to_B
  info['E0'] = E0
  info['params'] = params
  info['grid'] = grid
  info['moments'] = moments
  info['position'] = position
  info['layout'] = layout
  info['font_name'] = font_name
  info['font_size'] = font_size
  info['axis_style'] = 2
  info['path'] = path
  info['filepath'] = filepath
  info['datapath'] = expand_path(info.path+path_sep()+'parallel')
  info['datatest'] = 'parallel000000.h5'
  info['planes'] = planes
  info['timestep'] = timestep
  info['nt_max'] = nt_max
  info['title'] = string_time
  info['data_names'] = data_names
  info['data_context'] = 'spatial'
  info['flexible_data'] = 1B
  info['graphics_context'] = 'spatial'
  info['movies'] = 0B

  ;;==Create images from spatial data
  ;; eppic_spatial_analysis, info

  ;;==Create movies from spatial data
  ;; eppic_spatial_analysis, info,/movies

  ;; ;;-->DEV
  ;; eppic_graphics, info

                                ;-----------------------------;
                                ; 2-D images of spectral data ;
                                ;-----------------------------;

  ;;==Choose EPPIC spectral output quantities to analyze
  ;; data_names = list('den0','den1')
  force_spatial_data = 1B

  ;;==Declare panel positions for spectral data
  position = multi_position(layout[*], $
                            edges = [0.12,0.10,0.80,0.80], $
                            buffer = [0.0,0.2])

  ;;==Declare data ranges for spectral data
  ranges = {x:[0,grid.nx*params.nout_avg-1], $
            y:[0,grid.ny*params.nout_avg-1], $
            z:[0,grid.nz*params.nout_avg-1]}
  center = {x:0, $
            y:0, $
            z:0}
  vectors = {x:grid.x, $
             y:grid.y, $
             z:grid.z}

  ;;==Update info dictionary
  info['ranges'] = ranges
  info['center'] = center
  info['vectors'] = vectors
  info['position'] = position
  info['data_names'] = data_names
  info['dc_width'] = 8
  info['missing'] = -1e10
  info['data_context'] = 'spectral'
  info['graphics_context'] = 'spectral'
  info['full_transform'] = 1B
  ;; info['force_spatial_data'] = 0B
  ;; info['force_spectral_data'] = 0B

  ;;-->DEV
  eppic_graphics, info

  ;;==Create images from spectral data
  ;; eppic_spectral_analysis, info, $
  ;;                          force_spatial_data=force_spatial_data

  ;;==Create images from spectral data
  ;; eppic_spectral_analysis, info, $
  ;;                          force_spatial_data=force_spatial_data, $
  ;;                          /full_transform

  ;;==Create movies from spectral data
  ;; eppic_spectral_analysis, info, $
  ;;                          /movies

  ;;==Print closing message
  printf, wlun,"[EPPIC_FULL] Finished"

  ;;==Add a newline after each run
  printf, wlun," "

  ;;==Close log file
  if keyword_set(log) then begin
     close, wlun
     free_lun, wlun
  endif

end
