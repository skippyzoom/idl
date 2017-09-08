;+
; Create images of EPPIC simulation output.
;-
;; @load_eppic_params
;; loadStep = nout*[0,ntMax-1]
@load_project

;;==Create graphics
;; plotStep = loadStep
dataName = prj.data.keys()
nData = n_elements(dataName)
for id=0,nData-1 do $
   data_image, prj.data[dataName[id]],prj.xvec,prj.yvec, $
               kw_image = prj.kw[dataName[id]].image[*], $
               kw_colorbar = prj.kw[dataName[id]].colorbar[*], $
               filename = dataName[id]+'.png'

!PATH = paths.orig
