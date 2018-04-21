;+
; Script for making frames from a plane of EPPIC fluxy1 data.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;-

;;==Load graphics keywords for fluxy1
@fluxy1_kw

;;==Create image frames of fluxy1 data
filename = path+path_sep()+'frames'+ $
           path_sep()+'fluxy1-'+time.index+'.pdf'
data_graphics, fluxy1,xdata,ydata, $
               /make_frame, $
               filename = filename, $
               image_kw = image_kw, $
               colorbar_kw = colorbar_kw
filename = path+path_sep()+'frames'+ $
           path_sep()+'fluxy1-'+time.index+'_zoom.pdf'
data_graphics, fluxy1[1024-256:1024+255,*,*], $
               xdata[1024-256:1024+255],ydata, $
               /make_frame, $
               filename = filename, $
               image_kw = image_kw, $
               colorbar_kw = colorbar_kw
