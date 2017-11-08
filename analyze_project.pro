;+
; Execute common analysis code on data in
; the specified path.
;
; TO DO
; -- Check for consistency between panel.layout and panel.index?
;    May be better to do that in graphics routines.
; -- Allow for single- or multi-plot images in panel.<index,layout>
;    defaults.
;-
pro analyze_project, path, $
                     context, $
                     verbose=verbose

  ;;==Defaults and guards
  if n_elements(context) eq 0 then context = dictionary('data')
  ;; if ~context.haskey('data_name') then context.data_name = list('den1','phi')
  ;; n_names = context.data_name.count()
  ;; if ~context.haskey('data_type') then context.data_type = ['ph5','ph5']
  n_names = context.data.name.count()
  if ~context.data.haskey('name') then context.data.name = list('den1','phi')
  if ~context.data.haskey('type') then context.data.type = ['ph5','ph5']
  if ~context.haskey('image') then $
     context.image = dictionary('type', '.png', $
                                'desc', '')
  if ~context.image.haskey('type') then context.image.type = '.png'
  if ~context.haskey('movie') then $
     context.movie = dictionary('type', '.mp4', $
                                'desc', '', $
                                'make', 0B, $
                                'timestamps', 0B, $
                                'expand', 1.0, $
                                'rescale', 1.0)
  if ~context.movie.haskey('type') then context.movie.type = '.mp4'
  if ~context.movie.haskey('desc') then context.movie.desc = ''
  if ~context.movie.haskey('make') then context.movie.make = 0B
  if ~context.movie.haskey('timestamps') then context.movie.timestamps = 0B
  if ~context.movie.haskey('expand') then context.movie.expand = 1.0
  if ~context.movie.haskey('rescale') then context.movie.rescale = 1.0
  if ~context.haskey('colorbar') then $
     context.colorbar = dictionary('type', 'global')
  if ~context.haskey('panel') then $
     context.panel = dictionary('index', [0,1], 'layout', [1,2], 'show', 1B)
  if ~context.panel.haskey('index') then context.panel.index = [0,1]
  if ~context.panel.haskey('layout') then context.panel.layout = [1,2]
  if ~context.panel.haskey('show') then context.panel.show = 0B
  if ~context.image.haskey('rgb_table') then $
     context.image.rgb_table = dictionary(context.data.name.toarray(),make_array(n_names,value=0))

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
  temp = floor(context.panel.index*nt_max)
  ge_max = where(temp ge nt_max,count)
  if count gt 0 then temp[ge_max] = nt_max-1
  context.panel['index'] = temp

  ;;==Load simulation data
  data = load_eppic_data(context.data.name.toarray(), $
                         context.data.type, $
                         path = context.path, $
                         timestep = context.params.nout*lindgen(nt_max))

  ;;==Pack up the project dictionary
  d_keys = data.keys()
  d_size = size(data[d_keys[0]])
  if context.haskey('transpose') then context['transpose'] = context.transpose[0:d_size[0]-1]
  context = set_project_data(data,context.grid,context=context[*])

  ;;==Set up appropriate units for graphics, based on context.scale
  set_data_units, context,context.params.units
  context.data['label'] = set_data_labels(context.data.name.toarray())

  ;; ;;==Images of raw data
  ;; project_spatial_graphics, context

  ;; ;;==Images of spectrally transformed data
  ;; project_spectral_graphics, context

  ;;==All images
  project_graphics, context

end
