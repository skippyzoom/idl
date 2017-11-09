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
  ;; ;;--data
  ;; if n_elements(context) eq 0 then context = dictionary('data',dictionary())
  ;; if ~context.data.haskey('name') then context.data.name = list('den1','phi')
  ;; n_names = context.data.name.count()
  ;; if ~context.data.haskey('type') then context.data.type = ['ph5','ph5']
  ;; ;;--graphics
  ;; if ~context.haskey('graphics') then $
  ;;    context.graphics = dictionary('image', dictionary(), $
  ;;                                  'movie', dictionary(), $
  ;;                                  'colorbar', dictionary())
  ;; if ~context.graphics.haskey('desc') then context.graphics.desc = ''
  ;; if ~context.graphics.haskey('rgb_table') then $
  ;;    context.graphics.rgb_table = dictionary(context.data.name.toarray(), $
  ;;                                            make_array(n_names,value=0))
  ;; if ~context.graphics.haskey('class') then $
  ;;    context.graphics.class = dictionary()
  ;; ;;--graphics/image
  ;; if ~context.graphics.haskey('image') then $
  ;;    context.graphics.image = dictionary('type', '.png')
  ;; if ~context.graphics.image.haskey('type') then context.graphics.image.type = '.png'
  ;; ;;--graphics/movie
  ;; if ~context.graphics.haskey('movie') then $
  ;;    context.graphics.movie = dictionary('type', '.mp4', $
  ;;                                        'make', 0B, $
  ;;                                        'timestamps', 0B, $
  ;;                                        'expand', 1.0, $
  ;;                                        'rescale', 1.0)
  ;; if ~context.graphics.movie.haskey('type') then context.graphics.movie.type = '.mp4'
  ;; if ~context.graphics.movie.haskey('make') then context.graphics.movie.make = 0B
  ;; if ~context.graphics.movie.haskey('timestamps') then context.graphics.movie.timestamps = 0B
  ;; if ~context.graphics.movie.haskey('expand') then context.graphics.movie.expand = 1.0
  ;; if ~context.graphics.movie.haskey('rescale') then context.graphics.movie.rescale = 1.0
  ;; ;;--graphics/colorbar
  ;; if ~context.graphics.haskey('colorbar') then $
  ;;    context.colorbar = dictionary('type', 'global')
  ;; if ~context.graphics.colorbar.haskey('type') then context.graphics.colorbar.type = 'global'
  ;; ;;--panel
  ;; if ~context.haskey('panel') then $
  ;;    context.panel = dictionary('index', [0,1], 'layout', [1,2], 'show', 1B)
  ;; if ~context.panel.haskey('index') then context.panel.index = [0,1]
  ;; if ~context.panel.haskey('layout') then context.panel.layout = [1,2]
  ;; if ~context.panel.haskey('show') then context.panel.show = 0B
  if n_elements(context) eq 0 then context = load_default_context() $
  else set_context_defaults, context

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
