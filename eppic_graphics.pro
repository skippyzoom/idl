;+
; Create images of EPPIC simulation output.
;-

name = 'den1'
img = density_graphics(prj = prj, $
                       plotindex = plotindex, $
                       plotlayout = plotlayout, $
                       global_colorbar = global_colorbar)
filename = name+filetype
image_save, img,filename = filename,/landscape

fft_sw = 0.1/dx
help, fft_sw
img = fft_graphics(smooth(prj.data[name],[fft_sw,fft_sw,1]), $
                   plotindex = plotindex, $
                   plotlayout = plotlayout, $
                   global_colorbar = global_colorbar)
filename = name+'-fft'+filetype
image_save, img,filename = filename,/landscape

name = 'phi'
img = potential_graphics(prj = prj, $
                         plotindex = plotindex, $
                         plotlayout = plotlayout, $
                         global_colorbar = global_colorbar)
filename = name+filetype
image_save, img,filename = filename,/landscape

fft_sw = 0.1/dx
help, fft_sw
img = fft_graphics(smooth(prj.data[name],[fft_sw,fft_sw,1]), $
                   plotindex = plotindex, $
                   plotlayout = plotlayout, $
                   global_colorbar = global_colorbar)
filename = name+'-fft'+filetype
image_save, img,filename = filename,/landscape
