import { hilog } from '@kit.PerformanceAnalysisKit';
import testNapi from 'libn_vnc.so';

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';

  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}