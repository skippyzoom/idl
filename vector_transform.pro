;+
; Transform a vector from one coordinate system to another.
; Assumes that field is a struct.
;
; NB: Accessing the field components directly may be slower than
;     assigning intermediary vectors. However, the trade-off is
;     memory usage.
;
; TO DO
; -- Add support for other data types (e.g. array and dictionary)
;-
function vector_transform, field, $
                           polar_to_cartesian=polar_to_cartesian, $
                           cartesian_to_polar=cartesian_to_polar

  nDims = n_tags(field,/top_level)

  case nDims of
     2: begin
        if keyword_set(cartesian_to_polar) then begin           
           r = sqrt(field.x^2 + field.y^2)
           t = atan(field.y,field.x)
           return, {r:r, t:t}
        endif
     end
     3: begin
           r = sqrt(field.x^2 + field.y^2 + field.z^2)
           t = atan(field.y,field.x)
           p = acos(field.z/r)
           return, {r:r, t:t, p:p}
     end
     else: print, "VECTOR_TRANSFORM: Only supports 2D & 3D."

end
