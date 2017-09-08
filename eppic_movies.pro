;+
; Create movies of EPPIC simulation output.
;-

loadStep = nout*lindgen(ntMax)
@load_project

filetype = '.mp4'

;[TO DO]eppic_project_movies, prj,filetype = filetype
;[TO DO]eppic_efield_movies, prj.data.phi,...
;[TO DO]eppic_spectral_movies, prj.data.den1,...
;[TO DO]eppic_spectral_movies, prj.data.phi,...

@unload_project
