#include "napi/native_api.h"
#include "vnc_viewer.hpp"
#include "hilog/log.h"
#include "utils.hpp"
#include <cstddef>
#include <cstdint>
#include "string"
#include <multimodalinput/oh_key_code.h>
#include <stdexcept>
#include <sys/types.h>

#define napi_throw_error_m(code, fmt, ...)                                                                             \
    {                                                                                                                  \
        char errStr[64];                                                                                               \
        sprintf(errStr, fmt, __VA_ARGS__);                                                                             \
        napi_throw_error(env, #code, errStr);                                                                          \
    }

static napi_value update(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {};

    napi_status status = napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    if (status != napi_ok || argc < 2) {
        napi_throw_error(env, "-10", "napi_get_cb_info error.");
        return nullptr;
    }
    //    napi_value buffer;
    //    napi_typedarray_type buffet_type;
    //    size_t len, offset;
    //    status = napi_get_typedarray_info(env, args[0], &buffet_type, &len, nullptr, &buffer, &offset);
    //    if (status != napi_ok || argc < 2) {
    //        napi_throw_error(env, "-10", "napi_get_typedarray_info error.");
    //        return nullptr;
    //    }
    //    int32_t *data;
    //    size_t byte_length;
    //    napi_get_arraybuffer_info(env, buffer, (void **)&data, &byte_length);
    //    if (status != napi_ok || argc < 2) {
    //        napi_throw_error(env, "-10", "napi_get_arraybuffer_info error.");
    //        return nullptr;
    //    }
    //    if (buffet_type == napi_uint32_array) {
    //        for (int i = 0; i < len / sizeof(int32_t); i++) {
    //            data[i] *= data[i];
    //            data[i] += 1;
    //        }
    //    }


    napi_valuetype val_type;
    napi_typeof(env, args[0], &val_type);

    if (val_type != napi_function || argc < 2) {
        napi_throw_error_m(-12, "type error: %d, expect 'napi_function'", val_type);
        return nullptr;
    }

    napi_typeof(env, args[1], &val_type);

    if (val_type != napi_function || argc < 2) {
        napi_throw_error_m(-12, "type error: %d, expect 'napi_function'", val_type);
        return nullptr;
    }


    auto onResize = [&](size_t size) {
        auto ret = createNewBuffer(env, size);
        napi_value frameBufferNV;
        uint8_t *ptr = std::get<1>(ret);
        frameBufferNV = std::get<0>(ret);

        if (napi_ok != napi_call_function(env, nullptr, args[0], 1, &frameBufferNV, nullptr)) {
            napi_throw_error(env, "-10", "napi_call_function error.");
            return (uint8_t *)nullptr;
        }

        return ptr;
    };

    auto onUpdate = [&](RfbUpdateInfo &info) {
        napi_value jsInfo = parseRfbUpdateInfo(env, info);
        napi_call_function(env, nullptr, args[1], 1, &jsInfo, nullptr);
    };

    VncViewer::waitForMessage(onResize, onUpdate);

ErrExit:
    return nullptr;
}

static std::string value2String(napi_env env, napi_value value) {
    size_t stringSize = 0;
    napi_get_value_string_utf8(env, value, nullptr, 0, &stringSize);
    std::string valueString;
    valueString.resize(stringSize + 1);
    napi_get_value_string_utf8(env, value, &valueString[0], stringSize + 1, &stringSize);
    return valueString;
}

static napi_value vncInit(napi_env env, napi_callback_info info) {
    napi_value frameBufferNV = nullptr;
    auto onResize = [&](size_t size) {
        auto ret = createNewBuffer(env, size);
        uint8_t *ptr = std::get<1>(ret);
        frameBufferNV = std::get<0>(ret);
        return ptr;
    };

    size_t argc = 3;
    napi_value args[3] = {};

    napi_status status = napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    if (status != napi_ok || argc < 3) {
        napi_throw_error(env, "-10", "napi_get_cb_info error.");
        return nullptr;
    }

    napi_valuetype val_type;
    napi_typeof(env, args[0], &val_type);
    if (napi_string != val_type) {
        napi_throw_error_m(-12, "type error: %d, expect 'napi_string'", val_type);
        return nullptr;
    }
    std::string address = value2String(env, args[0]);

    napi_typeof(env, args[1], &val_type);
    if (napi_number != val_type) {
        napi_throw_error_m(-12, "type error: %d, expect 'napi_number'", val_type);
        return nullptr;
    }
    int32_t port = 0;
    napi_get_value_int32(env, args[1], &port);

    napi_typeof(env, args[2], &val_type);
    if (napi_string != val_type) {
        napi_throw_error_m(-12, "type error: %d, expect 'napi_string'", val_type);
        return nullptr;
    }
    std::string passwd = value2String(env, args[2]);

    // OH_LOG_INFO(LOG_APP, "address %{public}s %{public}d %{public}s", address.c_str(), port, passwd.c_str());

    VncViewer::setViewer(address.c_str(), port, passwd.c_str());

    try {
        VncViewer::initViewer(onResize);
    } catch (std::runtime_error e) {
    }

    return frameBufferNV;
}

static napi_value vncClose(napi_env env, napi_callback_info info) {
    VncViewer::closeViewer();

    napi_value ret(nullptr);
    if (napi_ok != napi_create_int32(env, 0, &ret)) {
        napi_throw_error(env, "-10", "napi_create_int32 error.");
        return nullptr;
    }

    return ret;
}

static napi_value mouseEvent(napi_env env, napi_callback_info info) {
    size_t argc = 3;
    napi_value args[3] = {};
    int x, y, buttonMask;

    napi_status status = napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    if (status != napi_ok || argc < 3) {
        napi_throw_error(env, "-10", "napi_get_cb_info error.");
        return nullptr;
    }

    napi_valuetype val_type;
    napi_typeof(env, args[0], &val_type);
    if (napi_number != val_type) {
        napi_throw_error_m(-12, "type error: %d, expect 'napi_string'", val_type) return nullptr;
    }
    napi_get_value_int32(env, args[0], &x);

    napi_typeof(env, args[1], &val_type);
    if (napi_number != val_type) {
        napi_throw_error_m(-12, "type error: %d, expect 'napi_string'", val_type) return nullptr;
    }
    napi_get_value_int32(env, args[1], &y);

    napi_typeof(env, args[2], &val_type);
    if (napi_number != val_type) {
        napi_throw_error_m(-12, "type error: %d, expect 'napi_string'", val_type) return nullptr;
    }
    napi_get_value_int32(env, args[2], &buttonMask);
    // OH_LOG_INFO(LOG_APP, "mouse: x_%{public}d, y_%{public}d, btn_%{public}d", x, y, buttonMask);
    VncViewer::mouseEvent(x, y, buttonMask);
    return nullptr;
}

static napi_value keyEvent(napi_env env, napi_callback_info info) {
    size_t argc = 2;
    napi_value args[2] = {};
    uint32_t key;
    bool down;

    napi_status status = napi_get_cb_info(env, info, &argc, args, nullptr, nullptr);
    if (status != napi_ok || argc < 2) {
        napi_throw_error(env, "-10", "napi_get_cb_info error.");
        return nullptr;
    }

    napi_valuetype val_type;
    napi_typeof(env, args[0], &val_type);
    if (napi_number != val_type) {
        napi_throw_error_m(-12, "type error: %d, expect 'napi_string'", val_type) return nullptr;
    }
    napi_get_value_uint32(env, args[0], &key);

    napi_typeof(env, args[1], &val_type);
    if (napi_boolean != val_type) {
        napi_throw_error_m(-12, "type error: %d, expect 'napi_string'", val_type) return nullptr;
    }
    napi_get_value_bool(env, args[1], &down);

    VncViewer::keyEvent(ohKeyCode2RFBKeyCode((Input_KeyCode)key, down), down);

    // OH_LOG_INFO(LOG_APP, "keyEvent: key_%{public}d, down_%{public}d", ohKeyCode2RFBKeyCode((Input_KeyCode)key),
    // down);

    return nullptr;
}


EXTERN_C_START static napi_value Init(napi_env env, napi_value exports) {
    napi_property_descriptor desc[] = {
        {"update", nullptr, update, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"vncInit", nullptr, vncInit, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"vncClose", nullptr, vncClose, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"mouseEvent", nullptr, mouseEvent, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"keyEvent", nullptr, keyEvent, nullptr, nullptr, nullptr, napi_default, nullptr}};
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
    return exports;
}
EXTERN_C_END

static napi_module demoModule = {
    .nm_version = 1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "n_vnc",
    .nm_priv = ((void *)0),
    .reserved = {0},
};

extern "C" __attribute__((constructor)) void RegisterN_vncModule(void) { napi_module_register(&demoModule); }
