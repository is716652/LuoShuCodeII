/**
 * 河洛真数 - 主页面
 * 全新UI设计
 */
import { HeluoService } from '../service/HeluoService';
import {
  CalendarData,
  BenMingInfo,
  FanjuAnalysis,
  HuagongAnalysis,
  HeluoAnalysis,
  YouNianAnalysis,
  YouNianRelation,
  QiuShuAnalysis,
  ZhengTongGuaResult,
  NianGanGuaResult,
  TiYongAnalysisResult,
  XiangDangResult,
  YuanTangInfo,
  LiuYueGuaInfo,
  LiuRiGuaInfo,
  XiaoXiangResult,
  NaJiaPanResult,
  YaoWithNaJia,
  PaipanRecord,
  TermExplanation
} from '../model/HeluoModels';
import { BaguaChart, GuaDetailDialog, GuaInfo, BAGUA_DATA } from '../components/BaguaChart';
import { YouNianChart } from '../components/YouNianChart';
import { QiuShuChart } from '../components/QiuShuChart';
import { ZhengTongGuaChart } from '../components/ZhengTongGuaChart';
import { NianGanGuaChart } from '../components/NianGanGuaChart';
import { TiYongAnalysis } from '../components/TiYongAnalysis';
import { XiangDangChart } from '../components/XiangDangChart';
import { StorageUtil } from '../utils/StorageUtil';

// 农历月份名称
const LUNAR_MONTHS: string[] = ['正', '二', '三', '四', '五', '六', '七', '八', '九', '十', '冬', '腊'];

// 农历日期名称
const LUNAR_DAYS: string[] = [
  '初一', '初二', '初三', '初四', '初五', '初六', '初七', '初八', '初九', '初十',
  '十一', '十二', '十三', '十四', '十五', '十六', '十七', '十八', '十九', '二十',
  '廿一', '廿二', '廿三', '廿四', '廿五', '廿六', '廿七', '廿八', '廿九', '三十'
];

// 时辰数据
const SHICHEN_LIST: string[] = [
  '子时 (23:00-01:00)', '丑时 (01:00-03:00)', '寅时 (03:00-05:00)', '卯时 (05:00-07:00)',
  '辰时 (07:00-09:00)', '巳时 (09:00-11:00)', '午时 (11:00-13:00)', '未时 (13:00-15:00)',
  '申时 (15:00-17:00)', '酉时 (17:00-19:00)', '戌时 (19:00-21:00)', '亥时 (21:00-23:00)'
];

const SHICHEN_NAMES: string[] = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];

// 预定义 Select 选项
class SelectOptionItem {
  value: string = '';
  constructor(val: string) {
    this.value = val;
  }
}

function getShichenOptions(): SelectOptionItem[] {
  const options: SelectOptionItem[] = [];
  for (const item of SHICHEN_LIST) {
    const opt = new SelectOptionItem(item);
    options.push(opt);
  }
  return options;
}

@Entry
@Component
struct Index {
  @State selectedYear: number = 1990;
  @State selectedMonth: number = 1;
  @State selectedDay: number = 1;
  @State selectedShichen: number = 6;
  @State selectedGender: number = 0; // 0=男, 1=女
  @State isLoading: boolean = false;
  @State hasResult: boolean = false;
  @State analysis: HeluoAnalysis | null = null;
  @State errorMsg: string = '';

  // Tab分页索引
  @State currentTabIndex: number = 0;

  // 八卦弹窗相关
  @State showGuaDetail: boolean = false;
  @State selectedGua: GuaInfo = new GuaInfo();
  @State isYuanqiGua: boolean = false;

  // 游年图相关
  @State younianAnalysis: YouNianAnalysis = new YouNianAnalysis();
  @State showYounianDetail: boolean = false;
  @State selectedYounianRel: YouNianRelation = new YouNianRelation();

  // 求数法相关
  @State qiushuAnalysis: QiuShuAnalysis = new QiuShuAnalysis();

  // 成卦法相关
  @State zhengTongGua: ZhengTongGuaResult = new ZhengTongGuaResult();
  @State nianGanGua: NianGanGuaResult = new NianGanGuaResult();
  @State tiYongResult: TiYongAnalysisResult = new TiYongAnalysisResult();

  // 八卦相荡法相关
  @State xiangDangResult: XiangDangResult = new XiangDangResult();

  // 定元堂式、起月卦、起日卦、六亲纳甲相关
  @State yuanTangInfo: YuanTangInfo = new YuanTangInfo();
  @State liuYueGuaList: LiuYueGuaInfo[] = [];
  @State liuRiGua: LiuRiGuaInfo = new LiuRiGuaInfo();
  @State xiaoXiangResult: XiaoXiangResult = new XiaoXiangResult();
  @State naJiaPan: NaJiaPanResult = new NaJiaPanResult();

  // 历史记录相关
  @State historyList: PaipanRecord[] = [];
  @State showHistoryDialog: boolean = false;

  // 术语解释相关
  @State showTermDialog: boolean = false;
  @State selectedTerm: TermExplanation | null = null;

  private heluoService: HeluoService | null = null;
  private guaDialogController: CustomDialogController | null = null;

  aboutToAppear(): void {
    this.heluoService = new HeluoService(getContext(this));
    this.heluoService.initialize();
    // 初始化存储工具
    StorageUtil.init(getContext(this));
    // 加载历史记录
    this.loadHistory();
  }

  async doAnalyze(): Promise<void> {
    if (!this.heluoService) return;
    this.isLoading = true;
    this.errorMsg = '';
    try {
      this.analysis = await this.heluoService.analyze(
        this.selectedYear,
        this.selectedMonth,
        this.selectedDay,
        this.selectedShichen
      );
      // 游年分析
      if (this.analysis.benMing) {
        this.younianAnalysis = this.heluoService.analyzeYounian(this.analysis.benMing.gua);
      }
      // 求数法分析
      if (this.analysis.calendar) {
        this.qiushuAnalysis = this.heluoService.analyzeQiuShu(this.analysis.calendar);

        // 成卦法分析
        const gender = this.selectedGender === 0 ? '男' : '女';
        this.zhengTongGua = await this.heluoService.analyzeZhengTongGua(
          this.qiushuAnalysis,
          gender,
          this.analysis.calendar.year_gan
        );
        this.nianGanGua = await this.heluoService.analyzeNianGanGua(
          this.qiushuAnalysis,
          this.analysis.calendar.year_gan,
          gender,
          this.analysis.calendar.day_zhi
        );
        this.tiYongResult = this.heluoService.analyzeTiYong(this.zhengTongGua, this.nianGanGua);

        // 八卦相荡法分析（推演未来10年流年）
        const currentYear = new Date().getFullYear();
        this.xiangDangResult = await this.heluoService.analyzeXiangDang(
          this.zhengTongGua,
          gender,
          this.analysis.calendar.year_gan,
          currentYear,
          10
        );

        // 六亲纳甲：对当前流年卦装六亲、定世应、查旺衰
        this.naJiaPan = new NaJiaPanResult();
        if (this.xiangDangResult.currentLiuNian && this.xiangDangResult.currentLiuNian.liuNianGua &&
          this.xiangDangResult.currentLiuNian.liuNianGua.name !== '') {
          this.naJiaPan = await this.heluoService.analyzeNaJiaForGua(
            this.xiangDangResult.currentLiuNian.liuNianGua.name,
            this.analysis.calendar.day_gan,
            this.analysis.calendar.month_zhi,
            this.analysis.calendar.solar_term || ''
          );
        }

        // 定元堂式：根据本命卦和时辰定元堂
        if (this.zhengTongGua.mingGua.name !== '') {
          this.yuanTangInfo = this.heluoService.defineYuanTang(
            this.zhengTongGua.mingGua,
            this.selectedShichen,
            gender,
            this.analysis.calendar.year_gan,
            this.analysis.calendar.solar_term || ''
          );

          // 起月卦：12个月的流月运势
          this.liuYueGuaList = [];
          for (let m = 1; m <= 12; m++) {
            const liuYueGua = this.heluoService.calculateLiuYueGua(
              this.yuanTangInfo.yaoPosition,
              this.analysis.calendar.day_gan,
              m
            );
            this.liuYueGuaList.push(liuYueGua);
          }
        }

        // 起日卦：今日运势
        this.liuRiGua = this.heluoService.calculateLiuRiGua(
          this.analysis.calendar.day_zhi,
          this.analysis.calendar.day_gan
        );

        // 小象行年：计算当前虚岁年龄的运势
        if (this.yuanTangInfo.yaoPosition > 0) {
          const birthYear = this.selectedYear;
          const currentYear = new Date().getFullYear();
          const age = currentYear - birthYear + 1; // 虚岁
          this.xiaoXiangResult = this.heluoService.calculateXiaoXiang(
            this.yuanTangInfo.yaoPosition,
            age,
            gender,
            this.analysis.calendar.year_gan
          );
        }
      }
      this.hasResult = true;

      // 保存到历史记录
      await this.saveToHistory();
    } catch (e) {
      this.errorMsg = '分析失败，请检查日期是否有效';
    } finally {
      this.isLoading = false;
    }
  }

  getLunarMonthName(month: number): string {
    return LUNAR_MONTHS[month - 1] || '';
  }

  getLunarDayName(day: number): string {
    return LUNAR_DAYS[day - 1] || '';
  }

  getActiveGuaList(): string[] {
    if (!this.analysis || !this.analysis.huagong) return [];
    // 根据化工分析获取当令卦
    const seasonElement = this.analysis.huagong.seasonElement;
    const guaList: string[] = [];
    for (const gua of BAGUA_DATA) {
      if (gua.element === seasonElement) {
        guaList.push(gua.name);
      }
    }
    return guaList;
  }

  // 获取生月对应的化工图高亮卦
  getHuagongGuaList(): string[] {
    if (!this.analysis || !this.analysis.benMing) return [];
    const benMingElement = this.analysis.benMing.element;
    const guaList: string[] = [];
    for (const gua of BAGUA_DATA) {
      if (gua.element === benMingElement) {
        guaList.push(gua.name);
      }
    }
    return guaList;
  }

  showGuaDetailDialog(gua: GuaInfo, isYuanqi: boolean): void {
    this.selectedGua = gua;
    this.isYuanqiGua = isYuanqi;
    if (this.guaDialogController) {
      this.guaDialogController.open();
    }
  }

  // ========== 历史记录相关方法 ==========

  // 加载历史记录
  async loadHistory(): Promise<void> {
    this.historyList = await StorageUtil.getHistory();
  }

  // 保存当前排盘到历史
  async saveToHistory(): Promise<void> {
    if (!this.analysis || !this.analysis.calendar || !this.analysis.benMing) {
      return;
    }

    const record = new PaipanRecord();
    record.id = Date.now().toString();
    record.gender = this.selectedGender === 0 ? '男' : '女';
    record.birthYear = this.selectedYear;
    record.birthMonth = this.selectedMonth;
    record.birthDay = this.selectedDay;
    record.shichenIndex = this.selectedShichen;
    record.lunarDate = `${this.analysis.calendar.lunar_year}年${this.getLunarMonthName(this.analysis.calendar.lunar_month)}月${this.getLunarDayName(this.analysis.calendar.lunar_day)}`;
    record.benMingGua = this.analysis.benMing.gua;
    record.createTime = Date.now();
    record.name = `${record.gender}·${this.selectedYear}年${this.selectedMonth}月${this.selectedDay}日`;

    await StorageUtil.saveHistory(record);
    await this.loadHistory();
  }

  // 删除单条历史记录
  async deleteHistory(id: string): Promise<void> {
    await StorageUtil.deleteHistory(id);
    await this.loadHistory();
  }

  // 加载历史记录
  loadHistoryRecord(record: PaipanRecord): void {
    this.selectedGender = record.gender === '男' ? 0 : 1;
    this.selectedYear = record.birthYear;
    this.selectedMonth = record.birthMonth;
    this.selectedDay = record.birthDay;
    this.selectedShichen = record.shichenIndex;
    this.showHistoryDialog = false;
    this.doAnalyze();
  }

  // ========== 术语解释相关方法 ==========

  // 显示术语解释
  async showTermExplanation(term: string): Promise<void> {
    if (!this.heluoService) return;
    const explanation = await this.heluoService.getTermExplanation(term);
    if (explanation) {
      this.selectedTerm = explanation;
      this.showTermDialog = true;
    }
  }

  build() {
    Stack() {
      Column() {
      // 顶部标题栏
      Row() {
        Text('☰')
          .fontSize(20)
          .fontColor('#D4AF37')
        Text('河洛真数')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#8B0000')
          .margin({ left: 8, right: 8 })
        Text('☷')
          .fontSize(20)
          .fontColor('#D4AF37')

        Blank()

        // 历史记录按钮
        Row() {
          Text('📜')
            .fontSize(18)
            .margin({ right: 4 })
          Text('历史')
            .fontSize(14)
            .fontColor('#8B7355')
        }
        .padding({ left: 10, right: 10, top: 6, bottom: 6 })
        .backgroundColor('#FFF9F0')
        .borderRadius(16)
        .onClick(() => {
          this.showHistoryDialog = true;
        })
        .margin({ right: 12 })
      }
      .width('100%')
      .height(56)
      .padding({ left: 12, right: 12 })
      .backgroundColor('#FFFEF9')
      .border({ width: { bottom: 1 }, color: '#E8DCC8' })

      Scroll() {
        Column() {
          // 输入区域
          Column() {
            // 性别选择
            Row() {
              Text('性别')
                .fontSize(14)
                .fontColor('#4A3728')
                .width(60)

              Row() {
                Row() {
                  Radio({ value: 'male', group: 'gender' })
                    .checked(this.selectedGender === 0)
                    .onChange((isChecked: boolean) => {
                      if (isChecked) this.selectedGender = 0;
                    })
                  Text('男（乾造）')
                    .fontSize(14)
                    .fontColor('#4A3728')
                    .margin({ left: 4 })
                }

                Row() {
                  Radio({ value: 'female', group: 'gender' })
                    .checked(this.selectedGender === 1)
                    .onChange((isChecked: boolean) => {
                      if (isChecked) this.selectedGender = 1;
                    })
                  Text('女（坤造）')
                    .fontSize(14)
                    .fontColor('#4A3728')
                    .margin({ left: 4 })
                }
                .margin({ left: 24 })
              }
            }
            .width('100%')
            .margin({ bottom: 12 })

            // 出生年月日
            Row() {
              Text('阳历')
                .fontSize(14)
                .fontColor('#4A3728')
                .width(60)

              TextInput({ text: this.selectedYear.toString() })
                .type(InputType.Number)
                .width(70)
                .height(36)
                .fontSize(14)
                .fontColor('#4A3728')
                .backgroundColor('#FFFFFF')
                .borderRadius(6)
                .border({ width: 1, color: '#E8DCC8' })
                .onChange((value: string) => {
                  const num = parseInt(value);
                  if (!isNaN(num) && num >= 1900 && num <= 2100) {
                    this.selectedYear = num;
                  }
                })
              Text('年')
                .fontSize(14)
                .fontColor('#4A3728')
                .margin({ left: 4, right: 8 })

              TextInput({ text: this.selectedMonth.toString() })
                .type(InputType.Number)
                .width(50)
                .height(36)
                .fontSize(14)
                .fontColor('#4A3728')
                .backgroundColor('#FFFFFF')
                .borderRadius(6)
                .border({ width: 1, color: '#E8DCC8' })
                .onChange((value: string) => {
                  const num = parseInt(value);
                  if (!isNaN(num) && num >= 1 && num <= 12) {
                    this.selectedMonth = num;
                  }
                })
              Text('月')
                .fontSize(14)
                .fontColor('#4A3728')
                .margin({ left: 4, right: 8 })

              TextInput({ text: this.selectedDay.toString() })
                .type(InputType.Number)
                .width(50)
                .height(36)
                .fontSize(14)
                .fontColor('#4A3728')
                .backgroundColor('#FFFFFF')
                .borderRadius(6)
                .border({ width: 1, color: '#E8DCC8' })
                .onChange((value: string) => {
                  const num = parseInt(value);
                  if (!isNaN(num) && num >= 1 && num <= 31) {
                    this.selectedDay = num;
                  }
                })
              Text('日')
                .fontSize(14)
                .fontColor('#4A3728')
                .margin({ left: 4 })
            }
            .width('100%')
            .margin({ bottom: 12 })

            // 时辰选择
            Row() {
              Text('时辰')
                .fontSize(14)
                .fontColor('#4A3728')
                .width(60)

              Select(getShichenOptions())
                .selected(this.selectedShichen)
                .value(SHICHEN_LIST[this.selectedShichen])
                .font({ size: 14 })
                .fontColor('#4A3728')
                .selectedOptionFont({ size: 14 })
                .optionFont({ size: 14 })
                .backgroundColor('#FFFFFF')
                .onSelect((index: number) => {
                  this.selectedShichen = index;
                })
            }
            .width('100%')
            .margin({ bottom: 16 })

            // 排盘按钮
            Button(this.isLoading ? '推演中...' : '起  盘')
              .width('100%')
              .height(44)
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor('#FFFFFF')
              .backgroundColor('#8B0000')
              .borderRadius(8)
              .enabled(!this.isLoading)
              .onClick(() => {
                this.doAnalyze();
              })

            if (this.errorMsg !== '') {
              Text(this.errorMsg)
                .fontSize(13)
                .fontColor('#B22222')
                .margin({ top: 8 })
            }
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFEF9')
          .borderRadius(12)
          .margin({ top: 12, left: 12, right: 12 })

          // 结果区域
          if (this.hasResult && this.analysis !== null && this.analysis.calendar !== null) {
            // 农历信息与四柱
            Column() {
              // 农历日期
              Row() {
                Text(this.selectedGender === 0 ? '乾造' : '坤造')
                  .fontSize(14)
                  .fontColor('#D4AF37')
                  .fontWeight(FontWeight.Bold)
                  .margin({ right: 12 })

                Text(`农历 ${this.analysis.calendar.year_gan}${this.analysis.calendar.year_zhi}年 ${this.getLunarMonthName(this.analysis.calendar.lunar_month)}月${this.getLunarDayName(this.analysis.calendar.lunar_day)} ${SHICHEN_NAMES[this.selectedShichen]}时`)
                  .fontSize(14)
                  .fontColor('#4A3728')
              }
              .width('100%')
              .margin({ bottom: 12 })

              // 四柱排盘
              Row() {
                // 年柱
                Column() {
                  Text('年柱')
                    .fontSize(11)
                    .fontColor('#8B7355')
                  Text(this.analysis.calendar.year_gan)
                    .fontSize(20)
                    .fontColor('#8B0000')
                    .fontWeight(FontWeight.Bold)
                  Text(this.analysis.calendar.year_zhi)
                    .fontSize(20)
                    .fontColor('#4A3728')
                    .fontWeight(FontWeight.Bold)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Center)

                // 月柱
                Column() {
                  Text('月柱')
                    .fontSize(11)
                    .fontColor('#8B7355')
                  Text(this.analysis.calendar.month_gan)
                    .fontSize(20)
                    .fontColor('#8B0000')
                    .fontWeight(FontWeight.Bold)
                  Text(this.analysis.calendar.month_zhi)
                    .fontSize(20)
                    .fontColor('#4A3728')
                    .fontWeight(FontWeight.Bold)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Center)

                // 日柱
                Column() {
                  Text('日柱')
                    .fontSize(11)
                    .fontColor('#8B7355')
                  Text(this.analysis.calendar.day_gan)
                    .fontSize(20)
                    .fontColor('#8B0000')
                    .fontWeight(FontWeight.Bold)
                  Text(this.analysis.calendar.day_zhi)
                    .fontSize(20)
                    .fontColor('#4A3728')
                    .fontWeight(FontWeight.Bold)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Center)

                // 时柱
                Column() {
                  Text('时柱')
                    .fontSize(11)
                    .fontColor('#8B7355')
                  Text(this.analysis.calendar.hour_gan)
                    .fontSize(20)
                    .fontColor('#8B0000')
                    .fontWeight(FontWeight.Bold)
                  Text(this.analysis.calendar.hour_zhi)
                    .fontSize(20)
                    .fontColor('#4A3728')
                    .fontWeight(FontWeight.Bold)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Center)
              }
              .width('100%')
              .padding({ top: 12, bottom: 12 })
              .backgroundColor('#FFF9F0')
              .borderRadius(8)
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFEF9')
            .borderRadius(12)
            .margin({ top: 12, left: 12, right: 12 })

            // Tab分页导航
            Row() {
              ForEach(['[定性]', '[定量]', '[流年]'], (tab: string, index: number) => {
                Text(tab)
                  .fontSize(14)
                  .fontWeight(this.currentTabIndex === index ? FontWeight.Bold : FontWeight.Normal)
                  .fontColor(this.currentTabIndex === index ? '#8B0000' : '#8B7355')
                  .padding({ left: 16, right: 16, top: 8, bottom: 8 })
                  .backgroundColor(this.currentTabIndex === index ? '#FFF9F0' : 'transparent')
                  .borderRadius(16)
                  .onClick(() => {
                    this.currentTabIndex = index;
                  })
              })
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceEvenly)
            .padding({ top: 8, bottom: 8 })
            .margin({ top: 12, left: 12, right: 12 })
            .backgroundColor('#FFFEF9')
            .borderRadius(12)

            // ========== Tab0: 定性分析 ==========
            if (this.currentTabIndex === 0) {

            // 元气图 - 生年得之大吉
            if (this.analysis.benMing !== null) {
              Column() {
                Row() {
                  Divider()
                    .vertical(true)
                    .height(16)
                    .strokeWidth(3)
                    .color('#D4AF37')
                    .margin({ right: 8 })
                  Text('元气图 · 生年得之大吉')
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#4A3728')
                }
                .width('100%')
                .margin({ bottom: 8 })

                Text(`生年地支「${this.analysis.calendar.year_zhi}」落于「${this.analysis.benMing.gua}卦」，五行属${this.analysis.benMing.element}，数理${this.analysis.benMing.number}`)
                  .fontSize(13)
                  .fontColor('#8B7355')
                  .margin({ bottom: 12 })

                // 八卦图（元气图）
                BaguaChart({
                  title: '',
                  highlightGua: this.analysis.benMing.gua,
                  activeGuaList: [],
                  showDetail: $showGuaDetail,
                  selectedGua: $selectedGua
                })
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFEF9')
              .borderRadius(12)
              .margin({ top: 12, left: 12, right: 12 })
            }

            // 化工之图 - 生月
            if (this.analysis.huagong !== null) {
              Column() {
                Row() {
                  Divider()
                    .vertical(true)
                    .height(16)
                    .strokeWidth(3)
                    .color('#D4AF37')
                    .margin({ right: 8 })
                  Text('化工之图 · 生月得令')
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#4A3728')
                }
                .width('100%')
                .margin({ bottom: 8 })

                Text(`生月地支「${this.analysis.calendar.month_zhi}」，当令五行「${this.analysis.huagong.seasonElement}」`)
                  .fontSize(13)
                  .fontColor('#8B7355')

                Row() {
                  Text('化工结果：')
                    .fontSize(13)
                    .fontColor('#8B7355')
                  Text(`${this.analysis.huagong.type}`)
                    .fontSize(14)
                    .fontColor(this.analysis.huagong.luck === '大吉' || this.analysis.huagong.luck === '吉' ? '#228B22' :
                      this.analysis.huagong.luck === '凶' ? '#B22222' : '#4A3728')
                    .fontWeight(FontWeight.Medium)
                  Text(` (${this.analysis.huagong.luck})`)
                    .fontSize(13)
                    .fontColor('#8B7355')
                }
                .margin({ top: 4, bottom: 12 })

                // 八卦图（化工图）
                BaguaChart({
                  title: '',
                  highlightGua: this.analysis.benMing?.gua || '',
                  activeGuaList: this.getActiveGuaList(),
                  showDetail: $showGuaDetail,
                  selectedGua: $selectedGua
                })

                // 化工说明
                Text(this.analysis.huagong.desc)
                  .fontSize(13)
                  .fontColor('#4A3728')
                  .margin({ top: 12 })
                  .lineHeight(20)
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFEF9')
              .borderRadius(12)
              .margin({ top: 12, left: 12, right: 12 })
            }

            // 游年图 - 八方吉凶
            if (this.younianAnalysis.relations.length > 0) {
              Column() {
                Row() {
                  Divider()
                    .vertical(true)
                    .height(16)
                    .strokeWidth(3)
                    .color('#D4AF37')
                    .margin({ right: 8 })
                  Text('游年图 · 八方吉凶指南')
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#4A3728')
                }
                .width('100%')
                .margin({ bottom: 8 })

                Text(`本命卦「${this.younianAnalysis.benMingGua}卦」遇八方各有吉凶，点击方位查看详情`)
                  .fontSize(13)
                  .fontColor('#8B7355')
                  .margin({ bottom: 12 })

                // 游年八卦图
                YouNianChart({
                  younianAnalysis: this.younianAnalysis,
                  onGuaClick: (rel: YouNianRelation) => {
                    this.selectedYounianRel = rel;
                    this.showYounianDetail = true;
                  }
                })

                // 吉方推荐
                if (this.younianAnalysis.jiList.length > 0) {
                  Column() {
                    Text('【吉方推荐】')
                      .fontSize(13)
                      .fontColor('#228B22')
                      .fontWeight(FontWeight.Medium)
                      .margin({ bottom: 4 })
                    ForEach(this.younianAnalysis.jiList, (rel: YouNianRelation) => {
                      Row() {
                        Text(`★ ${rel.direction}(${rel.targetGua}) - ${rel.star}：`)
                          .fontSize(12)
                          .fontColor('#4A3728')
                        Text(rel.starInfo?.desc || '')
                          .fontSize(12)
                          .fontColor('#8B7355')
                      }
                      .width('100%')
                      .margin({ top: 2 })
                    })
                  }
                  .width('100%')
                  .alignItems(HorizontalAlign.Start)
                  .margin({ top: 12 })
                  .padding(8)
                  .backgroundColor('#F0FFF0')
                  .borderRadius(6)
                }

                // 凶方提示
                if (this.younianAnalysis.xiongList.length > 0) {
                  Column() {
                    Text('【凶方提示】')
                      .fontSize(13)
                      .fontColor('#B22222')
                      .fontWeight(FontWeight.Medium)
                      .margin({ bottom: 4 })
                    ForEach(this.younianAnalysis.xiongList, (rel: YouNianRelation) => {
                      Row() {
                        Text(`⚠ ${rel.direction}(${rel.targetGua}) - ${rel.star}：`)
                          .fontSize(12)
                          .fontColor('#4A3728')
                        Text(rel.starInfo?.desc || '')
                          .fontSize(12)
                          .fontColor('#8B7355')
                      }
                      .width('100%')
                      .margin({ top: 2 })
                    })
                  }
                  .width('100%')
                  .alignItems(HorizontalAlign.Start)
                  .margin({ top: 8 })
                  .padding(8)
                  .backgroundColor('#FFF5EE')
                  .borderRadius(6)
                }
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFEF9')
              .borderRadius(12)
              .margin({ top: 12, left: 12, right: 12 })
            }
            } // 结束Tab0定性分析

            // ========== Tab1: 定量分析 ==========
            if (this.currentTabIndex === 1) {

            // 求数法 - 河洛数理密码
            if (this.qiushuAnalysis.pillars.length > 0) {
              Column() {
                Row() {
                  Divider()
                    .vertical(true)
                    .height(16)
                    .strokeWidth(3)
                    .color('#D4AF37')
                    .margin({ right: 8 })
                  Text('求数法 · 河洛数理密码')
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#4A3728')
                }
                .width('100%')
                .margin({ bottom: 8 })

                Text('天干用河图数(1-10)，地支用洛书数(1-12)。奇数为阳属左，偶数为阴属右。')
                  .fontSize(12)
                  .fontColor('#8B7355')
                  .margin({ bottom: 12 })

                // 求数法图表
                QiuShuChart({
                  qiushuAnalysis: this.qiushuAnalysis
                })
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFEF9')
              .borderRadius(12)
              .margin({ top: 12, left: 12, right: 12 })
            }

            // A法：正统成卦法（先天命卦）
            if (this.zhengTongGua.mingGua.name !== '') {
              Column() {
                Row() {
                  Divider()
                    .vertical(true)
                    .height(16)
                    .strokeWidth(3)
                    .color('#8B4513')
                    .margin({ right: 8 })
                  Text('成卦法A · 天地余数合成重卦')
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#4A3728')
                }
                .width('100%')
                .margin({ bottom: 12 })

                ZhengTongGuaChart({
                  result: this.zhengTongGua
                })
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFEF9')
              .borderRadius(12)
              .margin({ top: 12, left: 12, right: 12 })
            }

            // B法：年干起卦+动爻法（后天命盘）
            if (this.nianGanGua.benMingGua.name !== '') {
              Column() {
                Row() {
                  Divider()
                    .vertical(true)
                    .height(16)
                    .strokeWidth(3)
                    .color('#1E4D8C')
                    .margin({ right: 8 })
                  Text('成卦法B · 年干起卦+动爻变卦')
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#4A3728')
                }
                .width('100%')
                .margin({ bottom: 12 })

                NianGanGuaChart({
                  result: this.nianGanGua
                })
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFEF9')
              .borderRadius(12)
              .margin({ top: 12, left: 12, right: 12 })
            }

            // 体用综合分析
            if (this.tiYongResult.combinedResult !== '') {
              Column() {
                Row() {
                  Divider()
                    .vertical(true)
                    .height(16)
                    .strokeWidth(3)
                    .color('#4A0080')
                    .margin({ right: 8 })
                  Text('体用合参 · 综合断事')
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#4A3728')
                }
                .width('100%')
                .margin({ bottom: 12 })

                TiYongAnalysis({
                  tiYong: this.tiYongResult,
                  zhengTong: this.zhengTongGua,
                  nianGan: this.nianGanGua
                })
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFEF9')
              .borderRadius(12)
              .margin({ top: 12, left: 12, right: 12 })
            }
            } // 结束Tab1定量分析

            // ========== Tab2: 流年运势 ==========
            if (this.currentTabIndex === 2) {

            // 定元堂式 - 命主在卦中的位置
            if (this.yuanTangInfo.yaoPosition > 0) {
              Column() {
                Row() {
                  Divider()
                    .vertical(true)
                    .height(16)
                    .strokeWidth(3)
                    .color('#8B4513')
                    .margin({ right: 8 })
                  Text('定元堂式 · 命主定位')
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#4A3728')
                }
                .width('100%')
                .margin({ bottom: 12 })

                Text(`出生时辰「${this.yuanTangInfo.shichenName}」元堂在「${this.yuanTangInfo.yaoName}」`)
                  .fontSize(14)
                  .fontColor('#4A3728')
                  .margin({ bottom: 8 })

                Row() {
                  Text('爻位含义：')
                    .fontSize(13)
                    .fontColor('#8B7355')
                  Text(this.yuanTangInfo.meaning)
                    .fontSize(13)
                    .fontColor('#4A3728')
                }
                .margin({ bottom: 4 })

                Row() {
                  Text('计算规则：')
                    .fontSize(13)
                    .fontColor('#8B7355')
                  Text(this.yuanTangInfo.calcRule || '杂卦阴阳循环')
                    .fontSize(13)
                    .fontColor('#8B7355')
                }
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFEF9')
              .borderRadius(12)
              .margin({ top: 12, left: 12, right: 12 })
            }

            // 起日卦 - 今日运势
            if (this.liuRiGua.dayZhi !== '') {
              Column() {
                Row() {
                  Divider()
                    .vertical(true)
                    .height(16)
                    .strokeWidth(3)
                    .color('#FF8C00')
                    .margin({ right: 8 })
                  Text('起日卦 · 今日运势')
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#4A3728')
                }
                .width('100%')
                .margin({ bottom: 12 })

                Row() {
                  Column() {
                    Text('日支')
                      .fontSize(12)
                      .fontColor('#8B7355')
                    Text(this.liuRiGua.dayZhi)
                      .fontSize(24)
                      .fontColor('#8B0000')
                      .fontWeight(FontWeight.Bold)
                  }
                  .layoutWeight(1)

                  Column() {
                    Text('日卦')
                      .fontSize(12)
                      .fontColor('#8B7355')
                    Text(this.liuRiGua.dayGua)
                      .fontSize(24)
                      .fontColor('#4A3728')
                      .fontWeight(FontWeight.Bold)
                  }
                  .layoutWeight(1)

                  Column() {
                    Text('动爻')
                      .fontSize(12)
                      .fontColor('#8B7355')
                    Text(this.liuRiGua.dongYaoName)
                      .fontSize(24)
                      .fontColor('#1E90FF')
                      .fontWeight(FontWeight.Bold)
                  }
                  .layoutWeight(1)

                  Column() {
                    Text('五行')
                      .fontSize(12)
                      .fontColor('#8B7355')
                    Text(this.liuRiGua.wuxingRelation)
                      .fontSize(20)
                      .fontColor(this.liuRiGua.luck === '吉' ? '#228B22' : this.liuRiGua.luck === '凶' ? '#B22222' : '#4A3728')
                      .fontWeight(FontWeight.Medium)
                  }
                  .layoutWeight(1)
                }
                .width('100%')
                .padding({ top: 8, bottom: 8 })
                .backgroundColor('#FFF9F0')
                .borderRadius(8)

                Text(this.liuRiGua.desc)
                  .fontSize(13)
                  .fontColor('#4A3728')
                  .margin({ top: 12 })
                  .lineHeight(20)
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFEF9')
              .borderRadius(12)
              .margin({ top: 12, left: 12, right: 12 })
            }

            // 起月卦 - 12月流月运势
            if (this.liuYueGuaList.length > 0) {
              Column() {
                Row() {
                  Divider()
                    .vertical(true)
                    .height(16)
                    .strokeWidth(3)
                    .color('#9370DB')
                    .margin({ right: 8 })
                  Text('起月卦 · 流月运势')
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#4A3728')
                }
                .width('100%')
                .margin({ bottom: 12 })

                Text('元堂爻位逐月移动，配合月卦五行生克断吉凶')
                  .fontSize(12)
                  .fontColor('#8B7355')
                  .margin({ bottom: 8 })

                // 月份列表
                Grid() {
                  ForEach(this.liuYueGuaList, (item: LiuYueGuaInfo) => {
                    GridItem() {
                      Column() {
                        Text(`${item.month}月`)
                          .fontSize(12)
                          .fontColor('#8B7355')
                        Text(item.monthGua)
                          .fontSize(16)
                          .fontColor('#4A3728')
                          .fontWeight(FontWeight.Medium)
                        Text(item.luck)
                          .fontSize(12)
                          .fontColor(item.luck === '吉' ? '#228B22' : item.luck === '凶' ? '#B22222' : '#8B7355')
                      }
                      .padding(6)
                      .backgroundColor(item.luck === '吉' ? '#F0FFF0' : item.luck === '凶' ? '#FFF5F5' : '#FAFAFA')
                      .borderRadius(6)
                    }
                  })
                }
                .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr')
                .rowsGap(8)
                .columnsGap(8)
                .width('100%')
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFEF9')
              .borderRadius(12)
              .margin({ top: 12, left: 12, right: 12 })
            }

            // 八卦相荡法 - 流年推演
            if (this.xiangDangResult.benMingGua.name !== '') {
              Column() {
                Row() {
                  Divider()
                    .vertical(true)
                    .height(16)
                    .strokeWidth(3)
                    .color('#1E90FF')
                    .margin({ right: 8 })
                  Text('八卦相荡 · 流年推演')
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#4A3728')
                }
                .width('100%')
                .margin({ bottom: 12 })

                XiangDangChart({ result: this.xiangDangResult })
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFEF9')
              .borderRadius(12)
              .margin({ top: 12, left: 12, right: 12 })
            }

            // 六亲纳甲表格 - 当前流年卦六亲旺衰
            if (this.naJiaPan.yaoList.length > 0) {
              Column() {
                Row() {
                  Divider()
                    .vertical(true)
                    .height(16)
                    .strokeWidth(3)
                    .color('#2F4F4F')
                    .margin({ right: 8 })
                  Text('六亲纳甲 · 流年六爻旺衰')
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#4A3728')
                }
                .width('100%')
                .margin({ bottom: 12 })

                Text(`流年卦「${this.naJiaPan.guaName}」，属「${this.naJiaPan.gong}宫」，${this.getNaJiaTypeName(this.naJiaPan.type)}；世爻在「${this.getYaoName(this.naJiaPan.shiYao)}」，应爻在「${this.getYaoName(this.naJiaPan.yingYao)}」`)
                  .fontSize(12)
                  .fontColor('#8B7355')
                  .margin({ bottom: 8 })

                // 表头
                Row() {
                  Text('爻位')
                    .fontSize(12)
                    .fontColor('#8B7355')
                    .layoutWeight(1)
                  Text('纳支')
                    .fontSize(12)
                    .fontColor('#8B7355')
                    .layoutWeight(1)
                  Text('天干')
                    .fontSize(12)
                    .fontColor('#8B7355')
                    .layoutWeight(1)
                  Text('五行')
                    .fontSize(12)
                    .fontColor('#8B7355')
                    .layoutWeight(1)
                  Text('六亲')
                    .fontSize(12)
                    .fontColor('#8B7355')
                    .layoutWeight(1.2)
                  Text('世/应')
                    .fontSize(12)
                    .fontColor('#8B7355')
                    .layoutWeight(1)
                  Text('旺衰')
                    .fontSize(12)
                    .fontColor('#8B7355')
                    .layoutWeight(1.2)
                }
                .width('100%')
                .padding({ top: 6, bottom: 6, left: 8, right: 8 })
                .backgroundColor('#FFF9F0')
                .borderRadius(6)

                // 六爻明细，从上爻到初爻
                Column() {
                  ForEach(this.naJiaPan.yaoList.slice().reverse(), (item: YaoWithNaJia) => {
                    Row() {
                      Text(this.getYaoName(item.index))
                        .fontSize(13)
                        .fontColor('#4A3728')
                        .layoutWeight(1)
                      Text(item.zhi)
                        .fontSize(13)
                        .fontColor('#4A3728')
                        .layoutWeight(1)
                      Text(item.gan)
                        .fontSize(13)
                        .fontColor('#4A3728')
                        .layoutWeight(1)
                      Text(item.element)
                        .fontSize(13)
                        .fontColor('#4A3728')
                        .layoutWeight(1)
                      Text(item.liuQin || '-')
                        .fontSize(13)
                        .fontColor(this.getLiuQinColor(item.liuQin))
                        .layoutWeight(1.2)
                      Text(item.isShi ? '世' : item.isYing ? '应' : '')
                        .fontSize(13)
                        .fontColor(item.isShi || item.isYing ? '#8B0000' : '#8B7355')
                        .layoutWeight(1)
                      Text(item.wangShuai || '')
                        .fontSize(13)
                        .fontColor(this.getWangShuaiColor(item.wangShuai))
                        .layoutWeight(1.2)
                    }
                    .width('100%')
                    .padding({ top: 4, bottom: 4, left: 8, right: 8 })
                  })
                }
                .width('100%')
                .backgroundColor('#FFFEF9')
                .borderRadius(6)
                .margin({ top: 4 })

                Text('以日干为我，六爻纳甲为用：同我为兄弟，我生为子孙，生我为父母，我克为妻财，克我为官鬼；再结合节气旺衰判断每一爻的发力轻重。')
                  .fontSize(12)
                  .fontColor('#8B7355')
                  .margin({ top: 10 })
                  .lineHeight(18)
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFEF9')
              .borderRadius(12)
              .margin({ top: 12, left: 12, right: 12 })
            }

            // 小象行年 - 当前岁数运势
            if (this.xiaoXiangResult.age > 0) {
              Column() {
                Row() {
                  Divider()
                    .vertical(true)
                    .height(16)
                    .strokeWidth(3)
                    .color('#DC143C')
                    .margin({ right: 8 })
                  Text('小象行年 · 流年卦气')
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#4A3728')
                }
                .width('100%')
                .margin({ bottom: 12 })

                Text(`虚岁${this.xiaoXiangResult.age}岁，当前运势在「${this.xiaoXiangResult.currentYaoName}」`)
                  .fontSize(14)
                  .fontColor('#4A3728')
                  .margin({ bottom: 12 })

                // 小象断语
                Column() {
                  Row() {
                    Text('爻辞：')
                      .fontSize(13)
                      .fontColor('#8B7355')
                    Text(this.xiaoXiangResult.yaoCi)
                      .fontSize(14)
                      .fontColor('#4A3728')
                      .fontWeight(FontWeight.Medium)
                  }
                  .width('100%')
                  .margin({ bottom: 6 })

                  Row() {
                    Text('小象：')
                      .fontSize(13)
                      .fontColor('#8B7355')
                    Text(this.xiaoXiangResult.xiaoXiang)
                      .fontSize(14)
                      .fontColor('#4A3728')
                  }
                  .width('100%')
                  .margin({ bottom: 6 })

                  Row() {
                    Text('吉凶：')
                      .fontSize(13)
                      .fontColor('#8B7355')
                    Text(this.xiaoXiangResult.luck)
                      .fontSize(16)
                      .fontColor(this.xiaoXiangResult.luck === '大吉' || this.xiaoXiangResult.luck === '吉' ? '#228B22' :
                        this.xiaoXiangResult.luck === '凶' ? '#B22222' : '#4A3728')
                      .fontWeight(FontWeight.Bold)
                  }
                  .width('100%')
                }
                .width('100%')
                .padding(12)
                .backgroundColor('#FFF9F0')
                .borderRadius(8)

                // 建议
                Text(this.xiaoXiangResult.advice)
                  .fontSize(13)
                  .fontColor('#4A3728')
                  .margin({ top: 12 })
                  .lineHeight(20)
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFEF9')
              .borderRadius(12)
              .margin({ top: 12, left: 12, right: 12 })
            }
            } // 结束Tab2流年运势

            // 化工相反之图 - 反局检测（放在所有Tab外作为警告）
            if (this.analysis.fanju !== null) {
              Column() {
                Row() {
                  Divider()
                    .vertical(true)
                    .height(16)
                    .strokeWidth(3)
                    .color(this.analysis.fanju.triggered ? '#B22222' : '#D4AF37')
                    .margin({ right: 8 })
                  Text('化工相反之图 · 反局检测')
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#4A3728')
                }
                .width('100%')
                .margin({ bottom: 12 })

                Row() {
                  if (this.analysis.fanju.triggered) {
                    Text('⚠')
                      .fontSize(18)
                      .fontColor('#B22222')
                    Text(' 触发反局')
                      .fontSize(15)
                      .fontColor('#B22222')
                      .fontWeight(FontWeight.Medium)
                  } else {
                    Text('✓')
                      .fontSize(18)
                      .fontColor('#228B22')
                    Text(' 无反局')
                      .fontSize(15)
                      .fontColor('#228B22')
                      .fontWeight(FontWeight.Medium)
                  }
                }
                .margin({ bottom: 8 })

                Text(this.analysis.fanju.desc)
                  .fontSize(13)
                  .fontColor('#4A3728')
                  .lineHeight(20)
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FFFEF9')
              .borderRadius(12)
              .border({ width: 1, color: this.analysis.fanju.triggered ? '#B22222' : '#E8DCC8' })
              .margin({ top: 12, left: 12, right: 12 })
            }

            // 综合评估
            Column() {
              Row() {
                Divider()
                  .vertical(true)
                  .height(16)
                  .strokeWidth(3)
                  .color('#D4AF37')
                  .margin({ right: 8 })
                Text('综合评估')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#4A3728')
              }
              .width('100%')
              .margin({ bottom: 12 })

              Text(this.analysis.summary)
                .fontSize(14)
                .fontColor('#4A3728')
                .lineHeight(22)
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFEF9')
            .borderRadius(12)
            .border({ width: 2, color: '#D4AF37' })
            .margin({ top: 12, left: 12, right: 12, bottom: 24 })
          }
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .backgroundColor('#FDF8F0')
      .align(Alignment.Top)
    }
    .width('100%')
    .height('100%')
    .bindSheet($$this.showGuaDetail, this.GuaDetailSheet(), {
      height: SheetSize.FIT_CONTENT,
      backgroundColor: '#FFFEF9',
      showClose: true
    })
    .bindSheet($$this.showYounianDetail, this.YouNianDetailSheet(), {
      height: SheetSize.FIT_CONTENT,
      backgroundColor: '#FFFEF9',
      showClose: true
    })

      // 历史记录弹窗
      if (this.showHistoryDialog) {
        Column() {
          Column() {
            this.HistoryDialogSheet()
          }
          .width('90%')
          .backgroundColor('#FFFEF9')
          .borderRadius(16)
          .shadow({ radius: 20, color: '#00000030' })
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#00000080')
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.showHistoryDialog = false;
        })
      }

      // 术语解释弹窗
      if (this.showTermDialog) {
        Column() {
          Column() {
            this.TermDialogSheet()
          }
          .width('90%')
          .backgroundColor('#FFFEF9')
          .borderRadius(16)
          .shadow({ radius: 20, color: '#00000030' })
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#00000080')
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.showTermDialog = false;
        })
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  YouNianDetailSheet() {
    Column() {
      // 标题
      Row() {
        Text(this.selectedYounianRel.star)
          .fontSize(28)
          .fontColor(this.getStarColor(this.selectedYounianRel.starInfo?.luck || ''))
          .fontWeight(FontWeight.Bold)
        Column() {
          Text(`${this.selectedYounianRel.direction} · ${this.selectedYounianRel.targetGua}卦`)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#4A3728')
          Text(this.selectedYounianRel.starInfo?.luck || '')
            .fontSize(14)
            .fontColor(this.getStarColor(this.selectedYounianRel.starInfo?.luck || ''))
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 16 })
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .margin({ bottom: 20 })

      // 五行属性
      Row() {
        Text('五行：')
          .fontSize(14)
          .fontColor('#8B7355')
        Text(this.selectedYounianRel.starInfo?.element || '')
          .fontSize(16)
          .fontColor('#4A3728')
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
      .margin({ bottom: 12 })

      // 详细描述
      Column() {
        Text('详细说明：')
          .fontSize(14)
          .fontColor('#8B7355')
          .margin({ bottom: 8 })
        Text(this.selectedYounianRel.starInfo?.desc || '')
          .fontSize(14)
          .fontColor('#4A3728')
          .lineHeight(22)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .margin({ bottom: 16 })

      // 应用建议
      Column() {
        Divider().color('#E8DCC8').margin({ bottom: 12 })
        Text('应用建议：')
          .fontSize(14)
          .fontColor('#D4AF37')
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: 8 })
        Text(this.getYounianAdvice(this.selectedYounianRel.star))
          .fontSize(13)
          .fontColor('#4A3728')
          .lineHeight(20)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(24)
  }

  getStarColor(luck: string): string {
    if (luck === '大吉') return '#D4AF37';
    if (luck === '中吉') return '#228B22';
    if (luck === '小吉') return '#32CD32';
    if (luck === '大凶') return '#8B0000';
    if (luck === '次凶') return '#B22222';
    if (luck === '小凶') return '#CD853F';
    return '#666666';
  }

  getYounianAdvice(starName: string): string {
    const advices = new Map<string, string>([
      ['生气', '此方位大吉，适合起居、办公、开店。人际关系中遇此卦人，合作順利，事业兴旺。'],
      ['天医', '此方位吉利，适合养生康复，常得贵人相助。身体欠佳时，可朝此方寻医问药。'],
      ['延年', '此方位主和美缘分，适合姻姻交友。合作、婚姻之事遇此卦人，长久和睦。'],
      ['伏位', '此方位主平稳，守成则吉，求变则难。适合保持现状，蓄势待发。'],
      ['绝命', '此方位大凶，宜回避，不宜久留。重大决策、资产配置应避开此方。'],
      ['五鬼', '此方位主口舌是非，小人作祖。应避免在此方位谈判或签约，防火灾。'],
      ['六煞', '此方位主桃花纠纷，反复无常。感情、合作不宜在此方位定局，易生变数。'],
      ['祸害', '此方位主耗损，身体易走弱。不宜在此方进行健康相关活动，防小人。']
    ]);
    return advices.get(starName) || '暂无详细建议';
  }

  getYaoName(index: number): string {
    const names: string[] = ['初爻', '二爻', '三爻', '四爻', '五爻', '上爻'];
    if (index >= 1 && index <= 6) {
      return names[index - 1];
    }
    return '';
  }

  getNaJiaTypeName(type: string): string {
    switch (type) {
      case 'pure':
        return '八纯卦';
      case 'one_shi':
        return '一世卦';
      case 'two_shi':
        return '二世卦';
      case 'three_shi':
        return '三世卦';
      case 'four_shi':
        return '四世卦';
      case 'five_shi':
        return '五世卦';
      case 'you_hun':
        return '游魂卦';
      case 'gui_hun':
        return '归魂卦';
      default:
        return '';
    }
  }

  getLiuQinColor(liuQin: string): string {
    if (liuQin === '官鬼') return '#B22222';
    if (liuQin === '妻财') return '#8B4513';
    if (liuQin === '子孙') return '#228B22';
    if (liuQin === '父母') return '#1E90FF';
    if (liuQin === '兄弟') return '#4A3728';
    return '#4A3728';
  }

  getWangShuaiColor(type: string): string {
    if (type === '生助' || type === '比助') return '#228B22';
    if (type === '克制') return '#B22222';
    if (type === '克财' || type === '泄耗') return '#CD853F';
    return '#4A3728';
  }

  @Builder
  GuaDetailSheet() {
    Column() {
      // 标题
      Row() {
        Text(this.selectedGua.symbol)
          .fontSize(48)
          .fontColor('#8B0000')
        Column() {
          Text(`${this.selectedGua.name}卦`)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#4A3728')
          Text(`${this.selectedGua.direction} · ${this.selectedGua.element}`)
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
        Text(`${this.selectedGua.number}`)
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
        Text(this.selectedGua.tiangan.length > 0 ? this.selectedGua.tiangan.join('、') : '-')
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
        Text(this.selectedGua.dizhi.length > 0 ? this.selectedGua.dizhi.join('、') : '-')
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
        Text(this.selectedGua.desc)
          .fontSize(14)
          .fontColor('#4A3728')
          .lineHeight(22)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .margin({ bottom: 16 })

      // 纳甲原理
      Column() {
        Divider().color('#E8DCC8').margin({ bottom: 12 })
        Text('纳甲原理：')
          .fontSize(14)
          .fontColor('#D4AF37')
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: 8 })
        Text(this.getNajiaPrinciple(this.selectedGua.name))
          .fontSize(13)
          .fontColor('#4A3728')
          .lineHeight(20)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(24)
  }

  getNajiaPrinciple(guaName: string): string {
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
    return principles.get(guaName) || '暂无详细说明';
  }

  @Builder
  HistoryDialogSheet() {
    Column() {
      // 标题
      Text('📜 排盘历史')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#8B0000')
        .margin({ bottom: 16 })

      if (this.historyList.length === 0) {
        Column() {
          Text('📄')
            .fontSize(48)
            .margin({ bottom: 12 })
          Text('暂无历史记录')
            .fontSize(14)
            .fontColor('#8B7355')
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center)
      } else {
        Scroll() {
          Column() {
            ForEach(this.historyList, (item: PaipanRecord) => {
              Column() {
                Row() {
                  Column() {
                    Text(item.name)
                      .fontSize(15)
                      .fontColor('#4A3728')
                      .fontWeight(FontWeight.Medium)
                    Text(`${item.lunarDate} · ${SHICHEN_NAMES[item.shichenIndex]}时`)
                      .fontSize(12)
                      .fontColor('#8B7355')
                      .margin({ top: 4 })
                    Text(`元气：${item.benMingGua}卦`)
                      .fontSize(12)
                      .fontColor('#D4AF37')
                      .margin({ top: 4 })
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)

                  Column() {
                    Button('加载')
                      .fontSize(12)
                      .width(50)
                      .height(28)
                      .backgroundColor('#8B7355')
                      .onClick(() => {
                        this.loadHistoryRecord(item);
                      })
                    Button('删除')
                      .fontSize(12)
                      .width(50)
                      .height(28)
                      .backgroundColor('#CD853F')
                      .margin({ top: 6 })
                      .onClick(() => {
                        this.deleteHistory(item.id);
                      })
                  }
                }
                .width('100%')
                .padding(14)
                .backgroundColor('#FFFEF9')
                .borderRadius(10)
                .border({ width: 1, color: '#E8DCC8' })
              }
              .width('100%')
              .margin({ bottom: 10 })
            })
          }
        }
        .width('100%')
        .height(400)
      }
    }
    .width('100%')
    .padding(20)
  }

  @Builder
  TermDialogSheet() {
    Column() {
      if (this.selectedTerm) {
        // 标题
        Text(`📖 ${this.selectedTerm.term}`)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#8B0000')
          .margin({ bottom: 12 })

        Scroll() {
          Column() {
            // 分类
            Row() {
              Text(`【${this.selectedTerm.category}】`)
                .fontSize(12)
                .fontColor('#FFFFFF')
                .backgroundColor('#D4AF37')
                .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                .borderRadius(4)
            }
            .width('100%')
            .margin({ bottom: 12 })

            // 简述
            Text(this.selectedTerm.shortDesc)
              .fontSize(14)
              .fontColor('#8B7355')
              .lineHeight(22)
              .margin({ bottom: 16 })

            Divider().color('#E8DCC8').margin({ bottom: 16 })

            // 详细解释
            Column() {
              Text('详细解释：')
                .fontSize(14)
                .fontColor('#D4AF37')
                .fontWeight(FontWeight.Medium)
                .margin({ bottom: 8 })
              Text(this.selectedTerm.detailDesc)
                .fontSize(14)
                .fontColor('#4A3728')
                .lineHeight(24)
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .margin({ bottom: 16 })

            // 举例
            if (this.selectedTerm.example) {
              Column() {
                Text('举例说明：')
                  .fontSize(14)
                  .fontColor('#D4AF37')
                  .fontWeight(FontWeight.Medium)
                  .margin({ bottom: 8 })
                Text(this.selectedTerm.example)
                  .fontSize(13)
                  .fontColor('#8B7355')
                  .lineHeight(22)
                  .backgroundColor('#FFF9F0')
                  .padding(12)
                  .borderRadius(8)
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
              .margin({ bottom: 16 })
            }

            // 相关术语
            if (this.selectedTerm.relatedTerms.length > 0) {
              Column() {
                Text('相关术语：')
                  .fontSize(14)
                  .fontColor('#D4AF37')
                  .fontWeight(FontWeight.Medium)
                  .margin({ bottom: 8 })
                Flex({ wrap: FlexWrap.Wrap }) {
                  ForEach(this.selectedTerm.relatedTerms, (relatedTerm: string) => {
                    Text(relatedTerm)
                      .fontSize(12)
                      .fontColor('#8B7355')
                      .backgroundColor('#FFFEF9')
                      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                      .borderRadius(12)
                      .border({ width: 1, color: '#E8DCC8' })
                      .margin({ right: 8, bottom: 8 })
                  })
                }
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
            }
          }
        }
        .width('100%')
        .height(500)
      }
    }
    .width('100%')
    .padding(20)
  }
}
