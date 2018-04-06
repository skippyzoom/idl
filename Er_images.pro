;+
; Script for making image frames of E-field magnitude
;-
@Er_kw
filename = pd.path+path_sep()+'frames'+ $
           path_sep()+'efield_r-'+time.index+'.pdf'
data_graphics, Er,xdata,ydata, $
               /make_frame, $
               filename = filename, $
               image_kw = image_kw, $
               colorbar_kw = colorbar_kw
