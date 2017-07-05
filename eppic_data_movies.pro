;+
; Create movies of EPPIC simulation output.
;-

;;==Load density and potential for limited time steps
@load_eppic_params
timestep = nout*lindgen(ntMax)
dataName = ['den1','phi']
dataType = ['ph5','ph5']
data = load_eppic_data(dataName,dataType,timestep=timestep)

;;==Density
movData = reform(data.den1[*,grid.ny/2-grid.ny/4:grid.ny/2+grid.ny/4-1,0,*])
data_movie, movData,rgb_table=5,filename='den.mp4',/timestamps

;;==Potential
movData = reform(data.phi[*,grid.ny/2-grid.ny/4:grid.ny/2+grid.ny/4-1,0,*])
ct = get_custom_ct(1)
data_movie, movData,rgb_table=[[ct.r],[ct.g],[ct.b]],filename='phi.mp4',/timestamps
