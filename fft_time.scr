;+
; Script to read a data plane, calculate FFT in space only, and make an image
; of the spatial spectrum at each time step.
;-
;;==Declare the distribution
den = 'den1'

;;==Set the path to here
path = './'

;;==Read simulation parameters
params = set_eppic_params(path=path)

;;==Calculate max number of time steps
nt_max = calc_timesteps(path=path)

;;==Set up time-step info
time = time_strings(params.nout*[0,nt_max-1], $
                    dt=params.dt,scale=1e3,precision=2)

;;==Extract a plane of density data
plane = read_data_plane(name, $
                        timestep = fix(time.index), $
                        axes = 'xy', $
                        data_type = 4, $
                        data_isft = 0B, $
                        ranges = [0,1,0,1,0,1], $
                        rotate = 3, $
                        info_path = path, $
                        data_path = path+path_sep()+'parallel')

;;==Extract the data array for speed
fdata = plane.remove('f')
dx = plane.remove('dx')
dy = plane.remove('dy')
plane = !NULL

;;==Get dimensions of data array
fsize = size(fdata)
nx = fsize[1]
ny = fsize[2]
nt = fsize[3]

;;==Set up spectral array
nkx = nx
nky = ny
fftarr = make_array(nkx,nky,nt,type=6,value=0)
fftarr[0:nx-1,0:ny-1,*] = fdata

;;==Calculate spatial FFT of density
for it=0,nt-1 do $
   fftarr[*,*,it] = fft(fftarr[*,*,it],/overwrite,/center)

;;==Condition data for (kx,ky,t) images
fdata = abs(fftarr)
dc_mask = 3
fdata[nkx/2-dc_mask:nkx/2+dc_mask, $
      nky/2-dc_mask:nky/2+dc_mask,*] = min(fdata)
fdata /= max(fdata)
fdata = 10*alog10(fdata^2)

;;==Set up kx and ky vectors
xdata = 2*!pi*fftfreq(nkx,dx)
xdata = shift(xdata,nkx/2)
ydata = 2*!pi*fftfreq(nky,dy)
ydata = shift(ydata,nky/2)

;;==Make frame(s)
data_graphics, fdata,xdata,ydata, $
               name, $
               time = time, $
               frame_path = path+path_sep()+'frames', $
               frame_name = name+'_fft', $
               frame_type = '.pdf', $
               context = name+'_fft'
