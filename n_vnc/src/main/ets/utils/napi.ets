import native from 'libn_vnc.so'

export class UpdateInfo {
  static arrLen = 6;
  width: number = 0
  height: number = 0
  x: number = 0
  y: number = 0
  w: number = 0
  h: number = 0

  constructor(arr: Uint32Array | null | undefined) {
    if (arr !== null && arr !== undefined && arr.length === UpdateInfo.arrLen) {
      this.width = arr[0]
      this.height = arr[1]
      this.x = arr[2]
      this.y = arr[3]
      this.w = arr[4]
      this.h = arr[5]
    }
  }

  toString() {
    return `${this.width}, ${this.height}, ${this.x}, ${this.y}, ${this.w}, ${this.h}.`
  }
}

export function update(onResize: (x: Uint8Array) => void,
  onUpdate: (x: UpdateInfo) => void): number {
  let ret = native.update(onResize, (x: Uint8Array) => {
    onUpdate(new UpdateInfo(new Uint32Array(x.buffer)))
  })
  // console.info(`${arr}`)
  return ret
}

export function vncInit(address: string, port: number, passwd: string): Uint8Array {
  return native.vncInit(address, port, passwd)
}

export function vncClose(): number {
  return native.vncClose();
}

export function mouseEvent(x: number, y: number, buttonMask: number) {
  native.mouseEvent(x, y, buttonMask)
}

export function keyEvent(key: number, down: boolean) {
  native.keyEvent(key, down)
}