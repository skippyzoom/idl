;+
; Script for making frames from a plane of EPPIC den1 data.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;-

;;==Load defaults
@raw_frames_defaults

;;==Load graphics keywords for den1
@den1_kw

;;==Create image frame(s) of den1 data
filename = path+path_sep()+'frames'+ $
           path_sep()+'den1-'+time.index+ $
           name_info+'.pdf'
data_graphics, den1[x0:xf,y0:yf,*], $
               xdata[x0:xf],ydata[y0:yf], $
               /make_frame, $
               filename = filename, $
               image_kw = image_kw, $
               colorbar_kw = colorbar_kw
