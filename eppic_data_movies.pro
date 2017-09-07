;+
; Create movies of EPPIC simulation output.
;-

;; ;;==Declare the project name
;; if n_elements(projDir) eq 0 then projDir = './'
;; paths = source_project(projDir)
;; !PATH = paths.proj

;; ;;==Move to the project data directory
;; if n_elements(projPath) eq 0 then projPath = './'
;; cd, projPath

;; ;;==Load density and potential for all time steps
;; @load_eppic_params
;; plotStep = nout*lindgen(ntMax)
;; dataName = list('den1','phi')
;; dataType = ['ph5','ph5']
;; data = load_eppic_data(dataName.toarray(),dataType,timestep=plotStep)

;; ;;==Calculate electric-field quantities and add to existing data set
;; addName = 'emag'
;; dataName.add, addName
;; data[addName] = calc_emag(data.phi,phiSW=5.0,/add_E0,/verbose)

;; ;;==Load the project graphics parameters
;; @project.eppic
plotStep = nout*lindgen(ntMax)
@load_project

;;==Create movies
nData = n_elements(dataName)
for id=0,nData-1 do $
   data_movie, prj.data[dataName[id]],prj.xvec,prj.yvec, $
               kw_image = prj.kw[dataName[id]].image[*], $
               kw_colorbar = prj.kw[dataName[id]].colorbar[*], $
               filename = dataName[id]+'.mp4'

!PATH = paths.orig
