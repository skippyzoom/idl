;+
; Script for making image frames of E-field x-component means
;
; Note that this is the logical x component for the given plane.
; In other words, it is the 'x' component in the 'xy' plane, the
; 'x' component in the 'xz' plane, or the 'y' component in the
; 'yz' plane.
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;-
plot_kw = dictionary()
plot_kw['xstyle'] = 1
plot_kw['overplot'] = 1
plot_kw['color'] = ['black', $
                    'midnight blue', $
                    'dark blue', $
                    'medium blue', $
                    'blue', $
                    'dodger blue',$
                    'deep sky blue']
plot_kw['font_name'] = 'Times'

plot_kw['font_size'] = 10.0
Ex_xmean = mean(Ex,dim=1)
filename = path+path_sep()+'frames'+ $
           path_sep()+'efield_x-x_mean.pdf'
data_graphics, ydata,Ex_xmean, $
               /make_frame, $
               plot_kw = plot_kw, $
               filename = filename

plot_kw['font_size'] = 24.0
Ex_ymean = mean(Ex,dim=2)
filename = path+path_sep()+'frames'+ $
           path_sep()+'efield_x-y_mean.pdf'
data_graphics, xdata,Ex_ymean, $
               /make_frame, $
               plot_kw = plot_kw, $
               filename = filename
