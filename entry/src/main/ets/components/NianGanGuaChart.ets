/**
 * B法：年干起卦 + 动爻法组件
 * 用于显示后天命盘
 */
import { NianGanGuaResult } from '../model/HeluoModels';

@Component
export struct NianGanGuaChart {
  @Prop result: NianGanGuaResult = new NianGanGuaResult();

  build() {
    Column() {
      // 标题
      Text('B法·年干起卦（后天命盘）')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1E4D8C')
        .margin({ bottom: 12 })

      // 本命卦（体卦）
      Column() {
        Text('【本命卦（体）】')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#2C5282')
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 6 })

        Row() {
          Text(this.result.benMingGua.symbol)
            .fontSize(48)
            .fontColor('#1E4D8C')

          Column() {
            Text(this.result.benMingGua.name)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1E4D8C')
            Text(`属${this.result.benMingGua.element}`)
              .fontSize(14)
              .fontColor('#666')
          }
          .alignItems(HorizontalAlign.Start)
          .margin({ left: 12 })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .padding(12)
        .backgroundColor('#F0F7FF')
        .borderRadius(8)
      }
      .width('100%')
      .margin({ bottom: 12 })

      // 动爻计算
      Column() {
        Text('【动爻推算】')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#2C5282')
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 6 })

        Row() {
          Column() {
            Text('四柱总数')
              .fontSize(12)
              .fontColor('#666')
            Text(`${this.result.totalSum}`)
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333')
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)

          Column() {
            Text('mod 6')
              .fontSize(14)
              .fontColor('#999')
            Text(this.getDongYaoCalcDesc())
              .fontSize(11)
              .fontColor('#888')
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)

          Column() {
            Text('动爻位')
              .fontSize(12)
              .fontColor('#666')
            Text(this.getDongYaoName())
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#C41E3A')
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)
        }
        .width('100%')
        .padding(10)
        .backgroundColor('#FFF5F5')
        .borderRadius(8)

        // 余数0=上爻的提示
        Text('古法：余0=上爻动，非“无动爻”或“初爻”')
          .fontSize(10)
          .fontColor('#999')
          .margin({ top: 4 })
          .alignSelf(ItemAlign.End)
      }
      .width('100%')
      .margin({ bottom: 12 })

      // 变卦（用卦）
      Column() {
        Text('【变卦（用）】')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#2C5282')
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 6 })

        Row() {
          Text(this.result.bianGua.unicode)
            .fontSize(56)
            .fontColor(this.getBianGuaColor())

          Column() {
            Text(this.result.bianGua.name)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.getBianGuaColor())

            Row() {
              Text(`上${this.result.bianGua.upperGua}`)
                .fontSize(12)
                .fontColor('#666')
              Text(' · ')
                .fontSize(12)
                .fontColor('#999')
              Text(`下${this.result.bianGua.lowerGua}`)
                .fontSize(12)
                .fontColor('#666')
            }

            this.buildBianLuckBadge()
          }
          .alignItems(HorizontalAlign.Start)
          .margin({ left: 12 })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .padding(12)
        .backgroundColor('#FFFAF5')
        .borderRadius(8)

        if (this.result.bianGua.meaning) {
          Text(this.result.bianGua.meaning)
            .fontSize(12)
            .fontColor('#666')
            .margin({ top: 8 })
        }
      }
      .width('100%')
      .margin({ bottom: 12 })

      // 元堂定位
      Column() {
        Text('【元堂定位】')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#2C5282')
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 6 })

        Row() {
          // 六爻图示
          this.buildYaoChart()

          Column() {
            Text(`元堂在${this.result.yuanTang}爻`)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#8B4513')
            Text(this.result.yuanTangDesc)
              .fontSize(14)
              .fontColor('#666')
              .margin({ top: 4 })
            Text(this.getYuanTangMeaning())
              .fontSize(12)
              .fontColor('#888')
              .margin({ top: 4 })
          }
          .alignItems(HorizontalAlign.Start)
          .margin({ left: 16 })
          .layoutWeight(1)
        }
        .width('100%')
        .padding(12)
        .backgroundColor('#FFF8F0')
        .borderRadius(8)
      }
      .width('100%')
      .margin({ bottom: 12 })

      // 分析文字
      Text(this.result.analysis)
        .fontSize(13)
        .fontColor('#2C5282')
        .lineHeight(20)
        .width('100%')
        .padding(10)
        .backgroundColor('#F5F8FF')
        .borderRadius(8)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 2 })
  }

  @Builder
  buildYaoChart() {
    Column() {
      ForEach([6, 5, 4, 3, 2, 1], (yaoNum: number) => {
        Row() {
          Text(yaoNum === this.result.yuanTang ? '●' : '○')
            .fontSize(14)
            .fontColor(yaoNum === this.result.yuanTang ? '#C41E3A' : '#CCC')
          Text(yaoNum === this.result.dongYao ? ' 动' : '')
            .fontSize(10)
            .fontColor('#C41E3A')
        }
        .height(16)
      })
    }
    .padding(8)
    .backgroundColor('#FFF')
    .borderRadius(4)
    .border({ width: 1, color: '#E0E0E0' })
  }

  @Builder
  buildBianLuckBadge() {
    Text(this.result.bianGua.luck === '吉' ? '吉' :
      (this.result.bianGua.luck === '凶' ? '凶' : '平'))
      .fontSize(12)
      .fontColor('#FFF')
      .padding({ left: 8, right: 8, top: 2, bottom: 2 })
      .backgroundColor(this.getBianLuckColor())
      .borderRadius(10)
      .margin({ top: 4 })
  }

  getDongYaoName(): string {
    const names = ['初爻', '二爻', '三爻', '四爻', '五爻', '上爻'];
    return names[this.result.dongYao - 1] || '';
  }

  // 获取动爻计算描述
  getDongYaoCalcDesc(): string {
    const actualRemainder = this.result.totalSum % 6;
    if (actualRemainder === 0) {
      return `余0→上爻`;
    } else {
      return `余${actualRemainder}→${this.getDongYaoName()}`;
    }
  }

  getYuanTangMeaning(): string {
    const meanings = [
      '主基层、根基、白手起家',
      '主家宅、住所、安居乐业',
      '主门户、交际、出入平安',
      '主官位、事业、仕途发展',
      '主君位、权势、中年发达',
      '主宗庙、祖德、晚年安康'
    ];
    return meanings[this.result.yuanTang - 1] || '';
  }

  getBianGuaColor(): string {
    if (this.result.bianGua.luck === '吉') return '#8B4513';
    if (this.result.bianGua.luck === '凶') return '#4A4A4A';
    return '#666';
  }

  getBianLuckColor(): string {
    if (this.result.bianGua.luck === '吉') return '#C41E3A';
    if (this.result.bianGua.luck === '凶') return '#4A4A4A';
    return '#888888';
  }
}
