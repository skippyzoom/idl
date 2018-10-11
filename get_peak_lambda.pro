;+
; Return wavelength of peak growth for a given run
;-
function get_peak_lambda, path, $
                          lun=lun

  ;;==Set defaults
  if n_elements(lun) eq 0 then lun = -1

  ;;==Select wavelength based on path
  case 1B of
     strcmp(path, $
        get_base_dir()+ $
        path_sep()+ $
            'fb_flow_angle/2D/h0-Ey0_050-full_output/'): begin
        lambda = 3.20806
     end     
     strcmp(path, $
        get_base_dir()+ $
        path_sep()+ $
            'fb_flow_angle/2D/h1-Ey0_050-full_output/'): begin
        lambda = 2.61434
     end
     strcmp(path, $
        get_base_dir()+ $
        path_sep()+ $
            'fb_flow_angle/2D/h2-Ey0_050-full_output/'): begin
        lambda = 2.47445
     end
     strcmp(path, $
        get_base_dir()+ $
        path_sep()+ $
            'fb_flow_angle/3D/h0-Ey0_050-full_output/'): begin
        lambda = 2.49150
     end
     strcmp(path, $
        get_base_dir()+ $
        path_sep()+ $
            'fb_flow_angle/3D/h1-Ey0_050-full_output/'): begin
        lambda = 2.54248
     end
     strcmp(path, $
        get_base_dir()+ $
        path_sep()+ $
            'fb_flow_angle/3D/h2-Ey0_050-full_output/'): begin
        lambda = 2.47566
     end
     else: begin
        printf, lun,"[GET_PEAK_LAMBDA] Could not match path"
        lambda = 3.0
     end
  endcase

  return, lambda
end
