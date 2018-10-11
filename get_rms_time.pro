;+
; Return FFT RMS time ranges for a given run
;-
function get_rms_time, path, $
                       time, $
                       lun=lun

  ;;==Set defaults
  if n_elements(lun) eq 0 then lun = -1

  ;;==Select times based on path
  case 1B of
     strcmp(path, $
        get_base_dir()+ $
        path_sep()+ $
            'fb_flow_angle/2D/h0-Ey0_050-full_output/'): begin
        rms_time = [[find_closest(time.stamp,40), $
                     find_closest(time.stamp,110)], $
                    [find_closest(time.stamp,280), $
                     time.nt-1]]
     end     
     strcmp(path, $
        get_base_dir()+ $
        path_sep()+ $
            'fb_flow_angle/2D/h1-Ey0_050-full_output/'): begin
        rms_time = [[find_closest(time.stamp,40), $
                     find_closest(time.stamp,110)], $
                    [find_closest(time.stamp,280), $
                     time.nt-1]]
     end
     strcmp(path, $
        get_base_dir()+ $
        path_sep()+ $
            'fb_flow_angle/2D/h2-Ey0_050-full_output/'): begin
        rms_time = [[find_closest(time.stamp,40), $
                     find_closest(time.stamp,110)], $
                    [find_closest(time.stamp,280), $
                     time.nt-1]]
     end
     strcmp(path, $
        get_base_dir()+ $
        path_sep()+ $
            'fb_flow_angle/3D/h0-Ey0_050-full_output/'): begin
        rms_time = [[find_closest(time.stamp,20), $
                     find_closest(time.stamp,35)], $
                    [find_closest(time.stamp,70), $
                     time.nt-1]]
     end
     strcmp(path, $
        get_base_dir()+ $
        path_sep()+ $
            'fb_flow_angle/3D/h1-Ey0_050-full_output/'): begin
        rms_time = [[find_closest(time.stamp,20), $
                     find_closest(time.stamp,35)], $
                    [find_closest(time.stamp,70), $
                     time.nt-1]]
     end
     strcmp(path, $
        get_base_dir()+ $
        path_sep()+ $
            'fb_flow_angle/3D/h2-Ey0_050-full_output/'): begin
        rms_time = [[find_closest(time.stamp,25), $
                     find_closest(time.stamp,40)], $
                    [find_closest(time.stamp,70), $
                     time.nt-1]]
     end
     else: begin
        printf, lun,"[GET_RMS_TIME] Could not match path"
        rms_time = [0,time.nt-1]
     end
  endcase

  return, rms_time
end
