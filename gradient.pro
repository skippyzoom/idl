;+
; Returns a struct representing the gradient of a function, f.
;-
function gradient, f

  ;; gradf = make_array([size(f,/dim),size(f,/n_dim)],type=size(f,/type),value=0)
  gradf = dictionary()
  ;; switch size(f,/n_dim) of
  ;;    8: 
  ;;    7:
  ;;    6: gradf.
  ;;    5: gradf.v
  ;;    4: gradf.u
  ;;    3: gradf.z
  ;;    2: gradf.y
  ;;    1: gradf.x
  ;; endswitch

  return, gradf
end
