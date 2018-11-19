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
; first and last quarters of the run). Beware that using find_closest
; is more robust to changes in the time dictionary than is prodiving
; a relative index such as time.nt/2.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;-
function get_rms_ranges, path, $
                         time, $
                         lun=lun, $
                         from_frm_indices=from_frm_indices, $
                         delta=delta

  ;;==Set defaults
  if n_elements(lun) eq 0 then lun = -1

  ;;==Read parameter dictionary, in case we need it
  params = set_eppic_params(path=path)

  ;;==Return RMS indices
  if keyword_set(from_frm_indices) then begin
     if n_elements(delta) eq 0 then delta = 1
     frm_ind = get_frm_indices(path,time)
     n_frm = n_elements(frm_ind)
     rms_ranges = lonarr(2,n_frm)
     for it=0,n_frm-1 do $
        rms_ranges[*,it] = [frm_ind[it]-delta,frm_ind[it]]
     return, rms_ranges
  endif $
  else begin
                                ;---------------;
                                ; FB_FLOW_ANGLE ;
                                ;---------------;
     case 1B of
        ;;==2-D FULL OUTPUT 30 mV/m
        strcmp(path,get_base_dir()+path_sep()+ $
                        'fb_flow_angle/2D-full_output/h0-Ey0_030/'): $
           rms_ranges = [[0,time.nt/2-1],[time.nt/2,time.nt-1]]
        strcmp(path,get_base_dir()+path_sep()+ $
                        'fb_flow_angle/2D-full_output/h1-Ey0_030/'): $
           rms_ranges = [[0,time.nt/2-1],[time.nt/2,time.nt-1]]
        strcmp(path,get_base_dir()+path_sep()+ $
                        'fb_flow_angle/2D-full_output/h2-Ey0_030/'): $
           rms_ranges = [[0,time.nt/2-1],[time.nt/2,time.nt-1]]
        ;;==2-D FULL OUTPUT 50 mV/m
        strcmp(path,get_base_dir()+path_sep()+ $
                        'fb_flow_angle/2D-full_output/h0-Ey0_050/'): $
           rms_ranges = [[find_closest(time.stamp,66.30), $
                          find_closest(time.stamp,77.06)], $
                         [find_closest(time.stamp,280), $
                          time.nt-1]]
        strcmp(path,get_base_dir()+path_sep()+ $
                        'fb_flow_angle/2D-full_output/h1-Ey0_050/'): $
           rms_ranges = [[find_closest(time.stamp,66.30), $
                          find_closest(time.stamp,77.06)], $
                         [find_closest(time.stamp,280), $
                          time.nt-1]]
        strcmp(path,get_base_dir()+path_sep()+ $
                        'fb_flow_angle/2D-full_output/h2-Ey0_050/'): $
           rms_ranges = [[find_closest(time.stamp,66.30), $
                          find_closest(time.stamp,77.06)], $
                         [find_closest(time.stamp,280), $
                          time.nt-1]]
        ;;==2-D FULL OUTPUT 70 mV/m
        strcmp(path,get_base_dir()+path_sep()+ $
                        'fb_flow_angle/2D-full_output/h0-Ey0_070/'): $
           rms_ranges = [[find_closest(time.stamp,51.97), $
                          find_closest(time.stamp,62.72)], $
                         [find_closest(time.stamp,280), $
                          time.nt-1]]
        strcmp(path,get_base_dir()+path_sep()+ $
                        'fb_flow_angle/2D-full_output/h1-Ey0_070/'): $
           rms_ranges = [[find_closest(time.stamp,51.97), $
                          find_closest(time.stamp,62.72)], $
                         [find_closest(time.stamp,280), $
                          time.nt-1]]
        strcmp(path,get_base_dir()+path_sep()+ $
                        'fb_flow_angle/2D-full_output/h2-Ey0_070/'): $
           rms_ranges = [[find_closest(time.stamp,51.97), $
                          find_closest(time.stamp,62.72)], $
                         [find_closest(time.stamp,280), $
                          time.nt-1]]
        ;;==3-D FULL OUTPUT 30 mV/m
        strcmp(path,get_base_dir()+path_sep()+ $
                        'fb_flow_angle/3D-full_output/h0-Ey0_030/'): $
           rms_ranges = [[0,time.nt/2-1],[time.nt/2,time.nt-1]]
        strcmp(path,get_base_dir()+path_sep()+ $
                        'fb_flow_angle/3D-full_output/h1-Ey0_030/'): $
           rms_ranges = [[0,time.nt/2-1],[time.nt/2,time.nt-1]]
        strcmp(path,get_base_dir()+path_sep()+ $
                        'fb_flow_angle/3D-full_output/h2-Ey0_030/'): $
           rms_ranges = [[0,time.nt/2-1],[time.nt/2,time.nt-1]]
        ;;==3-D FULL OUTPUT 50 mV/m
        strcmp(path,get_base_dir()+path_sep()+ $
                        'fb_flow_angle/3D-full_output/h0-Ey0_050/'): $
           rms_ranges = [[find_closest(time.stamp,30.91), $
                          find_closest(time.stamp,33.60)], $
                         [find_closest(time.stamp,70), $
                          time.nt-1]]
        strcmp(path,get_base_dir()+path_sep()+ $
                        'fb_flow_angle/3D-full_output/h1-Ey0_050/'): $
           rms_ranges = [[find_closest(time.stamp,30.91), $
                          find_closest(time.stamp,33.60)], $
                         [find_closest(time.stamp,70), $
                          time.nt-1]]
        strcmp(path,get_base_dir()+path_sep()+ $
                        'fb_flow_angle/3D-full_output/h2-Ey0_050/'): $
           rms_ranges = [[find_closest(time.stamp,34.50), $
                          find_closest(time.stamp,37.18)], $
                         [find_closest(time.stamp,70), $
                          time.nt-1]]
        ;;==3-D FULL OUTPUT 70 mV/m
        strcmp(path,get_base_dir()+path_sep()+ $
                        'fb_flow_angle/3D-full_output/h0-Ey0_070/'): $
           rms_ranges = [[find_closest(time.stamp,16.58), $
                          find_closest(time.stamp,19.26)], $
                         [find_closest(time.stamp,70), $
                          time.nt-1]]
        strcmp(path,get_base_dir()+path_sep()+ $
                        'fb_flow_angle/3D-full_output/h1-Ey0_070/'): $
           rms_ranges = [[find_closest(time.stamp,16.58), $
                          find_closest(time.stamp,19.26)], $
                         [find_closest(time.stamp,70), $
                          time.nt-1]]
        strcmp(path,get_base_dir()+path_sep()+ $
                        'fb_flow_angle/3D-full_output/h2-Ey0_070/'): $
           rms_ranges = [[find_closest(time.stamp,16.58), $
                          find_closest(time.stamp,19.26)], $
                         [find_closest(time.stamp,70), $
                          time.nt-1]]

        ;;==2-D NEW COLL 50 mV/m
        strcmp(path,get_base_dir()+path_sep()+ $
                        'fb_flow_angle/2D-new_coll/h0-Ey0_050/'): $
           rms_ranges = [[find_closest(time.stamp,66.30), $
                          find_closest(time.stamp,77.06)], $
                         [find_closest(time.stamp,280), $
                          time.nt-1]]
        strcmp(path,get_base_dir()+path_sep()+ $
                        'fb_flow_angle/2D-new_coll/h1-Ey0_050/'): $
           rms_ranges = [[find_closest(time.stamp,66.30), $
                          find_closest(time.stamp,77.06)], $
                         [find_closest(time.stamp,280), $
                          time.nt-1]]
        strcmp(path,get_base_dir()+path_sep()+ $
                        'fb_flow_angle/2D-new_coll/h2-Ey0_050/'): $
           rms_ranges = [[find_closest(time.stamp,66.30), $
                          find_closest(time.stamp,77.06)], $
                         [find_closest(time.stamp,280), $
                          time.nt-1]]
        ;;==2-D NEW COLL 70 mV/m
        strcmp(path,get_base_dir()+path_sep()+ $
                        'fb_flow_angle/2D-new_coll/h0-Ey0_070/'): $
           rms_ranges = [[find_closest(time.stamp,51.97), $
                          find_closest(time.stamp,62.72)], $
                         [find_closest(time.stamp,280), $
                          time.nt-1]]
        strcmp(path,get_base_dir()+path_sep()+ $
                        'fb_flow_angle/2D-new_coll/h1-Ey0_070/'): $
           rms_ranges = [[find_closest(time.stamp,51.97), $
                          find_closest(time.stamp,62.72)], $
                         [find_closest(time.stamp,280), $
                          time.nt-1]]
        strcmp(path,get_base_dir()+path_sep()+ $
                        'fb_flow_angle/2D-new_coll/h2-Ey0_070/'): $
           rms_ranges = [[find_closest(time.stamp,51.97), $
                          find_closest(time.stamp,62.72)], $
                         [find_closest(time.stamp,280), $
                          time.nt-1]]
        ;;==3-D NEW COLL 50 mV/m
        strcmp(path,get_base_dir()+path_sep()+ $
                        'fb_flow_angle/3D-new_coll/h0-Ey0_050/'): $
           rms_ranges = [[find_closest(time.stamp,30.91), $
                          find_closest(time.stamp,33.60)], $
                         [find_closest(time.stamp,70), $
                          time.nt-1]]
        strcmp(path,get_base_dir()+path_sep()+ $
                        'fb_flow_angle/3D-new_coll/h1-Ey0_050/'): $
           rms_ranges = [[find_closest(time.stamp,30.91), $
                          find_closest(time.stamp,33.60)], $
                         [find_closest(time.stamp,70), $
                          time.nt-1]]
        strcmp(path,get_base_dir()+path_sep()+ $
                        'fb_flow_angle/3D-new_coll/h2-Ey0_050/'): $
           rms_ranges = [[find_closest(time.stamp,34.50), $
                          find_closest(time.stamp,37.18)], $
                         [find_closest(time.stamp,70), $
                          time.nt-1]]
        ;;==3-D NEW COLL 70 mV/m
        strcmp(path,get_base_dir()+path_sep()+ $
                        'fb_flow_angle/3D-new_coll/h0-Ey0_070/'): $
           rms_ranges = [[find_closest(time.stamp,16.58), $
                          find_closest(time.stamp,19.26)], $
                         [find_closest(time.stamp,70), $
                          time.nt-1]]
        strcmp(path,get_base_dir()+path_sep()+ $
                        'fb_flow_angle/3D-new_coll/h1-Ey0_070/'): $
           rms_ranges = [[find_closest(time.stamp,16.58), $
                          find_closest(time.stamp,19.26)], $
                         [find_closest(time.stamp,70), $
                          time.nt-1]]
        strcmp(path,get_base_dir()+path_sep()+ $
                        'fb_flow_angle/3D-new_coll/h2-Ey0_070/'): $
           rms_ranges = [[find_closest(time.stamp,16.58), $
                          find_closest(time.stamp,19.26)], $
                         [find_closest(time.stamp,70), $
                          time.nt-1]]
        else: begin
           printf, lun,"[GET_RMS_RANGES] Could not match path. "+ $
                   "Returning full time."
           rms_ranges = [0,time.nt-1]
        end
     endcase

     return, rms_ranges
  endelse

end
