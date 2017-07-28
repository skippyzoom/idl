;+
; Create the project struct for graphics.
;-
function set_current_prj, data,rngs,grid, $
                          np=np,xyzt=xyzt,title=title

  ;;==Defaults and guards
  if n_elements(data) eq 0 then $
     message, "Must supply data hash" $
  else if size(data,/type) ne 11 then $
     message, "Parameter 'data' must be a hash"
  if n_elements(rngs) eq 0 then $
     message, "Must supply rngs struct" $
  else if size(rngs,/type) ne 8 then $
     message, "Parameter 'rngs' must be a struct"
  if n_elements(grid) eq 0 then $
     message, "Must supply grid struct" $
  else if size(grid,/type) ne 8 then $
     message, "Parameter 'grid' must be a struct"
  if n_elements(np) eq 0 then np = 1
  if n_elements(xyzt) eq 0 then $
     xyzt = (max(np) gt 1) ? [0,1,2,3] : [0,1,2]
  if n_elements(title) eq 0 then title = ' '

  ;;==Set up untransposed vecs
  vecs = {x: grid.x[rngs.x[0]:rngs.x[1]], $
          y: grid.y[rngs.y[0]:rngs.y[1]], $
          z: grid.z[rngs.z[0]:rngs.z[1]]}

  ;;==Create project hash
  prj = hash('data', data[*], $  ;[*] makes a copy and preserves original
             'np', np, $
             'xyzt', xyzt, $
             'title', title, $
             'xrng', rngs.(xyzt[0]), $
             'yrng', rngs.(xyzt[1]), $
             'zrng', rngs.(xyzt[2]), $
             'xvec', vecs.(xyzt[0]), $
             'yvec', vecs.(xyzt[1]), $
             'zvec', vecs.(xyzt[2]))

  ;;==Calculate the aspect ratio (useful for images)
  prj['aspect_ratio'] = (1 + float((prj['yrng'])[1]) - float((prj['yrng'])[0]))/ $
                        (1 + float((prj['xrng'])[1]) - float((prj['xrng'])[0])) 

  ;;==Transpose data
  keys = data.keys()
  for ik=0,data.count()-1 do begin ;This could also be a foreach loop
     dataSize = size((prj['data'])[keys[ik]])
     if dataSize[0] eq 2 then xyzt = xyzt[0:1]
     (prj['data'])[keys[ik]] = $
        reform(transpose((data[keys[ik]])[rngs.x[0]:rngs.x[1], $
                                          rngs.y[0]:rngs.y[1], $
                                          rngs.z[0]:rngs.z[1], $
                                          *],xyzt))
  endfor
  xyzt = prj['xyzt']

  return, prj
end
