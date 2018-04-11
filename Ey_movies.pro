;+
; Script for making image movies of E-field y component.
;
; Note that this is the logical y component for the given plane.
; In other words, it is the 'y' component in the 'xy' plane, the
; 'z' component in the 'xz' plane, or the 'z' component in the
; 'yz' plane.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;-
@Ey_kw
filename = path+path_sep()+'movies'+ $
           path_sep()+'efield_'+strmid(axes,1,1)+ $
           '-'+time.index+'.mp4'
data_graphics, Ey,xdata,ydata, $
               /make_movie, $
               filename = filename, $
               image_kw = image_kw, $
               colorbar_kw = colorbar_kw
