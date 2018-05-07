;+
; Script for making movies from a plane of EPPIC fluxx1 data.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;-

;;==Set defaults
if n_elements(x0) eq 0 then x0 = 0
if n_elements(xf) eq 0 then xf = nx-1
if n_elements(y0) eq 0 then y0 = 0
if n_elements(yf) eq 0 then yf = ny-1
if n_elements(name_info) eq 0 then name_info = ''

;;==Load graphics keywords for fluxx1
@fluxx1_kw

;;==Create image movie of fluxx1 data
filename = path+path_sep()+'movies'+ $
           path_sep()+'fluxx1.mp4'
data_graphics, fluxx1,xdata,ydata, $
               /make_movie, $
               filename = filename, $
               image_kw = image_kw, $
               colorbar_kw = colorbar_kw
