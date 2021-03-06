;+
; Script for creating images of density in the working directory
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
plane = read_data_plane(den, $
                        timestep = fix(time.index), $
                        axes = 'xy', $
                        data_type = 4, $
                        data_isft = 0B, $
                        ranges = [0,1,0,1,0,1], $
                        rotate = 3, $
                        info_path = path, $
                        data_path = path+path_sep()+'parallel')

;;==Make frame(s)
data_graphics, plane.f,plane.x,plane.y, $
               den, $
               time = time, $
               frame_path = path+path_sep()+'frames', $
               frame_name = den, $
               frame_type = '.pdf', $
               context = den
