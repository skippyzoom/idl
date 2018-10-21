function bin_sum, f,xbs,ybs

  fsize = size(f)
  nx = fsize[1]
  ny = fsize[2]
  nxp = nx/xbs
  nyp = ny/ybs

  if (xbs gt 1) && (ybs gt 1) then begin
     fp = make_array(nxp,nyp,value=0,type=size(f,/type))
     for ix=0,nxp-1 do $
        for iy=0,nyp-1 do $
           fp[ix,iy] = total(f[xbs*ix:xbs*(ix+1)-1,ybs*iy:ybs*(iy+1)-1])
     return, fp
  endif $
  else return, f

end
