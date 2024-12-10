import { VncClient } from 'ets/utils/VncClient'
import { HistorySelector } from './HistorySelector'
import { HistoryStorage } from '../utils/FileStorage'

@Entry
@Component
struct Index {
  private pageStack: NavPathStack = new NavPathStack()
  private history = new HistoryStorage('records.json')
  @State private address: string = ""
  @State private passwd: string = ""
  private controller: CustomDialogController = new CustomDialogController({
    builder: HistorySelector({
      confirmed: (choice) => {
        this.address = choice.address
        this.passwd = choice.passwd
      },
      historyStorage: this.history,
      current: this.address
    }),

    autoCancel: true,
    customStyle: true,
  });

  onPageShow(): void {
    if (this.history.records.length) {
      this.address = this.history.records[this.history.records.length-1].address
      this.passwd = this.history.records[this.history.records.length-1].passwd
    }
  }

  build() {
    Navigation(this.pageStack) {
      Column() {
        RelativeContainer() {
          Text($r('app.string.app_name'))
            .id('text')
            .fontSize(80)
            .fontWeight(FontWeight.Bolder)
            .alignRules({
              center: { anchor: '__container__', align: VerticalAlign.Center },
              middle: { anchor: '__container__', align: HorizontalAlign.Center }
            })
        }
        .height('30%')
        .width('100%')

        RelativeContainer() {
          Row() {
            Text($r('app.string.address_input'))
              .fontSize(15)
              .height("100%")

            TextInput({
              placeholder: $r('app.string.address_input_notice'),
              text: this.address
            })
              .fontSize(20)
              .height(40)
              .width('50%')
              .onChange((str) => {
                this.address = str
                this.passwd = ''
              })
              .cancelButton({})
          }
          .alignRules(
            {
              center: { anchor: '__container__', align: VerticalAlign.Center },
              middle: { anchor: '__container__', align: HorizontalAlign.Center }
            })
        }
        .margin({ top: '3%' })
        .height('10%')

        RelativeContainer() {
          Row() {
            Text($r('app.string.passwd_input'))
              .fontSize(15)
              .height("100%")
            TextInput({
              placeholder: $r('app.string.passwd_input_notice'),
              text: this.passwd
            })
              .fontSize(20)
              .height(40)
              .width('50%')
              .type(InputType.Password)
              .onChange((str) => {
                this.passwd = str
              })
              .cancelButton({})
          }
          .alignRules(
            {
              center: { anchor: '__container__', align: VerticalAlign.Center },
              middle: { anchor: '__container__', align: HorizontalAlign.Center }
            })
        }
        .margin({ top: '1%' })
        .height('10%')

        RelativeContainer() {
          Row() {
            Button() {
              Image($r('app.media.gearshape'))
                .height("100%")
            }
            .type(ButtonType.Circle)
            .height('25%')
            .backgroundColor(Color.Transparent)
            .margin({ right: '5%' })
            .onClick(() => {
            })

            Button() {
              Image($r('app.media.arrow_counterclockwise_clock'))
                .height("100%")
            }
            .type(ButtonType.Circle)
            .height('25%')
            .backgroundColor(Color.Transparent)
            .margin({ right: '10%' })
            .onClick(() => {
              this.controller.open()
            })


            Button() {
              Image($r('app.media.chevron_right_circle'))
                .height('100%')
            }
            .type(ButtonType.Circle)
            .backgroundColor(Color.Orange)
            .height('30%')
            .width('10%')
            .onClick(
              () => {
                let vncClient = new VncClient()
                let address = this.address.split(':')
                let passwd = this.passwd
                let ip = address[0]
                let port = Number.parseInt(address[1])
                this.history.append({ address: this.address, passwd: this.passwd })
                if (vncClient.init(ip, port, passwd)) {
                  console.info(`path to the viewer page.`)
                  this.pageStack.pushPath({
                    name: "VncViewerPage", param: vncClient
                  })
                } else {
                  AlertDialog.show({
                    title: $r('app.string.connect_fail_title'),
                    message: $r('app.string.connect_fail_message'),
                    alignment: DialogAlignment.Center,
                  })
                }
              })
          }
          .alignRules({
            center: { anchor: '__container__', align: VerticalAlign.Center },
            middle: { anchor: '__container__', align: HorizontalAlign.Center }
          })
        }
        .height('30%')
        .width('100%')
      }
      .id('Column')
    }
    .hideTitleBar(true)
    .size({ width: '100%', height: '100%' })
    .mode(NavigationMode.Stack)
  }
}