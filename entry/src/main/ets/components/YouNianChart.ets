/**
 * 游年图组件 - 显示本命卦八方吉凶
 */
import { YouNianRelation, YouNianAnalysis } from '../model/HeluoModels';

// 卦象符号映射
const GUA_SYMBOLS: Map<string, string> = new Map([
  ['乾', '☰'], ['坤', '☷'], ['震', '☳'], ['巽', '☴'],
  ['坎', '☵'], ['离', '☲'], ['艮', '☶'], ['兑', '☱']
]);

// 吉凶颜色映射
function getLuckColor(luck: string): string {
  if (luck === '大吉') return '#D4AF37';      // 金色
  if (luck === '中吉') return '#228B22';      // 深绿
  if (luck === '小吉') return '#32CD32';      // 浅绿
  if (luck === '大凶') return '#8B0000';      // 深红
  if (luck === '次凶') return '#B22222';      // 红色
  if (luck === '小凶') return '#CD853F';      // 棕色
  return '#666666';
}

// 吉凶图标
function getLuckIcon(luck: string): string {
  if (luck === '大吉') return '★';
  if (luck === '中吉') return '✓';
  if (luck === '小吉') return '◆';
  if (luck === '大凶') return '✕';
  if (luck === '次凶') return '⚠';
  if (luck === '小凶') return '△';
  return '○';
}

@Component
export struct YouNianChart {
  @Prop younianAnalysis: YouNianAnalysis = new YouNianAnalysis();
  onGuaClick: (rel: YouNianRelation) => void = () => {};

  // 后天八卦方位布局 (3x3网格)
  // [巽东南, 离南, 坤西南]
  // [震东,   中宫, 兑西]
  // [艮东北, 坎北, 乾西北]
  private baguaLayout: string[][] = [
    ['巽', '离', '坤'],
    ['震', '', '兑'],
    ['艮', '坎', '乾']
  ];

  // 根据卦名获取关系
  getRelationByGua(guaName: string): YouNianRelation | null {
    for (const rel of this.younianAnalysis.relations) {
      if (rel.targetGua === guaName) {
        return rel;
      }
    }
    return null;
  }

  build() {
    Column() {
      // 九宫格
      ForEach(this.baguaLayout, (row: string[], rowIndex: number) => {
        Row() {
          ForEach(row, (guaName: string, colIndex: number) => {
            if (guaName === '') {
              // 中宫显示本命卦
              Column() {
                Text(GUA_SYMBOLS.get(this.younianAnalysis.benMingGua) || '☯')
                  .fontSize(28)
                  .fontColor('#8B0000')
                Text(this.younianAnalysis.benMingGua + '命')
                  .fontSize(12)
                  .fontColor('#8B0000')
                  .fontWeight(FontWeight.Bold)
              }
              .width(80)
              .height(80)
              .justifyContent(FlexAlign.Center)
              .backgroundColor('#FFF8DC')
              .borderRadius(8)
              .border({ width: 2, color: '#D4AF37' })
            } else {
              // 八方位
              this.buildGuaCell(guaName)
            }
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceEvenly)
        .margin({ bottom: rowIndex < 2 ? 8 : 0 })
      })
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#FFFEF9')
    .borderRadius(12)
  }

  @Builder
  buildGuaCell(guaName: string) {
    Column() {
      // 方位+卦名
      Row() {
        Text(this.getDirection(guaName))
          .fontSize(10)
          .fontColor('#8B7355')
        Text(GUA_SYMBOLS.get(guaName) || '')
          .fontSize(14)
          .fontColor('#4A3728')
          .margin({ left: 2 })
      }

      // 星名
      Text(this.getStarName(guaName))
        .fontSize(14)
        .fontColor(getLuckColor(this.getLuck(guaName)))
        .fontWeight(FontWeight.Medium)
        .margin({ top: 4 })

      // 吉凶图标
      Text(getLuckIcon(this.getLuck(guaName)))
        .fontSize(16)
        .fontColor(getLuckColor(this.getLuck(guaName)))
        .margin({ top: 2 })
    }
    .width(80)
    .height(80)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.getCellBgColor(this.getLuck(guaName)))
    .borderRadius(8)
    .border({ width: 1, color: '#E8DCC8' })
    .onClick(() => {
      const clickRel = this.getRelationByGua(guaName);
      if (clickRel) {
        this.onGuaClick(clickRel);
      }
    })
  }

  getDirection(guaName: string): string {
    const rel = this.getRelationByGua(guaName);
    return rel?.direction || '';
  }

  getStarName(guaName: string): string {
    const rel = this.getRelationByGua(guaName);
    return rel?.star || '';
  }

  getLuck(guaName: string): string {
    const rel = this.getRelationByGua(guaName);
    return rel?.starInfo?.luck || '';
  }

  getCellBgColor(luck: string): string {
    if (luck === '大吉') return '#FFFACD';   // 浅金
    if (luck === '中吉' || luck === '小吉') return '#F0FFF0';  // 浅绿
    if (luck === '大凶') return '#FFE4E1';   // 浅红
    if (luck === '次凶' || luck === '小凶') return '#FFF5EE'; // 浅橙
    return '#FFFFFF';
  }
}
