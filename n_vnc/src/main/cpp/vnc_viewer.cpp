//
// Created on 2024/11/19.
//
// Node APIs are not fully supported. To solve the compilation error of the interface cannot be found,
// please include "napi/native_api.h".

#include "vnc_viewer.hpp"
#include "rfb/rfb.h"
#include <cstddef>
#include <cstdint>
#include <stdexcept>
#include <unistd.h>

rfbClient *VncViewer::cl = nullptr;
VncViewer::onResizeCallback VncViewer::onResize = nullptr;
VncViewer::onUpdateCallback VncViewer::onUpdate = nullptr;
char VncViewer::passwd[] = {};

void VncViewer::update(rfbClient *cl, int x, int y, int w, int h) {
    /**
    OH_LOG_INFO(LOG_APP,
                "update0: width_%{public}d, height_%{public}d, x_%{public}d, y_%{public}d, w_%{public}d, h_%{public}d",
                cl->width, cl->height, x, y, w, h); /**/
    struct RfbUpdateInfo info = {.width = cl->width, .height = cl->height, .x = x, .y = y, .w = w, .h = h};
    if (onUpdate) {
        onUpdate(info);
    }
}

int VncViewer::waitForMessage(VncViewer::onResizeCallback onResize, VncViewer::onUpdateCallback onUpdate) {
    VncViewer::onResize = onResize;
    VncViewer::onUpdate = onUpdate;

    int i = WaitForMessage(cl, 500);
    if (i < 0) {
        rfbClientCleanup(cl);
    }
    if (i) {
        if (!HandleRFBServerMessage(cl)) {
            rfbClientCleanup(cl);
        }
    }
    VncViewer::onResize = nullptr;
    VncViewer::onUpdate = nullptr;
    return i;
}

char *VncViewer::getPasswd(rfbClient *cl) {
    char *passwd = (char *)malloc(RFB_BUF_SIZE);
    strcpy(passwd, "id15182608692");
    return passwd;
}

void VncViewer::closeViewer() {
    rfbCloseSocket(VncViewer::cl->sock);
    delete VncViewer::cl;
}

rfbBool VncViewer::resize(rfbClient *cl) {
    /**/
    OH_LOG_INFO(LOG_APP, "onResize: width_%{public}d, height_%{public}d", cl->width, cl->height);
    /**/
    size_t num = cl->height * cl->width * cl->format.bitsPerPixel / 8;
    if (onResize) {
        uint8_t *ptr = onResize(num);
        cl->frameBuffer = ptr;
        return TRUE;
    } else
        return FALSE;
}

void VncViewer::setViewer(const char *address, int port, const char *passwd) {
    VncViewer::cl = rfbGetClient(8, 3, 2);

    strcpy(VncViewer::passwd, passwd);
    VncViewer::cl->serverHost = strdup(address);
    VncViewer::cl->serverPort = port;

    VncViewer::cl->canHandleNewFBSize = TRUE;
    VncViewer::cl->MallocFrameBuffer = VncViewer::resize;
    VncViewer::cl->format.depth = 16;
    VncViewer::cl->format.bitsPerPixel = 16;
    VncViewer::cl->format.redShift = 11;
    VncViewer::cl->format.greenShift = 5;
    VncViewer::cl->format.blueShift = 0;
    VncViewer::cl->format.redMax = 0x1f;
    VncViewer::cl->format.greenMax = 0x3f;
    VncViewer::cl->format.blueMax = 0x1f;
    VncViewer::cl->appData.compressLevel = 5;
    VncViewer::cl->appData.qualityLevel = 1;
    VncViewer::cl->appData.encodingsString = "tight ultra";
    VncViewer::cl->GotFrameBufferUpdate = VncViewer::update;
    VncViewer::cl->appData.useRemoteCursor = TRUE;
    VncViewer::cl->listenPort = LISTEN_PORT_OFFSET;
    VncViewer::cl->listen6Port = LISTEN_PORT_OFFSET;
    VncViewer::cl->GetPassword = VncViewer::getPasswd;
}

void VncViewer::initViewer(VncViewer::onResizeCallback onResize) {
    VncViewer::onResize = onResize;

    OH_LOG_INFO(LOG_APP, "Init vncViewer.....");
    if (!rfbInitClient(VncViewer::cl, 0, nullptr)) {
        throw std::runtime_error("error init rfb client.");
    }
    VncViewer::onResize = nullptr;
}