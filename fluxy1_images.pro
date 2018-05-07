;+
; Script for making frames from a plane of EPPIC fluxy1 data.
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

;;==Load graphics keywords for fluxy1
@fluxy1_kw

;;==Create image frame(s) of fluxy1 data
filename = path+path_sep()+'frames'+ $
           path_sep()+'fluxy1-'+time.index+ $
           name_info+'.pdf'
data_graphics, fluxy1[x0:xf,y0:yf,*], $
               xdata[x0:xf],ydata[y0:yf], $
               /make_frame, $
               filename = filename, $
               image_kw = image_kw, $
               colorbar_kw = colorbar_kw
