;+
; Script for making frames from a plane of EPPIC fluxy1 data.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;-

;;==Load graphics keywords for fluxy1
@fluxy1_kw

;;==Create image movies of fluxy1 data
filename = path+path_sep()+'movies'+ $
           path_sep()+'fluxy1.mp4'
data_graphics, fluxy1,xdata,ydata, $
               /make_movie, $
               filename = filename, $
               image_kw = image_kw, $
               colorbar_kw = colorbar_kw
filename = path+path_sep()+'movies'+ $
           path_sep()+'fluxy1_zoom.mp4'
data_graphics, fluxy1[1024-256:1024+255,*,*], $
               xdata[1024-256:1024+255],ydata, $
               /make_movie, $
               filename = filename, $
               image_kw = image_kw, $
               colorbar_kw = colorbar_kw
