;+
; Attempts to determine how many time steps are 
; available for a simulation run. Designed to 
; handle typical PPIC3D or EPPIC runs.
;
; The CASE structure is designed to test the most 
; common cases first, for the sake of efficiency,
; but the speed-up may be negligible.
;
; NOTES:
; -- The parallel HDF method assumes all *.h5 files are
;    in the parallel directory. The user must be careful
;    when only transfering a subset of files from another
;    system (e.g. Stampede).
;-
function calc_timesteps, path,grid
  
  if file_test(expand_path(path+path_sep()+'domain000'),/directory) then $
     bp = expand_path(path+path_sep()+'domain*/') $
  else bp = expand_path(path+path_sep()+'./')
  nt_max = 0
  case 1 of
     file_test(expand_path(path+path_sep()+'moments1.out')): begin
        nt_max = file_lines(expand_path(path+path_sep()+'moments1.out'))-1
        print, "[CALC_TIMESTEPS] Computed max time steps from 'moments1.out'"
     end
     file_test(expand_path(path+path_sep()+'moments0.out')): begin
        nt_max = file_lines(expand_path(path+path_sep()+'moments0.out'))-1
        print, "[CALC_TIMESTEPS] Computed max time steps from 'moments0.out'"
     end
     file_test(expand_path(path+path_sep()+'domain000/moments1.out')): begin
        nt_max = file_lines(expand_path(path+path_sep()+'domain000/moments1.out'))-1
        print, "[CALC_TIMESTEPS] Computed max time steps from 'domain000/moments1.out'"
     end
     file_test(expand_path(path+path_sep()+'domain000/moments0.out')): begin
        nt_max = file_lines(expand_path(path+path_sep()+'domain000/moments0.out'))-1
        print, "[CALC_TIMESTEPS] Computed max time steps from 'domain000/moments0.out'"
     end
     file_test(expand_path(path+path_sep()+'parallel'),/directory): begin
        !NULL = file_search(expand_path(path+path_sep()+'parallel/*.h5'),count=count)
        nt_max = count
        print, "[CALC_TIMESTEPS] Computed max time steps from parallel/*.h5"
     end
     file_test(expand_path(path+path_sep()+'den1.bin')): begin
        nt_max = timesteps(expand_path(path+path_sep()+'den1.bin'), $
                          grid.sizepertime,grid.nsubdomains,basepath=bp)
        print, "[CALC_TIMESTEPS] Computed max time steps from den1.bin"
     end
     file_test(expand_path(path+path_sep()+'phi.bin')): begin
        nt_max = timesteps(expand_path(path+path_sep()+'phi.bin'), $
                          grid.sizepertime,grid.nsubdomains,basepath=bp)
        print, "[CALC_TIMESTEPS] Computed max time steps from phi.bin"
     end
     file_test(expand_path(path+path_sep()+'den0.bin')): begin
        nt_max = timesteps(expand_path(path+path_sep()+'den0.bin'), $
                          grid.sizepertime,grid.nsubdomains,basepath=bp)
        print, "[CALC_TIMESTEPS] Computed max time steps from 'den0.bin'"
     end
     else: print, "[CALC_TIMESTEPS] Could not compute max time steps"
  endcase
  ;; times = dt*nout*findgen(nt_max)/(nt_max-1)

  return, nt_max

end
