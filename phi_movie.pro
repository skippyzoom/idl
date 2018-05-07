;+
; Script for making movies from a plane of EPPIC phi data.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;-

;;==Declare graphics ranges
x0 = 0
xf = nx
y0 = 0
yf = ny

;;==Declare file type
movie_type = '.mp4'

;;==Load graphics keywords for phi
@phi_kw

;;==Create image movie of den1 data
filename = expand_path(path+path_sep()+'movies'+ $
           path_sep()+'phi')+ $
           '.'+get_extension(movie_type)
data_graphics, phi[x0:xf-1,y0:yf-1,*], $
               xdata[x0:xf-1],ydata[y0:yf-1], $
               /make_movie, $
               filename = filename, $
               image_kw = image_kw, $
               colorbar_kw = colorbar_kw
