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
;; function set_current_prj, data,rngs,grid, $
;;                           scale=scale,xyzt=xyzt, $
;;                           description=description
function set_project_data, data,rngs,grid,target=target

  dKeys = data.keys()
  nData = data.count()
  dSize = size(data[dKeys[0]])

  ;;==Defaults and guards
  if n_elements(data) eq 0 then $
     message, "Must supply data dictionary" $
  else if ~strcmp(typename(data),'DICTIONARY') then $
     message, "Parameter 'data' must be a dictionary"
  if n_elements(rngs) eq 0 then $
     message, "Must supply rngs struct" $
  else if size(rngs,/type) ne 8 then $
     message, "Parameter 'rngs' must be a struct"
  if n_elements(grid) eq 0 then $
     message, "Must supply grid struct" $
  else if size(grid,/type) ne 8 then $
     message, "Parameter 'grid' must be a struct"
  
  ;;==Set up untransposed vecs
  vecs = {x: grid.x[rngs.x[0]:rngs.x[1]], $
          y: grid.y[rngs.y[0]:rngs.y[1]], $
          z: grid.z[rngs.z[0]:rngs.z[1]]}

  ;;==Create or update project dictionary
  if n_elements(target) eq 0 then begin
     xyzt = ([0,1,2,3])[0:dSize[0]-1]
     target = dictionary('data', data[*], $
                         'grid', grid, $
                         'xrng', rngs.(xyzt[0]), $
                         'yrng', rngs.(xyzt[1]), $
                         'zrng', rngs.(xyzt[2]), $
                         'xvec', vecs.(xyzt[0]), $
                         'yvec', vecs.(xyzt[1]), $
                         'zvec', vecs.(xyzt[2]))
     target['scale'] = make_array(target.data.count(),value=1.0)
     target['xyzt'] = xyzt
  endif $
  else begin
     if ~target.haskey('xyzt') then $
        target['xyzt'] = ([0,1,2,3])[0:dSize[0]-1]
     target['data'] = data[*]
     target['grid'] = grid
     target['xrng'] = rngs.(target.xyzt[0])
     target['yrng'] = rngs.(target.xyzt[1])
     target['zrng'] = rngs.(target.xyzt[2])
     target['xvec'] = vecs.(target.xyzt[0])
     target['yvec'] = vecs.(target.xyzt[1])
     target['zvec'] = vecs.(target.xyzt[2])
     if ~target.haskey('scale') then $
        target['scale'] = make_array(target.data.count(),value=1.0) $
     else begin
        missing = where(target.scale.haskey(dKeys) eq 0,count)
        if count ne 0 then target.scale[dKeys[missing]] = 1.0  
     endelse
  endelse

  ;;==Calculate the aspect ratio (useful for images)
  target['aspect_ratio'] = (1 + float(target.yrng[1]) - float(target.yrng[0]))/ $
                        (1 + float(target.xrng[1]) - float(target.xrng[0])) 

  ;;==Transpose and scale data
  for ik=0,nData-1 do begin ;This could also be a foreach loop
     target.data[dKeys[ik]] = $
        reform(transpose((data[dKeys[ik]])[rngs.x[0]:rngs.x[1], $
                                          rngs.y[0]:rngs.y[1], $
                                          rngs.z[0]:rngs.z[1], $
                                          *],target.xyzt))*target.scale[dKeys[ik]]
  endfor

  return, target
end
