;+
; Execute common analysis code on data in
; the specified directory.
;-
pro analyze_project, path, $
                     prj, $
                     verbose=verbose

  ;;==Read the input file
  params = set_eppic_params(path)

  ;;==Assign grid to project
  prj['grid'] = set_grid(path)

  ;;==Calculate max number of time steps available
  nt_max = calc_timesteps(path,prj.grid)

  ;;==Declare (untransposed) data ranges
  rngs = {x: [0,prj.grid.nx-1], $
          y: [0,prj.grid.ny-1], $
          z: [0,prj.grid.nz-1]}

  ;;==Load simulation data
  ;; if n_elements(dataName) eq 0 then dataName = list('den1','phi')
  ;; if n_elements(dataType) eq 0 then dataType = ['ph5','ph5']
  data = load_eppic_data(prj.data_name.toarray(), $
                         prj.data_type, $
                         path, $
                         timestep = params.nout*lindgen(nt_max))

  ;;==Calculate E-field from phi and store with simulation data?

  ;;==Pack up the project dictionary
  ;; prj = set_current_prj(data,rngs,grid, $
  ;;                       scale = scale, $
  ;;                       xyzt = xyzt, $
  ;;                       description = description)
  dKeys = data.keys()
  dSize = size(data[dKeys[0]])
  if prj.haskey('xyzt') then prj['xyzt'] = prj.xyzt[0:dSize[0]-1]
  prj = set_project_data(data,rngs,prj.grid,target=prj)

  ;;==Free unneeded memory
  delvar, rngs

  ;;==Set up appropriate units for graphics, based on prj.scale
  set_data_units, prj,params.units

  ;;==Declare which output steps to plot (if applicable)
  prj['plotindex'] = [nt_max/4,nt_max/2,3*nt_max/4,nt_max-1]
  prj['plotlayout'] = [2,2]

  ;;==Declare file type for graphics
  prj['filetype'] = '.png'

  ;;==Declare whether to use global or panel-specific colorbar
  prj['colorbar_type'] = 'global'

  ;;==Images of raw data
  ;; project_data_graphics, prj

  ;;==Images of spectrally transformed data
  ;; project_spectral_graphics, prj

  ;; ;;==Reset IDL's path
  ;; !PATH = paths.orig
end
