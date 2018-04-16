@phi_kw
filename = path+path_sep()+'movies'+ $
           path_sep()+'phi.mp4'
data_graphics, phi,xdata,ydata, $
               /make_movie, $
               filename = filename, $
               image_kw = image_kw, $
               colorbar_kw = colorbar_kw
