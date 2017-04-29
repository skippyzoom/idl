;+
; Builds array of data from parallel HDF 
; files created by EPPIC
; Assumes that there is one parallel HDF 
; file per time step.
; If TIMESTEP is set, it must be given in 
; simulation time steps, not output steps.
; The user is responsible for knowing which
; time steps are available.
;
; NOTES:
; -- It may be more efficient to read 
;    multiple data fields from one time
;    step at a time than to read all 
;    time steps for a single quantity.
;    This function is currently only set
;    up to do the latter.
; -- By default, this function rotates
;    data to correct for the way EPPIC
;    outputs parallel HDF data. The user
;    can request the raw orientation by
;    calling the function with /NO_ROTATE
;    or NO_ROTATE=1.
;-
function read_ph5_data, dataName, $
                        verbose=verbose, $
                        ext=ext, $
                        nx=nx,ny=ny,nz=nz, $
                        timestep=timestep, $
                        type=type,path=path, $
                        no_rotate=no_rotate


  if n_elements(ext) eq 0 then ext = 'h5'
  if n_elements(nx) eq 0 then nx = 1
  if n_elements(ny) eq 0 then ny = 1
  if n_elements(nz) eq 0 then nz = 1
  if n_elements(type) eq 0 then type = 4
  if n_elements(path) eq 0 then path = './'
  path = terminal_slash(path)
  rotate_data = 1B
  if keyword_set(no_rotate) then rotate_data = 0B

  if strcmp(strmid(ext,0,1),'.') then $
     ext = strmid(ext,1,strlen(ext))
  h5File = file_search(path+'*.'+ext,count=count)
  nFiles = n_elements(h5File)
  if count ne 0 then begin
     h5Base = file_basename(h5File)
     all_timesteps = get_ph5timestep(h5Base)
     nout = all_timesteps[nFiles-1]/nFiles + 1
  endif else begin
     errmsg = "Found no files with extension "+ext
     message, errmsg
  endelse

  if n_elements(timestep) ne 0 then begin
     ;; tsInd = all_timesteps[timestep/nout]
     h5File = h5File(timestep/nout)
  endif

  nt = n_elements(h5File)
  data = make_array(nx,ny,nz,nt,type=type)

  ;-->Get dimensions from one file, then
  ;   define ndim_space and do dims check?

  if keyword_set(verbose) then print,"Reading ",dataName,"..."
  for it=0,nt-1 do begin
     fileID = h5f_open(h5File[it])
     dataID = h5d_open(fileID,dataName)
     temp = h5d_read(dataID)
     if rotate_data then begin
        ;; case ndim_space of
        ;;    2: temp = rotate(temp,4)
        ;;    3: for iz=0,nz-1 do $
        ;;          temp[*,*,iz] = rotate(temp[*,*,iz],5)
        ;; endcase
        if nz eq 1 then temp = rotate(temp,4) $
        else for iz=0,nz-1 do $
              temp[*,*,iz] = rotate(temp[*,*,iz],5)
     endif
     data[*,*,*,it] = temp
  endfor

  return, data
end
