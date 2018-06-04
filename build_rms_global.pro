;+
; Helper function for *_rms_total scripts
;-
function build_rms_global, proj_path, $
                           run, $
                           save_name, $
                           data_name, $
                           lun=lun

  ;;==Defaults
  if n_elements(lun) eq 0 then lun = -1

  ;;==Get number of runs
  nr = n_elements(run)

  ;;==Restore first save file
  path = expand_path(proj_path)+path_sep()+run[0]
  s_obj = obj_new('IDL_Savefile',expand_path(path)+path_sep()+save_name)
  s_obj->restore, data_name
  !NULL = execute('fft_t = '+data_name)

  ;;==Get number of time steps
  fsize = size(fft_t)
  nt = fsize[fsize[0]]

  ;;==Calculate RMS over all points at each time
  rms_global = fltarr(nr,nt)
  for it=0,nt-1 do $
     rms_global[0,it] = rms(fft_t[*,*,it])
  
  ;;==Loop over remaining save files
  for ir=1,nr-1 do begin
     path = expand_path(proj_path)+path_sep()+run[ir]
     s_obj = obj_new('IDL_Savefile',expand_path(path)+path_sep()+save_name)
     s_obj->restore, data_name
     !NULL = execute('fft_t = '+data_name)
     for it=0,nt-1 do $
        rms_global[ir,it] = rms(fft_t[*,*,it])
  endfor
  
  ;;==Return the summed array
  return, rms_global

end
