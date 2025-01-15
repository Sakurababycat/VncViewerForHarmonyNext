import { update, vncInit, vncClose, UpdateInfo, mouseEvent, keyEvent } from 'n_vnc'
import { image } from '@kit.ImageKit'

export class VncClient {
  private pixelArray: Uint8Array = new Uint8Array([])
  private address: string
  private port: number
  private passwd: string

  constructor(address: string, port: number, passwd: string) {
    this.address = address
    this.port = port
    this.passwd = passwd
  }

  close() {
    vncClose();
  }

  connect(): boolean {
    let a = vncInit(this.address, this.port, this.passwd)
    if (a) {
      this.pixelArray = a
      return true
    }
    return false
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
    let ret = update((x: Uint8Array) => {
      this.pixelArray = x
    }, onUpdate)
    if (ret < 0) {
      return false
    } else {
      return true
    }
  }

  onMouseEvent(x: number, y: number, buttonMask: number) {
    mouseEvent(x, y, buttonMask)
  }

  onKeyEvent(key: number, down: boolean) {
    keyEvent(key, down)
  }
}