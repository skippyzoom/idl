;+
; Script for making frames from a plane of EPPIC fluxx1 data.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;-

;;==Load graphics keywords for fluxx1
@fluxx1_kw

;;==Create image movies of fluxx1 data
filename = path+path_sep()+'movies'+ $
           path_sep()+'fluxx1.mp4'
data_graphics, fluxx1,xdata,ydata, $
               /make_movie, $
               filename = filename, $
               image_kw = image_kw, $
               colorbar_kw = colorbar_kw
filename = path+path_sep()+'movies'+ $
           path_sep()+'fluxx1_zoom.mp4'
data_graphics, fluxx1[1024-256:1024+255,*,*], $
               xdata[1024-256:1024+255],ydata, $
               /make_movie, $
               filename = filename, $
               image_kw = image_kw, $
               colorbar_kw = colorbar_kw
