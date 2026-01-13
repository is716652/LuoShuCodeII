/**
 * 求数法组件 - 显示四柱数理密码
 */
import { QiuShuAnalysis, PillarNumber } from '../model/HeluoModels';

// 获取位置颜色
function getPositionColor(position: string): string {
  return position === '左' ? '#D4AF37' : '#6B8E23';
}

// 获取阴阳背景色
function getYinYangBgColor(yinyang: string): string {
  return yinyang === '阳' ? '#FFFACD' : '#E6F3FF';
}

@Component
export struct QiuShuChart {
  @Prop qiushuAnalysis: QiuShuAnalysis = new QiuShuAnalysis();

  build() {
    Column() {
      // 阴阳分布图
      Row() {
        // 左边 - 阳数
        Column() {
          Text('阳（左）')
            .fontSize(14)
            .fontColor('#D4AF37')
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 8 })

          Text('清 · 贵 · 主')
            .fontSize(10)
            .fontColor('#8B7355')
            .margin({ bottom: 8 })

          // 阳数列表
          Column() {
            ForEach(this.getYangItems(), (item: string) => {
              Text(item)
                .fontSize(14)
                .fontColor('#4A3728')
                .margin({ top: 2 })
            })
          }
          .padding(8)
          .backgroundColor('#FFFACD')
          .borderRadius(6)
          .width('100%')

          Text(`合: ${this.qiushuAnalysis.yangSum}`)
            .fontSize(16)
            .fontColor('#D4AF37')
            .fontWeight(FontWeight.Bold)
            .margin({ top: 8 })
        }
        .width('45%')
        .padding(12)
        .backgroundColor('#FFFEF9')
        .borderRadius(8)
        .border({ width: 2, color: '#D4AF37' })

        // 中间太极符号
        Column() {
          Text('☯')
            .fontSize(32)
            .fontColor('#4A3728')
        }
        .width('10%')
        .justifyContent(FlexAlign.Center)

        // 右边 - 阴数
        Column() {
          Text('阴（右）')
            .fontSize(14)
            .fontColor('#6B8E23')
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 8 })

          Text('浊 · 贱 · 客')
            .fontSize(10)
            .fontColor('#8B7355')
            .margin({ bottom: 8 })

          // 阴数列表
          Column() {
            ForEach(this.getYinItems(), (item: string) => {
              Text(item)
                .fontSize(14)
                .fontColor('#4A3728')
                .margin({ top: 2 })
            })
          }
          .padding(8)
          .backgroundColor('#E6F3FF')
          .borderRadius(6)
          .width('100%')

          Text(`合: ${this.qiushuAnalysis.yinSum}`)
            .fontSize(16)
            .fontColor('#6B8E23')
            .fontWeight(FontWeight.Bold)
            .margin({ top: 8 })
        }
        .width('45%')
        .padding(12)
        .backgroundColor('#FFFEF9')
        .borderRadius(8)
        .border({ width: 2, color: '#6B8E23' })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      // 四柱明细表
      Column() {
        Text('【四柱明细】')
          .fontSize(13)
          .fontColor('#4A3728')
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: 8 })

        // 表头
        Row() {
          Text('柱位').fontSize(11).fontColor('#8B7355').width('15%').textAlign(TextAlign.Center)
          Text('天干').fontSize(11).fontColor('#8B7355').width('12%').textAlign(TextAlign.Center)
          Text('河图').fontSize(11).fontColor('#8B7355').width('12%').textAlign(TextAlign.Center)
          Text('位置').fontSize(11).fontColor('#8B7355').width('12%').textAlign(TextAlign.Center)
          Text('地支').fontSize(11).fontColor('#8B7355').width('12%').textAlign(TextAlign.Center)
          Text('洛书').fontSize(11).fontColor('#8B7355').width('12%').textAlign(TextAlign.Center)
          Text('位置').fontSize(11).fontColor('#8B7355').width('12%').textAlign(TextAlign.Center)
        }
        .width('100%')
        .padding({ top: 4, bottom: 4 })
        .backgroundColor('#F5F0E6')
        .borderRadius({ topLeft: 4, topRight: 4 })

        // 数据行
        ForEach(this.qiushuAnalysis.pillars, (pillar: PillarNumber) => {
          Row() {
            Text(pillar.pillar).fontSize(11).fontColor('#4A3728').width('15%').textAlign(TextAlign.Center)
            Text(pillar.tianGan).fontSize(12).fontColor('#4A3728').width('12%').textAlign(TextAlign.Center)
            Text(`${pillar.hetuNum}`).fontSize(12).fontColor('#4A3728').width('12%').textAlign(TextAlign.Center)
            Text(pillar.ganPosition)
              .fontSize(11)
              .fontColor(getPositionColor(pillar.ganPosition))
              .width('12%')
              .textAlign(TextAlign.Center)
            Text(pillar.diZhi).fontSize(12).fontColor('#4A3728').width('12%').textAlign(TextAlign.Center)
            Text(`${pillar.luoshuNum}`).fontSize(12).fontColor('#4A3728').width('12%').textAlign(TextAlign.Center)
            Text(pillar.zhiPosition)
              .fontSize(11)
              .fontColor(getPositionColor(pillar.zhiPosition))
              .width('12%')
              .textAlign(TextAlign.Center)
          }
          .width('100%')
          .padding({ top: 6, bottom: 6 })
          .border({ width: { bottom: 1 }, color: '#E8DCC8' })
        })
      }
      .width('100%')
      .margin({ top: 16 })
      .backgroundColor('#FFFEF9')
      .borderRadius(8)
      .border({ width: 1, color: '#E8DCC8' })
      .padding(8)

      // 格局判断
      Row() {
        Column() {
          Text('阴阳格局')
            .fontSize(12)
            .fontColor('#8B7355')
          Row() {
            Text(this.qiushuAnalysis.pattern)
              .fontSize(16)
              .fontColor(this.qiushuAnalysis.pattern.includes('阳') ? '#D4AF37' : '#6B8E23')
              .fontWeight(FontWeight.Bold)
            Text(` (阳${this.qiushuAnalysis.yangCount}:阴${this.qiushuAnalysis.yinCount})`)
              .fontSize(12)
              .fontColor('#8B7355')
          }
        }
        .alignItems(HorizontalAlign.Start)
        .width('50%')

        Column() {
          Text('数理轻重')
            .fontSize(12)
            .fontColor('#8B7355')
          Row() {
            Text(this.qiushuAnalysis.sumLevel)
              .fontSize(16)
              .fontColor('#4A3728')
              .fontWeight(FontWeight.Bold)
            Text(` (总数${this.qiushuAnalysis.totalSum})`)
              .fontSize(12)
              .fontColor('#8B7355')
          }
        }
        .alignItems(HorizontalAlign.Start)
        .width('50%')
      }
      .width('100%')
      .margin({ top: 12 })
      .padding(12)
      .backgroundColor('#F5F0E6')
      .borderRadius(8)

      // 解读
      Column() {
        Text(this.qiushuAnalysis.patternDesc)
          .fontSize(13)
          .fontColor('#4A3728')
          .lineHeight(20)
        Text(this.qiushuAnalysis.sumDesc)
          .fontSize(13)
          .fontColor('#4A3728')
          .lineHeight(20)
          .margin({ top: 4 })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .margin({ top: 8 })
    }
    .width('100%')
  }

  // 获取阳数项目列表
  getYangItems(): string[] {
    const items: string[] = [];
    for (const pillar of this.qiushuAnalysis.pillars) {
      if (pillar.hetuNum % 2 === 1) {
        items.push(`${pillar.tianGan}${pillar.hetuNum}`);
      }
      if (pillar.luoshuNum % 2 === 1) {
        items.push(`${pillar.diZhi}${pillar.luoshuNum}`);
      }
    }
    return items;
  }

  // 获取阴数项目列表
  getYinItems(): string[] {
    const items: string[] = [];
    for (const pillar of this.qiushuAnalysis.pillars) {
      if (pillar.hetuNum % 2 === 0) {
        items.push(`${pillar.tianGan}${pillar.hetuNum}`);
      }
      if (pillar.luoshuNum % 2 === 0) {
        items.push(`${pillar.diZhi}${pillar.luoshuNum}`);
      }
    }
    return items;
  }
}
