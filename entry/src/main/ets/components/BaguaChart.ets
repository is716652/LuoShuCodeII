/**
 * 八卦图组件 - 后天八卦方位图
 * 支持高亮指定卦象，点击显示详情
 */

// 卦象数据
export class GuaInfo {
  name: string = '';
  symbol: string = '';
  number: number = 0;
  element: string = '';
  direction: string = '';
  tiangan: string[] = [];
  dizhi: string[] = [];
  desc: string = '';
}

// 初始化八卦数据
function initBaguaData(): GuaInfo[] {
  const data: GuaInfo[] = [];

  const li = new GuaInfo();
  li.name = '离'; li.symbol = '☲'; li.number = 9; li.element = '火';
  li.direction = '南'; li.tiangan = ['丙', '丁']; li.dizhi = ['午'];
  li.desc = '离为火，南方，心目之象';
  data.push(li);

  const kun = new GuaInfo();
  kun.name = '坤'; kun.symbol = '☷'; kun.number = 2; kun.element = '土';
  kun.direction = '西南'; kun.tiangan = ['己']; kun.dizhi = ['未', '申'];
  kun.desc = '坤为地，西南，母土之象';
  data.push(kun);

  const dui = new GuaInfo();
  dui.name = '兑'; dui.symbol = '☱'; dui.number = 7; dui.element = '金';
  dui.direction = '西'; dui.tiangan = ['辛']; dui.dizhi = ['酉'];
  dui.desc = '兑为泽，西方，少女之象';
  data.push(dui);

  const qian = new GuaInfo();
  qian.name = '乾'; qian.symbol = '☰'; qian.number = 6; qian.element = '金';
  qian.direction = '西北'; qian.tiangan = ['甲', '壬']; qian.dizhi = ['戌', '亥'];
  qian.desc = '乾为天，西北，君父之象';
  data.push(qian);

  const kan = new GuaInfo();
  kan.name = '坎'; kan.symbol = '☵'; kan.number = 1; kan.element = '水';
  kan.direction = '北'; kan.tiangan = ['癸']; kan.dizhi = ['子'];
  kan.desc = '坎为水，北方，智慧之象';
  data.push(kan);

  const gen = new GuaInfo();
  gen.name = '艮'; gen.symbol = '☶'; gen.number = 8; gen.element = '土';
  gen.direction = '东北'; gen.tiangan = ['丙']; gen.dizhi = ['丑', '寅'];
  gen.desc = '艮为山，东北，少男之象';
  data.push(gen);

  const zhen = new GuaInfo();
  zhen.name = '震'; zhen.symbol = '☳'; zhen.number = 3; zhen.element = '木';
  zhen.direction = '东'; zhen.tiangan = ['甲']; zhen.dizhi = ['卯'];
  zhen.desc = '震为雷，东方，长男之象';
  data.push(zhen);

  const xun = new GuaInfo();
  xun.name = '巽'; xun.symbol = '☴'; xun.number = 4; xun.element = '木';
  xun.direction = '东南'; xun.tiangan = ['乙']; xun.dizhi = ['辰', '巳'];
  xun.desc = '巽为风，东南，长女之象';
  data.push(xun);

  return data;
}

// 八卦基础数据（后天八卦方位）
export const BAGUA_DATA: GuaInfo[] = initBaguaData();

// 获取五行对应颜色
function getElementColor(element: string): string {
  const colorMap = new Map<string, string>([
    ['金', '#D4AF37'],
    ['木', '#228B22'],
    ['水', '#1E90FF'],
    ['火', '#DC143C'],
    ['土', '#8B4513']
  ]);
  return colorMap.get(element) || '#4A3728';
}

@Component
export struct BaguaChart {
  @Prop title: string = '八卦图';
  @Prop highlightGua: string = '';  // 高亮的卦名
  @Prop activeGuaList: string[] = [];  // 激活（得令）的卦列表
  @Link showDetail: boolean;
  @Link selectedGua: GuaInfo;

  // 后天八卦方位布局 (3x3网格)
  // 巽4 离9 坤2
  // 震3 中  兑7
  // 艮8 坎1 乾6
  private baguaLayout: string[][] = [
    ['巽', '离', '坤'],
    ['震', '', '兑'],
    ['艮', '坎', '乾']
  ];

  getGuaByName(name: string): GuaInfo | null {
    for (const gua of BAGUA_DATA) {
      if (gua.name === name) {
        return gua;
      }
    }
    return null;
  }

  isHighlight(name: string): boolean {
    return this.highlightGua === name;
  }

  isActive(name: string): boolean {
    return this.activeGuaList.includes(name);
  }

  build() {
    Column() {
      // 标题
      Text(this.title)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#4A3728')
        .margin({ bottom: 12 })

      // 八卦九宫格
      Column() {
        ForEach(this.baguaLayout, (row: string[], rowIndex: number) => {
          Row() {
            ForEach(row, (guaName: string, colIndex: number) => {
              if (guaName === '') {
                // 中宫 - 太极
                Column() {
                  Text('☯')
                    .fontSize(32)
                    .fontColor('#8B0000')
                }
                .width(80)
                .height(80)
                .justifyContent(FlexAlign.Center)
                .backgroundColor('#FFF9F0')
                .borderRadius(8)
              } else {
                // 八卦位
                Column() {
                  Text(this.getGuaByName(guaName)?.symbol || '')
                    .fontSize(28)
                    .fontColor(this.isHighlight(guaName) ? '#FFFFFF' : 
                              this.isActive(guaName) ? '#228B22' : '#4A3728')
                  Text(guaName)
                    .fontSize(14)
                    .fontColor(this.isHighlight(guaName) ? '#FFFFFF' : '#4A3728')
                    .fontWeight(this.isHighlight(guaName) ? FontWeight.Bold : FontWeight.Normal)
                  Text(`${this.getGuaByName(guaName)?.number || ''}`)
                    .fontSize(12)
                    .fontColor(this.isHighlight(guaName) ? '#FFD700' : '#8B7355')
                }
                .width(80)
                .height(80)
                .justifyContent(FlexAlign.Center)
                .backgroundColor(this.isHighlight(guaName) ? '#8B0000' : 
                                this.isActive(guaName) ? '#E8FFE8' : '#FFFEF9')
                .borderRadius(8)
                .border({ 
                  width: this.isHighlight(guaName) ? 2 : 1, 
                  color: this.isHighlight(guaName) ? '#D4AF37' : 
                         this.isActive(guaName) ? '#228B22' : '#E8DCC8' 
                })
                .onClick(() => {
                  const gua = this.getGuaByName(guaName);
                  if (gua) {
                    this.selectedGua = gua;
                    this.showDetail = true;
                  }
                })
              }
            })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceEvenly)
          .margin({ bottom: rowIndex < 2 ? 8 : 0 })
        })
      }
      .padding(12)
      .backgroundColor('#FDF8F0')
      .borderRadius(12)

      // 图例
      Row() {
        if (this.highlightGua !== '') {
          Row() {
            Text('●')
              .fontSize(12)
              .fontColor('#8B0000')
            Text(' 生年卦')
              .fontSize(11)
              .fontColor('#8B7355')
          }
          .margin({ right: 16 })
        }
        if (this.activeGuaList.length > 0) {
          Row() {
            Text('●')
              .fontSize(12)
              .fontColor('#228B22')
            Text(' 当令卦')
              .fontSize(11)
              .fontColor('#8B7355')
          }
        }
      }
      .margin({ top: 8 })
    }
    .width('100%')
  }
}

// 卦象详情弹窗组件
@CustomDialog
export struct GuaDetailDialog {
  controller: CustomDialogController;
  @Prop gua: GuaInfo;
  @Prop isYuanqi: boolean = false;  // 是否是元气图（显示更详细解释）

  build() {
    Column() {
      // 标题
      Row() {
        Text(this.gua.symbol)
          .fontSize(48)
          .fontColor('#8B0000')
        Column() {
          Text(`${this.gua.name}卦`)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#4A3728')
          Text(this.gua.direction + ' · ' + this.gua.element)
            .fontSize(14)
            .fontColor('#8B7355')
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 16 })
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .margin({ bottom: 20 })

      // 数字
      Row() {
        Text('数字：')
          .fontSize(14)
          .fontColor('#8B7355')
        Text(`${this.gua.number}`)
          .fontSize(20)
          .fontColor('#D4AF37')
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .margin({ bottom: 12 })

      // 天干
      Row() {
        Text('天干：')
          .fontSize(14)
          .fontColor('#8B7355')
        Text(this.gua.tiangan.join('、'))
          .fontSize(16)
          .fontColor('#4A3728')
      }
      .width('100%')
      .margin({ bottom: 12 })

      // 地支
      Row() {
        Text('地支：')
          .fontSize(14)
          .fontColor('#8B7355')
        Text(this.gua.dizhi.join('、'))
          .fontSize(16)
          .fontColor('#4A3728')
      }
      .width('100%')
      .margin({ bottom: 12 })

      // 解释
      Column() {
        Text('解释：')
          .fontSize(14)
          .fontColor('#8B7355')
          .margin({ bottom: 8 })
        Text(this.gua.desc)
          .fontSize(14)
          .fontColor('#4A3728')
          .lineHeight(22)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .margin({ bottom: 16 })

      // 元气图特殊说明
      if (this.isYuanqi) {
        Column() {
          Divider().color('#E8DCC8').margin({ bottom: 12 })
          Text('纳甲原理：')
            .fontSize(14)
            .fontColor('#D4AF37')
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 8 })
          Text(this.getNajiaPrinciple())
            .fontSize(13)
            .fontColor('#4A3728')
            .lineHeight(20)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }

      // 关闭按钮
      Button('关闭')
        .width('50%')
        .height(40)
        .fontSize(16)
        .fontColor('#FFFFFF')
        .backgroundColor('#8B0000')
        .borderRadius(20)
        .margin({ top: 20 })
        .onClick(() => {
          this.controller.close();
        })
    }
    .width('90%')
    .padding(24)
    .backgroundColor('#FFFEF9')
    .borderRadius(16)
    .border({ width: 2, color: '#D4AF37' })
  }

  getNajiaPrinciple(): string {
    const principles = new Map<string, string>([
      ['乾', '乾卦统领甲、壬两个天干。戌亥是立冬前的月份，代表西北，是乾卦的"老家"（乾居西北）。在河图洛书中，乾为天，天一生水，地六成之，乾卦对应洛书的"六白"星，五行属金，故取数6。'],
      ['坤', '坤卦统领己、癸两个天干。未申是立秋前的月份，代表西南，是坤卦的本位。坤为地，对应洛书"二黑"星，五行属土，故取数2。'],
      ['震', '震卦统领庚天干。卯是春分前后的月份，代表正东，是震卦的本位。震为雷，对应洛书"三碧"星，五行属木，故取数3。'],
      ['巽', '巽卦统领辛天干。辰巳是立夏前的月份，代表东南，是巽卦的本位。巽为风，对应洛书"四绿"星，五行属木，故取数4。'],
      ['坎', '坎卦统领戊天干。子是冬至前后的月份，代表正北，是坎卦的本位。坎为水，对应洛书"一白"星，五行属水，故取数1。'],
      ['离', '离卦统领己天干。午是夏至前后的月份，代表正南，是离卦的本位。离为火，对应洛书"九紫"星，五行属火，故取数9。'],
      ['艮', '艮卦统领丙天干。丑寅是立春前的月份，代表东北，是艮卦的本位。艮为山，对应洛书"八白"星，五行属土，故取数8。'],
      ['兑', '兑卦统领丁天干。酉是秋分前后的月份，代表正西，是兑卦的本位。兑为泽，对应洛书"七赤"星，五行属金，故取数7。']
    ]);
    return principles.get(this.gua.name) || this.gua.desc;
  }
}
