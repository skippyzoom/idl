;+
; Script for making image frames of E-field x component
;-
@Ex_kw
filename = pd.path+path_sep()+'frames'+ $
           path_sep()+'efield_x-'+time.index+'.pdf'
data_graphics, Ex,xdata,ydata, $
               /make_frame, $
               filename = filename, $
               image_kw = image_kw, $
               colorbar_kw = colorbar_kw
