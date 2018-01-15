;+
; Graphics output for an EPPIC run.
; This routine contains more complicated
; analysis than eppic_basic.pro, and may
; expand or contract as necessary.
;
; Created on 18Dec2017 (may)
;-
pro eppic_full, path=path, $
                directory=directory

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
  nt = 9
  timestep = params.nout*(nt_max/(nt-1))*lindgen(nt)
  layout = [3,3]
  string_time = string(1e3*params.dt*timestep,format='(f8.2)')
  string_time = "t = "+strcompress(string_time,/remove_all)+" ms"

  ;;==Set global graphics preferences
  axis_style = 2

  ;;==Create a list of 2-D planes for 3-D data
  planes = ['xy','xz','yz']

  ;;==Declare transpose for images
  xyz = [1,0,2]

  ;;==Choose EPPIC spatial output quantities to analyze
  data_names = list('phi','den0','den1')

  ;;==Declare panel positions for spatial data
  position = multi_position(layout[*], $
                            edges = [0.12,0.10,0.80,0.80], $
                            buffer = [0.00,0.10])

  ;;==Declare data ranges for spatial data image panels
  rngs = [[0,grid.nx-1], $
          [grid.ny/2,grid.ny-1], $
          [0,grid.nz-1]]
  ctrs = [grid.nx/2,grid.ny/2,grid.nz/2]
  vecs = {x:grid.x, y:grid.y, z:grid.z}

  ;;==Pack spatial-data info
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
  info['layout'] = layout
  info['font_name'] = font_name
  info['axis_style'] = 2
  info['path'] = path
  info['filepath'] = filepath
  info['planes'] = planes
  info['timestep'] = timestep
  info['title'] = string_time
  info['data_names'] = data_names

  ;;==Create images from spatial data
  eppic_spatial_analysis, info,movies=0B

                                ;-----------------------------;
                                ; 2-D images of spectral data ;
                                ;-----------------------------;

  ;;==Choose EPPIC spectral output quantities to analyze
  ;; data_names = list('denft0','denft1')
  data_names = list('denft1')

  ;;==Declare panel positions for spectral data
  position = multi_position(layout[*], $
                            edges = [0.12,0.10,0.80,0.80], $
                            buffer = [0.10,0.10])

  ;;==Declare data ranges for spectral data
  rngs = [[0,grid.nx*params.nout_avg-1], $
          [0,grid.ny*params.nout_avg-1], $
          [0,grid.nz*params.nout_avg-1]]
  ctrs = [0,0,0]
  vecs = {x:grid.x, y:grid.y, z:grid.z}
  difs = [params.dx,params.dy,params.dz]

  ;;==Pack spectral-data info
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
  info['xdif'] = difs[xyz[0]]
  info['ydif'] = difs[xyz[1]]
  info['zdif'] = difs[xyz[2]]
  info['xyz'] = xyz
  info['params'] = params
  info['grid'] = grid
  info['position'] = position
  info['layout'] = layout
  info['font_name'] = font_name
  info['axis_style'] = 2
  info['path'] = path
  info['filepath'] = filepath
  info['planes'] = planes
  info['timestep'] = timestep
  info['title'] = string_time
  info['data_names'] = data_names

  ;;==Create images from spectral data
  eppic_spectral_analysis, info

end
