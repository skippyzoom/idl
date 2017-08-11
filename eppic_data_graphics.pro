;+
; Create images of EPPIC simulation output.
;-

;;==Declare the project name
;-->In a batch file?
prjDir = 'parametric_wave/run000/'
paths = source_project(prjDir)
!PATH = paths.proj

;;==Move to the project data directory
cd, '/projectnb/eregion/may/Stampede_runs/'+prjDir

;;==Load density and potential for limited time steps
@load_eppic_params
plotStep = nout*[1,ntMax-1]
;; dataName = ['den1','phi','emag']
dataName = list('den1','phi')
dataType = ['ph5','ph5']
nData = n_elements(dataName)
data = load_eppic_data(dataName.toarray(),dataType,timestep=plotStep)

;;==Calculate electric-field quantities and add to existing data set
addName = 'emag'
dataName.add, addName
data[addName] = calc_emag(data.phi,phiSW=5.0,/add_E0,/verbose)

;; ;;==Load the project graphics parameters
;; @project.pro

;; ;;==Create graphics
;; for id=0,nData-1 do $
;;    multi_image, prj.data[dataName[id]],prj.xvec,prj.yvec, $
;;                 kw_image = (kw[dataName[id]]).image[*], $
;;                 kw_colorbar = (kw[dataName[id]]).colorbar[*], $
;;                 name = dataName[id]+'_test.png'

