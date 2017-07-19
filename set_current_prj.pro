;+
; Create the project struct for graphics.
;
; NOTES
; -- The subset/transpose section may not be the
;    most memory efficient approach, since it makes
;    a copy of the input struct, but that may be okay 
;    if np isn't large and there aren't many fields.
;-
function set_current_prj, data,rngs,grid, $
                          np=np,xyzt=xyzt,title=title

  ;;==Defaults and guards
  if n_elements(data) eq 0 then $
     message, "Must supply data struct" $
  else if size(data,/type) ne 8 then $
     message, "Parameter 'data' must be a struct"
  if n_elements(rngs) eq 0 then $
     message, "Must supply rngs struct" $
  else if size(rngs,/type) ne 8 then $
     message, "Parameter 'rngs' must be a struct"
  if n_elements(grid) eq 0 then $
     message, "Must supply grid struct" $
  else if size(grid,/type) ne 8 then $
     message, "Parameter 'grid' must be a struct"
  if n_elements(np) eq 0 then np = 1
  if n_elements(xyzt) eq 0 then xyzt = (np gt 1) ? [0,1,2,3] : [0,1,2]
  if n_elements(title) eq 0 then title = ' '

  ;;==Set up untransposed vecs
  vecs = {x: grid.x[rngs.x[0]:rngs.x[1]], $
          y: grid.y[rngs.y[0]:rngs.y[1]], $
          z: grid.z[rngs.z[0]:rngs.z[1]]}

  ;;==Subset and transpose data
  data_in = data
  names = tag_names(data)
  ;; for it=0,n_tags(data)-1 do $
  ;;    replace_tag, data,names[it], $
  ;;                 reform(transpose((data_in.(it))[rngs.x[0]:rngs.x[1], $
  ;;                                                 rngs.y[0]:rngs.y[1], $
  ;;                                                 rngs.z[0]:rngs.z[1], $
  ;;                                                 *],xyzt))
  for it=0,n_tags(data)-1 do $
     data = replace_tag(data,names[it], $
                        reform(transpose((data_in.(it))[rngs.x[0]:rngs.x[1], $
                                                        rngs.y[0]:rngs.y[1], $
                                                        rngs.z[0]:rngs.z[1], $
                                                        *],xyzt)))

  ;;==Create project struct
  prj = {data: data, $
         np: np, $
         xyzt: xyzt, $
         title: title, $
         xrng: rngs.(xyzt[0]), $
         yrng: rngs.(xyzt[1]), $
         zrng: rngs.(xyzt[2]), $
         xvec: vecs.(xyzt[0]), $
         yvec: vecs.(xyzt[1]), $
         zvec: vecs.(xyzt[2])}

  return, prj
end
