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
function calc_timesteps, grid
  if file_test('domain000',/directory) then bp = 'domain*/' $
  else bp = './'
  ntMax = 0
  case 1 of
     file_test('moments1.out'): begin
        ntMax = file_lines('moments1.out')-1
        print, "CALC_TIMESTEPS: Computed ntMax from 'moments1.out'"
     end
     file_test('moments0.out'): begin
        ntMax = file_lines('moments0.out')-1
        print, "CALC_TIMESTEPS: Computed ntMax from 'moments0.out'"
     end
     file_test('domain000/moments1.out'): begin
        ntMax = file_lines('domain000/moments1.out')-1
        print, "CALC_TIMESTEPS: Computed ntMax from 'domain000/moments1.out'"
     end
     file_test('domain000/moments0.out'): begin
        ntMax = file_lines('domain000/moments0.out')-1
        print, "CALC_TIMESTEPS: Computed ntMax from 'domain000/moments0.out'"
     end
     file_test('parallel',/directory): begin
        !NULL = file_search('parallel/*.h5',count=count)
        ntMax = count
        print, "CALC_TIMESTEPS: Computed ntMax from parallel/*.h5"
     end
     file_test('den1.bin'): begin
        ntMax = timesteps('den1.bin', $
                          grid.sizepertime,grid.nsubdomains,basepath=bp)
        print, "CALC_TIMESTEPS: Computed ntMax from den1.bin"
     end
     file_test('phi.bin'): begin
        ntMax = timesteps('phi.bin', $
                          grid.sizepertime,grid.nsubdomains,basepath=bp)
        print, "CALC_TIMESTEPS: Computed ntMax from phi.bin"
     end
     file_test('den0.bin'): begin
        ntMax = timesteps('den0.bin', $
                          grid.sizepertime,grid.nsubdomains,basepath=bp)
        print, "CALC_TIMESTEPS: Computed ntMax from 'den0.bin'"
     end
     else: print, "CALC_TIMESTEPS: Could not compute ntMax"
  endcase
  ;; times = dt*nout*findgen(ntMax)/(ntMax-1)

  return, ntMax

end
