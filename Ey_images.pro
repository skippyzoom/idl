;+
; Script for making image frames of E-field y component
;-
@Ey_kw
filename = pd.path+path_sep()+'frames'+ $
           path_sep()+'efield_y-'+time.index+'.pdf'
data_graphics, Ey,xdata,ydata, $
               /make_frame, $
               filename = filename, $
               image_kw = image_kw, $
               colorbar_kw = colorbar_kw
