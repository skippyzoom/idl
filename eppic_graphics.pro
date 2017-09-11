;+
; Create images of EPPIC simulation output.
;-

@load_eppic_params
if n_elements(plotindex) eq 0 then plotindex = [0,ntMax-1]
if n_elements(dataName) eq 0 then dataName = list('den1','phi')
if n_elements(dataType) eq 0 then dataType = ['ph5','ph5']
data = load_eppic_data(dataName.toarray(),dataType,timestep=nout*lindgen(ntMax))

prj = set_current_prj(data,rngs,grid, $
                      scale = scale, $
                      plotindex = plotindex, $
                      xyzt = xyzt, $
                      title = title)
delvar, rngs

filetype = '.png'
global_colorbar = 1B

img = density_graphics(prj = prj, $
                       global_colorbar = global_colorbar)
filename = 'den1'+filetype
image_save, img,filename=filename,/landscape

;; img = fft_graphics(prj.data.den1, $
;;                    plotindex = plotindex, $
;;                    global_colorbar = global_colorbar)
;; img = fft_graphics(prj.data.den1, $
;;                    plotindex = plotindex)
img = fft_graphics(smooth(prj.data.den1,[9,9,1]), $
                   plotindex = plotindex, $
                   plotlayout = plotlayout)
filename = 'den1-fft'+filetype
image_save, img,filename=filename,/landscape
