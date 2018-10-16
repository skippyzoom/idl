;+
; Return FFT RMS time indices for a given run
;-
function get_rms_indices, path, $
                       time, $
                       lun=lun

  ;;==Set defaults
  if n_elements(lun) eq 0 then lun = -1

  ;;==Build look-up hash of times
  rms_time = hash()
  
  ;;==2-D 50 mV/m
  rms_time[get_base_dir()+path_sep()+ $
           'fb_flow_angle/2D/h0-Ey0_050-full_output/'] = $
     [[find_closest(time.stamp,40), $
       find_closest(time.stamp,110)], $
      [find_closest(time.stamp,280), $
       time.nt-1]]
  rms_time[get_base_dir()+path_sep()+ $
           'fb_flow_angle/2D/h1-Ey0_050-full_output/'] = $
     [[find_closest(time.stamp,40), $
       find_closest(time.stamp,110)], $
      [find_closest(time.stamp,280), $
       time.nt-1]]
  rms_time[get_base_dir()+path_sep()+ $
           'fb_flow_angle/2D/h2-Ey0_050-full_output/'] = $
     [[find_closest(time.stamp,40), $
       find_closest(time.stamp,110)], $
      [find_closest(time.stamp,280), $
       time.nt-1]]
  ;;==3-D 30 mV/m
  rms_time[get_base_dir()+path_sep()+ $
           'fb_flow_angle/3D/h0-Ey0_030-full_output/'] = $
     [[find_closest(time.stamp,20), $
       find_closest(time.stamp,25)], $
      [find_closest(time.stamp,75), $
       time.nt-1]]
  rms_time[get_base_dir()+path_sep()+ $
           'fb_flow_angle/3D/h1-Ey0_030-full_output/'] = $
     [[find_closest(time.stamp,21), $
       find_closest(time.stamp,26)], $
      [find_closest(time.stamp,75), $
       time.nt-1]]
  rms_time[get_base_dir()+path_sep()+ $
           'fb_flow_angle/3D/h2-Ey0_030-full_output/'] = $
     [[find_closest(time.stamp,32), $
       find_closest(time.stamp,37)], $
      [find_closest(time.stamp,75), $
       time.nt-1]]
  ;;==3-D 50 mV/m
  rms_time[get_base_dir()+path_sep()+ $
           'fb_flow_angle/3D/h0-Ey0_050-full_output/'] = $
     [[find_closest(time.stamp,12), $
       find_closest(time.stamp,27)], $
      [find_closest(time.stamp,70), $
       time.nt-1]]
  rms_time[get_base_dir()+path_sep()+ $
           'fb_flow_angle/3D/h1-Ey0_050-full_output/'] = $
     [[find_closest(time.stamp,15), $
       find_closest(time.stamp,30)], $
      [find_closest(time.stamp,70), $
       time.nt-1]]
  rms_time[get_base_dir()+path_sep()+ $
           'fb_flow_angle/3D/h2-Ey0_050-full_output/'] = $
     [[find_closest(time.stamp,20), $
       find_closest(time.stamp,35)], $
      [find_closest(time.stamp,70), $
       time.nt-1]]
  ;;==3-D 70 mV/m
  rms_time[get_base_dir()+path_sep()+ $
           'fb_flow_angle/3D/h0-Ey0_070-full_output/'] = $
     [[find_closest(time.stamp,12.54), $
       find_closest(time.stamp,17.92)], $
      [find_closest(time.stamp,70), $
       time.nt-1]]
  rms_time[get_base_dir()+path_sep()+ $
           'fb_flow_angle/3D/h1-Ey0_070-full_output/'] = $
     [[find_closest(time.stamp,12.54), $
       find_closest(time.stamp,14)], $
      [find_closest(time.stamp,70), $
       time.nt-1]]
  rms_time[get_base_dir()+path_sep()+ $
           'fb_flow_angle/3D/h2-Ey0_070-full_output/'] = $
     [[find_closest(time.stamp,4), $
       find_closest(time.stamp,14)], $
      [find_closest(time.stamp,70), $
       time.nt-1]]
  
  if rms_time.haskey(path) then begin
     return, rms_time[path]
  endif $
  else begin
     printf, lun,"[GET_RMS_INDICES] Could not match path. Returning full time."
     return, [0,time.nt-1]
  end

end
