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
        context.description = get_context_defaults('description')
     spawn, 'pwd',wd
     if ~context.haskey('path') then context.path = wd
     if ~context.haskey('params') then $
        context['params'] = $
        get_context_defaults('params',path=context.path)
     if ~context.haskey('grid') then $
        context['grid'] = $
        get_context_defaults('grid',path=context.path)
     if ~context.params.haskey('nt_max') then $
        context.params['nt_max'] = $
        get_context_defaults('params.nt_max','.',path=context.path)

     ;;==DATA
     if ~context.haskey('data') || $
        n_elements(context.data) eq 0 then context.data = dictionary()
     if ~context.data.haskey('name') then $
        context.data.name = get_context_defaults('data.name','.')
     if ~context.data.haskey('type') then $
        context.data.type = get_context_defaults('data.type','.')
     ;;==GRAPHICS
     if ~context.haskey('graphics') || $
        n_elements(context.graphics) eq 0 then $
        context.graphics = get_context_defaults('graphics')
     if ~context.graphics.haskey('note') then $
        context.graphics.note = get_context_defaults('graphics.note','.')
     if ~context.graphics.haskey('rgb_table') || $
        n_elements(context.graphics.rgb_table) eq 0 then $
        context.graphics.rgb_table = get_context_defaults('graphics.rgb_table','.')
     if ~context.graphics.haskey('class') || $
        n_elements(context.graphics.class) eq 0 then $
        context.graphics.class = get_context_defaults('graphics.class','.')
     if ~context.graphics.haskey('plane') || $
        n_elements(context.graphics.plane) eq 0 then $
        context.graphics.plane = get_context_defaults('graphics.plane','.')
     if ~context.graphics.haskey('image') || $
        n_elements(context.graphics.image) eq 0 then $
        context.graphics.image = get_context_defaults('graphics.image','.')
     if ~context.graphics.haskey('axes') || $
        n_elements(context.graphics.axes) eq 0 then $
        context.graphics.axes = get_context_defaults('graphics.axes','.')
     if ~context.graphics.haskey('colorbar') || $
        n_elements(context.graphics.colorbar) eq 0 then $
        context.colorbar = get_context_defaults('graphics.colorbar','.')
     if ~context.graphics.haskey('movie') || $
        n_elements(context.graphics.movie) eq 0 then $
        context.graphics.movie = get_context_defaults('graphics.movie','.')
     if ~context.graphics.haskey('smooth') then $
        context.graphics.smooth = get_context_defaults('graphics.smooth','.')
     ;;==graphics/RGB_TABLE
     if ~context.graphics.rgb_table.haskey('fft') then $
        context.graphics.rgb_table.fft = get_context_defaults('graphics.rgb_table.fft','.')
     ;;==graphics/AXES
     if ~context.graphics.axes.haskey('x') || $
        n_elements(context.graphics.axes.x) eq 0 then $
        context.graphics.axes.x = get_context_defaults('graphics.axes.x','.')
     if ~context.graphics.axes.haskey('y')  || $
        n_elements(context.graphics.axes.y) eq 0 then $
        context.graphics.axes.y = get_context_defaults('graphics.axes.y','.')
     if ~context.graphics.axes.haskey('z')  || $
        n_elements(context.graphics.axes.z) eq 0 then $
        context.graphics.axes.z = get_context_defaults('graphics.axes.z','.')
     ;;==graphics/axes/[X,Y,Z]
     if ~context.graphics.axes.x.haskey('title') then $
        context.graphics.axes.x.title = get_context_defaults('graphics.axes.x.title','.')
     if ~context.graphics.axes.y.haskey('title') then $
        context.graphics.axes.y.title = get_context_defaults('graphics.axes.y.title','.')
     if ~context.graphics.axes.z.haskey('title') then $
        context.graphics.axes.z.title = get_context_defaults('graphics.axes.z.title','.')
     ;;==graphics/SMOOTH
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
STOP
     ;;==graphics/IMAGE
     if ~context.graphics.image.haskey('type') then context.graphics.image.type = '.png'
     ;;==graphics/MOVIE
     if ~context.graphics.movie.haskey('type') then context.graphics.movie.type = '.mp4'
     if ~context.graphics.movie.haskey('make') then context.graphics.movie.make = 0B
     if ~context.graphics.movie.haskey('timestamps') then context.graphics.movie.timestamps = 0B
     if ~context.graphics.movie.haskey('expand') then context.graphics.movie.expand = 1.0
     if ~context.graphics.movie.haskey('rescale') then context.graphics.movie.rescale = 1.0
     ;;==graphics/COLORBAR
     if ~context.graphics.colorbar.haskey('type') then context.graphics.colorbar.type = 'global'

     ;;==PANEL
     if ~context.haskey('panel') then $
        context.panel = dictionary()
     ;; if ~context.panel.haskey('index') then context.panel.index = [0,1]
     ;; if ~context.panel.haskey('layout') then context.panel.layout = [1,2]
     ;; if ~context.panel.haskey('show') then context.panel.show = 0B
     if ~context.panel.haskey('index') then $
        context.panel.index = dictionary('value', [0,1], 'type', 'rel')
     if ~context.panel.haskey('layout') then begin
        context.panel.layout = dictionary('xy', [2,1])
        if context.params.ndim_space eq 3 then begin
           context.panel.layout['xz'] = [2,1]
           context.panel.layout['yz'] = [2,1]
        endif
     endif
     if ~context.panel.haskey('show') then $
        context.panel.show = 1B
  endelse

end
