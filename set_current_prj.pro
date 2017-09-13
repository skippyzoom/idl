;+
; Create the project dictionary for graphics.
;-
function set_current_prj, data,rngs,grid, $
                          scale=scale,xyzt=xyzt, $
                          description=description

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
  if ~strcmp(typename(scale),'DICTIONARY') then $
     message, "Parameter 'scale' must be a dictionary"
  missing = where(scale.haskey(dKeys) eq 0,count)
  if count ne 0 then scale[dKeys[missing]] = 1.0
  ;; if n_elements(xyzt) eq 0 then $
  ;;    xyzt = (max(np) gt 1) ? [0,1,2,3] : [0,1,2]
  if n_elements(xyzt) eq 0 then xyzt = [0,1,2,3]
  ;; if dSize[0] eq 2 then xyzt = xyzt[0:1] $
  ;; else if dSize[0] eq 3 then xyzt = xyzt[0:2]
  ;; xyzt = xyzt[0:dSize[0]-1]
  
  if n_elements(description) eq 0 then description = ' '

  ;;==Set up untransposed vecs
  vecs = {x: grid.x[rngs.x[0]:rngs.x[1]], $
          y: grid.y[rngs.y[0]:rngs.y[1]], $
          z: grid.z[rngs.z[0]:rngs.z[1]]}

  ;;==Create project dictionary
  prj = dictionary('data', data[*], $  ;[*] makes a copy and preserves original
                   'scale', scale, $
                   'xyzt', xyzt[0:dSize[0]-1], $
                   'description', description, $
                   'xrng', rngs.(xyzt[0]), $
                   'yrng', rngs.(xyzt[1]), $
                   'zrng', rngs.(xyzt[2]), $
                   'xvec', vecs.(xyzt[0]), $
                   'yvec', vecs.(xyzt[1]), $
                   'zvec', vecs.(xyzt[2]))

  ;;==Calculate the aspect ratio (useful for images)
  prj['aspect_ratio'] = (1 + float(prj.yrng[1]) - float(prj.yrng[0]))/ $
                        (1 + float(prj.xrng[1]) - float(prj.xrng[0])) 

  ;;==Transpose and scale data
  for ik=0,nData-1 do begin ;This could also be a foreach loop
     prj.data[dKeys[ik]] = $
        reform(transpose((data[dKeys[ik]])[rngs.x[0]:rngs.x[1], $
                                          rngs.y[0]:rngs.y[1], $
                                          rngs.z[0]:rngs.z[1], $
                                          *],prj.xyzt))*prj.scale[dKeys[ik]]
  endfor

  return, prj
end
