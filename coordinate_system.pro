;+
; Identify a coordinate system based on coordinate labels.
; Originally written for use in vector_transform.pro
;-
function coordinate_system, coordinates,verbose=verbose

  case 1B of
     array_equal(['x','y'],strlowcase(coordinates)): begin
        if keyword_set(verbose) then $
           print, "COORDINATE_SYSTEM: Cartesian (2-D)"
        return, dictionary('name','cartesian','dim',2)
     end
     array_equal(['x','y','z'],strlowcase(coordinates)): begin
        if keyword_set(verbose) then $
           print, "COORDINATE_SYSTEM: Cartesian (3-D)"
        return, dictionary('name','cartesian','dim',3)
     end
     array_equal(['r','t'],strlowcase(coordinates)): begin
        if keyword_set(verbose) then $
           print, "COORDINATE_SYSTEM: Polar (2-D)"
        return, dictionary('name','polar','dim',2)
     end
     array_equal(['r','t','p'],strlowcase(coordinates)): begin
        if keyword_set(verbose) then $
           print, "COORDINATE_SYSTEM: Spherical (3-D)"
        return, dictionary('name','spherical','dim',2)
     end     
     array_equal(['r','t','z'],strlowcase(coordinates)): begin
        if keyword_set(verbose) then $
           print, "COORDINATE_SYSTEM: Cylindrical (3-D)"
        return, dictionary('name','cylidrical','dim',2)
     end
     else: begin
        if keyword_set(verbose) then $
           print, "COORDINATE_SYSTEM: Could not determine system."
        return, !NULL
     end
  endcase  

end
