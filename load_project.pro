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
if n_elements(fullPath) eq 0 then fullPath = './'
cd, fullPath

;;==Load density and potential for specified time steps
@load_eppic_params
if n_elements(loadStep) eq 0 then loadStep = 0
if n_elements(dataName) eq 0 then dataName = list('den1','phi')
if n_elements(dataType) eq 0 then dataType = ['ph5','ph5']
data = load_eppic_data(dataName.toarray(),dataType,timestep=loadStep)

;;==Load the project graphics parameters
@project.eppic
