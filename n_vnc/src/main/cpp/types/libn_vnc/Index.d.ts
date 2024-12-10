export const update: (onResize: (x: Uint8Array) => void,
  onUpdate: (x: Uint8Array) => void) => number;

export const vncInit: (address: string, port: number, passwd: string) => Uint8Array | undefined;

export const vncClose: () => number;

export const mouseEvent: (x: number, y: number, buttonMask: number) => void;

export const keyEvent: (key: number, down: boolean) => void;