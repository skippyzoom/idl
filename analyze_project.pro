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

  ;;==Echo working path and store in project dictionary
  print, "ANALYZE_PROJECT: In ",path

  ;;==Set up an appropriate context dictionary
  spawn, 'pwd',wd
  if n_elements(path) eq 0 then path = wd
  if n_elements(context) eq 0 then begin
     context = load_default_context(path=path)
  endif $
  else begin
     context['path'] = path
     set_context_defaults, context
  endelse

  ;;==Load simulation data
  data = load_eppic_data(context.data.name.toarray(), $
                         context.data.type, $
                         path = context.path, $
                         timestep = context.params.nout*lindgen(context.params.nt_max))

  ;;==Set up data for graphics
  d_keys = data.keys()
  d_size = size(data[d_keys[0]])
  if context.haskey('transpose') then context['transpose'] = context.transpose[0:d_size[0]-1]
  context = set_project_data(data,context.grid,context=context[*])

  ;;==Set appropriate units for graphics
  set_data_units, context,context.params.units
  context.data['label'] = set_data_labels(context.data.name.toarray())

  ;;==Create graphical output
  project_graphics, context

end
