import { update, vncInit, vncClose, UpdateInfo, mouseEvent, keyEvent } from 'n_vnc'
import { image } from '@kit.ImageKit'
import socket from '@ohos.net.socket';
import { router } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

export class VncClient {
  private pixelArray: Uint8Array = new Uint8Array([])
  private sockMonitor?: socket.TCPSocket
  handleUnexpectedClose?: () => void

  init(address: string, port: number, passwd: string): boolean {
    let a = vncInit(address, port, passwd)
    if (a) {
      this.pixelArray = a
      this.sockMonitor = socket.constructTCPSocketInstance();
      this.sockMonitor.connect({
        address: {
          address: address,
          port: port
        },
        timeout: 1
      }); // try to link to prevent SIGSEGV by napi: if connection canceled by remote, any accession to socketfd will case a crash
      this.sockMonitor.on('close', () => {
        this.unexpectClose()
      })
      this.sockMonitor.on('error', () => {
        this.unexpectClose()
      })
      return true
    }
    return false
  }

  unexpectClose() {
    this.sockMonitor = undefined
    if (this.handleUnexpectedClose) {
      this.handleUnexpectedClose()
    }
  }

  close() {
    if (this.checkConnection()) {
      vncClose();
    }
  }

  checkConnection(): boolean {
    return this.sockMonitor != undefined
  }

  getUpdatePixelMap(x: UpdateInfo) {
    // console.info(`updateInfo: ${x}`)

    const bitsPerPixel = 2
    let freshAreaArray = new Uint8Array(x.h * x.w * bitsPerPixel)
    for (let i = 0; i < x.h; i++) {
      const srcStart = ((x.y + i) * x.width + x.x) * bitsPerPixel
      const srcEnd = srcStart + x.w * bitsPerPixel;
      const desStart = (i * x.w) * bitsPerPixel

      freshAreaArray.set(this.pixelArray.subarray(srcStart, srcEnd), desStart)
    }

    let opts: image.InitializationOptions = {
      alphaType: image.AlphaType.OPAQUE,
      size: { height: x.h, width: x.w },
      srcPixelFormat: image.PixelMapFormat.RGB_565,
      scaleMode: image.ScaleMode.CENTER_CROP,
      pixelFormat: image.PixelMapFormat.RGB_565,
      editable: false
    }

    let pixelMap = image.createPixelMapSync(freshAreaArray.buffer, opts)
    return pixelMap
  }


  checkUpdate(onUpdate: (x: UpdateInfo) => void) {
    // console.info(`check vnc update...`)
    if (this.checkConnection()) {
      update((x: Uint8Array) => {
        this.pixelArray = x
      }, onUpdate)
    }
  }

  onMouseEvent(x: number, y: number, buttonMask: number) {
    if (this.checkConnection()) {
      mouseEvent(x, y, buttonMask)
    }
  }

  onKeyEvent(key: number, down: boolean) {
    if (this.checkConnection()) {
      keyEvent(key, down)
    }
  }
}