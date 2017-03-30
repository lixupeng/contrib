##################################################
###       SQLITE   															 ###
##################################################
## SQLITE from http://gnuwin32.sourceforge.net/packages/sqlite.htm
## repacked installed files (deleting precompiled libraries) and created VisualStudio 2008 files

MACRO( OPENMS_CONTRIB_BUILD_SQLITE )
  OPENMS_LOGHEADER_LIBRARY("SQLITE")
  #extract: (takes very long.. so skip if possible)
  if(MSVC)
    set(ZIP_ARGS "x -y -osrc")
  else()
    set(ZIP_ARGS "xzf")
  endif(MSVC)
  OPENMS_SMARTEXTRACT(ZIP_ARGS ARCHIVE_SQLITE "SQLITE" "INSTALL")
  
  if(MSVC)
    if (CONTRIB_MSVC_VERSION STREQUAL "12")
      # patch config.h (for VS12 only, since math.h defines some functions which SQLITE re-defines otherwise)
      set(PATCH_FILE "${PATCH_DIR}/sqlite/config.diff")
      set(PATCHED_FILE "${SQLITE_DIR}/config.h")
      OPENMS_PATCH( PATCH_FILE SQLITE_DIR PATCHED_FILE)
    endif()	
	  
    ## we need to build sqlite-lib, sqlitecblas-lib in release and debug mode (=4 libs)
    set(MSBUILD_ARGS_SLN "${SQLITE_DIR}/win32_VS${CONTRIB_MSVC_VERSION}/sqlite.sln")
    set(MSBUILD_ARGS_TARGET "sqlite")
    OPENMS_BUILDLIB("SQLITE (Debug)" MSBUILD_ARGS_SLN MSBUILD_ARGS_TARGET "Debug" SQLITE_DIR)
    OPENMS_BUILDLIB("SQLITE (Release)" MSBUILD_ARGS_SLN MSBUILD_ARGS_TARGET "Release" SQLITE_DIR)

    set(MSBUILD_ARGS_TARGET "cblas")
    OPENMS_BUILDLIB("SQLITE-cblas (Debug)" MSBUILD_ARGS_SLN MSBUILD_ARGS_TARGET "Debug" SQLITE_DIR)
    OPENMS_BUILDLIB("SQLITE-cblas (Release)" MSBUILD_ARGS_SLN MSBUILD_ARGS_TARGET "Release" SQLITE_DIR)
  
    ## copy includes
    set(dir_target ${PROJECT_BINARY_DIR}/include/sqlite)
    set(dir_source ${SQLITE_DIR}/win32_VS${CONTRIB_MSVC_VERSION}/include/sqlite)
    OPENMS_COPYDIR(dir_source dir_target)

  else()
    # patch Makefile.in
    set(PATCH_FILE "${PATCH_DIR}/sqlite/Makefile_in.diff")
    set(PATCHED_FILE "${SQLITE_DIR}/Makefile.in")
    OPENMS_PATCH( PATCH_FILE SQLITE_DIR PATCHED_FILE)

    if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
     set (SQLITE_CUSTOM_FLAGS "${CXX_OSX_FLAGS}")
    endif()
    
    # configure -- 
    set( ENV{CC} ${CMAKE_C_COMPILER} )
    set( ENV{CXX} ${CMAKE_CXX_COMPILER} )
    set( ENV{CFLAGS} ${SQLITE_CUSTOM_FLAGS})

    if (BUILD_SHARED_LIBRARIES)
      set(STATIC_BUILD "--enable-static=no")
      set(SHARED_BUILD "--enable-shared=yes")
    else()
      set(STATIC_BUILD "--enable-static=yes")
      set(SHARED_BUILD "--enable-shared=no")		
    endif()
		
    message( STATUS "Configure SQLITE library (./configure --prefix ${CMAKE_BINARY_DIR} --with-pic --disable-shared) .. ")
    exec_program("./configure" "${SQLITE_DIR}"
      ARGS
      --prefix ${CMAKE_BINARY_DIR}
      --with-pic
      ${STATIC_BUILD}
      ${SHARED_BUILD}
      OUTPUT_VARIABLE SQLITE_CONFIGURE_OUT
      RETURN_VALUE SQLITE_CONFIGURE_SUCCESS
      )

    # logfile
    file(APPEND ${LOGFILE} ${SQLITE_CONFIGURE_OUT})

    if( NOT SQLITE_CONFIGURE_SUCCESS EQUAL 0)
      message( STATUS "Configure SQLITE library (./configure --prefix ${CMAKE_BINARY_DIR} --with-pic --disable-shared) .. failed")
      message( FATAL_ERROR ${SQLITE_CONFIGURE_OUT})
    else()
      message( STATUS "Configure SQLITE library (./configure --prefix ${CMAKE_BINARY_DIR} --with-pic --disable-shared) .. done")
    endif()
  
    # make 
    message( STATUS "Building SQLITE library (make) .. ")
    exec_program(${CMAKE_MAKE_PROGRAM} "${SQLITE_DIR}"
      ARGS -j ${NUMBER_OF_JOBS}
      OUTPUT_VARIABLE SQLITE_MAKE_OUT
      RETURN_VALUE SQLITE_MAKE_SUCCESS
      )

    file(APPEND ${LOGFILE} ${SQLITE_MAKE_OUT})

    if( NOT SQLITE_MAKE_SUCCESS EQUAL 0)
      message( STATUS "Building SQLITE library (make) .. failed")
      message( FATAL_ERROR ${SQLITE_MAKE_OUT})
    else()
      message( STATUS "Building SQLITE library (make) .. done")
    endif()

    # make install
    message( STATUS "Installing SQLITE library (make install) .. ")
    exec_program(${CMAKE_MAKE_PROGRAM} "${SQLITE_DIR}"
      ARGS "install"
      -j ${NUMBER_OF_JOBS}
      OUTPUT_VARIABLE SQLITE_INSTALL_OUT
      RETURN_VALUE SQLITE_INSTALL_SUCCESS
      )

    file(APPEND ${LOGFILE} ${SQLITE_INSTALL_OUT})

    if( NOT SQLITE_INSTALL_SUCCESS EQUAL 0)
      message( STATUS "Installing SQLITE library (make install) .. failed")      
      message( FATAL_ERROR ${SQLITE_INSTALL_OUT})
    else()
      message( STATUS "Installing SQLITE library (make install) .. done")
    endif()
endif()

ENDMACRO( OPENMS_CONTRIB_BUILD_SQLITE )
