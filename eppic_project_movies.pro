;+
; Create movies of EPPIC simulation output.
;-
pro eppic_project_movies, prj, $
                          filetype=filetype

;--> Make this consistent with eppic_project_graphics.pro

;; ;;==Create movies
;; plotStep = loadStep
;; dataName = prj.data.keys()
;; nData = n_elements(dataName)
;; for id=0,nData-1 do $
;;    data_movie, prj.data[dataName[id]],prj.xvec,prj.yvec, $
;;                kw_image = prj.kw[dataName[id]].image[*], $
;;                kw_colorbar = prj.kw[dataName[id]].colorbar[*], $
;;                filename = dataName[id]+'.mp4'

end
