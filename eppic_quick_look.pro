;+
; A script for taking the first look at simulation data
; before any real analysis. This should not grow too bulky.
; It only needs to show a few quantities (e.g. den and phi)
; so the user can know if the run is worth analyzing further.
;
; NB: It is especially important to keep this script portable.
;     Writing for IDL v8.0+ should be sufficient.
;-

;;==Load simulation data
@load_eppic_params
data = load_eppic_data(['den1','phi'],timestep=nout*lindgen(ntMax))

;;==Set up plots
loadct, 5
plotSteps = [ntMax/4,ntMax/2,3*ntMax/4,ntMax-1]
np = n_elements(plotSteps)
sw = 13

;;==Plot to buffers and save each individually
position = multi_position([2,(np/2)+1])
plotData = reform(data.den1[*,*,0,*])
;; plotData = smooth(plotData,[sw,sw,1],/edge_wrap)
background = smooth(plotData[*,*,0],sw,/edge_wrap)
rgb_table = 5
for ip=0,np-1 do img = image(plotData[*,*,plotSteps[ip]]-background, $
                             position = position[*,ip], $
                             current = (ip gt 0), $
                             rgb_table = rgb_table, $
                             /buffer)
image_save, img,filename='den1-quick_look.png'
plotData = reform(data.phi[*,*,0,*])
;; plotData = smooth(plotData,[sw,sw,1],/edge_wrap)
background = smooth(plotData[*,*,0],sw,/edge_wrap)
rgb_table = 5
for ip=0,np-1 do img = image(plotData[*,*,plotSteps[ip]]-background, $
                             position = position[*,ip], $
                             current = (ip gt 0), $
                             rgb_table = rgb_table, $
                             /buffer)
image_save, img,filename='phi-quick_look.png'
plotData = abs(fft_custom(smooth(reform(data.den1[*,*,0,*]),[sw,sw,1],/edge_wrap), $
                          /skip_time_fft, $
                          /center))
plotData = 10*alog10(plotData^2)
background = 10*alog10(plotData[*,*,0]^2)
rgb_table = 39
for ip=0,np-1 do img = image(plotData[*,*,plotSteps[ip]]-background, $
                             position = position[*,ip], $
                             current = (ip gt 0), $
                             rgb_table = rgb_table, $
                             /buffer)
image_save, img,filename='fftden1-quick_look.png'
