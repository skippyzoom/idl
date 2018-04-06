;+
; Script for making image frames of E-field angle
;-
@Et_kw
filename = pd.path+path_sep()+'frames'+ $
           path_sep()+'efield_t-'+time.index+'.pdf'
data_graphics, Et,xdata,ydata, $
               /make_frame, $
               filename = filename, $
               image_kw = image_kw, $
               colorbar_kw = colorbar_kw
