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
                     context, $
                     verbose=verbose

  ;;==Defaults and guards
  if n_elements(context) eq 0 then context = dictionary('data')
  if ~context.haskey('data_name') then context.data_name = list('den1','phi')
  nNames = context.data_name.count()
  if ~context.haskey('data_type') then context.data_type = ['ph5','ph5']
  if ~context.haskey('img_type') then context.img_type = '.png'
  if ~context.haskey('mov_type') then context.mov_type = '.mp4'
  if ~context.haskey('make_movies') then context.make_movies = 0B
  if ~context.haskey('movie_timestamps') then context.movie_timestamps = 0B
  if ~context.haskey('movie_expand') then context.movie_expand = 1.0
  if ~context.haskey('movie_rescale') then context.movie_rescale = 1.0
  if ~context.haskey('colorbar_type') then context.colorbar_type = 'global'
  if ~context.haskey('plot_index') then context.plot_index = [0,1]
  if ~context.haskey('plot_layout') then context.plot_layout = [1,2]
  if ~context.haskey('rgb_table') then $
     context.rgb_table = dictionary(context.data_name.toarray(),make_array(nNames,value=0))

  ;;==Echo working path and store in project dictionary
  print, "ANALYZE_PROJECT: In ",path
  context['path'] = path

  ;;==Read the input file
  context['params'] = set_eppic_params(path)

  ;;==Assign grid to project
  context['grid'] = set_grid(path)

  ;;==Calculate max number of time steps available
  nt_max = calc_timesteps(path,context.grid)
  context.params['nt_max'] = nt_max

  ;;==Set up graphics output steps
  temp = floor(context.plot_index*nt_max)
  ge_max = where(temp ge nt_max,count)
  if count gt 0 then temp[ge_max] = nt_max-1
  context['plot_index'] = temp

  ;;==Load simulation data
  data = load_eppic_data(context.data_name.toarray(), $
                         context.data_type, $
                         path = context.path, $
                         timestep = context.params.nout*lindgen(nt_max))

  ;;==Pack up the project dictionary
  dKeys = data.keys()
  dSize = size(data[dKeys[0]])
  if context.haskey('transpose') then context['transpose'] = context.transpose[0:dSize[0]-1]
  context = set_project_data(data,context.grid,context=context[*])

  ;;==Set up appropriate units for graphics, based on context.scale
  set_data_units, context,context.params.units
  context['data_label'] = set_data_labels(context.data_name.toarray())

  ;; ;;==Images of raw data
  ;; project_spatial_graphics, context

  ;; ;;==Images of spectrally transformed data
  ;; project_spectral_graphics, context

  ;;==All images
  project_graphics, context

end
