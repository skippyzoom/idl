;+
; Function to read data from either EPPIC (domain-decomposed) or 
; PPIC3D (single-domain) simulation. Determines whether data is 
; domain decomposed based on presence of domain directories, rather
; than by checking the value of the 'nsubdomains' variable, to 
; handle the uncommon case of a single-subdomain EPPIC run.
;
; NOTES
; -- This function assumes that nx is the full x size, not the
;    size of one subdomain. The reason is compatibility with
;    similar functions (e.g. read_ph5_data.pro), to provide a more
;    unified interface for read_xxx_data.pro
;-

function read_bin_data, inName, $
                        verbose=verbose, $
                        nx=nx,ny=ny,nz=nz,nsubdomains=nsubdomains, $
                        order=order,skip=iskip, $
                        istart=istart,iend=iend,sizepertime=sizepertime

  ;;==Preserve input data string
  dataName = inName

  ;;==If full file name is provided, extract name substring
  perPos = strpos(dataName,'.')
  if perPos ge 0 then dataName = strmid(dataName,0,perPos)

  ;;==Make sure dataName is lower-case
  dataName = strlowcase(dataName)

  ;;==Check for domain directories
  decomposed = 0B
  if file_test('domain000',/directory) then decomposed = 1B

  ;;==Read binary data
  binName = dataName+'.bin'
  if keyword_set(verbose) then print,"READ_BIN_DATA: Reading ",dataName,"..."
  if decomposed then begin
     data = read_domains(binName,[nx/nsubdomains,ny,nz],ndomains=nsubdomains, $
                         order=order,/binary,skip=iskip, $
                         first=long64(istart*sizepertime),last=long64(iend*sizepertime))
  endif else begin
     data = readarray(binName,[nx,ny,nz], $
                      order=order,/binary,skip=iskip, $
                      first=long64(istart*sizepertime),last=long64(iend*sizepertime))
  endelse

  return, data
end
