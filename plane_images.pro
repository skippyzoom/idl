pro plane_images, name, $
                  axes=axes, $
                  time=time, $
                  ranges=ranges, $
                  rotate=rotate, $
                  path=path, $
                  data_out=data_out

  ;;==Defaults and guards
  if n_elements(axes) eq 0 then axes = 'xy'
  if n_elements(time) eq 0 then time = dictionary()
  if ~isa(time,'dictionary') then time = dictionary(time)
  if ~time.haskey('index') then time['index'] = 0
  if n_elements(ranges) eq 0 then ranges = [0,1,0,1,0,1]
  if n_elements(rotate) eq 0 then rotate = 0
  if n_elements(path) eq 0 then path = './'

  ;;==Extract a plane of data
  plane = read_data_plane(name, $
                          timestep = fix(time.index), $
                          axes = axes, $
                          data_type = 4, $
                          data_isft = 0B, $
                          ranges = ranges, $
                          rotate = rotate, $
                          info_path = path, $
                          data_path = path+path_sep()+'parallel')

  ;;==Add name to plane
  plane['name'] = name

  ;;==Make data available to calling routine
  data_out = plane

  ;;==Get dimensions of data plane
  fsize = size(plane.f)
  nx = fsize[1]
  ny = fsize[2]
  nt = fsize[3]

  ;;==Make frame(s)
  data_graphics, plane.f,plane.x,plane.y, $
                 name, $
                 time = time, $
                 frame_path = path+path_sep()+'frames', $
                 frame_name = name, $
                 frame_type = '.pdf', $
                 context = name

end
