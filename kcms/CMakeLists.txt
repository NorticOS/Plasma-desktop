remove_definitions(-DQT_NO_CAST_FROM_ASCII -DQT_STRICT_ITERATORS -DQT_NO_CAST_FROM_BYTEARRAY -DQT_NO_KEYWORDS)

find_package(Freetype)
set_package_properties(Freetype PROPERTIES DESCRIPTION "A font rendering engine"
                       URL "https://www.freetype.org"
                       TYPE OPTIONAL
                       PURPOSE "Needed to build kfontinst, a simple font installer."
                      )


set(libkxftconfig_SRCS ${CMAKE_CURRENT_SOURCE_DIR}/fonts/kxftconfig.cpp )

if(X11_Xkb_FOUND AND XCB_XKB_FOUND)
    add_subdirectory( keyboard )
endif()

if (EVDEV_FOUND AND XORGLIBINPUT_FOUND AND X11_Xinput_FOUND)
    add_subdirectory( mouse )
endif()

add_subdirectory( access )
add_subdirectory( dateandtime )
add_subdirectory( autostart )
add_subdirectory( ksplash )

add_subdirectory( launch )
add_subdirectory( colors )
add_subdirectory( krdb )
add_subdirectory( style )
add_subdirectory( desktoptheme )
add_subdirectory( standard_actions )
add_subdirectory( keys )
add_subdirectory( ksmserver )
add_subdirectory( lookandfeel )
add_subdirectory( nightcolor )

add_subdirectory( hardware )
add_subdirectory( desktoppaths )

add_subdirectory(activities)
add_subdirectory(componentchooser)
add_subdirectory(emoticons)
add_subdirectory(icons)
add_subdirectory(kded)
add_subdirectory(formats)
add_subdirectory(notifications)
add_subdirectory(phonon)
add_subdirectory(runners)
add_subdirectory(spellchecking)
add_subdirectory(qtquicksettings)

add_subdirectory(workspaceoptions)
if (KF5Baloo_FOUND)
   add_subdirectory(baloo)
endif()
add_subdirectory(solid_actions)

if(X11_Xcursor_FOUND)
    add_subdirectory(cursortheme)
endif()

if (SYNAPTICS_FOUND AND X11_Xinput_FOUND)
    add_subdirectory(touchpad)
endif()

if(FONTCONFIG_FOUND AND FREETYPE_FOUND)
    add_subdirectory( kfontinst )
endif()

if( FREETYPE_FOUND )
   if(FONTCONFIG_FOUND )
       add_subdirectory( fonts )
   endif()
endif()
