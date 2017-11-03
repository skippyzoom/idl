;+
; Execute common analysis code on data in
; the specified path.
;
; TO DO
; -- Check for consistency between plot_layout and plot_index?
;    May be better to do that in graphics routines.
; -- Allow for single- or multi-plot images in plot_<index,layout>
;    defaults.
;-
pro analyze_project, path, $
                     target, $
                     verbose=verbose

  ;;==Defaults and guards
  if n_elements(target) eq 0 then target = dictionary('data')
  if ~target.haskey('data_name') then target.data_name = list('den1','phi')
  nNames = target.data_name.count()
  if ~target.haskey('data_type') then target.data_type = ['ph5','ph5']
  if ~target.haskey('img_type') then target.img_type = '.png'
  if ~target.haskey('mov_type') then target.mov_type = '.mp4'
  if ~target.haskey('make_movies') then target.make_movies = 0B
  if ~target.haskey('movie_timestamps') then target.movie_timestamps = 0B
  if ~target.haskey('movie_expand') then target.movie_expand = 1.0
  if ~target.haskey('movie_rescale') then target.movie_rescale = 1.0
  if ~target.haskey('colorbar_type') then target.colorbar_type = 'global'
  if ~target.haskey('plot_index') then target.plot_index = [0,1]
  if ~target.haskey('plot_layout') then target.plot_layout = [1,2]
  if ~target.haskey('rgb_table') then $
     target.rgb_table = dictionary(target.data_name.toarray(),make_array(nNames,value=0))

  ;;==Echo working path and store in project dictionary
  print, "ANALYZE_PROJECT: In ",path
  target['path'] = path

  ;;==Read the input file
  target['params'] = set_eppic_params(path)

  ;;==Assign grid to project
  target['grid'] = set_grid(path)

  ;;==Calculate max number of time steps available
  nt_max = calc_timesteps(path,target.grid)
  target.params['nt_max'] = nt_max

  ;;==Set up graphics output steps
  temp = floor(target.plot_index*nt_max)
  ge_max = where(temp ge nt_max,count)
  if count gt 0 then temp[ge_max] = nt_max-1
  target['plot_index'] = temp

  ;;==Load simulation data
  data = load_eppic_data(target.data_name.toarray(), $
                         target.data_type, $
                         path = target.path, $
                         timestep = target.params.nout*lindgen(nt_max))

  ;;==Pack up the project dictionary
  dKeys = data.keys()
  dSize = size(data[dKeys[0]])
  if target.haskey('transpose') then target['transpose'] = target.transpose[0:dSize[0]-1]
  target = set_project_data(data,target.grid,target=target[*])

  ;;==Set up appropriate units for graphics, based on target.scale
  set_data_units, target,target.params.units
  target['data_label'] = set_data_labels(target.data_name.toarray())

  ;;==Images of raw data
  project_data_graphics, target

  ;;==Images of spectrally transformed data
  ;; project_spectral_graphics, target

end
