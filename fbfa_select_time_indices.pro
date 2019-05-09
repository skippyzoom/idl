;+
; Flow angle paper: A unified interface for selecting snapshot time
; indices. 
;-
function fbfa_select_time_indices, path,time

  case 1B of
     strcmp(path, $
                '2D-new_coll'+path_sep()+'h0-Ey0_050'+path_sep()): $
        t_ind = [find_closest(float(time.stamp),78.85), $
                 time.nt-1]
     strcmp(path, $
                '2D-new_coll'+path_sep()+'h1-Ey0_050'+path_sep()): $
        t_ind = [find_closest(float(time.stamp),78.85), $
                 time.nt-1]
     strcmp(path, $
                '2D-new_coll'+path_sep()+'h2-Ey0_050'+path_sep()): $
        t_ind = [find_closest(float(time.stamp),111.10), $
                 time.nt-1]
     strcmp(path, $
                '3D-new_coll'+path_sep()+'h0-Ey0_050'+path_sep()): $
        t_ind = [find_closest(float(time.stamp),30.46), $
                 time.nt-1]
     strcmp(path, $
                '3D-new_coll'+path_sep()+'h1-Ey0_050'+path_sep()): $
        t_ind = [find_closest(float(time.stamp),25.09), $
                 time.nt-1]
     strcmp(path, $
                '3D-new_coll'+path_sep()+'h2-Ey0_050'+path_sep()): $
        t_ind = [find_closest(float(time.stamp),30.46), $
                 time.nt-1]
  endcase         

return, t_ind
end
