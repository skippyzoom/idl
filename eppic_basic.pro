;+
; Basic graphics output for an EPPIC run.
; This routine is designed to provide the first
; look at a simulation run to asses parameter
; choices and to determine if the run is worthy
; or further analysis.
;
; Created on 11Dec2017 (may)
;-
pro eppic_basic, path=path, $
                 directory=directory, $
                 moments=moments, $
                 phi=phi, $
                 dens=den, $
                 denft=denft, $
                 all=all

  ;;==Defaults and guards
  if keyword_set(all) then begin
     moments = 1B
     phi = 1B
     dens = 1B
     denft = 1B
  endif

  ;;==Navigate to working directory
  if n_elements(path) eq 0 then path = './'
  cd, path

  ;;==Echo working directory
  print, "[EPPIC_BASIC] In ",path
  
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

  ;;==Choose time steps for images
  nt = 9
  timestep = params.nout*(nt_max/(nt-1))*lindgen(nt)
  layout = [3,3]
                                ;--------------------;
                                ; 2-D images of data ;
                                ;--------------------;

  ;;==Create a dictionary of graphics options for each quantity
  data = hash()

  ;;==Electrostatic potential
  if keyword_set(phi) then begin
     data['Potential'] = dictionary('name','phi', $
                                    'rgb_table', 5, $
                                    'min_value', -0.1, $
                                    'max_value', 0.1, $
                                    'origin', hash('yz',0), $
                                    'fft_direction', 0, $
                                    'rotate_direction', 0)
  endif

  ;;==Densities
  if keyword_set(den) then begin
     for id=0,params.ndist-1 do begin
        dist = strcompress(id,/remove_all)
        data['Density (dist '+dist+')'] = dictionary('name','den'+dist, $
                                                     'rgb_table', 5, $
                                                     'min_value', -0.1, $
                                                     'max_value', 0.1, $
                                                     'origin', hash('yz',0), $
                                                     'fft_direction', 0, $
                                                     'rotate_direction', 0)
     endfor
  endif

  ;;==Fourier-transformed densities
  if keyword_set(denft) then begin
     for id=0,params.ndist-1 do begin
        dist = strcompress(id,/remove_all)
        data['FT Density (dist '+dist+')'] = dictionary('name','denft'+dist, $
                                                        'rgb_table', 5, $
                                                        'min_value', -0.1, $
                                                        'max_value', 0.1, $
                                                        'origin', hash('yz',0), $
                                                        'fft_direction', 0, $
                                                        'rotate_direction', 2)
     endfor
  endif

  ;;==Get an array of keys into the data hash
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
