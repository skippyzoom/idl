function build_multirun_kttrms, mr_ktt, $
                                data_name, $
                                lun=lun, $
                                run=run, $
                                lambda=lambda

  ;;==Set default LUN
  if n_elements(lun) eq 0 then lun = -1

  ;;==Get available runs
  all_runs = mr_ktt.keys()

  ;;==Sort runs into ascending order
  all_runs = all_runs.sort()

  ;;==Set default runs
  if n_elements(run) eq 0 then run = all_runs

  ;;==Get number of runs
  nr = n_elements(run)

  ;;==Get available wavelengths
  all_lambdas = (mr_ktt[run[0]])[data_name].keys()

  ;;==Sort wavelengths into ascending order
  all_lambdas = all_lambdas.sort()

  ;;==Set lambda default
  if n_elements(lambda) eq 0 then lambda = all_lambdas

  ;;==Get number of wavelengths
  nl = n_elements(lambda)

  ;;==Loop over runs to build RMS hash
  mr_kttrms = hash(run)
  for ir=0,nr-1 do begin
     current = mr_ktt[run[ir]]
     nt = n_elements(current.time.index)
     tmp = make_array(nt,value=0,/float)
     for il=0,nl-1 do $
        tmp += rms((current[data_name])[lambda[il]].f_interp,dim=1)
     mr_kttrms[run[ir]] = tmp
  endfor

  return, mr_kttrms
end
