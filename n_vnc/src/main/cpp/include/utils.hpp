//
// Created on 2024/11/21.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#ifndef SIMPLEVNC_UTILS_HPP_H
#define SIMPLEVNC_UTILS_HPP_H

#include "vnc_viewer.hpp"
#include "napi/native_api.h"
#include "tuple"

napi_value parseRfbUpdateInfo(napi_env, struct RfbUpdateInfo &);
std::tuple<napi_value, uint8_t *> createNewBuffer(napi_env, size_t);
rfbKeySym ohKeyCode2RFBKeyCode(Input_KeyCode k);

#endif // SIMPLEVNC_UTILS_HPP_H
