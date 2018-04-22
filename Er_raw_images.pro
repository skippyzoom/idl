;+
; Script for making image frames of E-field plane magnitude. 
;
; Note that the two components are the logical 'x' and 'y' components
; in the given plane, as set by the AXES variable. See notes in 
; Ex_images.pro and Ey_images.pro.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;-
@Er_kw
filename = path+path_sep()+'frames'+ $
           path_sep()+'efield_r'+axes+ $
           time.index+'.pdf'
data_graphics, Er,xdata,ydata, $
               /make_frame, $
               filename = filename, $
               image_kw = image_kw, $
               colorbar_kw = colorbar_kw
