;+
; Script for making movies from a plane of EPPIC den1 data.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;-

;;==Set defaults
@raw_movies_defaults

;;==Load graphics keywords for den1
@den1_kw

;;==Create image movie of den1 data
filename = path+path_sep()+'movies'+ $
           path_sep()+'den1.mp4'
data_graphics, den1[x0:xf,y0:yf,*], $
               xdata[x0:xf],ydata[y0:yf], $
               /make_movie, $
               filename = filename, $
               image_kw = image_kw, $
               colorbar_kw = colorbar_kw
