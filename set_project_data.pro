;+
; Create the project dictionary for graphics.
;
; NOTES
; -- The use of data[*] in assigning the project
;    makes a copy and preserves original, rather
;    than simply copying the memory location. This
;    is an aspect (feature? bug?) of dictionaries.
;
; TO DO
;-
function set_project_data, data,grid,context=context

  d_keys = data.keys()
  n_data = data.count()
  d_size = size(data[d_keys[0]])

  ;;==Defaults and guards
  if n_elements(data) eq 0 then $
     message, "Must supply data dictionary" $
  else if ~strcmp(typename(data),'DICTIONARY') then $
     message, "Parameter 'data' must be a dictionary"
  if n_elements(grid) eq 0 then $
     message, "Must supply grid struct" $
  else if size(grid,/type) ne 8 then $
     message, "Parameter 'grid' must be a struct"

  ;;==Set up untransposed vecs
  if n_elements(context) ne 0 && context.haskey('ranges') then begin
     ranges = {x: [context.ranges[0,0]*grid.nx,context.ranges[1,0]*grid.nx-1], $
               y: [context.ranges[0,1]*grid.ny,context.ranges[1,1]*grid.ny-1], $
               z: [context.ranges[0,2]*grid.nz,context.ranges[1,2]*grid.nz-1]}
     context.remove, 'ranges'
  endif $
  else begin
     ranges = {x: [0,grid.nx-1], $
               y: [0,grid.ny-1], $
               z: [0,grid.nz-1]}
  endelse
  vecs = {x: grid.x, $
          y: grid.y, $
          z: grid.z} 

  ;;==Create or update project dictionary
  if n_elements(context) eq 0 then begin
     transpose = ([0,1,2,3])[0:d_size[0]-1]
     context = dictionary('data', data[*], $
                          'grid', grid, $
                          'xrng', ranges.(transpose[0]), $
                          'yrng', ranges.(transpose[1]), $
                          'zrng', ranges.(transpose[2]), $
                          'xvec', vecs.(transpose[0]), $
                          'yvec', vecs.(transpose[1]), $
                          'zvec', vecs.(transpose[2]))
     context['scale'] = make_array(context.data.count(),value=1.0)
     context['transpose'] = transpose
  endif $
  else begin
     if ~context.haskey('transpose') then $
        context['transpose'] = ([0,1,2,3])[0:d_size[0]-1] $
     else context['transpose'] = (context['transpose'])[0:d_size[0]-1]
     context['data'] = data[*]
     context['grid'] = grid
     context['xrng'] = ranges.(context.transpose[0])
     context['yrng'] = ranges.(context.transpose[1])
     context['zrng'] = ranges.(context.transpose[2])
     context['dimensions'] = [context.xrng[1]-context.xrng[0]+1, $
                              context.yrng[1]-context.yrng[0]+1, $
                              context.zrng[1]-context.zrng[0]+1]
     context['xvec'] = vecs.(context.transpose[0])
     context['yvec'] = vecs.(context.transpose[1])
     context['zvec'] = vecs.(context.transpose[2])
     if ~context.haskey('scale') then $
        context['scale'] = dictionary(context.data_name.toarray(), $
                                      make_array(context.data.count(),value=1.0)) $
     else begin
        missing = where(context.scale.haskey(d_keys) eq 0,count)
        if count ne 0 then context.scale[d_keys[missing]] = 1.0  
     endelse
  endelse

  ;;==Calculate the aspect ratio (useful for images)
  context['aspect_ratio'] = (1 + float(context.yrng[1]) - float(context.yrng[0]))/ $
                            (1 + float(context.xrng[1]) - float(context.xrng[0])) 

  ;;==Transpose data, if applicable
  for ik=0,n_data-1 do begin
     if ~array_equal(context.transpose,([0,1,2,3])[0:d_size[0]-1]) then begin
        context.data[d_keys[ik]] = transpose(data[d_keys[ik]],context.transpose)
     endif
     context.data[d_keys[ik]] = reform(context.data[d_keys[ik]])
  endfor

  return, context
end
