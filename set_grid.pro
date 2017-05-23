;+
; Set quantities related to the simulation grid.
;
; The purpose of the grid struct is that other routines can
; build subsets of the coordinates without running into 
; recursion problems.
;
; Parallel HDF routines swap the X and Z dimensions in 
; output.cc, so this routine will undo that swap if it 
; detects that EPPIC used parallel HDF output.
;-

function set_grid
@default.prm
  if hdf_output_arrays eq 2 then begin
     case ndim_space of
        2: begin
           nxg = nx*nsubdomains/nout_avg
           x = dx*nout_avg*findgen(nxg)
           nyg = ny/nout_avg
           y = dy*nout_avg*findgen(nyg)
           nzg = 1
           z = findgen(nzg)
           sizepertime = long64(nxg)*long64(nyg)*long64(nzg)
           nout_avg =  nout_avg
           nsubdomains = nsubdomains
        end
        3: begin
           nxg = nz/nout_avg
           x = dz*nout_avg*findgen(nxg)
           nyg = ny/nout_avg
           y = dy*nout_avg*findgen(nyg)
           nzg = nx*nsubdomains/nout_avg
           z = dx*nout_avg*findgen(nzg)
           sizepertime = long64(nxg)*long64(nyg)*long64(nzg)
           nout_avg =  nout_avg
           nsubdomains = nsubdomains
           print, "SET_GRID: Swapped X and Z for 3D PHDF"
        end
     endcase
  endif else begin
     nxg = nx*nsubdomains/nout_avg
     x = dx*nout_avg*findgen(nxg)
     nyg = ny/nout_avg
     y = dy*nout_avg*findgen(nyg)
     nzg = 1
     z = findgen(nzg)
     if ndim_space eq 3 then begin
        nzg = nz/nout_avg
        z = dz*nout_avg*findgen(nzg)
     endif
     sizepertime = long64(nxg/nsubdomains)*long64(nyg)*long64(nzg)
     nout_avg =  nout_avg
     nsubdomains = nsubdomains
  endelse

  grid = {x:x, y:y, z:z, nx:nxg, ny:nyg, nz:nzg, $
          sizepertime:sizepertime, $
          nout_avg:nout_avg, nsubdomains:nsubdomains}
  return, grid
end
