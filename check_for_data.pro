;+
; Check for existence of a data quantity in parallel HDF files
;-
function check_for_data, data_name, $
                         count, $
                         lun=lun, $
                         base_path=base_path, $
                         data_dir=data_dir, $
                         ext=ext, $
                         fold_case=fold_case

  if n_elements(lun) eq 0 then lun = -1
  if n_elements(base_path) eq 0 then base_path = './'
  if n_elements(data_dir) eq 0 then data_dir = './'
  if n_elements(ext) eq 0 then ext = 'h5'
  if n_elements(fold_case) eq 0 then fold_case = 0B

  params = set_eppic_params(path=base_path)
  nt_max = calc_timesteps(path=base_path)
  data_path = expand_path(base_path+path_sep()+data_dir)
  file = file_search(data_path+path_sep()+'*.'+get_extension(ext))
  result = bytarr(nt_max)
  for it=0,nt_max-1 do $
     result[it] = string_exists(tag_names(h5_parse(file[it])), $
                                data_name,fold_case=fold_case)

  count = n_elements(where(result eq 1,/null))

  return, result
end
