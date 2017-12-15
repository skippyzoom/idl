function create_graphics_context, path=path

  ;;==Defaults and guards
  if n_elements(path) eq 0 then path = './'

  ;;==Declare common image keywords
  font_name = 'Times'
  font_size = 10
  axis_style = 0
  layout = [2,2]
  position = multi_position(layout[*], $
                            edges = [0.12,0.10,0.80,0.80], $
                            buffer = [0.00,0.10])

  ;;==Read in simulation parameters
  params = set_eppic_params(path=path)
  grid = set_grid(path=path)
  nt_max = calc_timesteps(path=path,grid=grid)
  
  ;;==Set up spatial ranges
  ranges = {x: [0,grid.nx-1], $
            y: [0,grid.ny-1], $
            z: [0,grid.nz-1]}
  center = {x: grid.nx/2, $
            y: grid.ny/2, $
            z: grid.nz/2}
  vecs = {x: grid.x, $
          y: grid.y, $
          z: grid.z} 
  transpose = [0,1,2,3]
  xrng = ranges.(transpose[0])
  yrng = ranges.(transpose[1])
  zrng = ranges.(transpose[2])
  xctr = center.(transpose[0])
  yctr = center.(transpose[1])
  zctr = center.(transpose[2])
  xvec = vecs.(transpose[0])
  yvec = vecs.(transpose[1])
  zvec = vecs.(transpose[2])

  ;;==Initialize the graphics context
  gc = dictionary()

  ;;==Store info common to all images
  key = 'global'
  gc[key] = dictionary()
  gc[key].ext = 'pdf'
  gc[key].path = path
  nt = layout[0]*layout[1]
  gc[key].timestep = params.nout*(nt_max/(nt-1))*lindgen(nt)

  ;;==Store info about image dimesions, etc.
  ;;  r is for coordinate space
  ;;  k is for spectral space
  key = 'grid'
  gc[key] = dictionary()
  gc[key].r = dictionary('xrng', xrng, $
                         'yrng', yrng, $
                         'zrng', zrng, $
                         'xctr', xctr, $
                         'yctr', yctr, $
                         'zctr', zctr, $
                         'xvec', xvec, $
                         'yvec', yvec, $
                         'zvec', zvec, $
                         'transpose', transpose)
  gc[key].k = dictionary('xrng', xrng, $
                         'yrng', yrng, $
                         'zrng', zrng, $
                         'xctr', xctr, $
                         'yctr', yctr, $
                         'zctr', zctr, $
                         'xvec', xvec, $
                         'yvec', yvec, $
                         'zvec', zvec, $
                         'transpose', transpose)

  ;;==Store info for the colorbar(s)
  key = 'colorbar'
  gc[key] = dictionary()
  gc[key].keywords = dictionary('orientation', 1, $
                                'textpos', 1, $
                                'tickdir', 1, $
                                'ticklen', 0.2, $
                                'major', 7, $
                                'font_name', 'Times', $
                                'font_size', 8.0, $
                                'width', 0.0225, $
                                'height', 0.40, $
                                'buffer', 0.03, $
                                'type', 'global')

  ;;==Store info specific to images
  key = 'image'
  gc[key] = hash()

  ;;==Electrostatic potential
  key = 'Potential'
  gc.image[key] = dictionary()
  gc.image[key].data = dictionary('name', 'phi', $
                                  'scale', 1e3, $
                                  'units', '[mV]', $
                                  'symbol', '$\phi$', $
                                  'grid', 'r')
  gc.image[key].data.filebase = gc.image[key].data.name
  gc.image[key].keywords = dictionary('rgb_table', 5, $
                                      'layout', layout, $
                                      'position', position, $
                                      'axis_style', axis_style, $
                                      'font_name', font_name, $
                                      'font_size', font_size)

  ;; ;;==Forward FFT of electrostatic potential
  ;; key = 'FFT Potential'
  ;; gc.image[key] = dictionary()
  ;; gc.image[key].data = dictionary('name','phi', $
  ;;                                 'symbol', 'FFT($\phi$)', $
  ;;                                 'grid', 'k', $
  ;;                                 'fft_direction', -1)
  ;; gc.image[key].data.filebase = gc.image[key].data.name+'-fwdFT'
  ;; gc.image[key].keywords = dictionary('rgb_table', 39, $
  ;;                                     'layout', layout, $
  ;;                                     'position', position, $
  ;;                                     'axis_style', axis_style, $
  ;;                                     'font_name', font_name, $
  ;;                                     'font_size', font_size)

  ;;==RMS Electric field
  key = 'RMS E field'
  gc.image[key] = dictionary()
  gc.image[key].data = dictionary('name', 'phi', $
                                  'scale', 1e3, $
                                  'units', '[mV/m]', $
                                  'symbol', '<|E|>', $
                                  'grid', 'r', $
                                  'gradient', 1, $
                                  'gradient_scale', -1.0, $
                                  'rms', 1)
  gc.image[key].data.filebase = 'E-rms'
  gc.image[key].keywords = dictionary('rgb_table', 5, $
                                      'layout', layout, $
                                      'position', position, $
                                      'axis_style', axis_style, $
                                      'font_name', font_name, $
                                      'font_size', font_size)

  ;;==Ion density
  key = 'Ion density'
  gc.image[key] = dictionary()
  gc.image[key].data = dictionary('name', 'den1', $
                                  'scale', 1e2, $
                                  'units', '[%]', $
                                  'symbol', '$\delta$ n/$n_0$', $
                                  'grid', 'r')
  gc.image[key].data.filebase = gc.image[key].data.name
  gc.image[key].keywords = dictionary('rgb_table', 5, $
                                      'layout', layout, $
                                      'position', position, $
                                      'axis_style', axis_style, $
                                      'font_name', font_name, $
                                      'font_size', font_size)

  ;; ;;==EPPIC FT ion density
  ;; key = 'FFT Ion density'
  ;; gc.image[key] = dictionary()
  ;; gc.image[key].data = dictionary('name','denft1', $
  ;;                                 'grid', 'k', $
  ;;                                 'symbol', 'FFT($\delta$ n/$n_0$)', $
  ;;                                 'rotate_direction', 2)
  ;; gc.image[key].data.filebase = gc.image[key].data.name
  ;; gc.image[key].keywords = dictionary('rgb_table', 39, $
  ;;                                     'layout', layout, $
  ;;                                     'position', position, $
  ;;                                     'axis_style', axis_style, $
  ;;                                     'font_name', font_name, $
  ;;                                     'font_size', font_size)


  return, gc
end
