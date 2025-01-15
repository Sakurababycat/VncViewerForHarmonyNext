# the minimum version of CMake.
cmake_minimum_required(VERSION 3.5.0)
project(native_vnc)
set(PROJECT_LANGUAGE C)
if(DEFINED CMAKE_CXX_COMPILER)
  set(CMAKE_CXX_STANDARD 17)
  list(APPEND PROJECT_LANGUAGES CXX)
endif(DEFINED CMAKE_CXX_COMPILER)

project(NativeVncClient VERSION 0.9.15 LANGUAGES ${PROJECT_LANGUAGES})
include(CheckFunctionExists)
include(CheckSymbolExists)
include(CheckIncludeFile)
include(CheckTypeSize)
include(TestBigEndian)
include(CheckCSourceCompiles)
include(CheckCSourceRuns)
include(GNUInstallDirs)

set(VERSION_SO             "1")
set(PROJECT_BUGREPORT_PATH "https://github.com/Sakurababycat/SimpleVncForHarmony5/issues")
set(COMMON_DIR ${CMAKE_CURRENT_SOURCE_DIR}/libvncserver/src/common)
set(LIBVNCCLIENT_DIR ${CMAKE_CURRENT_SOURCE_DIR}/libvncserver/src/libvncclient)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_CURRENT_SOURCE_DIR}/libvncserver/cmake/Modules/")
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

if(DEFINED PACKAGE_FIND_FILE)
    include(${PACKAGE_FIND_FILE})
endif()

include_directories(${CMAKE_CURRENT_SOURCE_DIR}
                    ${CMAKE_CURRENT_SOURCE_DIR}/include
                    ${CMAKE_CURRENT_SOURCE_DIR}/libvncserver/include
                    ${CMAKE_CURRENT_BINARY_DIR}/include
                    ${LIBVNCCLIENT_DIR}
                    ${COMMON_DIR}
                    )

option(WITH_LZO "Search for the LZO compression library to omit internal miniLZO implementation" ON)
option(WITH_GNUTLS "Search for the GnuTLS secure communications library to support TLS" ON)
option(WITH_OPENSSL "Search for the OpenSSL cryptography library to support TLS and use as crypto backend" ON)
option(WITH_GCRYPT "Search for Libgcrypt to use as crypto backend" ON)

if(WITH_LZO)
  find_package(LZO)
endif()

if(WITH_GNUTLS)
  find_package(GnuTLS 3.4.0)
endif(WITH_GNUTLS)

if(WITH_OPENSSL)
  find_package(OpenSSL)
endif(WITH_OPENSSL)

if(WITH_GCRYPT)
  find_library(LIBGCRYPT_LIBRARIES gcrypt)
endif(WITH_GCRYPT)

# headers needed for check_type_size()
check_include_file("vfork.h"       LIBVNCSERVER_HAVE_VFORK_H)
check_include_file("ws2tcpip.h"    LIBVNCSERVER_HAVE_WS2TCPIP_H)
check_include_file("arpa/inet.h"   HAVE_ARPA_INET_H)
check_include_file("stdint.h"      HAVE_STDINT_H)
check_include_file("stddef.h"      HAVE_STDDEF_H)
check_include_file("sys/types.h"   HAVE_SYS_TYPES_H)
check_include_file("sys/time.h"    LIBVNCSERVER_HAVE_SYS_TIME_H)
check_include_file("sys/socket.h"  LIBVNCSERVER_HAVE_SYS_SOCKET_H)
check_include_file("netinet/in.h"  LIBVNCSERVER_HAVE_NETINET_IN_H)

if(HAVE_ARPA_INET_H)
  # in_addr_t
  list(APPEND CMAKE_EXTRA_INCLUDE_FILES "arpa/inet.h")
endif(HAVE_ARPA_INET_H)
check_function_exists(vfork           LIBVNCSERVER_HAVE_VFORK)

if(LZO_FOUND)
  set(LIBVNCSERVER_HAVE_LZO 1)
else()
  unset(LZO_LIBRARIES CACHE) # would otherwise contain -NOTFOUND, confusing target_link_libraries()
endif()
if(NOT OPENSSL_FOUND)
    unset(OPENSSL_LIBRARIES) # would otherwise contain -NOTFOUND, confusing target_link_libraries()
endif()

# common crypto used by both libvncserver and libvncclient
if(WITH_GCRYPT AND LIBGCRYPT_LIBRARIES)
  message(STATUS "Building crypto with Libgcrypt")
  set(CRYPTO_LIBRARIES ${LIBGCRYPT_LIBRARIES})
  set(CRYPTO_SOURCES ${COMMON_DIR}/crypto_libgcrypt.c)
elseif(OPENSSL_FOUND)
  message(STATUS "Building crypto with OpenSSL")
  set(CRYPTO_LIBRARIES ${OPENSSL_LIBRARIES})
  set(CRYPTO_SOURCES ${COMMON_DIR}/crypto_openssl.c)
else()
  message(STATUS "Building crypto with builtin functions, only including SHA1 and D3DES")
  set(CRYPTO_SOURCES ${COMMON_DIR}/crypto_included.c ${COMMON_DIR}/sha1.c ${COMMON_DIR}/d3des.c)
endif()

check_type_size(pid_t     LIBVNCSERVER_PID_T)
check_type_size(size_t    LIBVNCSERVER_SIZE_T)
check_type_size(socklen_t LIBVNCSERVER_SOCKLEN_T)
check_type_size(in_addr_t LIBVNCSERVER_IN_ADDR_T)

configure_file(${CMAKE_CURRENT_SOURCE_DIR}/libvncserver/include/rfb/rfbconfig.h.cmakein ${CMAKE_CURRENT_BINARY_DIR}/include/rfb/rfbconfig.h)

set(LIBVNCCLIENT_SOURCES
    ${LIBVNCCLIENT_DIR}/cursor.c
    ${LIBVNCCLIENT_DIR}/listen.c
    ${LIBVNCCLIENT_DIR}/rfbclient.c
    ${LIBVNCCLIENT_DIR}/sockets.c
    ${LIBVNCCLIENT_DIR}/vncviewer.c
    ${COMMON_DIR}/sockets.c
    ${CRYPTO_SOURCES}
)

if(GNUTLS_FOUND)
  message(STATUS "Building TLS with GnuTLS")
  set(LIBVNCCLIENT_SOURCES
    ${LIBVNCCLIENT_SOURCES}
    ${LIBVNCCLIENT_DIR}/tls_gnutls.c
  )
  include_directories(${GNUTLS_INCLUDE_DIR})
elseif(OPENSSL_FOUND)
  message(STATUS "Building TLS with OpenSSL")
  set(LIBVNCCLIENT_SOURCES
    ${LIBVNCCLIENT_SOURCES}
    ${LIBVNCCLIENT_DIR}/tls_openssl.c
  )
  include_directories(${OPENSSL_INCLUDE_DIR})
else()
  message(STATUS "Building without TLS")
  set(LIBVNCCLIENT_SOURCES
    ${LIBVNCCLIENT_SOURCES}
    ${LIBVNCCLIENT_DIR}/tls_none.c
  )
endif()

if(LZO_FOUND)
  add_definitions(-DLIBVNCSERVER_HAVE_LZO)
  include_directories(${LZO_INCLUDE_DIR})
else()
  set(LIBVNCCLIENT_SOURCES
    ${LIBVNCCLIENT_SOURCES}
    ${COMMON_DIR}/minilzo.c
  )
endif()

configure_file(${CMAKE_CURRENT_SOURCE_DIR}/libvncserver/src/libvncclient/libvncclient.pc.cmakein ${CMAKE_CURRENT_BINARY_DIR}/libvncclient.pc @ONLY)

set(NVNCSOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/napi_init.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/vnc_viewer.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/utils.cpp
    )
add_library(n_vnc SHARED ${NVNCSOURCES} ${LIBVNCCLIENT_SOURCES})
target_link_libraries(n_vnc PUBLIC libace_napi.z.so libhilog_ndk.z.so)
