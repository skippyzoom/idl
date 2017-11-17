;+
; Provide default values for missing parameters in
; a user-supplied project context.
;-
pro set_context_defaults, context

  ;;==Check for proper input
  if n_elements(context) eq 0 then $
     message, "Must supply project-context dictionary" $
  else begin
     if ~strcmp(typename(context),'DICTIONARY') then $
        message, "Project context must be a dictionary"

     ;;==GENERAL
     if ~context.haskey('description') then $
        context.description = ''
     spawn, 'pwd',wd
     if ~context.haskey('path') then context.path = wd
     if ~context.haskey('params') then $
        context['params'] = set_eppic_params(context.path)
     if ~context.haskey('grid') then $
        context['grid'] = set_grid(context.path)
     if ~context.params.haskey('nt_max') then begin
        nt_max = calc_timesteps(context.path,context.grid)
        context.params['nt_max'] = nt_max
     endif

     ;;==DATA
     if ~context.haskey('data') then context.data = dictionary()
     if ~context.data.haskey('name') then $
        context.data.name = list('den1','phi')
     if ~context.data.haskey('type') then $
        context.data.type = ['ph5','ph5']
     d_array = context.data.name.toarray()
     d_count = context.data.name.count()

     ;;==GRAPHICS
     graphics_classes = ['space','kxyzt']
     if ~context.haskey('graphics') then context.graphics = dictionary()
     if ~context.graphics.haskey('note') then context.graphics.note = ''
     ;; if ~context.graphics.haskey('name') then begin
     ;;    context.graphics.name = dictionary(context.data.name.toarray())
     ;;    name_list = context.graphics.name.keys()
     ;;    for ik=0,context.graphics.name.count()-1 do $
     ;;       context.graphics.name[name_list[ik]] = list(graphics_classes)
     ;; endif
     if ~context.graphics.haskey('class') then begin
        context.graphics.class = dictionary(d_array)
        for id=0,d_count-1 do $
           context.graphics.class[d_array[id]] = graphics_classes
     endif
     if ~context.graphics.haskey('axes') then $
        context.graphics.axes = dictionary('x', dictionary(), $
                                           'y', dictionary(), $
                                           'z', dictionary())
     ;; if ~context.graphics.axes.y['title'] then $
     ;;    context.graphics.axes.y.title = dictionary(graphics_classes, ['y','$k_y$'])


     if ~context.graphics.haskey('rgb_table') then $
        context.graphics.rgb_table = dictionary(d_array, make_array(d_count,value=0)) $
     else begin
        for id=0,d_count-1 do begin
           if ~context.graphics.rgb_table.haskey(context.data.name[id]) then $
              context.graphics.rgb_table[name[id]] = 0
        endfor
     endelse
     if ~context.graphics.rgb_table.haskey('fft') then $
        context.graphics.rgb_table.fft = 0
     if ~context.graphics.haskey('smooth') then $
        context.graphics.smooth = [1,1,1,1]
     case n_elements(context.graphics.smooth) of 
        1: begin
           temp = context.graphics.smooth
           context.graphics.remove, 'smooth'
           context.graphics['smooth'] = make_array(context.params.ndim_space,value=temp)
        end
        4: ;Do nothing
        else: begin 
           print, "SET_CONTEXT_DEFAULTS: Smoothing width may be a scalar value or 4-D array"
           print, "                      with a smoothing width for each of x, y, z, and t."
           print, "                      Setting context.graphics.smooth = [1,1,1,1]"
           context.graphics.smooth = [1,1,1,1]
        end
     endcase
     if ~context.graphics.haskey('image') then $
        context.graphics.image = dictionary()
     if ~context.graphics.image.haskey('type') then context.graphics.image.type = '.png'
     if ~context.graphics.haskey('movie') then $
        context.graphics.movie = dictionary()
     if ~context.graphics.movie.haskey('type') then context.graphics.movie.type = '.mp4'
     if ~context.graphics.movie.haskey('make') then context.graphics.movie.make = 0B
     if ~context.graphics.movie.haskey('timestamps') then context.graphics.movie.timestamps = 0B
     if ~context.graphics.movie.haskey('expand') then context.graphics.movie.expand = 1.0
     if ~context.graphics.movie.haskey('rescale') then context.graphics.movie.rescale = 1.0
     if ~context.graphics.haskey('colorbar') then $
        context.colorbar = dictionary()
     if ~context.graphics.colorbar.haskey('type') then context.graphics.colorbar.type = 'global'

     ;;==PANEL
     if ~context.haskey('panel') then $
        context.panel = dictionary()
     if ~context.panel.haskey('index') then context.panel.index = [0,1]
     if ~context.panel.haskey('layout') then context.panel.layout = [1,2]
     if ~context.panel.haskey('show') then context.panel.show = 0B
     
  endelse

end
