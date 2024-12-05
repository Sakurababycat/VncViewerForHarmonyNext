import { common } from '@kit.AbilityKit';
import { buffer } from '@kit.ArkTS';
import { fileIo as fs, ReadOptions } from '@kit.CoreFileKit';


export interface ConnectionRecord {
  address: string
  passwd: string
}

export class HistoryStorage {
  static context = getContext() as common.UIAbilityContext
  static filesDir = HistoryStorage.context.filesDir
  private fileName: string
  private path: string
  private bakPath: string
  records: ConnectionRecord[] = []

  constructor(name: string) {
    this.fileName = name
    this.path = HistoryStorage.filesDir + `/${this.fileName}`
    this.bakPath = this.path + '.bak'
    if (!fs.accessSync(this.path)) {
      if (fs.accessSync(this.bakPath)) {
        fs.copyFileSync(this.bakPath, this.path)
      }
    }
    let file = fs.openSync(this.path, fs.OpenMode.READ_ONLY | fs.OpenMode.CREATE);
    let arrayBuffer = new ArrayBuffer(1024);
    let readOptions: ReadOptions = {
      offset: 0,
      length: arrayBuffer.byteLength
    };

    let readLen = fs.readSync(file.fd, arrayBuffer, readOptions);
    let buf = buffer.from(arrayBuffer, 0, readLen);
    try {
      this.records = JSON.parse(buf.toString());
      // for (let c of this.records) {
      //   console.info(`record: ${c.address + ', ' + c.passwd}`)
      // }
    } catch (e) {
      console.info(e)
    }
    fs.closeSync(file);
  }

  save() {
    fs.moveFileSync(this.path, this.bakPath)
    let file = fs.openSync(this.path, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);

    let content = JSON.stringify(this.records)
    fs.writeSync(file.fd, content)
    fs.closeSync(file);
  }

  append(record: ConnectionRecord) {
    let index = this.records.findIndex((rec) => rec.address == record.address)
    if (index != -1) {
      this.records.splice(index, 1)
    }
    this.records.push(record)
    this.save()
  }

  remove(index: number) {
    try {
      this.records.splice(index, 1)
    } catch (e) {
      console.info(e)
    }
    this.save()
  }
}