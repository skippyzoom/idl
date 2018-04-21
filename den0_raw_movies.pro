@den0_kw
filename = path+path_sep()+'movies'+ $
           path_sep()+'den0.mp4'
data_graphics, den0,xdata,ydata, $
               /make_movie, $
               filename = filename, $
               image_kw = image_kw, $
               colorbar_kw = colorbar_kw
