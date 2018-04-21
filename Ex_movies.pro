;+
; Script for making image movies of E-field x component.
;
; Note that this is the logical x component for the given plane.
; In other words, it is the 'x' component in the 'xy' plane, the
; 'x' component in the 'xz' plane, or the 'y' component in the
; 'yz' plane.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;-
@Ex_kw
filename = path+path_sep()+'movies'+ $
           path_sep()+'efield_'+strmid(axes,0,1)+'.mp4'
data_graphics, Ex,xdata,ydata, $
               /make_movie, $
               filename = filename, $
               image_kw = image_kw, $
               colorbar_kw = colorbar_kw
filename = path+path_sep()+'movies'+ $
           path_sep()+'efield_'+strmid(axes,0,1)+'_zoom.mp4'
data_graphics, Ex[1024-256:1024+255,*,*], $
               xdata[1024-256:1024+255],ydata, $
               /make_movie, $
               filename = filename, $
               image_kw = image_kw, $
               colorbar_kw = colorbar_kw
