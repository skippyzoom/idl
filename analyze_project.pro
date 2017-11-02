;+
; Execute common analysis code on data in
; the specified path.
;
; TO DO
; -- Check for consistency between plotlayout and plotindex?
;    May be better to do that in graphics routines.
;-
pro analyze_project, path, $
                     target, $
                     verbose=verbose

  ;;==Defaults and guards
  if n_elements(target) eq 0 then target = dictionary('data')
  if ~target.haskey('data_name') then target.data_name = list('den1','phi')
  nNames = target.data_name.count()
  if ~target.haskey('data_type') then target.data_type = ['ph5','ph5']
  if ~target.haskey('imgtype') then target.imgtype = '.png'
  if ~target.haskey('movtype') then target.movtype = '.mp4'
  if ~target.haskey('colorbar_type') then target.colorbar_type = 'global'
  if ~target.haskey('plotindex') then target.plotindex = [0,1]
  if ~target.haskey('plotlayout') then target.plotlayout = [1,2]
  if ~target.haskey('rgb_table') then $
     target.rgb_table = dictionary(target.data_name.toarray(),make_array(nNames,value=0))

  ;;==Echo working path and store in project dictionary
  print, "ANALYZE_PROJECT: In ",path
  target['path'] = path

  ;;==Read the input file
  target['params'] = set_eppic_params(path)

  ;;==Assign grid to project
  target['grid'] = set_grid(path)

  ;;==Calculate max number of time steps available
  nt_max = calc_timesteps(path,target.grid)
  target.params['nt_max'] = nt_max

  ;;==Set up graphics output steps
  temp = floor(target.plotindex*nt_max)
  ge_max = where(temp ge nt_max,count)
  if count gt 0 then temp[ge_max] = nt_max-1
  target['plotindex'] = temp

  ;;==Load simulation data
  data = load_eppic_data(target.data_name.toarray(), $
                         target.data_type, $
                         path = target.path, $
                         timestep = target.params.nout*lindgen(nt_max))

  ;;==Pack up the project dictionary
  dKeys = data.keys()
  dSize = size(data[dKeys[0]])
  if target.haskey('xyzt') then target['xyzt'] = target.xyzt[0:dSize[0]-1]
  target = set_project_data(data,target.grid,target=target[*])

  ;;==Set up appropriate units for graphics, based on target.scale
  set_data_units, target,target.params.units
  target['data_label'] = set_data_labels(target.data_name.toarray())

  ;;==Images of raw data
  project_data_graphics, target

  ;;==Movies of raw data
  project_data_movies, target

  ;;==Images of spectrally transformed data
  ;; project_spectral_graphics, target

end
