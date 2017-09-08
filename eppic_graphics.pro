;+
; Create images of EPPIC simulation output.
;-

if n_elements(plotStep) eq 0 then plotStep = nout*[0,ntMax-1]
loadStep = plotStep
@load_project

filetype = '.png'
global_colorbar = 1B

eppic_project_graphics, prj, $
                        filetype = filetype, $
                        global_colorbar = global_colorbar, $
                        project_kw = project_kw[*]
 
;[TO DO]eppic_efield_graphics, prj.data.phi,...
;[TO DO]eppic_spectral_graphics, prj.data.den1,...
;[TO DO]eppic_spectral_graphics, prj.data.phi,...

@unload_project
