;+
; Execute common analysis code on data in
; the specified directory.
;-
pro analyze_project, directory, $
                     description=description, $
                     data_name=data_name, $
                     data_type=data_type, $
                     data_scale=data_scale, $
                     data_xyzt=data_xyzt, $
                     data_grid=data_grid, $
                     verbose=verbose

  cd, directory

;; @load_eppic_params

  ;;==Declare (untransposed) data ranges
  rngs = {x: [0,grid.nx-1], $
          y: [0,grid.ny-1], $
          z: [0,grid.nz-1]}

  ;;==Load simulation data
  if n_elements(dataName) eq 0 then dataName = list('den1','phi')
  if n_elements(dataType) eq 0 then dataType = ['ph5','ph5']
  data = load_eppic_data(dataName.toarray(),dataType,timestep=nout*lindgen(ntMax))

  ;;==Calculate E-field from phi and store with simulation data?

  ;;==Pack up the project dictionary
  prj = set_current_prj(data,rngs,grid, $
                        scale = scale, $
                        xyzt = xyzt, $
                        description = description)
  ;;==Free unneeded memory
  delvar, rngs

  ;;==Set up appropriate units for graphics, based on prj.scale
  set_data_units, prj,units

  ;;==Declare which output steps to plot (if applicable)
  prj['plotindex'] = [ntMax/4,ntMax/2,3*ntMax/4,ntMax-1]
  prj['plotlayout'] = [2,2]

  ;;==Declare file type for graphics
  prj['filetype'] = '.png'

  ;;==Declare whether to use global or panel-specific colorbar
  prj['colorbar_type'] = 'global'

;; @eppic_graphics
  ;;==Images of raw data
  project_data_graphics, prj

  ;;==Images of spectrally transformed data
  ;; project_spectral_graphics, prj

end
