;+
; Convenience script for reading EPPIC den1 data.
;-

;;==Set up project-specific parameters
if n_elements(pd) eq 0 then $
   pd = project_setup(path=path,project=project)

;;==Set up time-step dictionary
if n_elements(time) eq 0 then $
   time = time_strings(pd.params.nout*lindgen(pd.params.nt_max), $
                       dt=pd.params.dt,scale=1e3,precision=2)

;;==Declare axes default
if n_elements(axes) eq 0 then axes = 'xy'

;;==Extract a plane of data
plane = read_data_plane('den1', $
                        timestep = fix(time.index), $
                        axes = axes, $
                        data_type = 4, $
                        data_isft = 0B, $
                        ranges = pd.ranges, $
                        rotate = pd.rotate, $
                        info_path = pd.path, $
                        data_path = pd.path+path_sep()+'parallel')

;;==Extract the data array for convenience
den1 = plane.remove('f')
xdata = plane.remove('x')
ydata = plane.remove('y')
dx = plane.remove('dx')
dy = plane.remove('dy')
plane = !NULL
