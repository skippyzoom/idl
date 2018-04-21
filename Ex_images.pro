;+
; Script for making image frames of E-field x component.
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
filename = path+path_sep()+'frames'+ $
           path_sep()+'efield_'+strmid(axes,0,1)+ $
           '-'+time.index+'.pdf'
data_graphics, Ex,xdata,ydata, $
               /make_frame, $
               filename = filename, $
               image_kw = image_kw, $
               colorbar_kw = colorbar_kw
filename = path+path_sep()+'frames'+ $
           path_sep()+'efield_'+strmid(axes,0,1)+ $
           '-'+time.index+'_zoom.pdf'
data_graphics, Ex[1024-256:1024+255,*,*], $
               xdata[1024-256:1024+255],ydata, $
               /make_frame, $
               filename = filename, $
               image_kw = image_kw, $
               colorbar_kw = colorbar_kw
