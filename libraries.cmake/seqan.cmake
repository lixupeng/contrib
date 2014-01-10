##################################################
###       SEQAN   														 ###
##################################################
## 
## 

MACRO( OPENMS_CONTRIB_BUILD_SEQAN )
  OPENMS_LOGHEADER_LIBRARY("SeqAn")
  #extract: (takes very long.. so skip if possible)
  if(MSVC)
    set(ZIP_ARGS "x -y -osrc")
  else()
    set(ZIP_ARGS "xzf")
  endif()
  OPENMS_SMARTEXTRACT(ZIP_ARGS ARCHIVE_SEQAN "SEQAN" "include/seqan/version.h")

  ## copy includes
  set(dir_target ${CONTRIB_BIN_INCLUDE_DIR}/seqan)
  set(dir_source ${SEQAN_DIR}/include/seqan)
  OPENMS_COPYDIR(dir_source dir_target)

ENDMACRO( OPENMS_CONTRIB_BUILD_SEQAN )
