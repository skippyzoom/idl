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

if hdf_output_arrays eq 2 then begin
   case ndim_space of
      2: begin
         ;; grid = {x:dy*nout_avg*findgen(ny2), $
         ;;         nx:ny2, $
         ;;         y:dx*nout_avg*findgen(nx2), $
         ;;         ny:nx2, $
         ;;         z:dz*nout_avg*findgen(nz2), $
         ;;         nz:nz2, $
         ;;         aspect_ratio:1.0, $
         ;;         nsubdomains:nsubdomains}
         grid = {x:dx*nout_avg*findgen(nx2), $
                 nx:nx2, $
                 y:dy*nout_avg*findgen(ny2), $
                 ny:ny2, $
                 z:dz*nout_avg*findgen(nz2), $
                 nz:nz2, $
                 aspect_ratio:1.0, $
                 nsubdomains:nsubdomains}
         ;; print, "SET_GRID: Swapped X and Y for 2D PHDF"
      end
      3: begin
         grid = {x:dz*nout_avg*findgen(nz2), $
                 nx:nz2, $
                 y:dy*nout_avg*findgen(ny2), $
                 ny:ny2, $
                 z:dx*nout_avg*findgen(nx2), $
                 nz:nx2, $
                 aspect_ratio:1.0, $
                 nsubdomains:nsubdomains}
         print, "SET_GRID: Swapped X and Z for 3D PHDF"
      end
   endcase
endif else begin
   grid = {x:dx*nout_avg*findgen(nx2), $
           nx:nx2, $
           y:dy*nout_avg*findgen(ny2), $
           ny:ny2, $
           z:dz*nout_avg*findgen(nz2), $
           nz:nz2, $
           aspect_ratio:1.0, $
           nsubdomains:nsubdomains}
endelse

grid.aspect_ratio = float(grid.nx)/grid.ny

end
