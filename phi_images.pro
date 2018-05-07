;+
; Script for making frames from a plane of EPPIC phi data.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;-

;;==Set defaults
@raw_frames_defaults

;;==Load graphics keywords for phi
@phi_kw

;;==Create image frame(s) of phi data
filename = path+path_sep()+'frames'+ $
           path_sep()+'phi-'+time.index+ $
           name_info+'.pdf'
data_graphics, phi[x0:xf,y0:yf,*], $
               xdata[x0:xf],ydata[y0:yf], $
               /make_frame, $
               filename = filename, $
               image_kw = image_kw, $
               colorbar_kw = colorbar_kw
