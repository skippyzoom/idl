;+
; Basic graphics output for an EPPIC run.
; This routine is designed to provide the first
; look at a simulation run to asses parameter
; choices and to determine if the run is worthy
; or further analysis.
;
; Created on 11Dec2017 (may)
;-
pro eppic_basic, path,directory=directory

  ;;==Navigate to working directory
  cd, path

  ;;==Echo working directory
  print, "[EPPIC_BASIC] In ",path
  
  ;;==Set up global graphics options
  font_name = 'Times'
  font_size = 10

  ;;==Make sure the graphics directory exists
  if n_elements(directory) eq 0 then directory = './'
  spawn, 'mkdir -p '+directory
  filepath = path+path_sep()+directory

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



  ;;==Choose time steps for images
  nt = 9
  timestep = params.nout*(nt_max/(nt-1))*lindgen(nt)
  layout = [3,3]
                                ;--------------------;
                                ; 2-D images of data ;
                                ;--------------------;
  ;;==Create a dictionary of graphics options for each quantity
  data = hash()
  data['Potential'] = dictionary('name','phi', $
                                 'rgb_table', 5, $
                                 'min_value', -0.1, $
                                 'max_value', 0.1, $
                                 'origin', hash('yz',0), $
                                 'fft_direction', 0, $
                                 'rotate_direction', 0)
  data['Density (dist 0)'] = dictionary('name','den0', $
                                        'rgb_table', 5, $
                                        'min_value', -0.1, $
                                        'max_value', 0.1, $
                                        'origin', hash('yz',0), $
                                        'fft_direction', 0, $
                                        'rotate_direction', 0)
  data['Density (dist 1)'] = dictionary('name','den1', $
                                        'rgb_table', 5, $
                                        'min_value', -0.1, $
                                        'max_value', 0.1, $
                                        'origin', hash('yz',0), $
                                        'fft_direction', 0, $
                                        'rotate_direction', 0)
  data['FT Density (dist 0)'] = dictionary('name','denft0', $
                                           'rgb_table', 5, $
                                           'min_value', -0.1, $
                                           'max_value', 0.1, $
                                           'origin', hash('yz',0), $
                                           'fft_direction', 0, $
                                           'rotate_direction', 2)
  data['FT Density (dist 1)'] = dictionary('name','denft1', $
                                           'rgb_table', 5, $
                                           'min_value', -0.1, $
                                           'max_value', 0.1, $
                                           'origin', hash('yz',0), $
                                           'fft_direction', 0, $
                                           'rotate_direction', 2)
  d_keys = data.keys()

  ;;==Loop over data quantities
  for id=0,data.count()-1 do begin

     ;;==Extract current key
     ikey = d_keys[id]

     ;;==Get current data name
     data_name = data[ikey].name
     filename = data_name+'.pdf'

     ;;==Modify file name, if necessary
     if data[ikey].fft_direction gt 0 then filename = data_name+'_fwdFT.pdf'
     if data[ikey].fft_direction lt 0 then filename = data_name+'_invFT.pdf'

     ;;==Create images
     basic_multi_image, data_name, $
                        timestep = timestep, $
                        rgb_table = data[ikey].rgb_table, $
                        min_value = data[ikey].min_value, $
                        max_value = data[ikey].max_value, $
                        fft_direction = data[ikey].fft_direction, $
                        rotate_direction = data[ikey].rotate_direction, $
                        layout = layout, $
                        font_size = font_size, $
                        font_name = font_name, $
                        origin = data[ikey].origin, $
                        path = path, $
                        filepath = filepath, $
                        filename = filename
  endfor

end
