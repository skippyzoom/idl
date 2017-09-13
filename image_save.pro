;+
; Save an image, given the reference returned by image().
; This function accepts any extension accepted by the IDL
; save method (https://www.harrisgeospatial.com/docs/save_method.html)
; If this function doesn't recognize the file extension,
; it will issue a warning and use '.png' as the extension.
;-
pro image_save, image,filename=filename,_EXTRA=ex

  if n_elements(image) ne 0 then begin  
     ;;==Defaults and guards
     if n_elements(filename) eq 0 then filename = "new_image.png"

     ;;==Get file extension from filename
     ext = get_extension(filename)

     ;;==Check for file support
     types = ['bmp', $          ;Windows bitmap
              'emf', $          ;Windows enhanced metafile
              'eps','ps', $     ;Encapsulated PostScript
              'gif', $          ;GIF image
              'jpg','jpeg', $   ;JPEG image
              'jp2','jpx','j2k', $ ;JPEG2000 image
              'kml', $             ;OGC Keyhole Markup Language
              'kmz', $             ;A compressed and zipped version of KML
              'pdf', $             ;Portable document format
              'pict', $            ;Macintosh PICT image
              'png', $             ;PNG image
              'svg', $             ;Scalable Vector Graphics
              'tif','tiff']        ;TIFF image
     supported = string_exists(types,ext,/fold_case)
     if ~supported then begin
        print, "IMAGE_SAVE: File type not recognized or not supported. Using PNG."
        filename = strip_extension(filename)+'.png'
     endif

     ;;==Save image
     print, "IMAGE_SAVE: Saving ",filename,"..."
     image.save, filename,_EXTRA=ex
     if strcmp(ext,'pdf') or strcmp(ext,'gif') then image.close
     print, "IMAGE_SAVE: Finished."
  endif else begin
     print, "IMAGE_SAVE: Invalid image hangle. Did not save ",filename,"."
  endelse
end
