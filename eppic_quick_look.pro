;+
; A script for taking the first look at simulation data
; before any real analysis. This should not grow too bulky.
; It only needs to show a few quantities (e.g. den and phi)
; so the user can know if the run is worth analyzing further.
;-

;;==Load simulation data
@load_eppic_params
data = load_eppic_data(['den1','phi'],timestep=nout*lindgen(ntMax))

;;==Set up plots
loadct, 5
plotSteps = [ntMax/4,ntMax/2,3*ntMax/4,ntMax-1]
np = n_elements(plotSteps)
sw = 13

;;==Plot to the screen
!p.multi = [0,2,np]
window, xpos=0,ypos=0,xsize=500,ysize=800
plotData = reform(data.den1[*,*,0,*])
;; plotData = smooth(plotData,[sw,sw,1],/edge_wrap)
background = smooth(plotData[*,*,0],sw,/edge_wrap)
for ip=0,np-1 do image_plot, plotData[*,*,plotSteps[ip]]-background,/aspect,/legend
plotData = reform(data.phi[*,*,0,*])
;; plotData = smooth(plotData,[sw,sw,1],/edge_wrap)
background = smooth(plotData[*,*,0],sw,/edge_wrap)
for ip=0,np-1 do image_plot, plotData[*,*,plotSteps[ip]]-background,/aspect,/legend

;;==Plot to a buffer
position = multi_position(2,(np/2)+1)
plotData = reform(data.den1[*,*,0,*])
;; plotData = smooth(plotData,[sw,sw,1],/edge_wrap)
background = smooth(plotData[*,*,0],sw,/edge_wrap)
for ip=0,np-1 do img = image(plotData[*,*,plotSteps[ip]]-background,/buffer,position=position[*,ip])
plotData = reform(data.phi[*,*,0,*])
;; plotData = smooth(plotData,[sw,sw,1],/edge_wrap)
background = smooth(plotData[*,*,0],sw,/edge_wrap)
for ip=0,np-1 do img = image(plotData[*,*,plotSteps[ip]]-background,/current,position=position[*,ip])

;;==Save graphics
image_save, img,name='quick_look.png'
