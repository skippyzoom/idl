;+
; Check for necessary fields in a user-supplied
; project context and set default values where
; necessary.
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

     ;;==DATA
     if ~context.haskey('data') then context.data = dictionary()
     if ~context.data.haskey('name') then $
        context.data.name = list('den1','phi')
     n_names = context.data.name.count()
     if ~context.data.haskey('type') then $
        context.data.type = ['ph5','ph5']

     ;;==GRAPHICS
     if ~context.haskey('graphics') then context.graphics = dictionary()
     if ~context.graphics.haskey('desc') then context.graphics.desc = ''
     if ~context.graphics.haskey('class') then $
        context.graphics.class = dictionary()
     ;;==graphics/RGB_TABLE
     if ~context.graphics.haskey('rgb_table') then $
        context.graphics.rgb_table = dictionary(context.data.name.toarray(), $
                                                make_array(n_names,value=0)) $
     else begin
        for id=0,n_names-1 do begin
           if ~context.graphics.rgb_table.haskey(context.data.name[id]) then $
              context.graphics.rgb_table[name[id]] = 0
        endfor
     endelse
     if ~context.graphics.rgb_table.haskey('fft') then $
        context.graphics.rgb_table.fft = 0
     ;;==graphics/IMAGE
     if ~context.graphics.haskey('image') then $
        context.graphics.image = dictionary()
     if ~context.graphics.image.haskey('type') then context.graphics.image.type = '.png'
     ;;==graphics/MOVIE
     if ~context.graphics.haskey('movie') then $
        context.graphics.movie = dictionary()
     if ~context.graphics.movie.haskey('type') then context.graphics.movie.type = '.mp4'
     if ~context.graphics.movie.haskey('make') then context.graphics.movie.make = 0B
     if ~context.graphics.movie.haskey('timestamps') then context.graphics.movie.timestamps = 0B
     if ~context.graphics.movie.haskey('expand') then context.graphics.movie.expand = 1.0
     if ~context.graphics.movie.haskey('rescale') then context.graphics.movie.rescale = 1.0
     ;;==graphics/COLORBAR
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
