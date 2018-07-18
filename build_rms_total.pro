;+
; Helper function for *_rms_total scripts
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;-
function build_rms_total, proj_path, $
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
  !NULL = execute('ktt_rms = '+data_name)

  ;;==Get wavelengths
  lambda = ktt_rms.keys()
  lambda = lambda.sort()
  nl = n_elements(lambda)

  ;;==Get max number of time steps
  nt = 0L
  for ir=0,nr-1 do begin
     path = expand_path(proj_path)+path_sep()+run[ir]
     s_obj = obj_new('IDL_Savefile',expand_path(path)+path_sep()+save_name)
     s_obj->restore, data_name
     !NULL = execute('ktt_rms = '+data_name)
     for il=0,nl-1 do $
        nt = max([nt,n_elements(ktt_rms[lambda[il]])])
  endfor

  ;;==Sum over all wavelengths for each run
  rms_total = hash(run)
  for ir=0,nr-1 do begin
     path = expand_path(proj_path)+path_sep()+run[ir]
     s_obj = obj_new('IDL_Savefile',expand_path(path)+path_sep()+save_name)
     s_obj->restore, data_name
     !NULL = execute('ktt_rms = '+data_name)
     ktt_rms_sum = make_array(size(ktt_rms[lambda[0]],/dim),value=0.0)
     for il=0,nl-1 do $
        ktt_rms_sum += ktt_rms[lambda[il]]
     rms_total[run[ir]] = ktt_rms_sum
  endfor     

  ;;==Return the summed array
  return, rms_total

end
