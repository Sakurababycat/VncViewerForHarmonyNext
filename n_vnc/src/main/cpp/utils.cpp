//
// Created on 2024/11/21.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".
#include "utils.hpp"
#include "rfb/keysym.h"
#include <cstddef>
#include <cstdint>
#include <multimodalinput/oh_key_code.h>

std::tuple<napi_value, uint8_t *> createNewBuffer(napi_env env, size_t num) {
    napi_value buffer;
    uint8_t *arrayPtr = NULL;
    if (napi_ok != napi_create_arraybuffer(env, num * sizeof(uint8_t), (void **)&arrayPtr, &buffer)) {
        napi_throw_error(env, "-10", "napi_create_arraybuffer error.");
        return std::make_tuple(nullptr, nullptr);
    }

    napi_value array;
    if (napi_ok != napi_create_typedarray(env, napi_uint8_array, num, buffer, 0, &array)) {
        napi_throw_error(env, "-10", "napi_create_typedarray error.");
        return std::make_tuple(nullptr, nullptr);
    };

    memset(arrayPtr, 0, num);

    return std::make_tuple(array, arrayPtr);
}

napi_value parseRfbUpdateInfo(napi_env env, struct RfbUpdateInfo &info) {
    napi_value jsInfo;
    uint8_t *infoPtr = NULL;
    constexpr size_t num = sizeof(info);
    auto ret = createNewBuffer(env, num);

    jsInfo = std::get<0>(ret);
    infoPtr = std::get<1>(ret);

    memcpy(infoPtr, &info, sizeof(info));

    return jsInfo;
}


rfbKeySym ohKeyCode2RFBKeyCode(Input_KeyCode k) {
    switch (k) {
    case KEYCODE_UNKNOWN:
    case KEYCODE_FN:
    case KEYCODE_VOLUME_UP:
    case KEYCODE_VOLUME_DOWN:
    case KEYCODE_POWER:
    case KEYCODE_CAMERA:
    case KEYCODE_VOLUME_MUTE:
    case KEYCODE_MUTE:
    case KEYCODE_BRIGHTNESS_UP:
    case KEYCODE_BRIGHTNESS_DOWN:
        return XK_VoidSymbol;
    case KEYCODE_0:
        return XK_0;
    case KEYCODE_1:
        return XK_1;
    case KEYCODE_2:
        return XK_2;
    case KEYCODE_3:
        return XK_3;
    case KEYCODE_4:
        return XK_4;
    case KEYCODE_5:
        return XK_5;
    case KEYCODE_6:
        return XK_6;
    case KEYCODE_7:
        return XK_7;
    case KEYCODE_8:
        return XK_8;
    case KEYCODE_9:
        return XK_9;
    case KEYCODE_STAR:
        return XK_asterisk; // *
    case KEYCODE_POUND:
        return XK_numbersign; // #
    case KEYCODE_DPAD_UP:
        return XK_Up;
    case KEYCODE_DPAD_DOWN:
        return XK_Down;
    case KEYCODE_DPAD_LEFT:
        return XK_Left;
    case KEYCODE_DPAD_RIGHT:
        return XK_Right;
    case KEYCODE_DPAD_CENTER:
        return XK_VoidSymbol;
    case KEYCODE_A:
        return XK_A;
    case KEYCODE_B:
        return XK_B;
    case KEYCODE_C:
        return XK_C;
    case KEYCODE_D:
        return XK_D;
    case KEYCODE_E:
        return XK_E;
    case KEYCODE_F:
        return XK_F;
    case KEYCODE_G:
        return XK_G;
    case KEYCODE_H:
        return XK_H;
    case KEYCODE_I:
        return XK_I;
    case KEYCODE_J:
        return XK_J;
    case KEYCODE_K:
        return XK_K;
    case KEYCODE_L:
        return XK_L;
    case KEYCODE_M:
        return XK_M;
    case KEYCODE_N:
        return XK_N;
    case KEYCODE_O:
        return XK_O;
    case KEYCODE_P:
        return XK_P;
    case KEYCODE_Q:
        return XK_Q;
    case KEYCODE_R:
        return XK_R;
    case KEYCODE_S:
        return XK_S;
    case KEYCODE_T:
        return XK_T;
    case KEYCODE_U:
        return XK_U;
    case KEYCODE_V:
        return XK_V;
    case KEYCODE_W:
        return XK_W;
    case KEYCODE_X:
        return XK_X;
    case KEYCODE_Y:
        return XK_Y;
    case KEYCODE_Z:
        return XK_Z;
    case KEYCODE_COMMA:
        return XK_comma;
    case KEYCODE_PERIOD:
        return XK_period;
    case KEYCODE_ALT_LEFT:
        return XK_Alt_L;
    case KEYCODE_ALT_RIGHT:
        return XK_Alt_R;
    case KEYCODE_SHIFT_LEFT:
        return XK_Shift_L;
    case KEYCODE_SHIFT_RIGHT:
        return XK_Shift_R;
    case KEYCODE_TAB:
        return XK_Tab;
    case KEYCODE_SPACE:
        return XK_space;
    case KEYCODE_SYM:
        return XK_VoidSymbol;
    case KEYCODE_EXPLORER:
        return XK_VoidSymbol;
    case KEYCODE_ENVELOPE:
        return XK_VoidSymbol;
    case KEYCODE_ENTER:
        return XK_Return;
    case KEYCODE_DEL:
        return XK_BackSpace;
    case KEYCODE_GRAVE:
        return XK_grave; // *
    case KEYCODE_MINUS:
        return XK_minus;
    case KEYCODE_EQUALS:
        return XK_equal;
    case KEYCODE_LEFT_BRACKET:
        return XK_bracketleft;
    case KEYCODE_RIGHT_BRACKET:
        return XK_bracketright;
    case KEYCODE_BACKSLASH:
        return XK_backslash;
    case KEYCODE_SEMICOLON:
        return XK_semicolon;
    case KEYCODE_APOSTROPHE:
        return XK_apostrophe;
    case KEYCODE_SLASH:
        return XK_slash;
    case KEYCODE_AT:
        return XK_at;
    case KEYCODE_PLUS:
        return XK_plus;
    case KEYCODE_MENU:
        return XK_Menu;
    case KEYCODE_PAGE_UP:
        return XK_Page_Up;
    case KEYCODE_PAGE_DOWN:
        return XK_Page_Down;
    case KEYCODE_ESCAPE:
        return XK_Escape;
    case KEYCODE_FORWARD_DEL:
        return XK_Delete;
    case KEYCODE_CTRL_LEFT:
        return XK_Control_L;
    case KEYCODE_CTRL_RIGHT:
        return XK_Control_R;
    case KEYCODE_CAPS_LOCK:
        return XK_Caps_Lock;
    case KEYCODE_SCROLL_LOCK:
        return XK_Scroll_Lock;
    case KEYCODE_META_LEFT:
        return XK_Meta_L;
    case KEYCODE_META_RIGHT:
        return XK_Meta_R;
    case KEYCODE_FUNCTION:
        return XK_VoidSymbol;
    case KEYCODE_SYSRQ:
        return XK_Sys_Req;
    case KEYCODE_BREAK:
        return XK_Break;
    case KEYCODE_MOVE_HOME:
        return XK_Home;
    case KEYCODE_MOVE_END:
        return XK_End;
    case KEYCODE_INSERT:
        return XK_Insert;
    case KEYCODE_FORWARD:
        return XK_VoidSymbol;
    case KEYCODE_MEDIA_PLAY:
        return XK_VoidSymbol;
    case KEYCODE_MEDIA_PAUSE:
        return XK_VoidSymbol;
    case KEYCODE_MEDIA_CLOSE:
        return XK_VoidSymbol;
    case KEYCODE_MEDIA_EJECT:
        return XK_VoidSymbol;
    case KEYCODE_MEDIA_RECORD:
        return XK_VoidSymbol;
    case KEYCODE_F1:
        return XK_F1;
    case KEYCODE_F2:
        return XK_F2;
    case KEYCODE_F3:
        return XK_F3;
    case KEYCODE_F4:
        return XK_F4;
    case KEYCODE_F5:
        return XK_F5;
    case KEYCODE_F6:
        return XK_F6;
    case KEYCODE_F7:
        return XK_F7;
    case KEYCODE_F8:
        return XK_F8;
    case KEYCODE_F9:
        return XK_F9;
    case KEYCODE_F10:
        return XK_F10;
    case KEYCODE_F11:
        return XK_F11;
    case KEYCODE_F12:
        return XK_F12;
    case KEYCODE_NUM_LOCK:
        return XK_Num_Lock;
    case KEYCODE_NUMPAD_0:
        return XK_KP_0;
    case KEYCODE_NUMPAD_1:
        return XK_KP_1;
    case KEYCODE_NUMPAD_2:
        return XK_KP_2;
    case KEYCODE_NUMPAD_3:
        return XK_KP_3;
    case KEYCODE_NUMPAD_4:
        return XK_KP_4;
    case KEYCODE_NUMPAD_5:
        return XK_KP_5;
    case KEYCODE_NUMPAD_6:
        return XK_KP_6;
    case KEYCODE_NUMPAD_7:
        return XK_KP_7;
    case KEYCODE_NUMPAD_8:
        return XK_KP_8;
    case KEYCODE_NUMPAD_9:
        return XK_KP_9;
    case KEYCODE_NUMPAD_DIVIDE:
        return XK_KP_Divide;
    case KEYCODE_NUMPAD_MULTIPLY:
        return XK_KP_Multiply;
    case KEYCODE_NUMPAD_SUBTRACT:
        return XK_KP_Subtract;
    case KEYCODE_NUMPAD_ADD:
        return XK_KP_Add;
    case KEYCODE_NUMPAD_DOT:
        return XK_KP_Decimal;
    case KEYCODE_NUMPAD_COMMA:
        return XK_KP_Separator;
    case KEYCODE_NUMPAD_ENTER:
        return XK_KP_Enter;
    case KEYCODE_NUMPAD_EQUALS:
        return XK_KP_Equal;
    case KEYCODE_NUMPAD_LEFT_PAREN:
        return XK_VoidSymbol;
    case KEYCODE_NUMPAD_RIGHT_PAREN:
        return XK_VoidSymbol;
    default:
        return XK_VoidSymbol;
    }
}