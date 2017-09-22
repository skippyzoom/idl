;+
; Execute common analysis code on data in
; the specified path.
;-
pro analyze_project, path, $
                     target, $
                     verbose=verbose

  ;;==Defaults and guards
  if n_elements(target) eq 0 then target = dictionary('data')
  if ~target.haskey('data_name') then target.data_name = list('den1','phi')
  if ~target.haskey('data_type') then target.data_type = ['ph5','ph5']
  if ~target.haskey('filetype') then target.filetype = '.png'
  if ~target.haskey('colorbar_type') then target.colorbar_type = 'global'

  ;;==Echo working path and store in project dictionary
  print, "ANALYZE_PROJECT: In ",path
  target['path'] = path

  ;;==Read the input file
  target['params'] = set_eppic_params(path)

  ;;==Assign grid to project
  target['grid'] = set_grid(path)

  ;;==Calculate max number of time steps available
  nt_max = calc_timesteps(path,target.grid)

  ;;==Set up graphics output steps
  if ~target.haskey('plotindex') then target['plotindex'] = [0,1]
  temp = floor(target.plotindex*nt_max)
  ge_max = where(temp ge nt_max,count)
  if count gt 0 then temp[ge_max] = nt_max-1
  target['plotindex'] = temp
  if ~target.haskey('plotlayout') then target['plotlayout'] = [1,2]

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

  ;;==Images of raw data
  project_data_graphics, target

  ;;==Images of spectrally transformed data
  project_spectral_graphics, target

end
