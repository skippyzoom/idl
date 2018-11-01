;+
; Return a reader-friendly label for a given path
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;-
function get_run_label, path, $
                        lun=lun

  ;;==Set defaults
  if n_elements(lun) eq 0 then lun = -1

  ;;==Build look-up hash
  label = hash()

                                ;---------------;
                                ; FB_FLOW_ANGLE ;
                                ;---------------;
     
     ;;==2-D FULL OUTPUT 30 mV/m
     label[get_base_dir()+path_sep()+ $
              'fb_flow_angle/2D-full_output/h0-Ey0_030/'] = $
        'h = 107 km $E_0$ = 30 mV/m (2D)'
     label[get_base_dir()+path_sep()+ $
              'fb_flow_angle/2D-full_output/h1-Ey0_030/'] = $
        'h = 110 km $E_0$ = 30 mV/m (2D)'
     label[get_base_dir()+path_sep()+ $
              'fb_flow_angle/2D-full_output/h2-Ey0_030/'] = $
        'h = 113 km $E_0$ = 30 mV/m (2D)'
     ;;==2-D FULL OUTPUT 50 mV/m
     label[get_base_dir()+path_sep()+ $
              'fb_flow_angle/2D-full_output/h0-Ey0_050/'] = $
        'h = 107 km $E_0$ = 50 mV/m (2D)'
     label[get_base_dir()+path_sep()+ $
              'fb_flow_angle/2D-full_output/h1-Ey0_050/'] = $
        'h = 110 km $E_0$ = 50 mV/m (2D)'
     label[get_base_dir()+path_sep()+ $
              'fb_flow_angle/2D-full_output/h2-Ey0_050/'] = $
        'h = 113 km $E_0$ = 50 mV/m (2D)'
     ;;==2-D FULL OUTPUT 70 mV/m
     label[get_base_dir()+path_sep()+ $
              'fb_flow_angle/2D-full_output/h0-Ey0_070/'] = $
        'h = 107 km $E_0$ = 70 mV/m (2D)'
     label[get_base_dir()+path_sep()+ $
              'fb_flow_angle/2D-full_output/h1-Ey0_070/'] = $
        'h = 110 km $E_0$ = 70 mV/m (2D)'
     label[get_base_dir()+path_sep()+ $
              'fb_flow_angle/2D-full_output/h2-Ey0_070/'] = $
        'h = 113 km $E_0$ = 70 mV/m (2D)'
     ;;==3-D FULL OUTPUT 30 mV/m
     label[get_base_dir()+path_sep()+ $
              'fb_flow_angle/3D-full_output/h0-Ey0_030/'] = $
        'h = 107 km $E_0$ = 30 mV/m (3D)'
     label[get_base_dir()+path_sep()+ $
              'fb_flow_angle/3D-full_output/h1-Ey0_030/'] = $
        'h = 110 km $E_0$ = 30 mV/m (3D)'
     label[get_base_dir()+path_sep()+ $
              'fb_flow_angle/3D-full_output/h2-Ey0_030/'] = $
        'h = 113 km $E_0$ = 30 mV/m (3D)'
     ;;==3-D FULL OUTPUT 50 mV/m
     label[get_base_dir()+path_sep()+ $
              'fb_flow_angle/3D-full_output/h0-Ey0_050/'] = $
        'h = 107 km $E_0$ = 50 mV/m (3D)'
     label[get_base_dir()+path_sep()+ $
              'fb_flow_angle/3D-full_output/h1-Ey0_050/'] = $
        'h = 110 km $E_0$ = 50 mV/m (3D)'
     label[get_base_dir()+path_sep()+ $
              'fb_flow_angle/3D-full_output/h2-Ey0_050/'] = $
        'h = 113 km $E_0$ = 50 mV/m (3D)'
     ;;==3-D FULL OUTPUT 70 mV/m
     label[get_base_dir()+path_sep()+ $
              'fb_flow_angle/3D-full_output/h0-Ey0_070/'] = $
        'h = 107 km $E_0$ = 70 mV/m (3D)'
     label[get_base_dir()+path_sep()+ $
              'fb_flow_angle/3D-full_output/h1-Ey0_070/'] = $
        'h = 110 km $E_0$ = 70 mV/m (3D)'
     label[get_base_dir()+path_sep()+ $
              'fb_flow_angle/3D-full_output/h2-Ey0_070/'] = $
        'h = 113 km $E_0$ = 70 mV/m (3D)'

     ;;==2-D NEW COLL 30 mV/m
     label[get_base_dir()+path_sep()+ $
              'fb_flow_angle/2D-new_coll/h0-Ey0_030/'] = $
        'h = 107 km $E_0$ = 30 mV/m (2D)'
     label[get_base_dir()+path_sep()+ $
              'fb_flow_angle/2D-new_coll/h1-Ey0_030/'] = $
        'h = 110 km $E_0$ = 30 mV/m (2D)'
     label[get_base_dir()+path_sep()+ $
              'fb_flow_angle/2D-new_coll/h2-Ey0_030/'] = $
        'h = 113 km $E_0$ = 30 mV/m (2D)'
     ;;==2-D NEW COLL 50 mV/m
     label[get_base_dir()+path_sep()+ $
              'fb_flow_angle/2D-new_coll/h0-Ey0_050/'] = $
        'h = 107 km $E_0$ = 50 mV/m (2D)'
     label[get_base_dir()+path_sep()+ $
              'fb_flow_angle/2D-new_coll/h1-Ey0_050/'] = $
        'h = 110 km $E_0$ = 50 mV/m (2D)'
     label[get_base_dir()+path_sep()+ $
              'fb_flow_angle/2D-new_coll/h2-Ey0_050/'] = $
        'h = 113 km $E_0$ = 50 mV/m (2D)'
     ;;==2-D NEW COLL 70 mV/m
     label[get_base_dir()+path_sep()+ $
              'fb_flow_angle/2D-new_coll/h0-Ey0_070/'] = $
        'h = 107 km $E_0$ = 70 mV/m (2D)'
     label[get_base_dir()+path_sep()+ $
              'fb_flow_angle/2D-new_coll/h1-Ey0_070/'] = $
        'h = 110 km $E_0$ = 70 mV/m (2D)'
     label[get_base_dir()+path_sep()+ $
              'fb_flow_angle/2D-new_coll/h2-Ey0_070/'] = $
        'h = 113 km $E_0$ = 70 mV/m (2D)'
     ;;==3-D NEW COLL 30 mV/m
     label[get_base_dir()+path_sep()+ $
              'fb_flow_angle/3D-new_coll/h0-Ey0_030/'] = $
        'h = 107 km $E_0$ = 30 mV/m (3D)'
     label[get_base_dir()+path_sep()+ $
              'fb_flow_angle/3D-new_coll/h1-Ey0_030/'] = $
        'h = 110 km $E_0$ = 30 mV/m (3D)'
     label[get_base_dir()+path_sep()+ $
              'fb_flow_angle/3D-new_coll/h2-Ey0_030/'] = $
        'h = 113 km $E_0$ = 30 mV/m (3D)'
     ;;==3-D NEW COLL 50 mV/m
     label[get_base_dir()+path_sep()+ $
              'fb_flow_angle/3D-new_coll/h0-Ey0_050/'] = $
        'h = 107 km $E_0$ = 50 mV/m (3D)'
     label[get_base_dir()+path_sep()+ $
              'fb_flow_angle/3D-new_coll/h1-Ey0_050/'] = $
        'h = 110 km $E_0$ = 50 mV/m (3D)'
     label[get_base_dir()+path_sep()+ $
              'fb_flow_angle/3D-new_coll/h2-Ey0_050/'] = $
        'h = 113 km $E_0$ = 50 mV/m (3D)'
     ;;==3-D NEW COLL 70 mV/m
     label[get_base_dir()+path_sep()+ $
              'fb_flow_angle/3D-new_coll/h0-Ey0_070/'] = $
        'h = 107 km $E_0$ = 70 mV/m (3D)'
     label[get_base_dir()+path_sep()+ $
              'fb_flow_angle/3D-new_coll/h1-Ey0_070/'] = $
        'h = 110 km $E_0$ = 70 mV/m (3D)'
     label[get_base_dir()+path_sep()+ $
              'fb_flow_angle/3D-new_coll/h2-Ey0_070/'] = $
        'h = 113 km $E_0$ = 70 mV/m (3D)'

     if label.haskey(path) then begin
        return, label[path]
     endif $
     else begin
        printf, lun,"[GET_RUN_LABEL] Could not match path."
        return, ''
     endelse

  return, label[path]
end
