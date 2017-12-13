function create_graphics_context, path=path

  ;;==Defaults and guards
  if n_elements(path) eq 0 then path = './'

  ;;==Set up global graphics options
  font_name = 'Times'
  font_size = 10

  ;;==Read in simulation parameters
  params = set_eppic_params(path=path)
  grid = set_grid(path=path)
  nt_max = calc_timesteps(path=path,grid=grid)
  
  ;;==Initialize the graphics context
  gc = dictionary()

  ;;==Store info common to all images
  key = 'info'
  gc[key] = dictionary()
  gc[key].path = path
  gc[key].layout = [2,2]
  nt = gc[key].layout[0]*gc[key].layout[1]
  gc[key].timestep = params.nout*(nt_max/(nt-1))*lindgen(nt)
  gc[key].position = multi_position(gc[key].layout)

  ;;==Store info specific to images
  key = 'image'
  gc[key] = hash()

  ;;==Store info for electrostatic potential
  key = 'Potential'
  gc.image[key] = dictionary()
  gc.image[key].data = dictionary('name','phi')
  gc.image[key].keywords = dictionary('rgb_table', 5, $
                                      'font_name', font_name, $
                                      'font_size', font_size)

  ;;==Store info for (forward) FFT of electrostatic potential
  key = 'FFT Potential'
  gc.image[key] = dictionary()
  gc.image[key].data = dictionary('name','phi', $
                                  'fft_direction', -1)
  gc.image[key].keywords = dictionary('rgb_table', 39, $
                                      'font_name', font_name, $
                                      'font_size', font_size)

  ;;==Store info for electric field
  key = 'E field'
  gc.image[key] = dictionary()
  gc.image[key].data = dictionary('name','phi', $
                                  'gradient', 1, $
                                  'scale', -1.0, $
                                  'rms', 1)
  gc.image[key].keywords = dictionary('rgb_table', 5, $
                                      'font_name', font_name, $
                                      'font_size', font_size)

  ;;==Store info for ion density
  key = 'Ion density'
  gc.image[key] = dictionary()
  gc.image[key].data = dictionary('name','den1')
  gc.image[key].keywords = dictionary('rgb_table', 5, $
                                      'font_name', font_name, $
                                      'font_size', font_size)

  ;;==Store info for EPPIC FT ion density
  key = 'FFT Ion density'
  gc.image[key] = dictionary()
  gc.image[key].data = dictionary('name','denft1', $
                                  'rotate_direction', 2)
  gc.image[key].keywords = dictionary('rgb_table', 39, $
                                      'font_name', font_name, $
                                      'font_size', font_size)


  return, gc
end
