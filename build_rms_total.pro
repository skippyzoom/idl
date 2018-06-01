;+
; Helper function for den1ktt_rms_total
;-
function build_rms_total, proj_path, $
                          run, $
                          save_name, $
                          lun=lun, $
                          data_name=data_name

  ;;==Defaults
  if n_elements(lun) eq 0 then lun = -1
  if n_elements(data_name) eq 0 then data_name = 'den1ktt_rms'

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

  ;;==Get number of time steps
  nt = n_elements(ktt_rms[lambda[0]])

  ;;==Sum over all wavelengths
  rms_total = fltarr(nr,nt)*0.0
  for il=0,nl-1 do $
     rms_total[0,*] += ktt_rms[lambda[il]]

  ;;==Get input parameters
  params = set_eppic_params(path=path)
  nt_max = calc_timesteps(path=path)
  params['nt_max'] = nt_max

  ;;==Loop over remaining save files
  for ir=1,nr-1 do begin
     path = expand_path(proj_path)+path_sep()+run[ir]
     s_obj = obj_new('IDL_Savefile',expand_path(path)+path_sep()+save_name)
     s_obj->restore, data_name
     !NULL = execute('ktt_rms = '+data_name)
     for il=0,nl-1 do $
        rms_total[ir,*] += ktt_rms[lambda[il]]

  endfor

  ;;==Return the summed array
  return, rms_total

end
