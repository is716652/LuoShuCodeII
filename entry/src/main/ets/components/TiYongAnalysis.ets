/**
 * 体用综合分析组件
 * 将A法（体）和B法（用）结果进行综合判断
 */
import { TiYongAnalysisResult, ZhengTongGuaResult, NianGanGuaResult } from '../model/HeluoModels';

@Component
export struct TiYongAnalysis {
  @Prop tiYong: TiYongAnalysisResult = new TiYongAnalysisResult();
  @Prop zhengTong: ZhengTongGuaResult = new ZhengTongGuaResult();
  @Prop nianGan: NianGanGuaResult = new NianGanGuaResult();

  build() {
    Column() {
      // 标题
      Text('体用合参·综合断事')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#4A0080')
        .margin({ bottom: 12 })

      // 体用对照表
      Row() {
        // 体（先天命卦）
        Column() {
          Text('体')
            .fontSize(12)
            .fontColor('#666')
          Text('先天命卦')
            .fontSize(11)
            .fontColor('#999')
            .margin({ top: 2 })

          Text(this.zhengTong.mingGua.unicode)
            .fontSize(36)
            .fontColor('#8B4513')
            .margin({ top: 4 })

          Text(this.zhengTong.mingGua.name)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333')

          this.buildLuckBadge(this.tiYong.tiLuck)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
        .padding(12)
        .backgroundColor('#FFF8F0')
        .borderRadius(12)

        // 加号
        Column() {
          Text('+')
            .fontSize(24)
            .fontColor('#999')
        }
        .padding({ left: 8, right: 8 })

        // 用（后天变卦）
        Column() {
          Text('用')
            .fontSize(12)
            .fontColor('#666')
          Text('后天变卦')
            .fontSize(11)
            .fontColor('#999')
            .margin({ top: 2 })

          Text(this.nianGan.bianGua.unicode)
            .fontSize(36)
            .fontColor('#1E4D8C')
            .margin({ top: 4 })

          Text(this.nianGan.bianGua.name)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333')

          this.buildLuckBadge(this.tiYong.yongLuck)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
        .padding(12)
        .backgroundColor('#F0F7FF')
        .borderRadius(12)

        // 等号
        Column() {
          Text('=')
            .fontSize(24)
            .fontColor('#999')
        }
        .padding({ left: 8, right: 8 })

        // 综合结果
        Column() {
          Text('综合')
            .fontSize(12)
            .fontColor('#666')

          Text(this.tiYong.combinedResult)
            .fontSize(32)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getCombinedColor())
            .margin({ top: 8 })

          Text(this.getCombinedEmoji())
            .fontSize(24)
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
        .padding(12)
        .backgroundColor(this.getCombinedBgColor())
        .borderRadius(12)
      }
      .width('100%')
      .margin({ bottom: 16 })

      // 综合描述
      Column() {
        Text('【综合判断】')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#4A0080')
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 8 })

        Text(this.tiYong.combinedDesc)
          .fontSize(15)
          .fontColor('#333')
          .lineHeight(22)
          .width('100%')
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#FAF5FF')
      .borderRadius(8)
      .margin({ bottom: 12 })

      // 建议
      Column() {
        Text('【行动建议】')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#4A0080')
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 8 })

        Text(this.tiYong.advice)
          .fontSize(14)
          .fontColor('#666')
          .lineHeight(20)
          .width('100%')
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#F5F0FF')
      .borderRadius(8)
      .margin({ bottom: 12 })

      // 体用关系说明
      Column() {
        Text('【体用关系】')
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor('#888')
          .alignSelf(ItemAlign.Start)
          .margin({ bottom: 6 })

        Text('体卦管"能不能成"——先天格局高低、根基深浅')
          .fontSize(12)
          .fontColor('#999')
          .margin({ bottom: 4 })

        Text('用卦管"怎么成、何时成"——实现路径、应期时机')
          .fontSize(12)
          .fontColor('#999')
      }
      .width('100%')
      .padding(10)
      .backgroundColor('#F8F8F8')
      .borderRadius(8)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 2 })
  }

  @Builder
  buildLuckBadge(luck: string) {
    Text(luck === '吉' ? '吉' : (luck === '凶' ? '凶' : '平'))
      .fontSize(11)
      .fontColor('#FFF')
      .padding({ left: 6, right: 6, top: 2, bottom: 2 })
      .backgroundColor(this.getLuckColor(luck))
      .borderRadius(8)
      .margin({ top: 4 })
  }

  getLuckColor(luck: string): string {
    if (luck === '吉') return '#C41E3A';
    if (luck === '凶') return '#4A4A4A';
    return '#888888';
  }

  getCombinedColor(): string {
    if (this.tiYong.combinedResult === '大吉') return '#C41E3A';
    if (this.tiYong.combinedResult === '大凶') return '#4A4A4A';
    return '#666666';
  }

  getCombinedBgColor(): string {
    if (this.tiYong.combinedResult === '大吉') return '#FFF0F0';
    if (this.tiYong.combinedResult === '大凶') return '#F0F0F0';
    return '#FFFFF0';
  }

  getCombinedEmoji(): string {
    if (this.tiYong.combinedResult === '大吉') return '🎉';
    if (this.tiYong.combinedResult === '大凶') return '⚠️';
    return '⚖️';
  }
}
