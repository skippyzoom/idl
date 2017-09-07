;+
; Load project graphics parameters and keywords, given a project name,
; then load simulation data for that project.
; This routine was originally intended to be called from a batch script
; for making graphical output for multiple projects.
;-

;;==Declare the project name
if n_elements(projDir) eq 0 then projDir = './'
paths = source_project(projDir)
!PATH = paths.proj

;;==Move to the project data directory
if n_elements(projPath) eq 0 then projPath = './'
cd, projPath

;;==Load density and potential for limited time steps
@load_eppic_params
if n_elements(plotStep) eq 0 then plotStep = nout*[0,ntMax-1]
dataName = list('den1','phi')
dataType = ['ph5','ph5']
data = load_eppic_data(dataName.toarray(),dataType,timestep=plotStep)

;;==Calculate electric-field quantities and add to existing data set
addName = 'emag'
dataName.add, addName
data[addName] = calc_emag(data.phi,phiSW=5.0,/add_E0,/verbose)

;;==Load the project graphics parameters
@project.eppic
