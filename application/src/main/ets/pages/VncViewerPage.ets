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
  private context: DrawingRenderingContext = new DrawingRenderingContext()
  private checkUpdateTimer: number = -1;
  private freshCanvasTimer: number = -1;
  private checkVncUpdateFlag: boolean = false;
  private updateCanvasFlag: boolean = false;
  private checkVncUpdateLock: ArkTSUtils.locks.AsyncLock = new ArkTSUtils.locks.AsyncLock()
  private updateCanvasLock: ArkTSUtils.locks.AsyncLock = new ArkTSUtils.locks.AsyncLock()
  private canvasSize: Size = display.getDefaultDisplaySync()
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
    clearInterval(this.checkUpdateTimer)
    clearInterval(this.freshCanvasTimer)
    this.checkVncUpdateFlag = false
    this.updateCanvasFlag = false
  }

  onPageShow(): void {
  }

  checkVncUpdate() {
    // console.info(`check vnc update...`)
    this.vncClient?.checkUpdate((x) => {
      let pixelMap = this.vncClient?.getUpdatePixelMap(x)

      if ((x.width != this.canvasSize.width && x.height != this.canvasSize.height) ||
        (this.leftShift == -1 && this.upShift == -1)) {
        console.info(`before scale: ${this.canvasSize.width} ${this.canvasSize.height}`)
        this.windowScale = Math.min(this.canvasSize.width / x.width, this.canvasSize.height / x.height)
        this.context.canvas.scale(this.windowScale, this.windowScale)
        this.canvasSize.width /= this.windowScale
        this.canvasSize.height /= this.windowScale
        // await pixelMap.scale(scale, scale)
        console.info(`after scale: ${this.canvasSize.width} ${this.canvasSize.height}`)
        this.leftShift = (this.canvasSize.width - x.width) / 2
        this.upShift = (this.canvasSize.height - x.height) / 2
      }

      this.updateCanvasLock.lockAsync(() => {
        this.context.canvas.drawImage(pixelMap, x.x + this.leftShift, x.y + this.upShift)
      })
    })
  }

  startCount() {
    this.checkVncUpdateFlag = true
    this.updateCanvasFlag = true

    this.checkUpdateTimer = setInterval(() => {
      if (this.checkVncUpdateFlag) {
        this.checkVncUpdateLock.lockAsync(() => {
          this.checkVncUpdateFlag = false
        })
        this.checkVncUpdate()
        this.checkVncUpdateLock.lockAsync(() => {
          this.checkVncUpdateFlag = true
        })
      }
    }, 1000 / 60)

    this.freshCanvasTimer = setInterval(() => {
      if (this.updateCanvasFlag) {
        this.updateCanvasLock.lockAsync(() => {
          this.updateCanvasFlag = false
          this.context.invalidate()
          this.updateCanvasFlag = true
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
      this.vncClient.handleUnexpectedClose = () => {
        AlertDialog.show({
          title: $r('app.string.connect_fail_title'),
          message: $r('app.string.connect_fail_message'),
          alignment: DialogAlignment.Center,
          confirm: {
            value: $r('app.string.choice_ok'),
            action: () => {
              this.pageStack.pop()
            }
          }
        })
      }
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
      if (event.action == MouseAction.Press) {
        this.mouseStat |= button2rfb.get(event.button) ?? 0
      } else if (event.action == MouseAction.Release) {
        this.mouseStat &= ~(button2rfb.get(event.button) ?? 0)
      }

      this.vncClient?.onMouseEvent(this.mouseX, this.mouseY, this.mouseStat)


      // console.info(`Mouse button:${buttonMapStr.get(event.button)}, action: ${actionMapStr.get(event.action)}, pos: (${x},${y}), stat: ${this.mouseStat}`)
    })
    .onKeyEvent((event) => {

      // console.info(`Key input: ${event.keyText}, ${event.keyCode}, type: ${keyTypeMapStr.get(event.type)}`)
      this.vncClient?.onKeyEvent(event.keyCode, event.type == KeyType.Down)
    })
    .onTouch((event) => {
      let equivalentMouseBtn = MouseButton.None

      let x = vp2px(event.touches[0].displayX) / this.windowScale - this.leftShift
      let y = vp2px(event.touches[0].displayY) / this.windowScale - this.upShift

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

      this.vncClient?.onMouseEvent(x, y, this.mouseStat)

      // console.info(`Mouse button:${buttonMapStr.get(equivalentMouseBtn)}, type: ${event.type}, pos: (${x},${y}), stat: ${this.mouseStat}`)
    })
  }
}