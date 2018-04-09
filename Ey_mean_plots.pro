;+
; Script for making image frames of E-field y-component means
;
; Note that this is the logical y component for the given plane.
; In other words, it is the 'y' component in the 'xy' plane, the
; 'z' component in the 'xz' plane, or the 'z' component in the
; 'yz' plane.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;-
plot_kw = dictionary()
plot_kw['xstyle'] = 1
plot_kw['overplot'] = 1
plot_kw['color'] = ['black', $
                    ;; 'midnight blue', $
                    'dark blue', $
                    'medium blue', $
                    ;; 'blue', $
                    ;; 'dodger blue',$
                    'deep sky blue']
plot_kw['font_name'] = 'Times'

plot_kw['font_size'] = 10.0
Ey_xmean = mean(Ey,dim=1)
filename = path+path_sep()+'frames'+ $
           path_sep()+'efield_y-x_mean.pdf'
data_graphics, ydata,Ey_xmean, $
               /make_frame, $
               plot_kw = plot_kw, $
               filename = filename

plot_kw['font_size'] = 24.0
Ey_ymean = mean(Ey,dim=2)
filename = path+path_sep()+'frames'+ $
           path_sep()+'efield_y-y_mean.pdf'
data_graphics, xdata,Ey_ymean, $
               /make_frame, $
               plot_kw = plot_kw, $
               filename = filename
