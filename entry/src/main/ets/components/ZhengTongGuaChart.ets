/**
 * A法：正统成卦法（天地余数合成重卦）组件
 * 用于显示先天命卦
 */
import { ZhengTongGuaResult } from '../model/HeluoModels';

@Component
export struct ZhengTongGuaChart {
  @Prop result: ZhengTongGuaResult = new ZhengTongGuaResult();

  build() {
    Column() {
      // 标题
      Text('A法·正统成卦（先天命卦）')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#8B4513')
        .margin({ bottom: 12 })

      // 计算过程展示
      Column() {
        Text('【天地数计算】')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#5C4033')
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 6 })

        Row() {
          Column() {
            Text('天数和(奇)')
              .fontSize(12)
              .fontColor('#666')
            Text(`${this.result.tianShuSum}`)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#C41E3A')
            Text(this.getTianYuDesc())
              .fontSize(11)
              .fontColor('#888')
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)

          Column() {
            Text('古法原则')
              .fontSize(11)
              .fontColor('#999')
            Text('→')
              .fontSize(24)
              .fontColor('#999')
            Text('满则减，不满取个位')
              .fontSize(10)
              .fontColor('#999')
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)

          Column() {
            Text('地数和(偶)')
              .fontSize(12)
              .fontColor('#666')
            Text(`${this.result.diShuSum}`)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1E90FF')
            Text(this.getDiYuDesc())
              .fontSize(11)
              .fontColor('#888')
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)
        }
        .width('100%')
        .padding(8)
        .backgroundColor('#FFF8DC')
        .borderRadius(8)
      }
      .width('100%')
      .margin({ bottom: 12 })

      // 性别与年干阴阳
      Row() {
        Text(`${this.result.gender}命`)
          .fontSize(14)
          .fontColor('#333')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor(this.result.gender === '男' ? '#E6F3FF' : '#FFE6F0')
          .borderRadius(4)

        Text(`年干${this.result.yearGanYinYang}`)
          .fontSize(14)
          .fontColor('#333')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor(this.result.yearGanYinYang === '阳' ? '#FFF0E6' : '#E6FFF0')
          .borderRadius(4)
          .margin({ left: 8 })

        Text(this.result.guaPosRule)
          .fontSize(11)
          .fontColor('#888')
          .margin({ left: 8 })
          .layoutWeight(1)
      }
      .width('100%')
      .margin({ bottom: 12 })

      // 重卦显示
      Column() {
        // 卦象大显示
        Row() {
          // 上卦
          Column() {
            Text('上卦')
              .fontSize(12)
              .fontColor('#666')
            Text(this.result.upperGua.symbol)
              .fontSize(40)
              .fontColor('#8B4513')
            Text(`${this.result.upperGua.name}(${this.result.upperGua.element})`)
              .fontSize(14)
              .fontColor('#333')
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)

          // 命卦
          Column() {
            Text(this.result.mingGua.unicode)
              .fontSize(64)
              .fontColor(this.getMingGuaColor())
            Text(this.result.mingGua.name)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.getMingGuaColor())
            this.buildLuckBadge()
          }
          .layoutWeight(2)
          .alignItems(HorizontalAlign.Center)

          // 下卦
          Column() {
            Text('下卦')
              .fontSize(12)
              .fontColor('#666')
            Text(this.result.lowerGua.symbol)
              .fontSize(40)
              .fontColor('#8B4513')
            Text(`${this.result.lowerGua.name}(${this.result.lowerGua.element})`)
              .fontSize(14)
              .fontColor('#333')
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)
        }
        .width('100%')
        .padding(12)
        .backgroundColor('#FFFAF0')
        .borderRadius(12)
      }
      .width('100%')
      .margin({ bottom: 12 })

      // 分析文字
      Text(this.result.analysis)
        .fontSize(13)
        .fontColor('#5C4033')
        .lineHeight(20)
        .width('100%')
        .padding(10)
        .backgroundColor('#FFF5EB')
        .borderRadius(8)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 2 })
  }

  @Builder
  buildLuckBadge() {
    Text(this.result.mingGua.luck === '吉' ? '吉' :
      (this.result.mingGua.luck === '凶' ? '凶' : '平'))
      .fontSize(12)
      .fontColor('#FFF')
      .padding({ left: 8, right: 8, top: 2, bottom: 2 })
      .backgroundColor(this.getLuckColor())
      .borderRadius(10)
      .margin({ top: 4 })
  }

  getMingGuaColor(): string {
    if (this.result.mingGua.luck === '吉') return '#C41E3A';
    if (this.result.mingGua.luck === '凶') return '#4A4A4A';
    return '#8B4513';
  }

  getLuckColor(): string {
    if (this.result.mingGua.luck === '吉') return '#C41E3A';
    if (this.result.mingGua.luck === '凶') return '#4A4A4A';
    return '#888888';
  }

  // 获取天数余描述
  getTianYuDesc(): string {
    if (this.result.tianShuSum >= 25) {
      return `${this.result.tianShuSum}-25=余${this.result.tianYu}`;
    } else {
      return `<25,取个位=${this.result.tianYu}`;
    }
  }

  // 获取地数余描述
  getDiYuDesc(): string {
    if (this.result.diShuSum >= 30) {
      return `${this.result.diShuSum}-30=余${this.result.diYu}`;
    } else {
      return `<30,取个位=${this.result.diYu}`;
    }
  }
}
