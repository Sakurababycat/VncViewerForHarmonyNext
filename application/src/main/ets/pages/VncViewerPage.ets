// VncViewerPage.ets
import { display } from '@kit.ArkUI'
import { VncClient } from 'ets/utils/VncClient'
import { ArkTSUtils } from '@kit.ArkTS'
import { actionMapStr, buttonMapStr, button2rfb, keyTypeMapStr, ScrollButtonMask } from '../utils/KeyMap'

@Builder
export function VncViewerPageBuilder() {
  ViewPage()
}

@Entry
@Component
struct ViewPage {
  private canvasSize: Size = display.getDefaultDisplaySync()
  private settings: RenderingContextSettings = new RenderingContextSettings(false)
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  private checkUpdateTimer: number = -1;
  private checkVncUpdateFlag: boolean = false;
  private checkVncUpdateLock: ArkTSUtils.locks.AsyncLock = new ArkTSUtils.locks.AsyncLock()
  private pageStack: NavPathStack = new NavPathStack()
  private vncClient?: VncClient
  private leftShift: number = -1
  private upShift: number = -1
  private mouseX: number = -1
  private mouseY: number = -1
  private windowScale: number = 1
  private mouseStat: number = 0
  private scroller = new Scroller()

  onPageHide(): void {
    this.vncClient?.close()
    this.vncClient = undefined
    clearInterval(this.checkUpdateTimer)
    this.checkVncUpdateFlag = false
  }

  onPageShow(): void {
  }

  checkVncUpdate() {
    // console.info(`check vnc update...`)
    let status = this.vncClient?.checkUpdate((x) => {
      let pixelMap = this.vncClient?.getUpdatePixelMap(x)
      if (pixelMap) {
        if ((x.width * this.windowScale != this.canvasSize.width &&
          x.height * this.windowScale != this.canvasSize.height) ||
          (this.leftShift == -1 && this.upShift == -1)) {
          this.windowScale = Math.min(this.canvasSize.width / x.width, this.canvasSize.height / x.height)
          console.info(`window_scale: ${this.windowScale}`)
          console.info(`${this.canvasSize.width}, ${this.canvasSize.height}`)
          this.leftShift = (this.canvasSize.width - x.width * this.windowScale) / 2
          this.upShift = (this.canvasSize.height - x.height * this.windowScale) / 2
          this.context.scale(this.windowScale, this.windowScale)
        }
        this.context.drawImage(pixelMap, px2vp(x.x + this.leftShift), px2vp(x.y + this.upShift))
      }
    })
    if (!status) {
      console.info(`connection error...`)
      this.onConnectionError()
    }
  }

  startCount() {
    this.checkVncUpdateFlag = true

    this.checkUpdateTimer = setInterval(() => {
      if (this.checkVncUpdateFlag) {
        this.checkVncUpdateLock.lockAsync(() => {
          this.checkVncUpdateFlag = false
          this.checkVncUpdate()
          this.checkVncUpdateFlag = true
        })
      }
    }, 1000 / 60)
  }

  build() {
    NavDestination() {
      Stack() {
        Canvas(this.context)
          .onReady(() => {
            this.startCount()
          })
          .height("100%")
          .width("100%")
        RelativeContainer() {
          Column() {
            Button() {
              Image($r('app.media.arrow_left'))
                .height("100%")
            }
            .type(ButtonType.Capsule)
            .backgroundColor('#cfffafaf')
            .width(40)
            .height(30)
            .alignRules({
              top: { anchor: '__container__', align: VerticalAlign.Top },
              left: { anchor: '__container__', align: HorizontalAlign.Start }
            })
            .margin({ left: 20, top: 20 })
            .onClick((event) => {
              console.info('returning to the first page.')
              this.pageStack.pop()
            })
            .onMouse((event) => event.stopPropagation())

            Scroll(this.scroller) {
              Text()
                .height(4000)
                .width('100%')
            }
            .scrollBar(BarState.Off)
            .onWillScroll((xOffset: number, yOffset: number, scrollState: ScrollState, scrollSource: ScrollSource) => {
              if (scrollSource == ScrollSource.OTHER_USER_INPUT) {
                // console.info(`${xOffset}, ${yOffset}, ${scrollState.toString()}, ${scrollSource.toString()}`)
                this.vncClient?.onMouseEvent(this.mouseX, this.mouseY,
                  yOffset > 0 ? ScrollButtonMask.yForward : ScrollButtonMask.yBack)
                this.scroller.scrollTo({ xOffset: 100, yOffset: 2000 })
              }
            })
            .onScrollEdge(() => {
              this.scroller.scrollTo({ xOffset: 100, yOffset: 2000 })
            })
            .height('100%')
            .width('100%')
          }
          .alignItems(HorizontalAlign.Start)
        }
      }
      .height('100%')
    }
    .onShown(() => {
      this.onPageShow()
    }
    )
    .onHidden(() => {
      this.onPageHide()
    }
    )
    .hideTitleBar(true)
    .onReady((context) => {
      this.pageStack = context.pathStack
      this.vncClient = this.pageStack.getParamByName("VncViewerPage")[0] as VncClient
    })
    .backgroundColor(Color.Black)
    .onMouse((event) => {
      event.stopPropagation() // prevent mistaking clicking on 'back' button
      let x = vp2px(event.displayX) / this.windowScale
      let y = vp2px(event.displayY) / this.windowScale

      if (event.displayX != 0 || event.displayY != 0 || event.action == MouseAction.Move) {
        this.mouseX = x - this.leftShift
        this.mouseY = y - this.upShift
      }

      if (event.button != MouseButton.Left) { // left click was handled by on Touch
        if (event.action == MouseAction.Press) {
          this.mouseStat |= button2rfb.get(event.button) ?? 0
        } else if (event.action == MouseAction.Release) {
          this.mouseStat &= ~(button2rfb.get(event.button) ?? 0)
        }

        this.vncClient?.onMouseEvent(this.mouseX, this.mouseY, this.mouseStat)
        // console.info(`Mouse button:${buttonMapStr.get(event.button)}, action: ${actionMapStr.get(event.action)}, pos: (${this.mouseX},${this.mouseY}), stat: ${this.mouseStat}`)
      }
    })
    .onKeyEvent((event) => {

      // console.info(`Key input: ${event.keyText}, ${event.keyCode}, type: ${keyTypeMapStr.get(event.type)}`)
      this.vncClient?.onKeyEvent(event.keyCode, event.type == KeyType.Down)
    })
    .onTouch((event) => {
      let equivalentMouseBtn = MouseButton.None

      let x = vp2px(event.touches[0].displayX) / this.windowScale
      let y = vp2px(event.touches[0].displayY) / this.windowScale

      if (event.touches[0].displayX != 0 || event.touches[0].displayY != 0 || event.touches[0].type == TouchType.Move) {
        this.mouseX = x - this.leftShift
        this.mouseY = y - this.upShift
      }

      switch (event.touches.length) {
        case 1:
          equivalentMouseBtn = MouseButton.Left
          break
        case 2:
          equivalentMouseBtn = MouseButton.Right
          break
        case 3:
          equivalentMouseBtn = MouseButton.Middle
          break
        default:
          equivalentMouseBtn = MouseButton.None
          break
      }

      switch (event.type) {
        case TouchType.Down:
          this.mouseStat |= button2rfb.get(equivalentMouseBtn) ?? 0
          break
        case TouchType.Up:
          this.mouseStat &= ~(button2rfb.get(equivalentMouseBtn) ?? 0)
          break
      }

      this.vncClient?.onMouseEvent(this.mouseX, this.mouseY, this.mouseStat)

      // console.info(`Touch: ${buttonMapStr.get(equivalentMouseBtn)}, type: ${event.type}, pos: (${this.mouseX},${this.mouseY}), stat: ${this.mouseStat}`)
    })
  }

  onConnectionError() {
    let retry = 3
    while (retry--) {
      if (this.vncClient?.connect()) {
        console.info('reconnect success...')
        return
      }
    }
    this.onPageHide()
    AlertDialog.show({
      title: $r('app.string.connect_fail_title'),
      message: $r('app.string.connect_fail_message'),
      alignment: DialogAlignment.Center,
      confirm: {
        value: $r('app.string.connect_fail_btn_msg'),
        action: () => {
          this.pageStack.pop()
        }
      }
    })
  }
}