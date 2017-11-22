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
;
; TO DO:
;-
function read_ph5_data, dataName, $
                        verbose=verbose, $
                        ext=ext, $
                        timestep=timestep, $
                        type=type, $
                        path=path

  if n_elements(ext) eq 0 then ext = 'h5'
  if n_elements(type) eq 0 then type = 4
  if n_elements(path) eq 0 then path = './'
  path = terminal_slash(path)

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

  if n_elements(timestep) ne 0 then h5File = h5File(timestep/nout)

  nt = n_elements(h5File)
  data = make_array([size(get_h5_data(h5File[0],dataName),/dim),nt],type=type)

  if keyword_set(verbose) then print,"[READ_PH5_DATA] Reading ",dataName,"..."
  nullCount = 0L
  for it=0,nt-1 do begin
     temp = get_h5_data(h5File[it],dataName)
     if n_elements(temp) ne 0 then begin
        case size(data,/n_dim) of
           2: data[*,it] = temp
           3: data[*,*,it] = temp
           4: data[*,*,*,it] = temp
           5: data[*,*,*,*,it] = temp
           6: data[*,*,*,*,*,it] = temp
           7: data[*,*,*,*,*,*,it] = temp
           8: data[*,*,*,*,*,*,*,it] = temp
        endcase
     endif else nullCount++
  endfor
  if nullCount gt 0 then $
     print, "[READ_PH5_DATA] Warning: Did not find '", $
            dataName+"' in ", $
            strcompress(nullCount,/remove_all),"/", $
            strcompress(nt,/remove_all)," files."

  return, data
end
