import { ConnectionRecord, HistoryStorage } from "../utils/FileStorage";

@CustomDialog
export struct HistorySelector {
  private controller: CustomDialogController;
  confirmed: (choice: ConnectionRecord) => void = (_) => {
  }
  private historyStorage?: HistoryStorage;
  private current: string = ""
  @State private checked: number = -1
  @State private recList: ConnectionRecord[] = []

  aboutToAppear(): void {
    if (this.historyStorage) {
      this.recList = this.historyStorage.records.slice().reverse()
    }
  }

  build() {
    Stack() {
      Column() {
        Text($r('app.string.history_selector_title'))
          .fontSize(20)
          .margin({ top: 15 })
        Text($r('app.string.history_selector_notice'))
          .fontSize(16)
          .margin({ top: 3 })
        List({ space: 10 }) {
          ForEach(this.recList, (item: ConnectionRecord, index) => {
            ListItem() {
              Column() {
                Row() {
                  Radio({ value: `${index}`, group: 'radioGroup' })
                    .onChange((isChecked: boolean) => {
                      if (isChecked) {
                        this.checked = index
                      }
                    })
                    .checked(index == this.checked || (item.address == this.current) && this.checked == -1)
                    .margin({ right: '5%' })
                    .width("5%")
                  Text(item.address)
                    .height(20)
                    .width('70%')
                  Button() {
                    Image($r('app.media.trash'))
                      .height("100%")
                  }
                  .type(ButtonType.Circle)
                  .height(20)
                  .width('15%')
                  .margin({ left: '5%' })
                  .backgroundColor(Color.Transparent)
                  .onClick(() => {
                    this.historyStorage?.remove(this.historyStorage?.records.length - 1 - index)
                    this.checked = -1
                    this.aboutToAppear()
                  })
                }
              }
              .onClick(() => {
                this.checked = index
              })
              .alignItems(HorizontalAlign.Start)
            }
          })
        }
        .divider({
          strokeWidth: '2px',
          color: "#bebbc1",
          startMargin: 10,
          endMargin: 10
        })
        .width('100%')
        .height(200)
        .padding(10)

        Text()
          .size({ width: "100%", height: "2px" })
          .backgroundColor("#bebbc1")
        Row() {
          Text($r('app.string.choice_cancle'))
            .height("100%")
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
            .fontSize(18)
            .fontColor("#317ef5")
            .onClick(() => {
              this.controller.close();
            })
          Text()
            .size({ width: "2px", height: "100%" })
            .backgroundColor("#bebbc1")
          Text($r('app.string.choice_ok'))
            .textAlign(TextAlign.Center)
            .fontSize(18)
            .fontColor("#317ef5")
            .height("100%")
            .layoutWeight(1)
            .onClick(() => {
              if (this.historyStorage && this.checked != -1) {
                this.confirmed(this.historyStorage?.records[this.historyStorage?.records.length - 1 - this.checked])
              }
              this.controller.close();
            })
        }
        .height(45)
        .width('100%')
      }
      .backgroundColor("#e6ffffff")
      .borderRadius(20)
    }
    .padding({ left: "5%", right: "55%" })
    .width("100%")
  }
}
