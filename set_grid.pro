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
           x = dx*nout_avg*findgen(nx*nsubdomains/nout_avg)
           nx = nx*nsubdomains/nout_avg
           y = dy*nout_avg*findgen(ny/nout_avg)
           ny = ny/nout_avg
           z = findgen(1) & nz = 1
           sizepertime = long64(nx)*long64(ny)*long64(nz)
           nout_avg =  nout_avg
           nsubdomains = nsubdomains
        end
        3: begin
           x = dz*nout_avg*findgen(nz/nout_avg)
           nx = nz/nout_avg
           y = dy*nout_avg*findgen(ny/nout_avg)
           ny = ny/nout_avg
           z = dx*nout_avg*findgen(nx*nsubdomains/nout_avg)
           nz = nx*nsubdomains/nout_avg
           sizepertime = long64(nx)*long64(ny)*long64(nz)
           nout_avg =  nout_avg
           nsubdomains = nsubdomains
           print, "SET_GRID: Swapped X and Z for 3D PHDF"
        end
     endcase
  endif else begin
     x = dx*nout_avg*findgen(nx*nsubdomains/nout_avg)
     nx = nx*nsubdomains/nout_avg
     y = dy*nout_avg*findgen(ny/nout_avg)
     ny = ny/nout_avg
     z = findgen(1) & nz = 1
     if ndim_space eq 3 then begin
        z = dz*nout_avg*findgen(nz/nout_avg)
        nz = nz/nout_avg
     endif
     sizepertime = long64(nx/nsubdomains)*long64(ny)*long64(nz)
     nout_avg =  nout_avg
     nsubdomains = nsubdomains
  endelse

  grid = {x:x, y:y, z:z, nx:nx, ny:ny, nz:nz, $
          sizepertime:sizepertime, $
          nout_avg:nout_avg, nsubdomains:nsubdomains}
  return, grid
end
