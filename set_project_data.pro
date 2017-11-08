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
function set_project_data, data,grid,target=target

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
  if n_elements(target) ne 0 && target.haskey('ranges') then begin
     ranges = {x: [target.ranges[0,0]*grid.nx,target.ranges[1,0]*grid.nx-1], $
               y: [target.ranges[0,1]*grid.ny,target.ranges[1,1]*grid.ny-1], $
               z: [target.ranges[0,2]*grid.nz,target.ranges[1,2]*grid.nz-1]}
     target.remove, 'ranges'
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
  if n_elements(target) eq 0 then begin
     transpose = ([0,1,2,3])[0:d_size[0]-1]
     target = dictionary('data', data[*], $
                         'grid', grid, $
                         'xrng', ranges.(transpose[0]), $
                         'yrng', ranges.(transpose[1]), $
                         'zrng', ranges.(transpose[2]), $
                         'xvec', vecs.(transpose[0]), $
                         'yvec', vecs.(transpose[1]), $
                         'zvec', vecs.(transpose[2]))
     target['scale'] = make_array(target.data.count(),value=1.0)
     target['transpose'] = transpose
  endif $
  else begin
     if ~target.haskey('transpose') then $
        target['transpose'] = ([0,1,2,3])[0:d_size[0]-1] $
     else target['transpose'] = (target['transpose'])[0:d_size[0]-1]
     target['data'] = data[*]
     target['grid'] = grid
     target['xrng'] = ranges.(target.transpose[0])
     target['yrng'] = ranges.(target.transpose[1])
     target['zrng'] = ranges.(target.transpose[2])
     target['dimensions'] = [target.xrng[1]-target.xrng[0]+1, $
                             target.yrng[1]-target.yrng[0]+1, $
                             target.zrng[1]-target.zrng[0]+1]
     target['xvec'] = vecs.(target.transpose[0])
     target['yvec'] = vecs.(target.transpose[1])
     target['zvec'] = vecs.(target.transpose[2])
     if ~target.haskey('scale') then $
        target['scale'] = dictionary(target.data_name.toarray(), $
                                     make_array(target.data.count(),value=1.0)) $
     else begin
        missing = where(target.scale.haskey(d_keys) eq 0,count)
        if count ne 0 then target.scale[d_keys[missing]] = 1.0  
     endelse
  endelse

  ;;==Calculate the aspect ratio (useful for images)
  target['aspect_ratio'] = (1 + float(target.yrng[1]) - float(target.yrng[0]))/ $
                           (1 + float(target.xrng[1]) - float(target.xrng[0])) 

  ;;==Transpose data, if applicable
  for ik=0,n_data-1 do begin
     if ~array_equal(target.transpose,([0,1,2,3])[0:d_size[0]-1]) then begin
        target.data[d_keys[ik]] = transpose(data[d_keys[ik]],target.transpose)
     endif
     target.data[d_keys[ik]] = reform(target.data[d_keys[ik]])
  endfor

  return, target
end
