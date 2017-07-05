;+
; Create images of EPPIC simulation output.
;-

;;==Load density and potential for limited time steps
@load_eppic_params
;; timestep = nout*[1,ntMax-1]
nSteps = n_elements(timestep)
dataName = ['den1','phi']
dataType = ['ph5','ph5']
data = load_eppic_data(dataName,dataType,timestep=timestep)

;;==Density
imgData = reform(data.den1[*,grid.ny/2-grid.ny/4:grid.ny/2+grid.ny/4-1,0,*])
imgData *= 100                  ;Rescale units to [%]
kw = set_kw('den',imgData=imgData,timestep=dt*timestep*1e3)
multi_image, imgData,kw_image=kw.image,kw_colorbar=kw.colorbar,name='den-P.pdf'


;;==Potential
imgData = reform(data.phi[*,grid.ny/2-grid.ny/4:grid.ny/2+grid.ny/4-1,0,*])
imgData *= 1000                 ;Rescale units to [mV]
kw = set_kw('phi',imgData=imgData,timestep=dt*timestep*1e3)
multi_image, imgData,kw_image=kw.image,kw_colorbar=kw.colorbar,name='phi-P.pdf'

;;==Total electric-field magnitude
emag = calc_emag(data.phi,phiSW=5.0,/add_E0,/verbose)
imgData = reform(emag[*,grid.ny/2-grid.ny/4:grid.ny/2+grid.ny/4-1,0,*])
imgData *= 1000                 ;Rescale units to [mV/m]
kw = set_kw('emag',imgData=imgData,timestep=dt*timestep*1e3)
multi_image, imgData,kw_image=kw.image,kw_colorbar=kw.colorbar,name='emag_full-P.pdf'

;;==Perturbed electric-field magnitude
emag = calc_emag(data.phi,phiSW=5.0,/verbose)
imgData = reform(emag[*,grid.ny/2-grid.ny/4:grid.ny/2+grid.ny/4-1,0,*])
imgData *= 1000                 ;Rescale units to [mV/m]
kw = set_kw('emag',imgData=imgData,timestep=dt*timestep*1e3)
multi_image, imgData,kw_image=kw.image,kw_colorbar=kw.colorbar,name='emag_pert-P.pdf'

;;==Spatial RMS of perturbed electric field
pltName = "emag_rms-P.pdf"
timestep = nout*lindgen(timestep[nSteps-1]/nout-1)
@plot_emag_rms

