;+
; A lightweight routine for checking EPPIC simulation output
; prior to more intensive analysis. 
;
; KEEP THIS ROUTINE SIMPLE
; -- Use as few levels of subroutines as possible.
; -- Use IDL-distribution routines as much as possible.
; -- Use only well-tested homemade routines.
; -- Avoid doing complicated analysis.
;    For example: It's okay to calculate an FFT for the
;    sake of plotting a basic spectrum but don't further
;    use that spectrum to calculate V_phase versus |k|. 
;    Do that in a more robust analysis pipeline.
;-
pro eppic_first_look, path,directory=directory

  ;;==Navigate to working directory
  cd, path

  ;;==Echo working directory
  print, "[EPPIC_FIRST_LOOK] In ",path
  
  ;;==Set up graphics keywords
  font_name = 'Times'
  font_size = 10

  ;;==Make a special directory for these graphics
  if n_elements(directory) eq 0 then directory = './'
  spawn, 'mkdir -p '+directory

  ;;==Read in simulation parameters
  params = set_eppic_params(path=path)
  grid = set_grid(path=path)
  nt_max = calc_timesteps(path=path,grid=grid)

  ;;==Choose time steps to read
  timestep = params.nout*[0,nt_max-1]

                                ;---------;
                                ; Moments ;
                                ;---------;
  ;;==Read in data
  moments = analyze_moments(path=path)

  ;;==Create plots
  plot_moments, moments,params=params, $
                path=path+path_sep()+directory, $
                font_name=font_name,font_size=font_size
  
                                ;-----------;
                                ; Potential ;
                                ;-----------;
  ;;==Read in data
  data = load_eppic_data('phi',path=path,timestep=timestep)
  ;;==Create images
  if n_elements(data.phi) ne 0 then $
     efl_image, data.phi,name='phi', $
                path=path+path_sep()+directory, $
                center=[grid.nx/2,grid.ny/2,grid.nz/2], $
                rgb_table=5,font_name=font_name,font_size=font_size
  ;;==Free memory
  data = !NULL

                                ;---------;
                                ; Density ;
                                ;---------;
  ;;==Read in data
  data = load_eppic_data(['den0','den1'],path=path,timestep=timestep)
  ;;==Create images
  if n_elements(data.den0) ne 0 then $
     efl_image, data.den0,name='den0', $
                path=path+path_sep()+directory, $
                center=[grid.nx/2,grid.ny/2,grid.nz/2], $
                rgb_table=5,font_name=font_name,font_size=font_size
  if n_elements(data.den1) ne 0 then $
     efl_image, data.den1,name='den1', $
                path=path+path_sep()+directory, $
                center=[grid.nx/2,grid.ny/2,grid.nz/2], $
                rgb_table=5,font_name=font_name,font_size=font_size
  ;;==Free memory
  data = !NULL

                                ;-----------------------------;
                                ; Fourier-transformed density ;
                                ;-----------------------------;
  ;;==Read in data
  data = load_eppic_data(['denft0','denft1'],path=path,timestep=timestep)
  ;;==Create images
  if n_elements(data.denft0) ne 0 then $
     efl_image, data.denft0,name='denft0', $
                path=path+path_sep()+directory, $
                center=[0,0,0], $
                rgb_table=39,font_name=font_name,font_size=font_size
  if n_elements(data.denft1) ne 0 then $
     efl_image, data.denft1,name='denft1', $
                path=path+path_sep()+directory, $
                center=[0,0,0], $
                rgb_table=39,font_name=font_name,font_size=font_size
STOP
  ;;==Free memory
  data = !NULL
end
