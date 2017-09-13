;+
; Transform a vector from one coordinate system to another.
; Assumes that field is a struct.
;
; NOTES
; -- Accessing the field components directly may be slower than
;    assigning intermediary vectors. However, the trade-off is
;    memory usage.
; -- The section that determines the transform is written as it
;    is (e.g. rather than as a case block) so that all possible
;    transforms will have a boolean value.
;
; TO DO
; -- Add support for other data types (e.g. array and dictionary)
;-
function vector_transform, field, $
                           ;; ;; polar_to_cartesian=polar_to_cartesian, $
                           ;; ;; cartesian_to_polar=cartesian_to_polar
                           coords_in,coords_out, $
                           verbose=verbose

  ;;==Determine the input/output coordinate systems
  sys_in = coordinate_system(coords_in,verbose=verbose)
  sys_out = coordinate_system(coords_out,verbose=verbose)
  if sys_in.dim ne sys_out.dim then begin
     print, "VECTOR_TRANSFORM: Coordinate-system dimensions do not match."
     return, !NULL
  endif

  ;;==Determine transform
  ct2_pol = (sys_in.dim eq 2) && $
     (strcmp(sys_in.name,'cartesian') && strcmp(sys_out.name,'polar'))
  pol_ct2 = (sys_in.dim eq 2) && $
     (strcmp(sys_in.name,'polar') && strcmp(sys_out.name,'cartesian'))
  ct3_sph = (sys_in.dim eq 3) && $
     (strcmp(sys_in.name,'cartesian') && strcmp(sys_out.name,'spherical'))
  sph_ct3 = (sys_in.dim eq 3) && $
     (strcmp(sys_in.name,'spherical') && strcmp(sys_out.name,'cartesian'))
  ct3_cyl = (sys_in.dim eq 3) && $
     (strcmp(sys_in.name,'cartesian') && strcmp(sys_out.name,'cylindrical'))
  cyl_ct3 = (sys_in.dim eq 3) && $
     (strcmp(sys_in.name,'cylindrical') && strcmp(sys_out.name,'cartesian'))
  sph_cyl = (sys_in.dim eq 3) && $
     (strcmp(sys_in.name,'spherical') && strcmp(sys_out.name,'cylindrical'))
  cyl_sph = (sys_in.dim eq 3) && $
     (strcmp(sys_in.name,'cylindrical') && strcmp(sys_out.name,'spherical'))

  case 1B of
     ct2_pol: begin
        r = sqrt(field.x^2 + field.y^2)
        t = atan(field.y,field.x)
        return, {r:r, t:t}        
     end
     ct3_sph: begin
        r = sqrt(field.x^2 + field.y^2 + field.z^2)
        t = atan(field.y,field.x)
        p = acos(field.z/r)
        return, {r:r, t:t, p:p}
     end
     else: print, "VECTOR_TRANSFORM: Only supports 2D & 3D."
  endcase

end
