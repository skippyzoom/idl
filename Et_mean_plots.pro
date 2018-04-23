plot_kw = dictionary()
plot_kw['xstyle'] = 1
tmp = make_array(n_elements(time.index),value=1)
tmp[0] = 0B
plot_kw['overplot'] = tmp
plot_kw['color'] = ['black', $
                    'midnight blue', $
                    'dark blue', $
                    'medium blue', $
                    'blue', $
                    'dodger blue',$
                    'deep sky blue']
plot_kw['font_name'] = 'Times'

plot_kw['font_size'] = 10.0
Et_xmean = mean(Et,dim=1)
filename = path+path_sep()+'frames'+ $
           path_sep()+'efield_t-x_mean.pdf'
data_graphics, ydata,Et_xmean, $
               /make_frame, $
               plot_kw = plot_kw, $
               filename = filename

plot_kw['font_size'] = 24.0
Et_ymean = mean(Et,dim=2)
filename = path+path_sep()+'frames'+ $
           path_sep()+'efield_t-y_mean.pdf'
data_graphics, xdata,Et_ymean, $
               /make_frame, $
               plot_kw = plot_kw, $
               filename = filename
