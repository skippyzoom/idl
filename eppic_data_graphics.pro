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
dataName = list('den1','phi')
dataType = ['ph5','ph5']
data = load_eppic_data(dataName.toarray(),dataType,timestep=plotStep)

;;==Calculate electric-field quantities and add to existing data set
addName = 'emag'
dataName.add, addName
data[addName] = calc_emag(data.phi,phiSW=5.0,/add_E0,/verbose)

;;==Load the project graphics parameters
@project.pro

;;==Create graphics
nData = n_elements(dataName)
for id=0,nData-1 do $
   data_image, prj.data[dataName[id]],prj.xvec,prj.yvec, $
               kw_image = prj.kw[dataName[id]].image[*], $
               kw_colorbar = prj.kw[dataName[id]].colorbar[*], $
               filename = dataName[id]+'_test.png'

