;+
; Load an empty instance of the default project context
; dictionary. This simply builds as many dictionaries as
; necessary for the user to populate with other types
; (e.g., numbers, strings, lists).
;-

function load_empty_context

  context = dictionary('data', dictionary('scale', dictionary()), $
                       'graphics', dictionary('rgb_table', dictionary(), $
                                              'class', dictionary(), $
                                              'plane', dictionary(), $
                                              'image', dictionary(), $
                                              'axes', dictionary('x', dictionary(), $
                                                                 'y', dictionary(), $
                                                                 'z', dictionary()), $
                                              'colorbar', dictionary(), $
                                              'movie', dictionary()), $
                       'panel', dictionary('index', dictionary(), $
                                           'layout', dictionary() $
                                          ) $
                      )

  return, context
end
