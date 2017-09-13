;+
; This is the code to execute in each project directory
; that parameter_space.bat visits
;
; This routine declares certain variables (e.g. rngs and plotindex)
; that need to know about run-specific parameters (e.g. nx and ntMax).
;-

projPath = baseDir+projDir
fullPath = projPath+runDir
cd, fullPath
$pwd

@load_eppic_params

;;==Declare (untransposed) data ranges
rngs = {x: [0,grid.nx-1], $
        y: [0,grid.ny-1], $
        z: [0,grid.nz-1]}

;;==Declare which output steps to plot (if applicable)
plotindex = [ntMax/4,ntMax/2,3*ntMax/4,ntMax-1]
plotlayout = [2,2]
;; plotindex = [ntMax/2,ntMax-1]
;; plotlayout = [1,2]
@load_eppic_params
if n_elements(dataName) eq 0 then dataName = list('den1','phi')
if n_elements(dataType) eq 0 then dataType = ['ph5','ph5']
data = load_eppic_data(dataName.toarray(),dataType,timestep=nout*lindgen(ntMax))

prj = set_current_prj(data,rngs,grid, $
                      scale = scale, $
                      xyzt = xyzt, $
                      description = description)
delvar, rngs

set_data_units, prj,units

filetype = '.png'
global_colorbar = 1B

@eppic_graphics

;; @load_eppic_params
;; loadStep = nout*lindgen(ntMax)
;; plotStep = loadStep
;; @eppic_movies
