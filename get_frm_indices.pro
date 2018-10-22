;+
; Return time indices for single-frames of a given run.
;
; This function needs to return indices into EPPIC arrays. There are a
; few ways to accomplish that. You could use find_closest with the
; time dictionary to provide a time stamp (approximate or exact)
; corresponding to the appropriate index. You could use the index
; member of the time dictionary, divided by params.nout, if you know
; the time range in term of time steps. You could also simply provide
; the output indices if you know them (e.g., you know you want the
; first and last quarters of the run). Beware that using find_closest
; is more robust to changes in the time dictionary than is prodiving
; a relative index such as time.nt/2.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;-
function get_frm_indices, path, $
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
     [time.nt/2,time.nt-1]
  rms_time[get_base_dir()+path_sep()+ $
           'fb_flow_angle/2D/h1-Ey0_030-full_output/'] = $
     [time.nt/2,time.nt-1]
  rms_time[get_base_dir()+path_sep()+ $
           'fb_flow_angle/2D/h2-Ey0_030-full_output/'] = $
     [time.nt/2,time.nt-1]
  ;;==2-D 50 mV/m
  rms_time[get_base_dir()+path_sep()+ $
           'fb_flow_angle/2D/h0-Ey0_050-full_output/'] = $
     [find_closest(time.stamp,71.68),time.nt-1]
  rms_time[get_base_dir()+path_sep()+ $
           'fb_flow_angle/2D/h1-Ey0_050-full_output/'] = $
     [find_closest(time.stamp,71.68),time.nt-1]
  rms_time[get_base_dir()+path_sep()+ $
           'fb_flow_angle/2D/h2-Ey0_050-full_output/'] = $
     [find_closest(time.stamp,71.68),time.nt-1]
  ;;==2-D 70 mV/m
  rms_time[get_base_dir()+path_sep()+ $
           'fb_flow_angle/2D/h0-Ey0_070-full_output/'] = $
     [find_closest(time.stamp,57.34),time.nt-1]
  rms_time[get_base_dir()+path_sep()+ $
           'fb_flow_angle/2D/h1-Ey0_070-full_output/'] = $
     [find_closest(time.stamp,57.34),time.nt-1]
  rms_time[get_base_dir()+path_sep()+ $
           'fb_flow_angle/2D/h2-Ey0_070-full_output/'] = $
     [find_closest(time.stamp,57.34),time.nt-1]
  ;;==3-D 30 mV/m
  rms_time[get_base_dir()+path_sep()+ $
           'fb_flow_angle/3D/h0-Ey0_030-full_output/'] = $
     [time.nt/2,time.nt-1]
  rms_time[get_base_dir()+path_sep()+ $
           'fb_flow_angle/3D/h1-Ey0_030-full_output/'] = $
     [time.nt/2,time.nt-1]
  rms_time[get_base_dir()+path_sep()+ $
           'fb_flow_angle/3D/h2-Ey0_030-full_output/'] = $
     [time.nt/2,time.nt-1]
  ;;==3-D 50 mV/m
  rms_time[get_base_dir()+path_sep()+ $
           'fb_flow_angle/3D/h0-Ey0_050-full_output/'] = $
     [find_closest(time.stamp,32.26),time.nt-1]
  rms_time[get_base_dir()+path_sep()+ $
           'fb_flow_angle/3D/h1-Ey0_050-full_output/'] = $
     [find_closest(time.stamp,32.26),time.nt-1]
  rms_time[get_base_dir()+path_sep()+ $
           'fb_flow_angle/3D/h2-Ey0_050-full_output/'] = $
     [find_closest(time.stamp,32.26),time.nt-1]
  ;;==3-D 70 mV/m
  rms_time[get_base_dir()+path_sep()+ $
           'fb_flow_angle/3D/h0-Ey0_070-full_output/'] = $
     [find_closest(time.stamp,21.50),time.nt-1]
  rms_time[get_base_dir()+path_sep()+ $
           'fb_flow_angle/3D/h1-Ey0_070-full_output/'] = $
     [find_closest(time.stamp,21.50),time.nt-1]
  rms_time[get_base_dir()+path_sep()+ $
           'fb_flow_angle/3D/h2-Ey0_070-full_output/'] = $
     [find_closest(time.stamp,21.50),time.nt-1]
  
  if rms_time.haskey(path) then begin
     return, rms_time[path]
  endif $
  else begin
     printf, lun,"[GET_FRM_INDICES] Could not match path. Returning {0,nt-1}."
     return, [0,time.nt-1]
  end

end
