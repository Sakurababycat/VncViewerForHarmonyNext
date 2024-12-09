# the minimum version of CMake.
cmake_minimum_required(VERSION 3.5.0)
project(native_vnc)
set(PROJECT_LANGUAGE C)
if(DEFINED CMAKE_CXX_COMPILER)
  set(CMAKE_CXX_STANDARD 17)
  list(APPEND PROJECT_LANGUAGES CXX)
endif(DEFINED CMAKE_CXX_COMPILER)

project(LibVNCServer VERSION 0.9.15 LANGUAGES ${PROJECT_LANGUAGES})
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
option(WITH_THREADS "Search for a threading library to build with multithreading support" ON)
option(WITH_GNUTLS "Search for the GnuTLS secure communications library to support TLS" ON)
option(WITH_OPENSSL "Search for the OpenSSL cryptography library to support TLS and use as crypto backend" ON)
option(WITH_GCRYPT "Search for Libgcrypt to use as crypto backend" ON)
option(WITH_TIGHTVNC_FILETRANSFER "Enable filetransfer if there is pthreads support" ON)
option(WITH_24BPP "Allow 24 bpp" ON)
option(WITH_IPv6 "Enable IPv6 Support" ON)
option(WITH_WEBSOCKETS "Build with websockets support" ON)
option(WITH_SASL "Build with SASL support" ON)

if(WITH_LZO)
  find_package(LZO)
endif()

if(WITH_THREADS)
  find_package(Threads)
endif(WITH_THREADS)


if(WITH_GNUTLS)
  find_package(GnuTLS 3.4.0)
endif(WITH_GNUTLS)


if(WITH_OPENSSL)
  find_package(OpenSSL)
endif(WITH_OPENSSL)

if(WITH_GCRYPT)
  find_library(LIBGCRYPT_LIBRARIES gcrypt)
endif(WITH_GCRYPT)

check_include_file("dirent.h"      LIBVNCSERVER_HAVE_DIRENT_H)
check_include_file("endian.h"      LIBVNCSERVER_HAVE_ENDIAN_H)
check_include_file("fcntl.h"       LIBVNCSERVER_HAVE_FCNTL_H)
check_include_file("netinet/in.h"  LIBVNCSERVER_HAVE_NETINET_IN_H)
check_include_file("sys/endian.h"  LIBVNCSERVER_HAVE_SYS_ENDIAN_H)
check_include_file("sys/socket.h"  LIBVNCSERVER_HAVE_SYS_SOCKET_H)
check_include_file("sys/stat.h"    LIBVNCSERVER_HAVE_SYS_STAT_H)
check_include_file("sys/time.h"    LIBVNCSERVER_HAVE_SYS_TIME_H)
check_include_file("sys/types.h"   LIBVNCSERVER_HAVE_SYS_TYPES_H)
check_include_file("sys/wait.h"    LIBVNCSERVER_HAVE_SYS_WAIT_H)
check_include_file("unistd.h"      LIBVNCSERVER_HAVE_UNISTD_H)
check_include_file("sys/resource.h"     LIBVNCSERVER_HAVE_SYS_RESOURCE_H)


# headers needed for check_type_size()
check_include_file("vfork.h"       LIBVNCSERVER_HAVE_VFORK_H)
check_include_file("ws2tcpip.h"    LIBVNCSERVER_HAVE_WS2TCPIP_H)
check_include_file("arpa/inet.h"   HAVE_ARPA_INET_H)
check_include_file("stdint.h"      HAVE_STDINT_H)
check_include_file("stddef.h"      HAVE_STDDEF_H)
check_include_file("sys/types.h"   HAVE_SYS_TYPES_H)

check_function_exists(gettimeofday    LIBVNCSERVER_HAVE_GETTIMEOFDAY)
check_function_exists(vfork           LIBVNCSERVER_HAVE_VFORK)
check_function_exists(vprintf         LIBVNCSERVER_HAVE_VPRINTF)
check_function_exists(mmap            LIBVNCSERVER_HAVE_MMAP)
check_function_exists(fork            LIBVNCSERVER_HAVE_FORK)
check_function_exists(ftime           LIBVNCSERVER_HAVE_FTIME)
check_function_exists(gethostbyname   LIBVNCSERVER_HAVE_GETHOSTBYNAME)
check_function_exists(gethostname     LIBVNCSERVER_HAVE_GETHOSTNAME)
check_function_exists(inet_ntoa       LIBVNCSERVER_HAVE_INET_NTOA)
check_function_exists(memmove         LIBVNCSERVER_HAVE_MEMMOVE)
check_function_exists(memset          LIBVNCSERVER_HAVE_MEMSET)
check_function_exists(mkfifo          LIBVNCSERVER_HAVE_MKFIFO)
check_function_exists(select          LIBVNCSERVER_HAVE_SELECT)
check_function_exists(socket          LIBVNCSERVER_HAVE_SOCKET)
check_function_exists(strchr          LIBVNCSERVER_HAVE_STRCHR)
check_function_exists(strcspn         LIBVNCSERVER_HAVE_STRCSPN)
check_function_exists(strdup          LIBVNCSERVER_HAVE_STRDUP)
check_function_exists(strerror        LIBVNCSERVER_HAVE_STRERROR)
check_function_exists(strstr          LIBVNCSERVER_HAVE_STRSTR)

check_symbol_exists(htobe64 "endian.h" LIBVNCSERVER_HAVE_HTOBE64)
check_symbol_exists(htobe64 "sys/endian.h" LIBVNCSERVER_HAVE_HTOBE64)
check_symbol_exists(OSSwapHostToBigInt64 "libkern/OSByteOrder.h" LIBVNCSERVER_HAVE_OSSWAPHOSTTOBIGINT64)

if(WITH_THREADS AND Threads_FOUND)
  set(ADDITIONAL_LIBS ${ADDITIONAL_LIBS} ${CMAKE_THREAD_LIBS_INIT})
endif(WITH_THREADS AND Threads_FOUND)
if(ZLIB_FOUND)
  set(LIBVNCSERVER_HAVE_LIBZ 1)
else()
  unset(ZLIB_LIBRARIES) # would otherwise contain -NOTFOUND, confusing target_link_libraries()
endif(ZLIB_FOUND)
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

if(WITH_WEBSOCKETS AND (LIBVNCSERVER_HAVE_HTOBE64 OR LIBVNCSERVER_HAVE_OSSWAPHOSTTOBIGINT64))
  set(LIBVNCSERVER_WITH_WEBSOCKETS 1)
endif()

if(WITH_GCRYPT AND LIBGCRYPT_LIBRARIES)
  set(LIBVNCSERVER_HAVE_LIBGCRYPT 1)
endif(WITH_GCRYPT AND LIBGCRYPT_LIBRARIES)

if(GNUTLS_FOUND)
  set(LIBVNCSERVER_HAVE_GNUTLS 1)
endif(GNUTLS_FOUND)

if(OPENSSL_FOUND)
  include_directories(${OPENSSL_INCLUDE_DIR})
  set(LIBVNCSERVER_HAVE_LIBSSL 1)
endif(OPENSSL_FOUND)

if(WITH_IPv6)
  if(WIN32 AND LIBVNCSERVER_HAVE_WS2TCPIP_H AND LIBVNCSERVER_HAVE_VPRINTF)
    set(LIBVNCSERVER_IPv6 1)
  endif()
  if(NOT WIN32)
    set(LIBVNCSERVER_IPv6 1)
  endif()
endif(WITH_IPv6)


if(WITH_24BPP)
  set(LIBVNCSERVER_ALLOW24BPP 1)
endif()

# Make sure that only one threading system is used. This happens on MinGW.
if(WITH_THREADS)
  if(CMAKE_USE_PTHREADS_INIT AND CMAKE_USE_WIN32_THREADS_INIT)
    if(PREFER_WIN32THREADS)
      unset(CMAKE_USE_PTHREADS_INIT)
    else()
      unset(CMAKE_USE_WIN32_THREADS_INIT)
    endif(PREFER_WIN32THREADS)
  endif(CMAKE_USE_PTHREADS_INIT AND CMAKE_USE_WIN32_THREADS_INIT)

  if(CMAKE_USE_PTHREADS_INIT)
    set(LIBVNCSERVER_HAVE_LIBPTHREAD 1)
    message(STATUS "Threads support is using pthreads")
  endif(CMAKE_USE_PTHREADS_INIT)

  if(CMAKE_USE_WIN32_THREADS_INIT)
    set(LIBVNCSERVER_HAVE_WIN32THREADS 1)
    message(STATUS "Threads support is using win32 threads")
  endif(CMAKE_USE_WIN32_THREADS_INIT)
endif(WITH_THREADS)

if(LIBVNCSERVER_HAVE_SYS_SOCKET_H)
  # socklen_t
  list(APPEND CMAKE_EXTRA_INCLUDE_FILES "sys/socket.h")
endif(LIBVNCSERVER_HAVE_SYS_SOCKET_H)
if(HAVE_ARPA_INET_H)
  # in_addr_t
  list(APPEND CMAKE_EXTRA_INCLUDE_FILES "arpa/inet.h")
endif(HAVE_ARPA_INET_H)

check_type_size(pid_t     LIBVNCSERVER_PID_T)
check_type_size(size_t    LIBVNCSERVER_SIZE_T)
check_type_size(socklen_t LIBVNCSERVER_SOCKLEN_T)
check_type_size(in_addr_t LIBVNCSERVER_IN_ADDR_T)
if(NOT HAVE_LIBVNCSERVER_IN_ADDR_T)
  set(LIBVNCSERVER_NEED_INADDR_T 1)
endif(NOT HAVE_LIBVNCSERVER_IN_ADDR_T)

TEST_BIG_ENDIAN(LIBVNCSERVER_WORDS_BIGENDIAN)

if(WITH_SASL)
  find_path(SASL2_INCLUDE_DIR sasl/sasl.h)
  find_library(LIBSASL2_LIBRARIES sasl2 libsasl.lib)
endif(WITH_SASL)

if(WITH_SASL AND LIBSASL2_LIBRARIES AND SASL2_INCLUDE_DIR)
  message(STATUS "Building with SASL: ${LIBSASL2_LIBRARIES} and ${SASL2_INCLUDE_DIR}")
  set(LIBVNCSERVER_HAVE_SASL 1)
  set(ADDITIONAL_LIBS ${ADDITIONAL_LIBS} ${LIBSASL2_LIBRARIES})
  include_directories(${SASL2_INCLUDE_DIR})
endif(WITH_SASL AND LIBSASL2_LIBRARIES AND SASL2_INCLUDE_DIR)

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

if(LIBVNCSERVER_HAVE_SASL)
  set(LIBVNCCLIENT_SOURCES
    ${LIBVNCCLIENT_SOURCES}
    ${LIBVNCCLIENT_DIR}/sasl.c
  )
endif()

if(ZLIB_FOUND)
  add_definitions(-DLIBVNCSERVER_HAVE_LIBZ)
  include_directories(${ZLIB_INCLUDE_DIR})
endif(ZLIB_FOUND)

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
