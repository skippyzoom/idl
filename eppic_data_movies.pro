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
;; movData = reform(data.den1[*,grid.ny/2-grid.ny/4:grid.ny/2+grid.ny/4-1,0,*])
movData = transpose(reform(data.den1[*,*,0,*]),[1,0,2])
max_abs = max(abs(movData))
min_value = -max_abs
max_value = max_abs
data_movie, movData, $
            ;; /timestamps, $
            rgb_table = 5, $
            min_value = min_value, $
            max_value = max_value, $
            filename = 'den.mp4'

;;==Potential
;; movData = reform(data.phi[*,grid.ny/2-grid.ny/4:grid.ny/2+grid.ny/4-1,0,*])
movData = transpose(reform(data.phi[*,*,0,*]),[1,0,2])
max_abs = max(abs(movData))
min_value = -max_abs
max_value = max_abs
ct = get_custom_ct(1)
data_movie, movData, $
            ;; /timestamps, $
            rgb_table=[[ct.r],[ct.g],[ct.b]], $
            min_value = min_value, $
            max_value = max_value, $
            filename='phi.mp4'
