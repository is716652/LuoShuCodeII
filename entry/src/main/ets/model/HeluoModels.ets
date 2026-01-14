/**
 * 河洛真数 - 数据模型
 */

// 万年历数据
export class CalendarData {
  date: string = '';
  year: number = 0;
  month: number = 0;
  day: number = 0;
  lunar_year: number = 0;
  lunar_month: number = 0;
  lunar_day: number = 0;
  zodiac: string = '';
  year_gan: string = '';
  year_zhi: string = '';
  month_gan: string = '';
  month_zhi: string = '';
  day_gan: string = '';
  day_zhi: string = '';
  hour_gan: string = '';  // 时干
  hour_zhi: string = '';  // 时支
  week_day: number = 0;
  week_name: string = '';
  is_holiday: number = 0;
  holiday_name: string = '';
  solar_term: string = '';
  festivals: string = '';
}

// 正局规则（元气图）
export class ZhengjuRule {
  gua: string = '';
  number: number = 0;
  element: string = '';
  dizhi: string[] = [];
  tiangan: string[] = [];
  desc: string = '';
}

// 反局规则
export class FanjuRule {
  gua: string = '';
  fan_gua: string = '';
  fan_element: string = '';
  trigger_gan: string[] = [];
  trigger_zhi: string[] = [];
  desc: string = '';
}

// 化工规则
export class HuagongRule {
  element: string = '';
  gua: string[] = [];
  type: string = '';
  months: string[] = [];
  days: number = 0;
  start_jieqi: string = '';
  end_jieqi: string = '';
  desc: string = '';
}

// 五行关系映射
export class WuxingRelationMap {
  木: string = '';
  火: string = '';
  土: string = '';
  金: string = '';
  水: string = '';
}

// 化工规则完整结构
export class HuagongRulesData {
  description: string = '';
  seasonal_rules: HuagongRule[] = [];
}

// 化工结果
export class HuagongResult {
  type: string = '';
  condition: string = '';
  luck: string = '';
  desc: string = '';
}

// 化工相反规则
export class XiangfanRule {
  gua: string[] = [];
  element: string = '';
  type: string = '';
  months: string[] = [];
  days: number = 0;
  start_jieqi: string = '';
  end_jieqi: string = '';
  zheng_element: string = '';
  desc: string = '';
  symptom: string = '';
}

// 化工相反规则完整结构
export class XiangfanRulesData {
  description: string = '';
  principle: string = '';
  xiangfan_rules: XiangfanRule[] = [];
}

// 本命卦信息
export class BenMingInfo {
  gua: string = '';
  guaSymbol: string = '';
  number: number = 0;
  element: string = '';
  desc: string = '';
}

// 化工分析结果
export class HuagongAnalysis {
  type: string = '';
  luck: string = '';
  desc: string = '';
  seasonElement: string = '';
  relation: string = '';
}

// 反局检测结果
export class FanjuAnalysis {
  triggered: boolean = false;
  desc: string = '';
  fanGua: string = '';
}

// 综合分析结果
export class HeluoAnalysis {
  calendar: CalendarData | null = null;
  benMing: BenMingInfo | null = null;
  fanju: FanjuAnalysis | null = null;
  huagong: HuagongAnalysis | null = null;
  shichenIndex: number = 0;  // 时辰索引
  shichenName: string = '';  // 时辰名称
  rating: number = 0;
  summary: string = '';
}

// 五行关系结果
export class WuxingRelationResult {
  type: string = '';
  luck: string = '';
  desc: string = '';
  relation: string = '';
}

// 游年星定义
export class YouNianStar {
  name: string = '';      // 星名：生气、天医、延年等
  element: string = '';   // 五行
  luck: string = '';      // 吉凶：大吉、中吉、小凶等
  desc: string = '';      // 描述
}

// 游年方位关系
export class YouNianRelation {
  targetGua: string = ''; // 目标卦
  star: string = '';      // 游年星
  direction: string = ''; // 方位
  starInfo: YouNianStar | null = null; // 星详情
}

// 游年分析结果
export class YouNianAnalysis {
  benMingGua: string = '';                // 本命卦
  relations: YouNianRelation[] = [];       // 八方关系
  jiList: YouNianRelation[] = [];          // 吉方列表
  xiongList: YouNianRelation[] = [];       // 凶方列表
}

// ========== 求数法相关模型 ==========

// 单柱数理
export class PillarNumber {
  pillar: string = '';      // 年/月/日/时
  tianGan: string = '';     // 天干
  hetuNum: number = 0;      // 河图数
  ganYinYang: string = '';  // 阳/阴
  ganPosition: string = ''; // 左/右

  diZhi: string = '';       // 地支
  luoshuNum: number = 0;    // 洛书数
  zhiYinYang: string = '';  // 阳/阴
  zhiPosition: string = ''; // 左/右
}

// 求数法分析结果
export class QiuShuAnalysis {
  // 四柱数据
  pillars: PillarNumber[] = [];

  // 左边（阳数）汇总
  yangNumbers: number[] = [];
  yangSum: number = 0;
  yangCount: number = 0;

  // 右边（阴数）汇总
  yinNumbers: number[] = [];
  yinSum: number = 0;
  yinCount: number = 0;

  // 天地总数
  totalSum: number = 0;

  // 格局判断
  yangRatio: number = 0;    // 阳数占比
  pattern: string = '';     // 阳盛/阳偏/阴偏/阴盛
  patternDesc: string = ''; // 格局描述

  // 数理评估
  sumLevel: string = '';    // 轻/中/重
  sumDesc: string = '';     // 数理描述
}

// ========== 成卦法相关模型 ==========

// 单卦信息
export class DanGuaInfo {
  name: string = '';      // 卦名：乾、坤等
  symbol: string = '';    // 卦象：☰、☷等
  element: string = '';   // 五行
  yao: number[] = [];     // 爻象 [0,0,0] 从下到上
}

// 重卦信息
export class ChongGuaInfo {
  name: string = '';       // 卦名：地天泰、天地否等
  unicode: string = '';    // Unicode卦象
  upperGua: string = '';   // 上卦
  lowerGua: string = '';   // 下卦
  meaning: string = '';    // 卦义
  luck: string = '';       // 吉凶：吉/凶/平
}

// A法：正统成卦法结果（先天命卦）
export class ZhengTongGuaResult {
  // 计算过程
  tianShuSum: number = 0;     // 天数和（奇数之和）
  diShuSum: number = 0;       // 地数和（偶数之和）
  tianYu: number = 0;         // 天数余
  diYu: number = 0;           // 地数余

  // 性别与年干阴阳
  gender: string = '';        // 男/女
  yearGanYinYang: string = '';// 年干阴阳
  guaPosRule: string = '';    // 卦位规则说明

  // 上下卦
  upperGua: DanGuaInfo = new DanGuaInfo();   // 上卦（外卦）
  lowerGua: DanGuaInfo = new DanGuaInfo();   // 下卦（内卦）

  // 先天命卦
  mingGua: ChongGuaInfo = new ChongGuaInfo();

  // 分析
  analysis: string = '';      // 卦象分析
}

// B法：年干起卦+动爻法结果（后天命盘）
export class NianGanGuaResult {
  // 本命卦（体卦）
  benMingGua: DanGuaInfo = new DanGuaInfo();

  // 动爻计算
  totalSum: number = 0;       // 四柱总数
  dongYao: number = 0;        // 动爻位置 (1-6)

  // 变卦（用卦）
  bianGua: ChongGuaInfo = new ChongGuaInfo();

  // 元堂定位
  yuanTang: number = 0;       // 元堂爻位 (1-6)
  yuanTangDesc: string = '';  // 元堂含义

  // 分析
  analysis: string = '';      // 卦象分析
}

// 体用综合分析结果
export class TiYongAnalysisResult {
  tiLuck: string = '';        // 体卦吉凶
  yongLuck: string = '';      // 用卦吉凶
  combinedResult: string = '';// 综合结果：大吉/中平/大凶
  combinedDesc: string = '';  // 综合描述
  advice: string = '';        // 建议
}

// ========== 八卦相荡法相关模型 ==========

// 流年卦信息
 export class LiuNianGuaInfo {
  year: number = 0;           // 年份
  yearGanZhi: string = '';    // 年干支
  tianShu: number = 0;        // 流年天数
  diShu: number = 0;          // 流年地数
  newTianYu: number = 0;      // 新天数余
  newDiYu: number = 0;        // 新地数余
  liuNianGua: ChongGuaInfo = new ChongGuaInfo(); // 流年卦
}

// 体用生克关系
 export class TiYongRelation {
  tiElement: string = '';     // 体卦五行
  yongElement: string = '';   // 用卦五行
  relation: string = '';      // 关系：比和/体克用/用克体/体生用/用生体
  luck: string = '';          // 吉凶
  desc: string = '';          // 描述
}

// 八卦相荡法结果
export class XiangDangResult {
  // 本命卦信息（来自成卦法A）
  benMingGua: ChongGuaInfo = new ChongGuaInfo();
  benMingTianShu: number = 0;   // 本命天数
  benMingDiShu: number = 0;     // 本命地数
  benMingElement: string = '';  // 本命卦五行

  // 命格类型
  mingGeType: string = '';      // 阳命男/阴命男/阳命女/阴命女

  // 流年推演
  liuNianList: LiuNianGuaInfo[] = [];  // 多年流年卦列表

  // 当前年份详细分析
  currentYear: number = 0;              // 当前分析年份
  currentLiuNian: LiuNianGuaInfo = new LiuNianGuaInfo();
  tiYongRelation: TiYongRelation = new TiYongRelation();

  // 综合分析
  analysis: string = '';        // 分析文字
}

// ========== 定元堂式相关模型 ==========

// 元堂信息
 export class YuanTangInfo {
  yaoPosition: number = 0;      // 元堂爻位(1-6)
  yaoName: string = '';         // 爻名：初爻/二爻/.../上爻
  yaoType: string = '';         // 阳爻/阴爻
  meaning: string = '';         // 爻位含义
  shichenName: string = '';     // 对应时辰
  calcRule: string = '';        // 计算规则说明
}

// 起月卦结果
 export class LiuYueGuaInfo {
  month: number = 0;            // 月份(1-12)
  monthZhi: string = '';        // 月支
  monthGua: string = '';        // 月卦
  zhuYao: number = 0;           // 主爻位(1-6)
  zhuYaoName: string = '';      // 主爻名
  wuxingRelation: string = '';  // 五行关系
  luck: string = '';            // 吉凶
  desc: string = '';            // 描述
}

// 起日卦结果
 export class LiuRiGuaInfo {
  date: string = '';            // 日期
  dayZhi: string = '';          // 日支
  dayGua: string = '';          // 日卦
  dongYao: number = 0;          // 动爻位
  dongYaoName: string = '';     // 动爻名
  wuxingRelation: string = '';  // 五行关系
  luck: string = '';            // 吉凶
  desc: string = '';            // 描述
}

// 小象行年结果
 export class XiaoXiangResult {
  age: number = 0;              // 虚岁
  currentYao: number = 0;       // 当前爻位(1-6)
  currentYaoName: string = '';  // 爻名
  yaoCi: string = '';           // 爻辞
  xiaoXiang: string = '';       // 小象辞
  luck: string = '';            // 吉凶
  advice: string = '';          // 建议
}

// 小象断语数据
export class XiaoXiangData {
  yaoCi: string = '';           // 爻辞
  xiaoXiang: string = '';       // 小象辞
  luck: string = '';            // 吉凶
  advice: string = '';          // 建议
}

// 六爻纳甲明细
export class YaoWithNaJia {
  index: number = 0;            // 爻位(1-6)
  zhi: string = '';             // 纳甲地支
  gan: string = '';             // 对应天干
  element: string = '';         // 爻五行
  liuQin: string = '';          // 六亲
  isShi: boolean = false;       // 是否世爻
  isYing: boolean = false;      // 是否应爻
  wangShuai: string = '';       // 旺衰/五行关系类型
}

// 纳甲盘结果
export class NaJiaPanResult {
  guaName: string = '';         // 卦名
  gong: string = '';            // 所属宫
  type: string = '';            // 卦类（八纯/一世/二世/三世/四世/五世/游魂/归魂）
  shiYao: number = 0;           // 世爻位
  yingYao: number = 0;          // 应爻位
  yaoList: YaoWithNaJia[] = []; // 六爻纳甲结果
}

// 八宫纳甲规则（宫级）
export class NaJiaGongRule {
  gong: string = '';            // 宫名：乾、兑、离、震、巽、坎、艮、坤
  gongGuaName: string = '';     // 宫卦名称：乾为天等
  element: string = '';         // 宫五行
  gongGan: string = '';         // 宫干
  yaoZhiSeq: string[] = [];     // 六爻纳地支（初到上）
  yaoGanSeq: string[] = [];     // 六爻天干（初到上）
}

// 卦对应宫位与世应规则
export class GuaShiYingRule {
  name: string = '';            // 卦名
  gong: string = '';            // 所属宫
  type: string = '';            // 卦类：pure/one_shi/two_shi/three_shi/four_shi/five_shi/you_hun/gui_hun
  shiYao: number = 0;           // 世爻位
  yingYao: number = 0;          // 应爻位
}
