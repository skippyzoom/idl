;+
; Script for making image frames of E-field y component.
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
filename = path+path_sep()+'frames'+ $
           path_sep()+'efield_'+strmid(axes,1,1)+ $
           '-'+time.index+'.pdf'
data_graphics, Ey,xdata,ydata, $
               /make_frame, $
               filename = filename, $
               image_kw = image_kw, $
               colorbar_kw = colorbar_kw
filename = path+path_sep()+'frames'+ $
           path_sep()+'efield_'+strmid(axes,1,1)+ $
           '-'+time.index+'_zoom.pdf'
data_graphics, Ey[1024-256:1024+255,*,*], $
               xdata[1024-256:1024+255],ydata, $
               /make_frame, $
               filename = filename, $
               image_kw = image_kw, $
               colorbar_kw = colorbar_kw
