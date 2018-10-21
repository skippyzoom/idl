;+
; Return FFT RMS time indices for a given run
;
; This function needs to return indices into EPPIC arrays. There are a
; few ways to accomplish that. You could use find_closest with the
; time dictionary to provide a time stamp (approximate or exact)
; corresponding to the appropriate index. You could use the index
; member of the time dictionary, divided by params.nout, if you know
; the time range in term of time steps. You could also simply provide
; the output indices if you know them (e.g., you know you want the
; first and last quarters of the run).
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;-
function get_rms_indices, path, $
                          time, $
                          lun=lun

  ;;==Set defaults
  if n_elements(lun) eq 0 then lun = -1

  ;;==Read parameter dictionary, in case we need it
  params = set_eppic_params(path=path)

  ;;==Build look-up hash of times
  rms_time = hash()

  ;---------------;
  ; FB_FLOW_ANGLE ;
  ;---------------;
  
  ;;==2-D 30 mV/m
  rms_time[get_base_dir()+path_sep()+ $
           'fb_flow_angle/2D/h0-Ey0_030-full_output/'] = $
     [[0,time.nt/2-1],[time.nt/2,time.nt-1]]
  rms_time[get_base_dir()+path_sep()+ $
           'fb_flow_angle/2D/h1-Ey0_030-full_output/'] = $
     [[0,time.nt/2-1],[time.nt/2,time.nt-1]]
  rms_time[get_base_dir()+path_sep()+ $
           'fb_flow_angle/2D/h2-Ey0_030-full_output/'] = $
     [[0,time.nt/2-1],[time.nt/2,time.nt-1]]
  ;;==2-D 50 mV/m
  rms_time[get_base_dir()+path_sep()+ $
           'fb_flow_angle/2D/h0-Ey0_050-full_output/'] = $
     [[find_closest(time.stamp,68.10), $
       find_closest(time.stamp,80.64)], $
      [find_closest(time.stamp,280), $
       time.nt-1]]
  rms_time[get_base_dir()+path_sep()+ $
           'fb_flow_angle/2D/h1-Ey0_050-full_output/'] = $
     [[find_closest(time.stamp,77.06), $
       find_closest(time.stamp,89.60)], $
      [find_closest(time.stamp,280), $
       time.nt-1]]
  rms_time[get_base_dir()+path_sep()+ $
           'fb_flow_angle/2D/h2-Ey0_050-full_output/'] = $
     [[find_closest(time.stamp,77.06), $
       find_closest(time.stamp,89.60)], $
      [find_closest(time.stamp,280), $
       time.nt-1]]
  ;;==2-D 70 mV/m
  rms_time[get_base_dir()+path_sep()+ $
           'fb_flow_angle/2D/h0-Ey0_070-full_output/'] = $
     [[find_closest(time.stamp,37.63), $
       find_closest(time.stamp,51.18)], $
      [find_closest(time.stamp,280), $
       time.nt-1]]
  rms_time[get_base_dir()+path_sep()+ $
           'fb_flow_angle/2D/h1-Ey0_070-full_output/'] = $
     [[find_closest(time.stamp,37.63), $
       find_closest(time.stamp,51.18)], $
      [find_closest(time.stamp,280), $
       time.nt-1]]
  rms_time[get_base_dir()+path_sep()+ $
           'fb_flow_angle/2D/h2-Ey0_070-full_output/'] = $
     [[find_closest(time.stamp,37.63), $
       find_closest(time.stamp,51.18)], $
      [find_closest(time.stamp,280), $
       time.nt-1]]
  ;;==3-D 30 mV/m
  rms_time[get_base_dir()+path_sep()+ $
           'fb_flow_angle/3D/h0-Ey0_030-full_output/'] = $
     [[0,time.nt/2-1],[time.nt/2,time.nt-1]]
  rms_time[get_base_dir()+path_sep()+ $
           'fb_flow_angle/3D/h1-Ey0_030-full_output/'] = $
     [[0,time.nt/2-1],[time.nt/2,time.nt-1]]
  rms_time[get_base_dir()+path_sep()+ $
           'fb_flow_angle/3D/h2-Ey0_030-full_output/'] = $
     [[0,time.nt/2-1],[time.nt/2,time.nt-1]]
  ;;==3-D 50 mV/m
  rms_time[get_base_dir()+path_sep()+ $
           'fb_flow_angle/3D/h0-Ey0_050-full_output/'] = $
     [[find_closest(time.stamp,33.60), $
       find_closest(time.stamp,36.29)], $
      [find_closest(time.stamp,70), $
       time.nt-1]]
  rms_time[get_base_dir()+path_sep()+ $
           'fb_flow_angle/3D/h1-Ey0_050-full_output/'] = $
     [[find_closest(time.stamp,25.98), $
       find_closest(time.stamp,28.67)], $
      [find_closest(time.stamp,70), $
       time.nt-1]]
  rms_time[get_base_dir()+path_sep()+ $
           'fb_flow_angle/3D/h2-Ey0_050-full_output/'] = $
     [[find_closest(time.stamp,33.60), $
       find_closest(time.stamp,36.29)], $
      [find_closest(time.stamp,70), $
       time.nt-1]]
  ;;==3-D 70 mV/m
  rms_time[get_base_dir()+path_sep()+ $
           'fb_flow_angle/3D/h0-Ey0_070-full_output/'] = $
     [[find_closest(time.stamp,15.23), $
       find_closest(time.stamp,17.92)], $
      [find_closest(time.stamp,70), $
       time.nt-1]]
  rms_time[get_base_dir()+path_sep()+ $
           'fb_flow_angle/3D/h1-Ey0_070-full_output/'] = $
     [[find_closest(time.stamp,14.34), $
       find_closest(time.stamp,17.02)], $
      [find_closest(time.stamp,70), $
       time.nt-1]]
  rms_time[get_base_dir()+path_sep()+ $
           'fb_flow_angle/3D/h2-Ey0_070-full_output/'] = $
     [[find_closest(time.stamp,15.23), $
       find_closest(time.stamp,17.92)], $
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
