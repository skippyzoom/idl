;+
; Script for making image movies of E-field plane magnitude. 
;
; Note that the two components are the logical 'x' and 'y' components
; in the given plane, as set by the AXES variable. See notes in 
; Ex_images.pro and Ey_images.pro.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;-
@Er_kw
filename = path+path_sep()+'movies'+ $
           path_sep()+'efield_r'+axes+'.mp4'
data_graphics, Er,xdata,ydata, $
               /make_movie, $
               filename = filename, $
               image_kw = image_kw, $
               colorbar_kw = colorbar_kw
filename = path+path_sep()+'movies'+ $
           path_sep()+'efield_r'+axes+'.mp4'
data_graphics, Er[1024-256:1024+255,*,*], $
               xdata[1024-256:1024+255],ydata, $
               /make_movie, $
               filename = filename, $
               image_kw = image_kw, $
               colorbar_kw = colorbar_kw