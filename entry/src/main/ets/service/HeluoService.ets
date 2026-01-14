/**
 * 河洛真数 - 数据服务
 * 从 JSON 加载数据并进行命理分析
 */
import { util } from '@kit.ArkTS';
import {
  CalendarData,
  ZhengjuRule,
  FanjuRule,
  HuagongRule,
  HuagongRulesData,
  XiangfanRule,
  XiangfanRulesData,
  BenMingInfo,
  HuagongAnalysis,
  FanjuAnalysis,
  HeluoAnalysis,
  WuxingRelationResult,
  YouNianStar,
  YouNianRelation,
  YouNianAnalysis,
  PillarNumber,
  QiuShuAnalysis,
  DanGuaInfo,
  ChongGuaInfo,
  ZhengTongGuaResult,
  NianGanGuaResult,
  TiYongAnalysisResult,
  LiuNianGuaInfo,
  TiYongRelation,
  XiangDangResult,
  YuanTangInfo,
  LiuYueGuaInfo,
  LiuRiGuaInfo,
  XiaoXiangResult,
  XiaoXiangData,
  YaoWithNaJia,
  NaJiaPanResult,
  NaJiaGongRule,
  GuaShiYingRule,
  TermExplanation
} from '../model/HeluoModels';

// 卦象符号映射
const GUA_SYMBOLS: Map<string, string> = new Map([
  ['乾', '☰'], ['坤', '☷'], ['震', '☳'], ['巽', '☴'],
  ['坎', '☵'], ['离', '☲'], ['艮', '☶'], ['兑', '☱']
]);

// 五行到卦的映射
const WUXING_GUA_MAP: Map<string, string[]> = new Map([
  ['木', ['震', '巽']],
  ['火', ['离']],
  ['土', ['坤', '艮']],
  ['金', ['乾', '兑']],
  ['水', ['坎']]
]);

// 五行生关系
const WUXING_SHENG: Map<string, string> = new Map([
  ['木', '火'], ['火', '土'], ['土', '金'], ['金', '水'], ['水', '木']
]);

// 五行克关系
const WUXING_KE: Map<string, string> = new Map([
  ['木', '土'], ['土', '水'], ['水', '火'], ['火', '金'], ['金', '木']
]);

// 五行被生关系
const WUXING_BEISHENG: Map<string, string> = new Map([
  ['木', '水'], ['火', '木'], ['土', '火'], ['金', '土'], ['水', '金']
]);

// 五行被克关系
const WUXING_BEIKE: Map<string, string> = new Map([
  ['木', '金'], ['火', '水'], ['土', '木'], ['金', '火'], ['水', '土']
]);

// 节气顺序
const JIEQI_ORDER: string[] = [
  '小寒', '大寒', '立春', '雨水', '惊蛰', '春分',
  '清明', '谷雨', '立夏', '小满', '芒种', '夏至',
  '小暑', '大暑', '立秋', '处暑', '白露', '秋分',
  '寒露', '霜降', '立冬', '小雪', '大雪', '冬至'
];

// 十天干
const TIAN_GAN: string[] = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'];

// 十二地支
const DI_ZHI: string[] = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];

export class HeluoService {
  private context: Context;
  private zhengjuRules: ZhengjuRule[] = [];
  private fanjuRules: FanjuRule[] = [];
  private huagongRules: HuagongRulesData | null = null;
  private xiangfanRules: XiangfanRulesData | null = null;
  private calendarCache: Map<string, CalendarData[]> = new Map();
  private younianStars: YouNianStar[] = [];
  private younianRules: Map<string, YouNianRelation[]> = new Map();
  private naJiaGongRules: Map<string, NaJiaGongRule> = new Map();
  private guaShiYingMap: Map<string, GuaShiYingRule> = new Map();
  private liuQinMap: Map<string, string> = new Map();
  private naJiaLoaded: boolean = false;
  private guaShiYingLoaded: boolean = false;
  private liuQinLoaded: boolean = false;
  private termExplanations: Map<string, TermExplanation> = new Map();
  private termLoaded: boolean = false;

  constructor(context: Context) {
    this.context = context;
  }

  // 初始化：加载所有规则
  async initialize(): Promise<void> {
    await this.loadZhengjuRules();
    await this.loadFanjuRules();
    await this.loadHuagongRules();
    await this.loadXiangfanRules();
    await this.loadYounianRules();
  }

  // 加载正局规则
  private async loadZhengjuRules(): Promise<void> {
    try {
      const data = await this.loadRawFile('rules/zhengju_rules.json');
      const parsed = JSON.parse(data) as object[];
      this.zhengjuRules = parsed.map((item: object): ZhengjuRule => {
        const rule = new ZhengjuRule();
        const obj = item as Record<string, Object>;
        rule.gua = obj['gua'] as string;
        rule.number = obj['number'] as number;
        rule.element = obj['element'] as string;
        rule.dizhi = obj['dizhi'] as string[];
        rule.tiangan = obj['tiangan'] as string[] || [];
        rule.desc = obj['desc'] as string;
        return rule;
      });
    } catch (e) {
      console.error('加载正局规则失败:', JSON.stringify(e));
    }
  }

  // 加载反局规则
  private async loadFanjuRules(): Promise<void> {
    try {
      const data = await this.loadRawFile('rules/fanju_rules.json');
      const parsed = JSON.parse(data) as object[];
      this.fanjuRules = parsed.map((item: object): FanjuRule => {
        const rule = new FanjuRule();
        const obj = item as Record<string, Object>;
        rule.gua = obj['gua'] as string;
        rule.fan_gua = obj['fan_gua'] as string;
        rule.fan_element = obj['fan_element'] as string;
        rule.trigger_gan = obj['trigger_gan'] as string[];
        rule.trigger_zhi = obj['trigger_zhi'] as string[];
        rule.desc = obj['desc'] as string;
        return rule;
      });
    } catch (e) {
      console.error('加载反局规则失败:', JSON.stringify(e));
    }
  }

  // 加载化工规则
  private async loadHuagongRules(): Promise<void> {
    try {
      const data = await this.loadRawFile('rules/huagong_rules.json');
      const parsed = JSON.parse(data) as Record<string, Object>;
      this.huagongRules = new HuagongRulesData();
      this.huagongRules.description = parsed['description'] as string;
      const seasonalRules = parsed['seasonal_rules'] as object[];
      this.huagongRules.seasonal_rules = seasonalRules.map((item: object): HuagongRule => {
        const rule = new HuagongRule();
        const obj = item as Record<string, Object>;
        rule.element = obj['element'] as string;
        rule.gua = obj['gua'] as string[] || [];
        rule.type = obj['type'] as string;
        rule.months = obj['months'] as string[] || [];
        rule.days = obj['days'] as number || 0;
        rule.start_jieqi = obj['start_jieqi'] as string || '';
        rule.end_jieqi = obj['end_jieqi'] as string || '';
        rule.desc = obj['desc'] as string;
        return rule;
      });
    } catch (e) {
      console.error('加载化工规则失败:', JSON.stringify(e));
    }
  }

  // 加载化工相反规则
  private async loadXiangfanRules(): Promise<void> {
    try {
      const data = await this.loadRawFile('rules/huagong_xiangfan_rules.json');
      const parsed = JSON.parse(data) as Record<string, Object>;
      this.xiangfanRules = new XiangfanRulesData();
      this.xiangfanRules.description = parsed['description'] as string;
      this.xiangfanRules.principle = parsed['principle'] as string;
      const xiangfanRules = parsed['xiangfan_rules'] as object[];
      this.xiangfanRules.xiangfan_rules = xiangfanRules.map((item: object): XiangfanRule => {
        const rule = new XiangfanRule();
        const obj = item as Record<string, Object>;
        rule.gua = obj['gua'] as string[];
        rule.element = obj['element'] as string;
        rule.type = obj['type'] as string;
        rule.months = obj['months'] as string[] || [];
        rule.days = obj['days'] as number || 0;
        rule.start_jieqi = obj['start_jieqi'] as string || '';
        rule.end_jieqi = obj['end_jieqi'] as string || '';
        rule.zheng_element = obj['zheng_element'] as string;
        rule.desc = obj['desc'] as string;
        rule.symptom = obj['symptom'] as string;
        return rule;
      });
    } catch (e) {
      console.error('加载化工相反规则失败:', JSON.stringify(e));
    }
  }

  // 加载 rawfile 文件
  private async loadRawFile(path: string): Promise<string> {
    const resourceManager = this.context.resourceManager;
    const uint8Array = await resourceManager.getRawFileContent(path);
    const decoder = util.TextDecoder.create('utf-8');
    return decoder.decodeToString(uint8Array);
  }

  // 根据年份获取万年历文件编号
  private getCalendarFileIndex(year: number): string {
    const index = Math.floor((year - 1900) / 10) + 1;
    return index.toString().padStart(4, '0');
  }

  // 加载指定年份的万年历数据
  async loadCalendarData(year: number): Promise<CalendarData[]> {
    const fileIndex = this.getCalendarFileIndex(year);
    const cacheKey = fileIndex;

    if (this.calendarCache.has(cacheKey)) {
      return this.calendarCache.get(cacheKey)!;
    }

    try {
      const data = await this.loadRawFile(`calendar/calendar_data_${fileIndex}.json`);
      const parsed = JSON.parse(data) as object[];
      const calendarData = parsed.map((item: object): CalendarData => {
        const cal = new CalendarData();
        const obj = item as Record<string, Object>;
        cal.date = obj['date'] as string;
        cal.year = obj['year'] as number;
        cal.month = obj['month'] as number;
        cal.day = obj['day'] as number;
        cal.lunar_year = obj['lunar_year'] as number;
        cal.lunar_month = obj['lunar_month'] as number;
        cal.lunar_day = obj['lunar_day'] as number;
        cal.zodiac = obj['zodiac'] as string;
        cal.year_gan = obj['year_gan'] as string;
        cal.year_zhi = obj['year_zhi'] as string;
        cal.month_gan = obj['month_gan'] as string;
        cal.month_zhi = obj['month_zhi'] as string;
        cal.day_gan = obj['day_gan'] as string;
        cal.day_zhi = obj['day_zhi'] as string;
        cal.week_day = obj['week_day'] as number;
        cal.week_name = obj['week_name'] as string;
        cal.is_holiday = obj['is_holiday'] as number;
        cal.holiday_name = obj['holiday_name'] as string || '';
        cal.solar_term = obj['solar_term'] as string || '';
        cal.festivals = obj['festivals'] as string || '';
        return cal;
      });
      this.calendarCache.set(cacheKey, calendarData);
      return calendarData;
    } catch (e) {
      console.error(`加载万年历数据失败:`, JSON.stringify(e));
      return [];
    }
  }

  // 根据日期查找万年历数据
  async findCalendarByDate(year: number, month: number, day: number): Promise<CalendarData | null> {
    const calendarData = await this.loadCalendarData(year);
    const monthStr = month < 10 ? `0${month}` : `${month}`;
    const dayStr = day < 10 ? `0${day}` : `${day}`;
    const dateStr = `${year}-${monthStr}-${dayStr}`;
    for (const item of calendarData) {
      if (item.date === dateStr) {
        return item;
      }
    }
    return null;
  }

  // 查找最近的节气
  async findRecentSolarTerm(year: number, month: number, day: number): Promise<string> {
    const calendarData = await this.loadCalendarData(year);
    const monthStr = month < 10 ? `0${month}` : `${month}`;
    const dayStr = day < 10 ? `0${day}` : `${day}`;
    const dateStr = `${year}-${monthStr}-${dayStr}`;

    let foundTerm = '';
    for (const item of calendarData) {
      if (item.solar_term && item.solar_term !== '') {
        foundTerm = item.solar_term;
      }
      if (item.date === dateStr) {
        break;
      }
    }
    return foundTerm;
  }

  // 根据年支获取本命卦
  getBenMingGua(yearZhi: string): BenMingInfo | null {
    for (const rule of this.zhengjuRules) {
      if (rule.dizhi.includes(yearZhi)) {
        const info = new BenMingInfo();
        info.gua = rule.gua;
        info.guaSymbol = GUA_SYMBOLS.get(rule.gua) || '';
        info.number = rule.number;
        info.element = rule.element;
        info.desc = rule.desc;
        return info;
      }
    }
    return null;
  }

  // 检测反局
  checkFanju(yearGan: string, yearZhi: string, benMingGua: string): FanjuAnalysis {
    const result = new FanjuAnalysis();
    for (const rule of this.fanjuRules) {
      if (rule.gua === benMingGua &&
        (rule.trigger_gan.includes(yearGan) || rule.trigger_zhi.includes(yearZhi))) {
        result.triggered = true;
        result.desc = rule.desc;
        result.fanGua = rule.fan_gua;
        return result;
      }
    }

    result.triggered = false;
    result.desc = '生年干支与本命卦和谐，无先天冲突';
    result.fanGua = '';
    return result;
  }

  // 判断化工（得令分析）
  analyzeHuagong(benMingElement: string, monthZhi: string, solarTerm: string): HuagongAnalysis {
    const result = new HuagongAnalysis();

    if (!this.huagongRules) {
      result.type = '未知';
      result.luck = '未知';
      result.desc = '规则未加载';
      return result;
    }

    // 1. 检查是否得令
    for (const rule of this.huagongRules.seasonal_rules) {
      if (rule.element === benMingElement) {
        if (rule.type === '四季寄旺' && rule.months.length > 0) {
          if (rule.months.includes(monthZhi)) {
            result.type = '得令';
            result.luck = '大吉';
            result.desc = '元气充沛，如鱼得水';
            result.seasonElement = benMingElement;
            result.relation = '当令';
            return result;
          }
        }
        if (rule.type === '节气区间' && rule.start_jieqi && rule.end_jieqi) {
          if (this.isInJieqiRange(solarTerm, rule.start_jieqi, rule.end_jieqi)) {
            result.type = '得令';
            result.luck = '大吉';
            result.desc = '元气充沛，如鱼得水';
            result.seasonElement = benMingElement;
            result.relation = '当令';
            return result;
          }
        }
      }
    }

    // 2. 检查是否失令
    if (this.xiangfanRules) {
      for (const rule of this.xiangfanRules.xiangfan_rules) {
        const guaElement = this.getGuaElementFromList(rule.gua);
        if (guaElement === benMingElement) {
          if (rule.type === '四季篡位' && rule.months.length > 0) {
            if (rule.months.includes(monthZhi)) {
              result.type = '犯旺';
              result.luck = '凶';
              result.desc = rule.desc;
              result.seasonElement = rule.zheng_element;
              result.relation = '失令';
              return result;
            }
          }
          if (rule.type === '节气错乱' && rule.start_jieqi && rule.end_jieqi) {
            if (this.isInJieqiRange(solarTerm, rule.start_jieqi, rule.end_jieqi)) {
              result.type = '犯旺';
              result.luck = '凶';
              result.desc = rule.desc;
              result.seasonElement = rule.zheng_element;
              result.relation = '失令';
              return result;
            }
          }
        }
      }
    }

    // 3. 判断五行生克关系
    const seasonElement = this.getSeasonElement(solarTerm, monthZhi);
    const relationResult = this.getWuxingRelation(benMingElement, seasonElement);
    result.type = relationResult.type;
    result.luck = relationResult.luck;
    result.desc = relationResult.desc;
    result.seasonElement = seasonElement;
    result.relation = relationResult.relation;
    return result;
  }

  // 获取卦列表的五行
  private getGuaElementFromList(guaList: string[]): string {
    if (guaList.length === 0) return '';
    const firstGua = guaList[0];
    const entries = WUXING_GUA_MAP.entries();
    let entry = entries.next();
    while (!entry.done) {
      if (entry.value[1].includes(firstGua)) {
        return entry.value[0];
      }
      entry = entries.next();
    }
    return '';
  }

  // 判断是否在节气范围内
  private isInJieqiRange(current: string, start: string, end: string): boolean {
    const currentIdx = JIEQI_ORDER.indexOf(current);
    const startIdx = JIEQI_ORDER.indexOf(start);
    const endIdx = JIEQI_ORDER.indexOf(end);

    if (currentIdx < 0 || startIdx < 0 || endIdx < 0) return false;

    if (startIdx <= endIdx) {
      return currentIdx >= startIdx && currentIdx < endIdx;
    } else {
      return currentIdx >= startIdx || currentIdx < endIdx;
    }
  }

  // 根据节气/月支获取当令五行
  private getSeasonElement(solarTerm: string, monthZhi: string): string {
    const springTerms = ['春分', '清明', '谷雨', '立夏', '小满', '芒种'];
    const summerTerms = ['夏至', '小暑', '大暑', '立秋', '处暑', '白露'];
    const autumnTerms = ['秋分', '寒露', '霜降', '立冬', '小雪', '大雪'];
    const winterTerms = ['冬至', '小寒', '大寒', '立春', '雨水', '惊蛰'];

    if (springTerms.includes(solarTerm)) return '木';
    if (summerTerms.includes(solarTerm)) return '火';
    if (autumnTerms.includes(solarTerm)) return '金';
    if (winterTerms.includes(solarTerm)) return '水';

    const earthMonths = ['辰', '未', '戌', '丑'];
    if (earthMonths.includes(monthZhi)) return '土';

    return '木';
  }

  // 获取五行生克关系
  private getWuxingRelation(myElement: string, seasonElement: string): WuxingRelationResult {
    const result = new WuxingRelationResult();

    // 被生（印星）- 吉
    if (WUXING_BEISHENG.get(myElement) === seasonElement) {
      result.type = '生助';
      result.luck = '吉';
      result.desc = '有靠山贵人，身体强壮';
      result.relation = `${seasonElement}生${myElement}`;
      return result;
    }

    // 克他（财星）- 辛苦得财
    if (WUXING_KE.get(myElement) === seasonElement) {
      result.type = '克财';
      result.luck = '平';
      result.desc = '求财辛苦，需付出努力';
      result.relation = `${myElement}克${seasonElement}`;
      return result;
    }

    // 被克（官杀）- 看身强弱
    if (WUXING_BEIKE.get(myElement) === seasonElement) {
      result.type = '克制';
      result.luck = '看身强弱';
      result.desc = '身强则成器，身弱则受压';
      result.relation = `${seasonElement}克${myElement}`;
      return result;
    }

    // 生他（食伤）- 泄耗
    if (WUXING_SHENG.get(myElement) === seasonElement) {
      result.type = '泄耗';
      result.luck = '辛苦';
      result.desc = '才华外露但奔波劳碌';
      result.relation = `${myElement}生${seasonElement}`;
      return result;
    }

    // 同类（比劫）
    if (myElement === seasonElement) {
      result.type = '比助';
      result.luck = '平';
      result.desc = '同类相助，根基稳固';
      result.relation = '同类';
      return result;
    }

    result.type = '平';
    result.luck = '平';
    result.desc = '';
    result.relation = '';
    return result;
  }

  // 综合分析
  async analyze(year: number, month: number, day: number, shichenIndex: number = 6): Promise<HeluoAnalysis> {
    const result = new HeluoAnalysis();

    // 1. 获取万年历数据
    const calendar = await this.findCalendarByDate(year, month, day);
    if (!calendar) {
      result.summary = '未找到该日期的万年历数据';
      return result;
    }

    // 2. 计算时柱
    const hourZhi = DI_ZHI[shichenIndex];
    const hourGan = this.calculateHourGan(calendar.day_gan, shichenIndex);
    calendar.hour_gan = hourGan;
    calendar.hour_zhi = hourZhi;
    result.calendar = calendar;
    result.shichenIndex = shichenIndex;
    result.shichenName = `${hourZhi}时`;

    // 3. 查找最近节气
    const solarTerm = await this.findRecentSolarTerm(year, month, day);

    // 4. 获取本命卦
    const benMing = this.getBenMingGua(calendar.year_zhi);
    if (!benMing) {
      result.summary = '无法确定本命卦';
      return result;
    }
    result.benMing = benMing;

    // 5. 检测反局
    const fanju = this.checkFanju(calendar.year_gan, calendar.year_zhi, benMing.gua);
    result.fanju = fanju;

    // 6. 分析化工
    const huagong = this.analyzeHuagong(benMing.element, calendar.month_zhi, solarTerm);
    result.huagong = huagong;

    // 7. 计算综合评级
    let rating = 3;
    if (huagong.luck === '大吉') rating += 2;
    else if (huagong.luck === '吉') rating += 1;
    else if (huagong.luck === '凶') rating -= 1;

    if (fanju.triggered) rating -= 1;

    rating = Math.max(1, Math.min(5, rating));
    result.rating = rating;

    // 8. 生成总结
    result.summary = this.generateSummary(benMing, fanju, huagong, rating);

    return result;
  }

  // 根据日干和时辰计算时干（五鼠遁时法）
  private calculateHourGan(dayGan: string, shichenIndex: number): string {
    // 五鼠遁时法：
    // 甲己之日：甲子起时（时干从0开始）
    // 乙庚之日：丙子起时（时干从2开始）
    // 丙辛之日：戊子起时（时干从4开始）
    // 丁壬之日：庚子起时（时干从6开始）
    // 戊癸之日：壬子起时（时干从8开始）
    const dayGanIndex = TIAN_GAN.indexOf(dayGan);
    let startGanIndex = 0;

    if (dayGanIndex === 0 || dayGanIndex === 5) { // 甲、己
      startGanIndex = 0;
    } else if (dayGanIndex === 1 || dayGanIndex === 6) { // 乙、庚
      startGanIndex = 2;
    } else if (dayGanIndex === 2 || dayGanIndex === 7) { // 丙、辛
      startGanIndex = 4;
    } else if (dayGanIndex === 3 || dayGanIndex === 8) { // 丁、壬
      startGanIndex = 6;
    } else if (dayGanIndex === 4 || dayGanIndex === 9) { // 戊、癸
      startGanIndex = 8;
    }

    const hourGanIndex = (startGanIndex + shichenIndex) % 10;
    return TIAN_GAN[hourGanIndex];
  }

  // 生成总结文字
  private generateSummary(benMing: BenMingInfo, fanju: FanjuAnalysis, huagong: HuagongAnalysis, rating: number): string {
    const ratingTexts = ['', '凶', '平下', '平', '上吉', '大吉'];
    const ratingText = ratingTexts[rating] || '';
    let summary = `${benMing.gua}卦属${benMing.element}，数理${benMing.number}。`;

    if (fanju.triggered) {
      summary += `先天触发反局，需注意调和。`;
    }

    if (huagong.type === '得令') {
      summary += `生月得令，元气充沛。`;
    } else if (huagong.type === '犯旺') {
      summary += `生月失令，需后天调补。`;
    } else if (huagong.type === '生助') {
      summary += `月令生助，有贵人扶持。`;
    }

    summary += `综合评级：${ratingText}。`;
    return summary;
  }

  // 加载游年规则
  private async loadYounianRules(): Promise<void> {
    try {
      const data = await this.loadRawFile('rules/younian_rules.json');
      const parsed = JSON.parse(data) as Record<string, Object>;

      // 加载八星定义
      const stars = parsed['stars'] as object[];
      this.younianStars = stars.map((item: object): YouNianStar => {
        const star = new YouNianStar();
        const obj = item as Record<string, Object>;
        star.name = obj['name'] as string;
        star.element = obj['element'] as string;
        star.luck = obj['luck'] as string;
        star.desc = obj['desc'] as string;
        return star;
      });

      // 加载卦与方位的游年关系
      const rules = parsed['rules'] as object[];
      for (const ruleItem of rules) {
        const obj = ruleItem as Record<string, Object>;
        const guaName = obj['gua'] as string;
        const relations = obj['relations'] as object[];
        const relList: YouNianRelation[] = [];
        for (const relItem of relations) {
          const relObj = relItem as Record<string, Object>;
          const rel = new YouNianRelation();
          rel.targetGua = relObj['target'] as string;
          rel.star = relObj['star'] as string;
          rel.direction = relObj['direction'] as string;
          // 关联星详情
          rel.starInfo = this.getStarByName(rel.star);
          relList.push(rel);
        }
        this.younianRules.set(guaName, relList);
      }
    } catch (e) {
      console.error('加载游年规则失败:', JSON.stringify(e));
    }
  }

  // 根据星名获取星信息
  private getStarByName(name: string): YouNianStar | null {
    for (const star of this.younianStars) {
      if (star.name === name) {
        return star;
      }
    }
    return null;
  }

  // 游年分析：根据本命卦获取八方吉凶
  analyzeYounian(benMingGua: string): YouNianAnalysis {
    const result = new YouNianAnalysis();
    result.benMingGua = benMingGua;
    result.relations = [];
    result.jiList = [];
    result.xiongList = [];

    const relations = this.younianRules.get(benMingGua);
    if (!relations) {
      return result;
    }

    for (const rel of relations) {
      result.relations.push(rel);

      // 分类吉凶
      if (rel.starInfo) {
        const luck = rel.starInfo.luck;
        if (luck === '大吉' || luck === '中吉' || luck === '小吉') {
          result.jiList.push(rel);
        } else if (luck === '大凶' || luck === '次凶' || luck === '小凶') {
          result.xiongList.push(rel);
        }
      }
    }

    return result;
  }

  // ========== 六亲纳甲系统 ==========

  // 加载八宫纳甲规则
  private async loadNaJiaRules(): Promise<void> {
    if (this.naJiaLoaded) {
      return;
    }
    try {
      const data = await this.loadRawFile('rules/najia_rules.json');
      const parsed = JSON.parse(data) as Record<string, Object>;
      const gongRules = parsed['gong_rules'] as object[] || [];
      for (const item of gongRules) {
        const obj = item as Record<string, Object>;
        const gong = obj['gong'] as string;
        if (!gong) {
          continue;
        }
        const rule = new NaJiaGongRule();
        rule.gong = gong;
        rule.gongGuaName = obj['gong_gua_name'] as string || '';
        rule.element = obj['element'] as string || '';
        rule.gongGan = obj['gong_gan'] as string || '';
        rule.yaoZhiSeq = obj['yao_zhi_seq'] as string[] || [];
        rule.yaoGanSeq = obj['yao_gan_seq'] as string[] || [];
        this.naJiaGongRules.set(gong, rule);
      }
      this.naJiaLoaded = true;
    } catch (e) {
      console.error('加载纳甲规则失败:', JSON.stringify(e));
    }
  }

  // 加载卦世应规则
  private async loadGuaShiYingRules(): Promise<void> {
    if (this.guaShiYingLoaded) {
      return;
    }
    try {
      const data = await this.loadRawFile('rules/gua_shiying_rules.json');
      const parsed = JSON.parse(data) as Record<string, Object>;
      const rules = parsed['gua_shiying'] as object[] || [];
      for (const item of rules) {
        const obj = item as Record<string, Object>;
        const name = obj['name'] as string;
        if (!name) {
          continue;
        }
        const rule = new GuaShiYingRule();
        rule.name = name;
        rule.gong = obj['gong'] as string || '';
        rule.type = obj['type'] as string || '';
        rule.shiYao = obj['shi_yao'] as number || 0;
        rule.yingYao = obj['ying_yao'] as number || 0;
        this.guaShiYingMap.set(name, rule);
      }
      this.guaShiYingLoaded = true;
    } catch (e) {
      console.error('加载卦世应规则失败:', JSON.stringify(e));
    }
  }

  // 加载六亲规则
  private async loadLiuQinRules(): Promise<void> {
    if (this.liuQinLoaded) {
      return;
    }
    try {
      const data = await this.loadRawFile('rules/liuqin_rules.json');
      const parsed = JSON.parse(data) as Record<string, Object>;
      const list = parsed['liuqin_by_relation'] as object[] || [];
      for (const item of list) {
        const obj = item as Record<string, Object>;
        const relationKey = obj['relation'] as string;
        const liuQin = obj['liuqin'] as string;
        if (relationKey && liuQin) {
          this.liuQinMap.set(relationKey, liuQin);
        }
      }
      this.liuQinLoaded = true;
    } catch (e) {
      console.error('加载六亲规则失败:', JSON.stringify(e));
    }
  }

  // 计算五行关系对应的六亲关系编码
  private getLiuQinRelationKey(myElement: string, yaoElement: string): string {
    if (!myElement || !yaoElement) {
      return '';
    }
    // 同我
    if (myElement === yaoElement) {
      return 'tong_wo';
    }
    // 我生
    if (WUXING_SHENG.get(myElement) === yaoElement) {
      return 'wo_sheng';
    }
    // 生我
    if (WUXING_SHENG.get(yaoElement) === myElement) {
      return 'sheng_wo';
    }
    // 我克
    if (WUXING_KE.get(myElement) === yaoElement) {
      return 'wo_ke';
    }
    // 克我
    if (WUXING_KE.get(yaoElement) === myElement) {
      return 'ke_wo';
    }
    return '';
  }

  // 卦的六亲纳甲盘（可用于本命卦或流年卦）
  async analyzeNaJiaForGua(
    guaName: string,
    riGan: string,
    monthZhi: string,
    solarTerm: string
  ): Promise<NaJiaPanResult> {
    await this.loadNaJiaRules();
    await this.loadGuaShiYingRules();
    await this.loadLiuQinRules();

    const result = new NaJiaPanResult();
    result.guaName = guaName;

    const guaRule = this.guaShiYingMap.get(guaName);
    if (!guaRule) {
      return result;
    }
    result.gong = guaRule.gong;
    result.type = guaRule.type;
    result.shiYao = guaRule.shiYao;
    result.yingYao = guaRule.yingYao;

    const gongRule = this.naJiaGongRules.get(result.gong);
    if (!gongRule) {
      return result;
    }

    const myElement = this.getGanElement(riGan);
    const seasonElement = this.getSeasonElement(solarTerm, monthZhi);

    result.yaoList = [];
    for (let i = 0; i < 6; i++) {
      const yao = new YaoWithNaJia();
      yao.index = i + 1;
      yao.zhi = gongRule.yaoZhiSeq[i] || '';
      yao.gan = gongRule.yaoGanSeq[i] || '';
      yao.element = this.getZhiElement(yao.zhi);

      const relKey = this.getLiuQinRelationKey(myElement, yao.element);
      if (relKey) {
        yao.liuQin = this.liuQinMap.get(relKey) || '';
      } else {
        yao.liuQin = '';
      }

      yao.isShi = result.shiYao === yao.index;
      yao.isYing = result.yingYao === yao.index;

      const wangResult = this.getWuxingRelation(yao.element, seasonElement);
      yao.wangShuai = wangResult.type;

      result.yaoList.push(yao);
    }

    return result;
  }

  // ========== 术语解释系统 ==========

  // 加载术语解释规则
  private async loadTermExplanations(): Promise<void> {
    if (this.termLoaded) {
      return;
    }
    try {
      const data = await this.loadRawFile('rules/term_explanations.json');
      const parsed = JSON.parse(data) as Record<string, Object>;
      const terms = parsed['terms'] as object[] || [];

      for (const item of terms) {
        const obj = item as Record<string, Object>;
        const term = new TermExplanation();
        term.term = obj['term'] as string || '';
        term.category = obj['category'] as string || '';
        term.shortDesc = obj['shortDesc'] as string || '';
        term.detailDesc = obj['detailDesc'] as string || '';
        term.example = obj['example'] as string || '';
        term.relatedTerms = obj['relatedTerms'] as string[] || [];
        this.termExplanations.set(term.term, term);
      }
      this.termLoaded = true;
      console.info('术语解释规则加载完成，共', this.termExplanations.size, '条');
    } catch (e) {
      console.error('加载术语解释规则失败:', JSON.stringify(e));
    }
  }

  // 获取术语解释
  async getTermExplanation(term: string): Promise<TermExplanation | null> {
    await this.loadTermExplanations();
    return this.termExplanations.get(term) || null;
  }

  // 获取所有术语列表（按分类）
  async getAllTerms(): Promise<Map<string, TermExplanation[]>> {
    await this.loadTermExplanations();
    const categoryMap: Map<string, TermExplanation[]> = new Map();
    this.termExplanations.forEach((term: TermExplanation) => {
      const list = categoryMap.get(term.category) || [];
      list.push(term);
      categoryMap.set(term.category, list);
    });
    return categoryMap;
  }

  // ========== 求数法 ==========

  // 求数法分析：将四柱干支转化为数理密码
  analyzeQiuShu(calendar: CalendarData): QiuShuAnalysis {
    const result = new QiuShuAnalysis();
    result.pillars = [];
    result.yangNumbers = [];
    result.yinNumbers = [];

    // 四柱信息
    const pillarNames: string[] = ['年柱', '月柱', '日柱', '时柱'];
    const gans: string[] = [calendar.year_gan, calendar.month_gan, calendar.day_gan, calendar.hour_gan];
    const zhis: string[] = [calendar.year_zhi, calendar.month_zhi, calendar.day_zhi, calendar.hour_zhi];

    // 处理每一柱
    for (let i = 0; i < 4; i++) {
      const pillarName = pillarNames[i];
      const gan = gans[i];
      const zhi = zhis[i];

      const pillar = new PillarNumber();
      pillar.pillar = pillarName;
      pillar.tianGan = gan;
      pillar.diZhi = zhi;

      // 天干取河图数
      pillar.hetuNum = this.getHetuNumber(gan);
      pillar.ganYinYang = pillar.hetuNum % 2 === 1 ? '阳' : '阴';
      pillar.ganPosition = pillar.hetuNum % 2 === 1 ? '左' : '右';

      // 地支取洛书数
      pillar.luoshuNum = this.getLuoshuNumber(zhi);
      pillar.zhiYinYang = pillar.luoshuNum % 2 === 1 ? '阳' : '阴';
      pillar.zhiPosition = pillar.luoshuNum % 2 === 1 ? '左' : '右';

      result.pillars.push(pillar);

      // 分类汇总阳数和阴数
      if (pillar.hetuNum % 2 === 1) {
        result.yangNumbers.push(pillar.hetuNum);
      } else {
        result.yinNumbers.push(pillar.hetuNum);
      }

      if (pillar.luoshuNum % 2 === 1) {
        result.yangNumbers.push(pillar.luoshuNum);
      } else {
        result.yinNumbers.push(pillar.luoshuNum);
      }
    }

    // 计算汇总
    result.yangSum = result.yangNumbers.reduce((a, b) => a + b, 0);
    result.yinSum = result.yinNumbers.reduce((a, b) => a + b, 0);
    result.yangCount = result.yangNumbers.length;
    result.yinCount = result.yinNumbers.length;
    result.totalSum = result.yangSum + result.yinSum;

    // 计算阳数占比
    const totalCount = result.yangCount + result.yinCount;
    result.yangRatio = totalCount > 0 ? result.yangCount / totalCount : 0;

    // 判断格局
    if (result.yangRatio >= 0.7) {
      result.pattern = '阳盛';
      result.patternDesc = '性格刚强，主动进取，有领导力但易刚愈自用';
    } else if (result.yangRatio >= 0.5) {
      result.pattern = '阳偏';
      result.patternDesc = '偏于阳刚，善于开拓，行事果断';
    } else if (result.yangRatio >= 0.3) {
      result.pattern = '阴偏';
      result.patternDesc = '偏于阴柔，善于守成，行事谨慎';
    } else {
      result.pattern = '阴盛';
      result.patternDesc = '性格柔顺，被动守成，善于配合但易优柔寡断';
    }

    // 判断数理轻重
    if (result.totalSum <= 16) {
      result.sumLevel = '轻';
      result.sumDesc = '数理偏轻，宜静不宜动，守成为上';
    } else if (result.totalSum <= 32) {
      result.sumLevel = '中';
      result.sumDesc = '数理适中，进退有度，可攻可守';
    } else {
      result.sumLevel = '重';
      result.sumDesc = '数理偏重，宜动不宜静，开拓为上';
    }

    return result;
  }

  // 获取天干的河图数
  private getHetuNumber(gan: string): number {
    const index = TIAN_GAN.indexOf(gan);
    return index >= 0 ? index + 1 : 0;
  }

  // 获取地支的洛书数
  private getLuoshuNumber(zhi: string): number {
    const index = DI_ZHI.indexOf(zhi);
    return index >= 0 ? index + 1 : 0;
  }

  // ========== 成卦法 ==========

  // 洛书九宫配卦
  private readonly LUOSHU_GUA: Map<number, DanGuaInfo> = new Map([
    [1, this.makeDanGua('坎', '☵', '水', [0, 1, 0])],
    [2, this.makeDanGua('坤', '☷', '土', [0, 0, 0])],
    [3, this.makeDanGua('震', '☳', '木', [1, 0, 0])],
    [4, this.makeDanGua('巽', '☴', '木', [0, 1, 1])],
    [5, this.makeDanGua('坤', '☷', '土', [0, 0, 0])], // 中五寄坤
    [6, this.makeDanGua('乾', '☰', '金', [1, 1, 1])],
    [7, this.makeDanGua('兑', '☱', '金', [1, 1, 0])],
    [8, this.makeDanGua('艮', '☶', '土', [0, 0, 1])],
    [9, this.makeDanGua('离', '☲', '火', [1, 0, 1])],
    [0, this.makeDanGua('坤', '☷', '土', [0, 0, 0])] // 余0取坤
  ]);

  // 年干起卦映射
  private readonly NIANGAN_GUA: Map<string, DanGuaInfo> = new Map([
    ['甲', this.makeDanGua('乾', '☰', '金', [1, 1, 1])],
    ['乙', this.makeDanGua('坤', '☷', '土', [0, 0, 0])],
    ['丙', this.makeDanGua('艮', '☶', '土', [0, 0, 1])],
    ['丁', this.makeDanGua('兑', '☱', '金', [1, 1, 0])],
    ['戊', this.makeDanGua('坎', '☵', '水', [0, 1, 0])],
    ['己', this.makeDanGua('离', '☲', '火', [1, 0, 1])],
    ['庚', this.makeDanGua('震', '☳', '木', [1, 0, 0])],
    ['辛', this.makeDanGua('巽', '☴', '木', [0, 1, 1])],
    ['壬', this.makeDanGua('乾', '☰', '金', [1, 1, 1])],
    ['癸', this.makeDanGua('坤', '☷', '土', [0, 0, 0])]
  ]);

  // 64卦速查表
  private chongGuaMap: Map<string, ChongGuaInfo> = new Map();
  private chongGuaLoaded: boolean = false;

  // 创建单卦对象
  private makeDanGua(name: string, symbol: string, element: string, yao: number[]): DanGuaInfo {
    const gua = new DanGuaInfo();
    gua.name = name;
    gua.symbol = symbol;
    gua.element = element;
    gua.yao = yao;
    return gua;
  }

  // 加载64卦表
  private async loadChongGuaMap(): Promise<void> {
    if (this.chongGuaLoaded) return;
    try {
      const data = await this.loadRawFile('rules/chengua_rules.json');
      const parsed = JSON.parse(data) as Record<string, Object>;
      const chonggua64 = parsed['chonggua_64'] as Record<string, Object>;
      const guaData = chonggua64['data'] as Record<string, Object>;

      const keys = Object.keys(guaData);
      for (const key of keys) {
        const item = guaData[key] as Record<string, Object>;
        const info = new ChongGuaInfo();
        const parts = key.split('-');
        info.upperGua = parts[0];
        info.lowerGua = parts[1];
        info.name = item['name'] as string;
        info.unicode = item['unicode'] as string;
        info.meaning = item['meaning'] as string;
        // 判断吉凶
        info.luck = this.judgeGuaLuck(info.name, info.meaning);
        this.chongGuaMap.set(key, info);
      }
      this.chongGuaLoaded = true;
    } catch (e) {
      console.error('加载64卦表失败:', JSON.stringify(e));
    }
  }

  // 判断卦象吉凶
  private judgeGuaLuck(name: string, meaning: string): string {
    const jiGua = ['地天泰', '水地比', '火天大有', '地山谦', '水火既济', '风雷益'];
    const xiongGua = ['天地否', '山地剥', '泽水困', '坎为水', '地水师', '天水讼'];
    if (jiGua.includes(name)) return '吉';
    if (xiongGua.includes(name)) return '凶';
    if (meaning.includes('进取') || meaning.includes('通达') || meaning.includes('收获') || meaning.includes('吉祥')) return '吉';
    if (meaning.includes('闭塞') || meaning.includes('艰难') || meaning.includes('衰败') || meaning.includes('困境')) return '凶';
    return '平';
  }

  // 获取重卦信息
  private getChongGua(upperGua: string, lowerGua: string): ChongGuaInfo {
    const key = `${upperGua}-${lowerGua}`;
    const info = this.chongGuaMap.get(key);
    if (info) return info;
    // 默认返回
    const defaultInfo = new ChongGuaInfo();
    defaultInfo.upperGua = upperGua;
    defaultInfo.lowerGua = lowerGua;
    defaultInfo.name = `${upperGua}${lowerGua}卦`;
    defaultInfo.luck = '平';
    return defaultInfo;
  }

  // A法：正统成卦法（天地余数合成重卦）
  async analyzeZhengTongGua(qiuShu: QiuShuAnalysis, gender: string, yearGan: string): Promise<ZhengTongGuaResult> {
    await this.loadChongGuaMap();
    const result = new ZhengTongGuaResult();

    // 1. 天数和（奇数之和）、地数和（偶数之和）
    result.tianShuSum = qiuShu.yangSum;
    result.diShuSum = qiuShu.yinSum;

    // 2. 计算余数（古法分情况处理）
    // 依据《皇极经世》："天数积而满二十五，则复归于一。"
    // 只有"满"了才循环减去，不满就按实际数用

    // 天数余计算
    let tianYu: number;
    if (result.tianShuSum >= 25) {
      // 满数情况：和 - 25，若 ≥10 则取个位
      tianYu = result.tianShuSum - 25;
      if (tianYu >= 10) tianYu = tianYu % 10;
    } else {
      // 不满数情况：直接取个位数
      tianYu = result.tianShuSum % 10;
    }
    // 结果为0则视为10
    if (tianYu === 0) tianYu = 10;
    result.tianYu = tianYu;

    // 地数余计算
    let diYu: number;
    if (result.diShuSum >= 30) {
      // 满数情况：和 - 30，若 ≥10 则取个位
      diYu = result.diShuSum - 30;
      if (diYu >= 10) diYu = diYu % 10;
    } else {
      // 不满数情况：直接取个位数
      diYu = result.diShuSum % 10;
    }
    // 结果为0则视为10
    if (diYu === 0) diYu = 10;
    result.diYu = diYu;

    // 3. 年干阴阳与性别
    result.gender = gender;
    const yangGan = ['甲', '丙', '戊', '庚', '壬'];
    result.yearGanYinYang = yangGan.includes(yearGan) ? '阳' : '阴';

    // 4. 确定上下卦位置
    // 口诀：阳男阴女顺，阴男阳女逆
    // 顺：天卦为上，地卦为下
    // 逆：地卦为上，天卦为下
    const isShun = (result.yearGanYinYang === '阳' && gender === '男') ||
      (result.yearGanYinYang === '阴' && gender === '女');

    // 天卦（由天数余定）、地卦（由地数余定）
    const tianGua = this.LUOSHU_GUA.get(tianYu) || this.LUOSHU_GUA.get(0)!;
    const diGua = this.LUOSHU_GUA.get(diYu) || this.LUOSHU_GUA.get(0)!;

    // 特殊处理：若天数为0（无奇数），取年干对应卦
    let actualTianGua = tianGua;
    if (result.tianShuSum === 0) {
      actualTianGua = this.NIANGAN_GUA.get(yearGan) || tianGua;
    }

    if (isShun) {
      result.upperGua = actualTianGua;
      result.lowerGua = diGua;
      result.guaPosRule = `阳男阴女顺：天卦(${actualTianGua.name})上、地卦(${diGua.name})下`;
    } else {
      result.upperGua = diGua;
      result.lowerGua = actualTianGua;
      result.guaPosRule = `阴男阳女逆：地卦(${diGua.name})上、天卦(${actualTianGua.name})下`;
    }

    // 5. 合成先天命卦
    result.mingGua = this.getChongGua(result.upperGua.name, result.lowerGua.name);

    // 6. 生成分析
    result.analysis = this.generateZhengTongAnalysis(result);

    return result;
  }

  // 生成正统成卦法分析
  private generateZhengTongAnalysis(result: ZhengTongGuaResult): string {
    let analysis = `先天命卦为${result.mingGua.name}，`;
    analysis += `上${result.upperGua.name}(${result.upperGua.element})下${result.lowerGua.name}(${result.lowerGua.element})。`;

    if (result.mingGua.meaning) {
      analysis += `卦义：${result.mingGua.meaning}。`;
    }

    if (result.mingGua.luck === '吉') {
      analysis += '此卦主吉，先天格局通达，宜稳中求进。';
    } else if (result.mingGua.luck === '凶') {
      analysis += '此卦主凶，先天多阻，需后天调塑。';
    } else {
      analysis += '此卦平平，稳守为吉。';
    }

    return analysis;
  }

  // B法：年干起卦 + 动爻法
  async analyzeNianGanGua(qiuShu: QiuShuAnalysis, yearGan: string, gender: string, dayZhi: string): Promise<NianGanGuaResult> {
    await this.loadChongGuaMap();
    const result = new NianGanGuaResult();

    // 1. 本命卦（体卦）：由年干定
    const benMingGua = this.NIANGAN_GUA.get(yearGan);
    if (benMingGua) {
      result.benMingGua = benMingGua;
    }

    // 2. 动爻计算：四柱总数 mod 6
    result.totalSum = qiuShu.totalSum;
    result.dongYao = qiuShu.totalSum % 6;
    if (result.dongYao === 0) result.dongYao = 6; // 余数0视为上爻动

    // 3. 生成变卦：本卦第N爻变动
    result.bianGua = this.getBianGua(result.benMingGua, result.dongYao);

    // 4. 元堂定位
    const yuanTangResult = this.calculateYuanTang(gender, yearGan, dayZhi);
    result.yuanTang = yuanTangResult[0];
    result.yuanTangDesc = yuanTangResult[1];

    // 5. 生成分析
    result.analysis = this.generateNianGanAnalysis(result);

    return result;
  }

  // 根据动爻生成变卦
  private getBianGua(benGua: DanGuaInfo, dongYao: number): ChongGuaInfo {
    // 本命卦是单卦，拓展为重卦（上下均为本卦）
    // 然后第N爻变动
    const fullYao = benGua.yao.concat(benGua.yao); // [0,0,0,0,0,0] from bottom to top

    // 变动第N爻（dongYao=1是初爻，即最下面的爻）
    const yaoIndex = dongYao - 1;
    fullYao[yaoIndex] = fullYao[yaoIndex] === 1 ? 0 : 1;

    // 下卦（初爻、二爻、三爻），上卦（四爻、五爻、上爻）
    const lowerYao = fullYao.slice(0, 3);
    const upperYao = fullYao.slice(3, 6);

    const lowerGuaName = this.yaoToGuaName(lowerYao);
    const upperGuaName = this.yaoToGuaName(upperYao);

    return this.getChongGua(upperGuaName, lowerGuaName);
  }

  // 爻象转卦名
  private yaoToGuaName(yao: number[]): string {
    const yaoStr = yao.join('');
    const yaoGuaMap: Map<string, string> = new Map([
      ['111', '乾'], ['000', '坤'], ['100', '震'], ['011', '巽'],
      ['010', '坎'], ['101', '离'], ['001', '艮'], ['110', '兑']
    ]);
    return yaoGuaMap.get(yaoStr) || '坤';
  }

  // 计算元堂位置
  private calculateYuanTang(gender: string, yearGan: string, dayZhi: string): [number, string] {
    // 阴阳男女顺逆口诀：
    // 阳男阴女从初爻顺数，阴男阳女从上爻逆数
    const yangGan = ['甲', '丙', '戊', '庚', '壬'];
    const isYang = yangGan.includes(yearGan);

    const zhiIndex = DI_ZHI.indexOf(dayZhi) + 1; // 1-12
    const countNum = ((zhiIndex - 1) % 6) + 1; // 计算需要数几步

    let yuanTang = 1;
    if ((isYang && gender === '男') || (!isYang && gender === '女')) {
      // 从初爻顺数
      yuanTang = countNum;
    } else {
      // 从上爻逆数
      yuanTang = 7 - countNum;
      if (yuanTang <= 0) yuanTang += 6;
    }

    const yaoNames = ['初爻(基层)', '二爻(住所)', '三爻(门庙)', '四爻(官位)', '五爻(君位)', '上爻(宗庙)'];
    const yaoDesc = yaoNames[yuanTang - 1] || '';

    return [yuanTang, yaoDesc];
  }

  // 生成年干起卦法分析
  private generateNianGanAnalysis(result: NianGanGuaResult): string {
    let analysis = `本命卦：${result.benMingGua.name}(${result.benMingGua.symbol})，`;
    analysis += `四柱总数${result.totalSum}，${result.dongYao}爻动。`;
    analysis += `变卦：${result.bianGua.name}。`;

    if (result.yuanTang >= 4) {
      analysis += `元堂在${result.yuanTangDesc}，主中年后发达。`;
    } else if (result.yuanTang === 1) {
      analysis += `元堂在${result.yuanTangDesc}，主白手起家。`;
    } else {
      analysis += `元堂在${result.yuanTangDesc}。`;
    }

    if (result.bianGua.meaning) {
      analysis += `变卦义：${result.bianGua.meaning}`;
    }

    return analysis;
  }

  // 体用综合分析
  analyzeTiYong(zhengTong: ZhengTongGuaResult, nianGan: NianGanGuaResult): TiYongAnalysisResult {
    const result = new TiYongAnalysisResult();

    result.tiLuck = zhengTong.mingGua.luck;
    result.yongLuck = nianGan.bianGua.luck;

    // 体用合参
    if (result.tiLuck === '吉' && result.yongLuck === '吉') {
      result.combinedResult = '大吉';
      result.combinedDesc = '体用皆吉，大富大贵，一生顺遂';
      result.advice = '可积极进取，把握机会，大胆开拓';
    } else if (result.tiLuck === '吉' && result.yongLuck === '凶') {
      result.combinedResult = '中平';
      result.combinedDesc = '怀才不遇，需待时而动，中年后转运';
      result.advice = '宜徐图大计，不急于一时，重积累和学习';
    } else if (result.tiLuck === '凶' && result.yongLuck === '吉') {
      result.combinedResult = '中平';
      result.combinedDesc = '有才无运，或富贵不长久，宜稳健';
      result.advice = '宜步步为营，稳守为先，保守经营';
    } else if (result.tiLuck === '凶' && result.yongLuck === '凶') {
      result.combinedResult = '大凶';
      result.combinedDesc = '多灾多难，宜守不宜攻，韬光养晦';
      result.advice = '静待时机，保存实力，注重健康，不宜冒进';
    } else {
      result.combinedResult = '平';
      result.combinedDesc = '平平淡淡，稳守为吉';
      result.advice = '稳中求进，勿贪功冲';
    }

    return result;
  }

  // ========== 八卦相荡法 ==========

  // 八卦相荡法：推演流年
  async analyzeXiangDang(
    zhengTong: ZhengTongGuaResult,
    gender: string,
    yearGan: string,
    startYear: number,
    years: number = 10
  ): Promise<XiangDangResult> {
    await this.loadChongGuaMap();
    const result = new XiangDangResult();

    // 1. 本命卦信息（来自成卦法A）
    result.benMingGua = zhengTong.mingGua;
    result.benMingTianShu = zhengTong.tianShuSum;
    result.benMingDiShu = zhengTong.diShuSum;
    result.benMingElement = this.getGuaElement(zhengTong.mingGua.upperGua);

    // 2. 命格类型
    const yangGan = ['甲', '丙', '戊', '庚', '壬'];
    const isYangYear = yangGan.includes(yearGan);
    if (isYangYear && gender === '男') {
      result.mingGeType = '阳命男';
    } else if (isYangYear && gender === '女') {
      result.mingGeType = '阳命女';
    } else if (!isYangYear && gender === '男') {
      result.mingGeType = '阴命男';
    } else {
      result.mingGeType = '阴命女';
    }

    // 3. 推演多年流年卦
    result.liuNianList = [];
    for (let i = 0; i < years; i++) {
      const targetYear = startYear + i;
      const liuNianGua = this.calculateLiuNianGua(
        result.benMingTianShu,
        result.benMingDiShu,
        targetYear,
        result.mingGeType
      );
      result.liuNianList.push(liuNianGua);
    }

    // 4. 当前年份详细分析（默认第一年）
    result.currentYear = startYear;
    if (result.liuNianList.length > 0) {
      result.currentLiuNian = result.liuNianList[0];
      result.tiYongRelation = this.analyzeTiYongRelation(
        result.benMingElement,
        this.getGuaElement(result.currentLiuNian.liuNianGua.upperGua)
      );
    }

    // 5. 生成分析文字
    result.analysis = this.generateXiangDangAnalysis(result);

    return result;
  }

  // 计算流年卦
  private calculateLiuNianGua(
    benMingTianShu: number,
    benMingDiShu: number,
    targetYear: number,
    mingGeType: string
  ): LiuNianGuaInfo {
    const liuNian = new LiuNianGuaInfo();
    liuNian.year = targetYear;

    // 计算年干支
    const ganZhi = this.getYearGanZhi(targetYear);
    liuNian.yearGanZhi = ganZhi;

    // 计算流年天地数
    const yearGan = ganZhi.charAt(0);
    const yearZhi = ganZhi.charAt(1);
    liuNian.tianShu = this.getHetuNumber(yearGan);
    liuNian.diShu = DI_ZHI.indexOf(yearZhi) + 1;

    // 相荡计算：(本命数 + 流年数) mod 25/30
    let newTianSum = benMingTianShu + liuNian.tianShu;
    let newDiSum = benMingDiShu + liuNian.diShu;

    // 天数余：满25则减，取个位
    liuNian.newTianYu = this.calculateYu(newTianSum, 25);
    // 地数余：满30则减，取个位
    liuNian.newDiYu = this.calculateYu(newDiSum, 30);

    // 根据余数得卦
    const tianGuaName = this.yuToGuaName(liuNian.newTianYu);
    const diGuaName = this.yuToGuaName(liuNian.newDiYu);

    // 根据命格类型决定上下卦位置
    let upperGuaName: string;
    let lowerGuaName: string;
    if (mingGeType === '阳命男' || mingGeType === '阴命女') {
      // 天在上，地在下
      upperGuaName = tianGuaName;
      lowerGuaName = diGuaName;
    } else {
      // 天在下，地在上
      upperGuaName = diGuaName;
      lowerGuaName = tianGuaName;
    }

    liuNian.liuNianGua = this.getChongGua(upperGuaName, lowerGuaName);

    return liuNian;
  }

  // 计算余数（古法）
  private calculateYu(sum: number, base: number): number {
    let yu: number;
    if (sum >= base) {
      yu = sum - base;
      while (yu >= 10) {
        yu = yu % 10;
      }
    } else {
      yu = sum % 10;
    }
    if (yu === 0) yu = 10;
    return yu;
  }

  // 余数转卦名（洛书数配卦）
  private yuToGuaName(yu: number): string {
    // 洛书数配卦：1坎 2坤 3震 4巽 5寄坤 6乾 7兑 8艮 9离 10寄坤
    const yuGuaMap: Map<number, string> = new Map([
      [1, '坎'], [2, '坤'], [3, '震'], [4, '巽'],
      [5, '坤'], [6, '乾'], [7, '兑'], [8, '艮'],
      [9, '离'], [10, '坤']
    ]);
    return yuGuaMap.get(yu) || '坤';
  }

  // 获取年份干支
  private getYearGanZhi(year: number): string {
    // 天干：(year - 4) % 10
    const ganIndex = (year - 4) % 10;
    // 地支：(year - 4) % 12
    const zhiIndex = (year - 4) % 12;
    return TIAN_GAN[ganIndex] + DI_ZHI[zhiIndex];
  }

  // 分析体用生克关系
  private analyzeTiYongRelation(tiElement: string, yongElement: string): TiYongRelation {
    const relation = new TiYongRelation();
    relation.tiElement = tiElement;
    relation.yongElement = yongElement;

    if (tiElement === yongElement) {
      // 比和
      relation.relation = '比和';
      relation.luck = '吉';
      relation.desc = '同气相求，得朋友相助，万事顺遍';
    } else if (WUXING_KE.get(tiElement) === yongElement) {
      // 体克用
      relation.relation = '体克用';
      relation.luck = '大吉';
      relation.desc = '我克者为财，主进财得利，事业顺遂';
    } else if (WUXING_KE.get(yongElement) === tiElement) {
      // 用克体
      relation.relation = '用克体';
      relation.luck = '凶';
      relation.desc = '克我者为官鬼，主灾祸口舌，受制于人';
    } else if (WUXING_SHENG.get(tiElement) === yongElement) {
      // 体生用
      relation.relation = '体生用';
      relation.luck = '小凶';
      relation.desc = '我生者为子孙，主泄气耗财，劳而少功';
    } else if (WUXING_SHENG.get(yongElement) === tiElement) {
      // 用生体
      relation.relation = '用生体';
      relation.luck = '大吉';
      relation.desc = '生我者为贵人，主得贵人提拔，进财得利';
    } else {
      relation.relation = '无特殊关系';
      relation.luck = '平';
      relation.desc = '平平淡淡，无大起大落';
    }

    return relation;
  }

  // 获取卦的五行
  private getGuaElement(guaName: string): string {
    const guaElementMap: Map<string, string> = new Map([
      ['乾', '金'], ['兑', '金'],
      ['坤', '土'], ['艮', '土'],
      ['震', '木'], ['巽', '木'],
      ['坎', '水'],
      ['离', '火']
    ]);
    return guaElementMap.get(guaName) || '土';
  }

  // 生成相荡法分析文字
  private generateXiangDangAnalysis(result: XiangDangResult): string {
    let analysis = `命格：${result.mingGeType}，本命卦为${result.benMingGua.name}。`;

    if (result.currentLiuNian && result.currentLiuNian.year > 0) {
      analysis += `\n${result.currentYear}年(${result.currentLiuNian.yearGanZhi})流年卦为${result.currentLiuNian.liuNianGua.name}。`;
      analysis += `\n体用关系：${result.tiYongRelation.relation}，${result.tiYongRelation.desc}`;
    }

    return analysis;
  }

  // ========== 定元堂式 ==========

  // 定元堂式：在卦中找到命主的位置（完整版，考虑时辰阴阳、杂卦纯卦）
  defineYuanTang(
    chongGua: ChongGuaInfo,
    shichenIndex: number,
    gender: string,
    yearGan: string,
    solarTerm: string
  ): YuanTangInfo {
    const result = new YuanTangInfo();
    result.shichenName = DI_ZHI[shichenIndex];

    // 判断阳时/阴时
    const isYangShi = shichenIndex < 6; // 子丑寅卯辰巳为阳时

    // 获取卦的爻象
    const yaoList = this.getChongGuaYao(chongGua);

    // 计算阳爻和阴爻的位置
    const yangYaoPos: number[] = [];
    const yinYaoPos: number[] = [];
    for (let i = 0; i < 6; i++) {
      if (yaoList[i] === 1) {
        yangYaoPos.push(i + 1);
      } else {
        yinYaoPos.push(i + 1);
      }
    }

    // 特殊处理：乾卦（六阳）和坤卦（六阴）
    if (chongGua.name.includes('乾为天') || yangYaoPos.length === 6) {
      result.yaoPosition = this.calcQianKunYuanTang(isYangShi, gender, '乾', yearGan, solarTerm, shichenIndex);
      result.calcRule = '乾卦纯阳，特殊定式';
    } else if (chongGua.name.includes('坤为地') || yinYaoPos.length === 6) {
      result.yaoPosition = this.calcQianKunYuanTang(isYangShi, gender, '坤', yearGan, solarTerm, shichenIndex);
      result.calcRule = '坤卦纯阴，特殊定式';
    } else {
      // 杂卦处理
      if (isYangShi) {
        // 阳时报阳爻
        const yangCount = yangYaoPos.length;
        const cycleIndex = shichenIndex % yangCount;
        result.yaoPosition = yangYaoPos[cycleIndex];
        result.yaoType = '阳爻';
        result.calcRule = `阳时报阳，${yangCount}阳爻循环`;
      } else {
        // 阴时报阴爻
        const yinCount = yinYaoPos.length;
        const cycleIndex = (shichenIndex - 6) % yinCount;
        result.yaoPosition = yinYaoPos[cycleIndex];
        result.yaoType = '阴爻';
        result.calcRule = `阴时报阴，${yinCount}阴爻循环`;
      }
    }

    // 设置爻名和含义
    const yaoNames = ['初爻', '二爻', '三爻', '四爻', '五爻', '上爻'];
    const yaoMeanings = [
      '祖业、基层、白手起家',
      '家宅、住所、安居乐业',
      '门户、交际、出入平安',
      '官位、事业、仕途发展',
      '君位、权势、中年发达',
      '宗庙、祖德、晚年安康'
    ];
    result.yaoName = yaoNames[result.yaoPosition - 1] || '';
    result.meaning = yaoMeanings[result.yaoPosition - 1] || '';

    return result;
  }

  // 乾坤卦定元堂（需考虑节气和顺逆）
  private calcQianKunYuanTang(
    isYangShi: boolean,
    gender: string,
    guaType: string, // '乾'或'坤'
    yearGan: string,
    solarTerm: string,
    shichenIndex: number
  ): number {
    // 简化处理：阳时在下卦(1-3)，阴时在上卦(4-6)
    // 完整实现需要考虑节气和性别
    const baseIndex = shichenIndex % 3;
    if (isYangShi) {
      return baseIndex + 1; // 下卦：1,2,3
    } else {
      return baseIndex + 4; // 上卦：4,5,6
    }
  }

  // 获取重卦的爻象
  private getChongGuaYao(chongGua: ChongGuaInfo): number[] {
    // 根据上下卦名获取爻象
    const guaYaoMap: Map<string, number[]> = new Map([
      ['乾', [1, 1, 1]], ['坤', [0, 0, 0]],
      ['震', [1, 0, 0]], ['巽', [0, 1, 1]],
      ['坎', [0, 1, 0]], ['离', [1, 0, 1]],
      ['艮', [0, 0, 1]], ['兑', [1, 1, 0]]
    ]);
    const lowerYao = guaYaoMap.get(chongGua.lowerGua) || [0, 0, 0];
    const upperYao = guaYaoMap.get(chongGua.upperGua) || [0, 0, 0];
    return [...lowerYao, ...upperYao]; // 从下到上
  }

  // ========== 起月卦 ==========

  // 起月卦：推算流月运势
  calculateLiuYueGua(
    yuanTangYao: number, // 元堂爻位
    dayGan: string,       // 日元
    month: number         // 月份(1-12)
  ): LiuYueGuaInfo {
    const result = new LiuYueGuaInfo();
    result.month = month;

    // 月支映射
    const monthZhiList = ['寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥', '子', '丑'];
    result.monthZhi = monthZhiList[(month - 1) % 12];

    // 月支转卦
    const zhiToGua: Map<string, string> = new Map([
      ['子', '坎'], ['丑', '艮'], ['寅', '震'], ['卯', '巽'],
      ['辰', '巽'], ['巳', '离'], ['午', '离'], ['未', '坤'],
      ['申', '乾'], ['酉', '兑'], ['戌', '乾'], ['亥', '坎']
    ]);
    result.monthGua = zhiToGua.get(result.monthZhi) || '坤';

    // 主爻位 = (元堂爻位 + 月份 - 2) % 6 + 1
    result.zhuYao = ((yuanTangYao + month - 2) % 6) + 1;
    const yaoNames = ['初爻', '二爻', '三爻', '四爻', '五爻', '上爻'];
    result.zhuYaoName = yaoNames[result.zhuYao - 1];

    // 五行关系判断
    const dayElement = this.getGanElement(dayGan);
    const monthElement = this.getGuaElement(result.monthGua);
    const relationResult = this.getWuxingRelation(dayElement, monthElement);
    result.wuxingRelation = relationResult.type;
    result.luck = relationResult.luck;
    result.desc = this.getMonthDesc(result.luck, result.zhuYao);

    return result;
  }

  // ========== 起日卦 ==========

  // 起日卦：推算流日运势
  calculateLiuRiGua(dayZhi: string, dayGan: string): LiuRiGuaInfo {
    const result = new LiuRiGuaInfo();
    result.dayZhi = dayZhi;

    // 日支转卦
    const zhiToGua: Map<string, string> = new Map([
      ['子', '坎'], ['丑', '艮'], ['寅', '震'], ['卯', '巽'],
      ['辰', '巽'], ['巳', '离'], ['午', '离'], ['未', '坤'],
      ['申', '乾'], ['酉', '兑'], ['戌', '乾'], ['亥', '坎']
    ]);
    result.dayGua = zhiToGua.get(dayZhi) || '坤';

    // 动爻 = (日支序数) % 6 + 1
    const zhiIndex = DI_ZHI.indexOf(dayZhi);
    result.dongYao = (zhiIndex % 6) + 1;
    const yaoNames = ['初爻', '二爻', '三爻', '四爻', '五爻', '上爻'];
    result.dongYaoName = yaoNames[result.dongYao - 1];

    // 五行关系
    const dayElement = this.getGanElement(dayGan);
    const zhiElement = this.getZhiElement(dayZhi);
    const relationResult = this.getWuxingRelation(dayElement, zhiElement);
    result.wuxingRelation = relationResult.type;
    result.luck = relationResult.luck;
    result.desc = this.getDayDesc(result.luck, result.dongYao);

    return result;
  }

  // 获取天干五行
  private getGanElement(gan: string): string {
    const ganElementMap: Map<string, string> = new Map([
      ['甲', '木'], ['乙', '木'], ['丙', '火'], ['丁', '火'], ['戊', '土'],
      ['己', '土'], ['庚', '金'], ['辛', '金'], ['壬', '水'], ['癸', '水']
    ]);
    return ganElementMap.get(gan) || '土';
  }

  // 获取地支五行
  private getZhiElement(zhi: string): string {
    const zhiElementMap: Map<string, string> = new Map([
      ['子', '水'], ['丑', '土'], ['寅', '木'], ['卯', '木'],
      ['辰', '土'], ['巳', '火'], ['午', '火'], ['未', '土'],
      ['申', '金'], ['酉', '金'], ['戌', '土'], ['亥', '水']
    ]);
    return zhiElementMap.get(zhi) || '土';
  }

  // 月运描述
  private getMonthDesc(luck: string, yao: number): string {
    if (luck === '吉') return `本月主爻在${yao}爻，得印比相助，诸事顺遍`;
    if (luck === '凶') return `本月主爻在${yao}爻，受克制之象，宜守不宜进`;
    return `本月主爻在${yao}爻，运势平平，无大起大落`;
  }

  // 日运描述
  private getDayDesc(luck: string, yao: number): string {
    if (luck === '吉') return `今日动爻在${yao}爻，宜出行、签约、开业`;
    if (luck === '凶') return `今日动爻在${yao}爻，宜祈福、休养，忌冲动`;
    return `今日动爻在${yao}爻，日常事务可进行`;
  }


  calculateXiaoXiang(
    yuanTangYao: number, // 元堂爻位(1-6)
    age: number,         // 虚岁年龄
    gender: string,      // 性别
    yearGan: string      // 年干
  ): XiaoXiangResult {
    const result = new XiaoXiangResult();
    result.age = age;

    // 判断顺行/逆行
    const yangGan = ['甲', '丙', '戊', '庚', '壬'];
    const isYangYear = yangGan.includes(yearGan);
    // 阳男阴女顺行，阴男阳女逆行
    const isShunXing = (isYangYear && gender === '男') || (!isYangYear && gender === '女');

    // 计算当年所在爻位（从元堂算起为1岁）
    // 流年入爻法：一爻一年循环
    let currentYao: number;
    if (isShunXing) {
      // 顺行：初 -> 二 -> 三 -> 四 -> 五 -> 上 -> 初...
      currentYao = ((yuanTangYao - 1 + age - 1) % 6) + 1;
    } else {
      // 逆行：上 -> 五 -> 四 -> 三 -> 二 -> 初 -> 上...
      currentYao = yuanTangYao - ((age - 1) % 6);
      if (currentYao <= 0) currentYao += 6;
    }
    result.currentYao = currentYao;

    const yaoNames = ['初爻', '二爻', '三爻', '四爻', '五爻', '上爻'];
    result.currentYaoName = yaoNames[currentYao - 1];

    // 获取小象断语（简化版，根据爻位给出通用断语）
    const xiaoXiangMap = this.getXiaoXiangByYao(currentYao);
    result.yaoCi = xiaoXiangMap.yaoCi;
    result.xiaoXiang = xiaoXiangMap.xiaoXiang;
    result.luck = xiaoXiangMap.luck;
    result.advice = xiaoXiangMap.advice;

    return result;
  }

  // 根据爻位获取通用小象断语
  private getXiaoXiangByYao(yao: number): XiaoXiangData {
    // 初爻：基层，初始
    const data1 = new XiaoXiangData();
    data1.yaoCi = '潜龙勿用';
    data1.xiaoXiang = '阳在下也';
    data1.luck = '平';
    data1.advice = '今年宜韬光养晦，稳扎基础，不宜强出头';

    // 二爻：住所，安定
    const data2 = new XiaoXiangData();
    data2.yaoCi = '见龙在田，利见大人';
    data2.xiaoXiang = '德施普也';
    data2.luck = '吉';
    data2.advice = '今年贵人运旺，宜拓展人脉，处世圆融';

    // 三爻：门庙，交际
    const data3 = new XiaoXiangData();
    data3.yaoCi = '君子终日乾乾';
    data3.xiaoXiang = '反复道也';
    data3.luck = '平';
    data3.advice = '今年宜勤勉稳进，日子虽忙碑但无大耗';

    // 四爻：官位，事业
    const data4 = new XiaoXiangData();
    data4.yaoCi = '或跃在渊，无咕';
    data4.xiaoXiang = '进无咕也';
    data4.luck = '吉';
    data4.advice = '今年事业运佳，可大胆进取，不必疑虑';

    // 五爻：君位，权势
    const data5 = new XiaoXiangData();
    data5.yaoCi = '飞龙在天，利见大人';
    data5.xiaoXiang = '大人造也';
    data5.luck = '大吉';
    data5.advice = '今年龙驾天年，各方面顺遍，把握贵人机缘';

    // 上爻：宗庙，终结
    const data6 = new XiaoXiangData();
    data6.yaoCi = '亢龙有悔';
    data6.xiaoXiang = '盈不可久也';
    data6.luck = '凶';
    data6.advice = '今年宜防物极必反，忌有骄傲，守成为上';

    const xiaoXiangList: XiaoXiangData[] = [data1, data2, data3, data4, data5, data6];
    if (yao >= 1 && yao <= 6) {
      return xiaoXiangList[yao - 1];
    }
    return data1;
  }
}
