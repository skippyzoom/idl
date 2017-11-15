;+
; Load a context dictionary with default values.
; The user can call this within a batch script, then
; pass the context to analyze_project.pro
;
; TO DO
; -- Allow user to query a particular parameter. That
;    option would allow set_context_default.pro to
;    remain consisent with this function.
;-
function load_default_context, path=path

  ;;==Create the dictionary
  context = dictionary()

  ;;==GENERAL
  context['description'] = ''
  if keyword_set(path) then begin
     context['path'] = path
     context['params'] = set_eppic_params(path)
     context['grid'] = set_grid(path)
     nt_max = calc_timesteps(path,context.grid)
     context.params['nt_max'] = nt_max
  endif

  ;;==DATA
  context['data'] = dictionary('name', list('den1','phi'), $
                               'type', ['ph5','ph5'], $
                               'transpose', [0,1,2,3], $
                               'ranges', [[0,1],[0,1],[0,1]], $
                               'scale', dictionary('den1', 1e2, $
                                                   'phi', 1e3, $
                                                   'emag', 1e3))
  n_names = context.data.name.count()

  ;;==GRAPHICS
  context['graphics'] = dictionary()
  context.graphics['desc'] = ''
  ;; context.graphics['class'] = dictionary(['space','kxyzt'])
  graphics_classes = ['space','kxyzt']
  context.graphics['name'] = dictionary(context.data.name.toarray())
  for ik=0,context.graphics.name.count()-1 do $
     context.graphics.name[ik] = list(graphics_classes)
  ;;==graphics/AXES
  context.graphics['axes'] = dictionary(['x','y','z'])
  ;; context.graphics.axes['xtitle'] = $
  ;;    dictionary(context.graphics.class.toarray(), ['x','$k_x$'])
  ;; context.graphics.axes['ytitle'] = $
  ;;    dictionary(context.graphics.class.toarray(), ['y','$k_y$'])
  context.graphics.axes.x['title'] = $
     dictionary(graphics_classes, ['x','$k_x$'])
  context.graphics.axes.y['title'] = $
     dictionary(graphics_classes, ['y','$k_y$'])
  context.graphics.axes.z['title'] = $
     dictionary(graphics_classes, ['z','$k_z$'])
  ;;==graphics/RGB_TABLE
  context.graphics['rgb_table'] = dictionary(context.data.name.toarray(), $
                                             make_array(n_names,value=0))
  context.graphics.rgb_table['fft'] = 0
  ;;==graphics/SMOOTH
  context.graphics.smooth = [1,1,1,1]
  ;;==graphics/IMAGE
  context.graphics['image'] = dictionary('type', '.png')
  ;;==graphics/MOVIE
  context.graphics['movie'] = dictionary('type', '.mp4', $
                                         'make', 0B, $
                                         'timestamps', 0B, $
                                         'expand', 1.0, $
                                         'rescale', 0.1)
  ;;==graphics/COLORBAR
  context.graphics['colorbar'] = dictionary('type', 'global')

  ;;==PANEL
  context['panel'] = dictionary('index', [0,1], $
                                'layout', [2,2], $
                                'show', 1B)

  return, context
end
