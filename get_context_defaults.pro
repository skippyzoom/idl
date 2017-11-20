;+
; Load a context dictionary with default values.
; The user can call this within a batch script, then
; pass the context to analyze_project.pro.
;
; This function has two modes:
; 1) If the user does not supply request, this function will
;    return the default context dictionary.
; 2) If the user supplies request, this function will return
;    only the value of the requested parameter.
;
;
; Usage:
; Result = get_context_defaults([request[,pattern]][,path=path])
; Where
;   REQUEST is a string indicating the full "path" to a valid
;     key in the default context dictionary.
;   PATTERN is a string indicating the separator for levels in
;     the default context dictionary. See the IDL man page for 
;     strsplit.pro for further documentation.
;   PATH is a fully qualified path to the directory containing 
;     simulation run parameters. If the user doesn't supply a
;     path, the returned context will not contain fields that
;     require knowledge of run parameters.
;
; Examples:
; IDL> ctx = get_context_defaults()
;   Returns the default context dictionary, without run 
;   parameters.
; IDL> ctx = get_context_defaults(path='/path/to/params/')
;   Returns the default context dictionary, including 
;   parameters and parameter-dependent fields based on
;   the parameter file located in the directory 
;   '/path/to/params/'
; IDL> rgb = get_context_defaults('graphics.rgb_table','.')
;   Returns the dictionary of color table values contained
;   in the field context.graphics.rgb_table. Note that the
;   pattern '.' indicates that the user requested the value
;   of rgb_table, which is an element of the graphics 
;   dictionary.
;    
;    
;
; TO DO
;-
function get_context_defaults, request,pattern,path=path

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
                               'scale', dictionary('den1', 1.0, $
                                                   'phi', 1.0, $
                                                   'emag', 1.0))
  d_array = context.data.name.toarray()
  d_count = context.data.name.count()

  ;;==GRAPHICS
  graphics_classes = ['space','kxyzt']
  context['graphics'] = dictionary()
  context.graphics['note'] = ''
  context.graphics['class'] = dictionary(d_array)
  for ik=0,d_count-1 do $
     context.graphics.class[d_array[ik]] = graphics_classes
  context.graphics['axes'] = dictionary()
  if context.haskey('params') then begin
     context.graphics['plane'] = list('xy')
     if context.params.ndim_space eq 3 then begin
        context.graphics.plane.add, 'xz'
        context.graphics.plane.add, 'yz'
     endif
  endif
  context.graphics['rgb_table'] = dictionary(context.data.name.toarray(), $
                                             make_array(d_count,value=0))
  context.graphics.smooth = [1,1,1,1]
  ;;==graphics/AXES
  context.graphics.axes['x'] = dictionary('title', dictionary(), 'show', 0B)
  context.graphics.axes['y'] = dictionary('title', dictionary(), 'show', 0B)
  context.graphics.axes['z'] = dictionary('title', dictionary(), 'show', 0B)
  ;;==graphics/axes/[X,Y,Z]
  context.graphics.axes.x['title'] = dictionary(graphics_classes, ['x','$k_x$'])
  context.graphics.axes.y['title'] = dictionary(graphics_classes, ['y','$k_y$'])
  context.graphics.axes.z['title'] = dictionary(graphics_classes, ['z','$k_z$'])
  ;;==graphics/RGB_TABLE
  context.graphics.rgb_table['fft'] = 0
  ;;==graphics/SMOOTH
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
  context['panel'] = dictionary()
  context.panel['index'] = dictionary('value', [0,1], 'type', 'rel')
  if context.haskey('params') then begin
     context.panel['layout'] = dictionary('xy', [2,1])
     if context.params.ndim_space eq 3 then begin
        context.panel.layout['xz'] = [2,1]
        context.panel.layout['yz'] = [2,1]
     endif
  endif

  if n_elements(request) eq 0 then return, context $
  else begin
     if n_elements(pattern) eq 0 then $
        reqkeys = strsplit(request,/extract,count=nk) $
     else $
        reqkeys = strsplit(request,pattern,/extract,count=nk)
     target = context[reqkeys[0]]
     for ik=1,nk-1 do target = target[reqkeys[ik]]
     return, target
  endelse
end
