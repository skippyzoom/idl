;+
; Script for making movies from a plane of EPPIC phi data.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;-

;;==Set defaults
@raw_movies_defaults

;;==Load graphics keywords for phi
@phi_kw

;;==Create image movie of phi data
filename = path+path_sep()+'movies'+ $
           path_sep()+'phi.mp4'
data_graphics, phi[x0:xf,y0:yf,*], $
               xdata[x0:xf],ydata[y0:yf], $
               /make_movie, $
               filename = filename, $
               image_kw = image_kw, $
               colorbar_kw = colorbar_kw
