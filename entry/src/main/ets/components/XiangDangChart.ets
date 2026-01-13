/**
 * 八卦相荡法组件
 * 用于显示流年推演（动态命盘）
 */
import { XiangDangResult, LiuNianGuaInfo } from '../model/HeluoModels';

@Component
export struct XiangDangChart {
  @Prop result: XiangDangResult = new XiangDangResult();
  @State selectedYear: number = 0;

  aboutToAppear() {
    if (this.result.currentYear > 0) {
      this.selectedYear = this.result.currentYear;
    }
  }

  build() {
    Column() {
      // 标题
      Text('八卦相荡·流年推演')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1E4D8C')
        .margin({ bottom: 12 })

      // 命格与本命卦
      Row() {
        Column() {
          Text('命格')
            .fontSize(12)
            .fontColor('#666')
          Text(this.result.mingGeType)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#8B4513')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Column() {
          Text('本命卦（体）')
            .fontSize(12)
            .fontColor('#666')
          Text(this.result.benMingGua.name)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1E4D8C')
          Text(this.result.benMingGua.unicode)
            .fontSize(32)
            .fontColor('#1E4D8C')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Column() {
          Text('本命五行')
            .fontSize(12)
            .fontColor('#666')
          Text(this.result.benMingElement)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getElementColor(this.result.benMingElement))
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#F5F8FF')
      .borderRadius(8)
      .margin({ bottom: 12 })

      // 流年卦列表（滚动展示）
      Text('【流年推演】')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#2C5282')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 8 })

      Scroll() {
        Row({ space: 8 }) {
          ForEach(this.result.liuNianList, (item: LiuNianGuaInfo) => {
            this.buildYearCard(item)
          })
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
      .height(120)
      .margin({ bottom: 12 })

      // 当前选中年份详情
      if (this.getSelectedLiuNian()) {
        this.buildYearDetail(this.getSelectedLiuNian()!)
      }

      // 体用关系分析
      if (this.result.tiYongRelation.relation) {
        Column() {
          Text('【体用生克】')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor('#2C5282')
            .alignSelf(ItemAlign.Start)
            .margin({ bottom: 6 })

          Row() {
            // 体卦
            Column() {
              Text('体')
                .fontSize(12)
                .fontColor('#666')
              Text(this.result.benMingElement)
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.getElementColor(this.result.benMingElement))
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)

            // 关系箭头
            Column() {
              Text(this.getRelationArrow())
                .fontSize(24)
                .fontColor(this.getRelationColor())
              Text(this.result.tiYongRelation.relation)
                .fontSize(12)
                .fontColor(this.getRelationColor())
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)

            // 用卦
            Column() {
              Text('用')
                .fontSize(12)
                .fontColor('#666')
              Text(this.result.tiYongRelation.yongElement)
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.getElementColor(this.result.tiYongRelation.yongElement))
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)

            // 吉凶
            Column() {
              Text(this.result.tiYongRelation.luck)
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.getLuckColor(this.result.tiYongRelation.luck))
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Center)
          }
          .width('100%')
          .padding(12)
          .backgroundColor(this.getRelationBgColor())
          .borderRadius(8)

          Text(this.result.tiYongRelation.desc)
            .fontSize(12)
            .fontColor('#666')
            .margin({ top: 8 })
        }
        .width('100%')
        .margin({ bottom: 12 })
      }

      // 综合分析
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
  buildYearCard(item: LiuNianGuaInfo) {
    Column() {
      Text(`${item.year}`)
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.selectedYear === item.year ? '#FFF' : '#333')
      Text(item.yearGanZhi)
        .fontSize(12)
        .fontColor(this.selectedYear === item.year ? '#FFF' : '#666')
      Text(item.liuNianGua.unicode)
        .fontSize(28)
        .fontColor(this.selectedYear === item.year ? '#FFF' : '#1E4D8C')
      Text(item.liuNianGua.name)
        .fontSize(11)
        .fontColor(this.selectedYear === item.year ? '#FFF' : '#666')
    }
    .width(72)
    .height(110)
    .justifyContent(FlexAlign.Center)
    .padding(6)
    .backgroundColor(this.selectedYear === item.year ? '#1E4D8C' : '#F0F7FF')
    .borderRadius(8)
    .border({
      width: this.selectedYear === item.year ? 2 : 1,
      color: this.selectedYear === item.year ? '#0D3B66' : '#E0E0E0'
    })
    .onClick(() => {
      this.selectedYear = item.year;
    })
  }

  @Builder
  buildYearDetail(item: LiuNianGuaInfo) {
    Column() {
      Text(`【${item.year}年详情】`)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#2C5282')
        .alignSelf(ItemAlign.Start)
        .margin({ bottom: 6 })

      Row() {
        Column() {
          Text('流年干支')
            .fontSize(11)
            .fontColor('#888')
          Text(item.yearGanZhi)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Column() {
          Text('天数')
            .fontSize(11)
            .fontColor('#888')
          Text(`${item.tianShu}`)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#C41E3A')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Column() {
          Text('地数')
            .fontSize(11)
            .fontColor('#888')
          Text(`${item.diShu}`)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1E4D8C')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Column() {
          Text('流年卦')
            .fontSize(11)
            .fontColor('#888')
          Text(item.liuNianGua.name)
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor('#8B4513')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .padding(10)
      .backgroundColor('#FFFAF5')
      .borderRadius(8)

      // 计算过程说明
      Text(`相荡：本命天${this.result.benMingTianShu}+流年${item.tianShu}=余${item.newTianYu}，本命地${this.result.benMingDiShu}+流年${item.diShu}=余${item.newDiYu}`)
        .fontSize(10)
        .fontColor('#999')
        .margin({ top: 4 })
    }
    .width('100%')
    .margin({ bottom: 12 })
  }

  getSelectedLiuNian(): LiuNianGuaInfo | undefined {
    return this.result.liuNianList.find(item => item.year === this.selectedYear);
  }

  getElementColor(element: string): string {
    const colorMap: Map<string, string> = new Map([
      ['金', '#D4AF37'],
      ['木', '#228B22'],
      ['水', '#1E90FF'],
      ['火', '#DC143C'],
      ['土', '#8B4513']
    ]);
    return colorMap.get(element) || '#333';
  }

  getLuckColor(luck: string): string {
    if (luck === '大吉' || luck === '吉') return '#C41E3A';
    if (luck === '凶' || luck === '小凶') return '#4A4A4A';
    return '#666';
  }

  getRelationArrow(): string {
    const relation = this.result.tiYongRelation.relation;
    if (relation === '体克用') return '→';
    if (relation === '用克体') return '←';
    if (relation === '体生用') return '→';
    if (relation === '用生体') return '←';
    if (relation === '比和') return '↔';
    return '-';
  }

  getRelationColor(): string {
    const luck = this.result.tiYongRelation.luck;
    if (luck === '大吉') return '#C41E3A';
    if (luck === '吉') return '#228B22';
    if (luck === '凶') return '#4A4A4A';
    if (luck === '小凶') return '#8B4513';
    return '#666';
  }

  getRelationBgColor(): string {
    const luck = this.result.tiYongRelation.luck;
    if (luck === '大吉') return '#FFF0F0';
    if (luck === '吉') return '#F0FFF0';
    if (luck === '凶') return '#F5F5F5';
    if (luck === '小凶') return '#FFFAF5';
    return '#F8F8F8';
  }
}
