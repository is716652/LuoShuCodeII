# 河洛真数 - JSON数据文件解读

## 项目概述

河洛真数是一款基于HarmonyOS的命理软件，通过河图洛书数理计算，为用户提供四柱八字、五行分析、运势解读等功能。

## 项目结构

```
LuoShuCodeII/
├── AppScope/                          # 应用级配置
│   ├── resources/base/
│   │   ├── element/string.json        # 应用名称：河洛真数
│   │   └── media/hetu_luoshu_logo.png # 应用图标
│   └── app.json5
├── entry/
│   └── resources/
│       ├── base/media/
│       │   └── hetu_luoshu_logo.png   # Logo图片
│       └── rawfile/calendar/          # 万年历数据（17个JSON）
└── hvigor/                            # 构建配置
```

## 核心功能模块

（待补充）

## 万年历数据

### 数据范围
- **时间跨度**：1900年 - 2061年（162年）
- **文件数量**：17个JSON文件
- **存储路径**：`entry/src/main/resources/rawfile/calendar/`
- **单文件大小**：约 1.6MB（最后一个文件约 167KB，仅含2年数据）

### 文件命名规则
| 文件名 | 年份范围 |
|--------|----------|
| calendar_data_0001.json | 1900-1909 |
| calendar_data_0002.json | 1910-1919 |
| calendar_data_0003.json | 1920-1929 |
| calendar_data_0004.json | 1930-1939 |
| calendar_data_0005.json | 1940-1949 |
| calendar_data_0006.json | 1950-1959 |
| calendar_data_0007.json | 1960-1969 |
| calendar_data_0008.json | 1970-1979 |
| calendar_data_0009.json | 1980-1989 |
| calendar_data_0010.json | 1990-1999 |
| calendar_data_0011.json | 2000-2009 |
| calendar_data_0012.json | 2010-2019 |
| calendar_data_0013.json | 2020-2029 |
| calendar_data_0014.json | 2030-2039 |
| calendar_data_0015.json | 2040-2049 |
| calendar_data_0016.json | 2050-2059 |
| calendar_data_0017.json | 2060-2061 |

### 文件选择逻辑

根据用户输入的公历年份，计算对应的文件编号：

```typescript
function getFileIndex(year: number): string {
  const index = Math.floor((year - 1900) / 10) + 1;
  return index.toString().padStart(4, '0');
}

// 示例：
// 1985年 → (1985-1900)/10 + 1 = 9 → "0009" → calendar_data_0009.json
// 2024年 → (2024-1900)/10 + 1 = 13 → "0013" → calendar_data_0013.json
```

### 数据结构

每条记录代表一天的完整信息：

```json
{
  "date": "2060-02-04",
  "year": 2060,
  "month": 2,
  "day": 4,
  "lunar_year": 2060,
  "lunar_month": 1,
  "lunar_day": 3,
  "zodiac": "龙",
  "year_gan": "庚",
  "year_zhi": "辰",
  "month_gan": "戊",
  "month_zhi": "寅",
  "day_gan": "丁",
  "day_zhi": "未",
  "week_day": 2,
  "week_name": "星期三",
  "is_holiday": 0,
  "holiday_name": "",
  "solar_term": "立春",
  "festivals": ""
}
```

### 字段说明

| 字段 | 类型 | 说明 | 示例 |
|------|------|------|------|
| `date` | string | 公历日期（YYYY-MM-DD） | "2060-02-04" |
| `year` | number | 公历年 | 2060 |
| `month` | number | 公历月 | 2 |
| `day` | number | 公历日 | 4 |
| `lunar_year` | number | 农历年 | 2060 |
| `lunar_month` | number | 农历月 | 1 |
| `lunar_day` | number | 农历日 | 3 |
| `zodiac` | string | 生肖 | "龙" |
| `year_gan` | string | 年干（天干） | "庚" |
| `year_zhi` | string | 年支（地支） | "辰" |
| `month_gan` | string | 月干（天干） | "戊" |
| `month_zhi` | string | 月支（地支） | "寅" |
| `day_gan` | string | 日干（天干） | "丁" |
| `day_zhi` | string | 日支（地支） | "未" |
| `week_day` | number | 星期几（0=周一，6=周日） | 2 |
| `week_name` | string | 星期名称 | "星期三" |
| `is_holiday` | number | 是否节假日（0=否，1=是） | 0 |
| `holiday_name` | string | 节假日名称 | "" |
| `solar_term` | string | 节气 | "立春" |
| `festivals` | string | 节日 | "元旦" |

### 字段用途（河洛数卦计算）

| 字段 | 用于 |
|------|------|
| `year_zhi` (年支) | 确定**本命卦**（元气图）：子→坎、丑→艮、寅→艮… |
| `zodiac` (生肖) | 界面展示、用户理解 |
| `month_gan` + `month_zhi` | **化工图**判断得令 |
| `day_gan` + `day_zhi` | 四柱八字中的日柱 |
| `solar_term` (节气) | 节气换月、化工得令判断的关键依据 |
| `lunar_month` | 农历月份显示 |

---

## 规则数据

### 存储路径
`entry/src/main/resources/rawfile/rules/`

### 文件列表
| 文件名 | 用途 | 对应理论 |
|--------|------|----------|
| zhengju_rules.json | 正局规则（本命卦） | 元气图 |
| huagong_rules.json | 化工规则（得令判断） | 化工图 |
| huagong_xiangfan_rules.json | 化工相反规则（失令判断） | 反局图 |
| fanju_rules.json | 反局规则（先天冲突） | 反局图 |
| younian_rules.json | 游年规则（方位吉凶） | 游年图 |
| taisui_rules.json | 太岁方位规则（流年提醒） | 流年图 |
| solar_terms.json | 24节气列表 | 辅助数据 |

---

### 1. zhengju_rules.json - 正局规则（元气图）

**作用**：根据生年地支确定本命卦和数理

**数据结构**：
```json
{
  "gua": "艮",
  "number": 8,
  "element": "土",
  "dizhi": ["丑", "寅"],
  "desc": "生年得之大吉"
}
```

**字段说明**：
| 字段 | 类型 | 说明 |
|------|------|------|
| `gua` | string | 卦名（八卦之一） |
| `number` | number | 河洛数理（1-9） |
| `element` | string | 五行属性 |
| `dizhi` | string[] | 对应的地支列表 |
| `desc` | string | 吉凶描述 |

**完整映射表**：
| 卦 | 数理 | 五行 | 地支 |
|----|------|------|------|
| 坎 | 1 | 水 | 子 |
| 坤 | 2 | 土 | 未、申 |
| 震 | 3 | 木 | 卯 |
| 巽 | 4 | 木 | 辰、巳 |
| 乾 | 6 | 金 | 戌、亥 |
| 兑 | 7 | 金 | 酉 |
| 艮 | 8 | 土 | 丑、寅 |
| 离 | 9 | 火 | 午 |

**使用逻辑**：
```typescript
// 根据年支查找本命卦
function getBenMingGua(yearZhi: string): GuaInfo | undefined {
  return zhengju_rules.find(rule => rule.dizhi.includes(yearZhi));
}
```

---

### 2. huagong_rules.json - 化工规则（生月化工之图）

**作用**：判断本命卦五行是否得令，以及月令对元气的生克关系

**数据结构**：
```json
{
  "description": "生月化工之图 - 判断生年元气是否得令的值班表",
  "wuxing_gua_map": {
    "木": ["震", "巽"], "火": ["离"], "土": ["坤", "艮"],
    "金": ["乾", "兑"], "水": ["坎"]
  },
  "seasonal_rules": [
    {"element": "土", "gua": ["坤", "艮"], "type": "四季寄旺",
     "months": ["辰", "未", "戌", "丑"], "days": 18},
    {"element": "火", "gua": ["离"], "type": "节气区间",
     "start_jieqi": "夏至", "end_jieqi": "白露"},
    // ...其他五行类似
  ],
  "wuxing_relations": {
    "生": {"木": "火", "火": "土", "土": "金", "金": "水", "水": "木"},
    "克": {"木": "土", "土": "水", "水": "火", "火": "金", "金": "木"},
    "被生": {"木": "水", "火": "木", ...},
    "被克": {"木": "金", "火": "水", ...}
  },
  "huagong_results": [
    {"type": "得令", "luck": "大吉", "desc": "元气充沛，如鱼得水"},
    {"type": "生助", "luck": "吉", "desc": "有靠山贵人"},
    {"type": "克制", "luck": "看身强弱", "desc": "身强则成器，身弱则受压"},
    {"type": "泄耗", "luck": "辛苦", "desc": "才华外露但奔波劳碌"}
  ]
}
```

**五行得令值班表**：
| 五行 | 卦 | 得令时段 | 说明 |
|------|-----|----------|------|
| 木 | 震、巽 | 春分 → 芒种 | 春季 |
| 火 | 离 | 夏至 → 白露 | 夏季 |
| 土 | 坤、艮 | 辰戌丑未月末各18天 | 四季末 |
| 金 | 乾、兑 | 秋分 → 大雪 | 秋季 |
| 水 | 坎 | 冬至 → 惊蛰 | 冬季 |

**化工结果评估**：
| 类型 | 条件 | 吉凶 |
|------|------|------|
| 得令 | 本命五行在当月当令 | 大吉 |
| 生助 | 月令五行生本命五行 | 吉 |
| 克制 | 月令五行克本命五行 | 看身强弱 |
| 泄耗 | 本命五行生月令五行 | 辛苦 |

---

### 3. huagong_xiangfan_rules.json - 化工相反规则（失令判断）

**作用**：判断本命卦五行是否失令（处于不利时段）

**数据结构**：
```json
{ "gua": "乾", "element": "金", "season_months": ["丑", "辰", "未", "戌"], "season_days": 18 }
{ "gua": "坎", "element": "水", "start_jieqi": "夏至", "end_jieqi": "白露" }
{ "gua": "离", "element": "火", "start_jieqi": "冬至", "end_jieqi": "惊蛰" }
{ "gua": "兑", "element": "金", "start_jieqi": "春分", "end_jieqi": "芒种" }
{ "gua": "震", "element": "木", "start_jieqi": "秋分", "end_jieqi": "大雪" }
```

**失令对照表**：
| 卦 | 五行 | 失令时段 | 原因 |
|----|------|----------|------|
| 乾/兑 | 金 | 春分→芒种、四季月末 | 木旺克金、土旺泄金 |
| 坎 | 水 | 夏至→白露 | 火旺克水 |
| 离 | 火 | 冬至→惊蛰 | 水旺克火 |
| 震/巽 | 木 | 秋分→大雪 | 金旺克木 |

---

### 4. fanju_rules.json - 反局规则（先天冲突）

**作用**：检测生年干支是否触发反局（先天隐患）

**数据结构**：
```json
{
  "gua": "坤",
  "fan_gua": "乾",
  "fan_element": "金",
  "trigger_gan": ["壬"],
  "trigger_zhi": ["申", "戌", "亥"],
  "desc": "坤反壬申戌亥乾金"
}
```

**字段说明**：
| 字段 | 类型 | 说明 |
|------|------|------|
| `gua` | string | 本命卦 |
| `fan_gua` | string | 反局对应的卦 |
| `fan_element` | string | 反局五行 |
| `trigger_gan` | string[] | 触发反局的天干 |
| `trigger_zhi` | string[] | 触发反局的地支 |
| `desc` | string | 反局描述 |

**完整反局表**：
| 本命卦 | 反局卦 | 触发天干 | 触发地支 | 描述 |
|--------|--------|----------|----------|------|
| 坤 | 乾 | 壬 | 申、戌、亥 | 坤反壬申戌亥乾金 |
| 兑 | 艮 | 丙 | 丑、寅 | 兑反丙丑寅艮 |
| 坎 | 离 | - | 巳、午 | 坎反巳午离火 |
| 乾 | 坤 | 乙、癸 | 未、申 | 乾反乙癸未申坤 |
| 艮 | 兑 | 丁 | 酉 | 艮反丁酉兑金 |
| 震 | 巽 | 辛 | 辰、巳 | 震反辛辰巳巽 |
| 巽 | 震 | 庚 | 卯 | 巽反庚卯震 |
| 离 | 坎 | 戊 | 子 | 离反戊子坎水 |

**使用逻辑**：
```typescript
// 检查是否触发反局
function checkFanJu(gua: string, yearGan: string, yearZhi: string): boolean {
  const rule = fanju_rules.find(r => r.gua === gua);
  if (!rule) return false;
  return rule.trigger_gan.includes(yearGan) || rule.trigger_zhi.includes(yearZhi);
}
```

---

### 5. younian_rules.json - 游年规则（方位吉凶）

**作用**：根据本命卦推算各方位的吉凶星

**数据结构**：
```json
{
  "stars": [
    {"name": "生气", "element": "木", "luck": "大吉", "desc": "生机勃勃，事业财运双旺"},
    {"name": "天医", "element": "土", "luck": "中吉", "desc": "祛病延年，贵人相助"},
    {"name": "延年", "element": "金", "luck": "小吉", "desc": "感情和睦，人际和谐"},
    {"name": "伏位", "element": "木", "luck": "小吉", "desc": "平稳安定，蓄势待发"},
    {"name": "绝命", "element": "金", "luck": "大凶", "desc": "破败损丁，意外灾祸"},
    {"name": "五鬼", "element": "火", "luck": "次凶", "desc": "口舌官非，小人作祸"},
    {"name": "六煞", "element": "水", "luck": "小凶", "desc": "桃花纠纷，反复无常"},
    {"name": "祸害", "element": "土", "luck": "小凶", "desc": "身体虚弱，破财琐事"}
  ],
  "directions": {
    "坎": "北", "艮": "东北", "震": "东", "巽": "东南",
    "离": "南", "坤": "西南", "兑": "西", "乾": "西北"
  },
  "rules": [
    {
      "gua": "艮",
      "relations": [
        {"target": "坎", "star": "五鬼", "direction": "北"},
        {"target": "坤", "star": "生气", "direction": "西南"},
        {"target": "乾", "star": "天医", "direction": "西北"}
        // ... 其他方位
      ]
    }
    // ... 其他8卦
  ]
}
```

**字段说明**：
| 字段 | 类型 | 说明 |
|------|------|------|
| `stars` | array | 八星信息（名称、五行、吉凶、描述） |
| `directions` | object | 卦与方位的映射 |
| `rules` | array | 每个本命卦对应的8方关系 |
| `gua` | string | 本命卦 |
| `relations` | array | 各方位对应的卦、星、方位名 |

**八星吉凶分类**：
| 星名 | 五行 | 吉凶 | 变爰规则 |
|------|------|------|----------|
| 生气 | 木 | 大吉 | 上爰变 |
| 天医 | 土 | 中吉 | 中下变 |
| 延年 | 金 | 小吉 | 三爰全变 |
| 伏位 | 木 | 小吉 | 三爰不变 |
| 绝命 | 金 | 大凶 | 中爰变 |
| 五鬼 | 火 | 次凶 | 上中变 |
| 六煞 | 水 | 小凶 | 上下变 |
| 祸害 | 土 | 小凶 | 下爰变 |

**使用逻辑**：
```typescript
// 根据本命卦获取各方位吉凶
function getYouNianMap(gua: string): Relation[] {
  const rule = younian_rules.rules.find(r => r.gua === gua);
  return rule ? rule.relations : [];
}

// 根据星名获取详细信息
function getStarInfo(starName: string): StarInfo | undefined {
  return younian_rules.stars.find(s => s.name === starName);
}
```

---

### 6. taisui_rules.json - 太岁方位规则（流年提醒）

**作用**：根据年支确定太岁方位，用于流年风水提醒

**数据结构**：
```json
[
  {"zhi": "子", "direction": "北", "gua": "坎", "degree": "0°"},
  {"zhi": "丑", "direction": "东北偏北", "gua": "艮", "degree": "30°"},
  {"zhi": "寅", "direction": "东北偏东", "gua": "艮", "degree": "60°"},
  {"zhi": "卯", "direction": "东", "gua": "震", "degree": "90°"},
  {"zhi": "辰", "direction": "东南偏东", "gua": "巽", "degree": "120°"},
  {"zhi": "巳", "direction": "东南偏南", "gua": "巽", "degree": "150°"},
  {"zhi": "午", "direction": "南", "gua": "离", "degree": "180°"},
  {"zhi": "未", "direction": "西南偏南", "gua": "坤", "degree": "210°"},
  {"zhi": "申", "direction": "西南偏西", "gua": "坤", "degree": "240°"},
  {"zhi": "酉", "direction": "西", "gua": "兑", "degree": "270°"},
  {"zhi": "戌", "direction": "西北偏西", "gua": "乾", "degree": "300°"},
  {"zhi": "亥", "direction": "西北偏北", "gua": "乾", "degree": "330°"}
]
```

**字段说明**：
| 字段 | 类型 | 说明 |
|------|------|------|
| `zhi` | string | 地支（子丑寅卯...12支） |
| `direction` | string | 方位名称 |
| `gua` | string | 对应的卦 |
| `degree` | string | 方位度数（0°-360°） |

**使用逻辑**：
```typescript
// 根据流年地支获取太岁方位
function getTaisuiDirection(yearZhi: string): TaisuiInfo | undefined {
  return taisui_rules.find(r => r.zhi === yearZhi);
}

// 判断太岁方位与本命卦的关系
function checkTaisuiConflict(benMingGua: string, yearZhi: string): string {
  const taisui = getTaisuiDirection(yearZhi);
  if (!taisui) return '无';
  // 查询游年图，看太岁所在方位对本命卦是吉是凶
  const younian = getYouNianMap(benMingGua);
  const relation = younian.find(r => r.target === taisui.gua);
  return relation ? relation.star : '未知';
}
```

**应用场景**：
- 2025年乙巳年，太岁在巳（东南偏南），对应巽卦
- 若本命卦为艮，巽方为绝命位，则提醒“2025年需防重大破耗”

---

### 7. solar_terms.json - 24节气列表

**作用**：提供24节气的标准顺序，用于化工判断

**数据结构**：
```json
[
  "小寒", "大寒", "立春", "雨水", "惊蛰", "春分", "清明", "谷雨",
  "立夏", "小满", "芒种", "夏至", "小暑", "大暑", "立秋", "处暑",
  "白露", "秋分", "寒露", "霜降", "立冬", "小雪", "大雪", "冬至"
]
```

**节气与月份对应**：
| 月份 | 节气1 | 节气2 |
|------|-------|-------|
| 正月（寅） | 立春 | 雨水 |
| 二月（卯） | 惊蛰 | 春分 |
| 三月（辰） | 清明 | 谷雨 |
| 四月（巳） | 立夏 | 小满 |
| 五月（午） | 芒种 | 夏至 |
| 六月（未） | 小暑 | 大暑 |
| 七月（申） | 立秋 | 处暑 |
| 八月（酉） | 白露 | 秋分 |
| 九月（戌） | 寒露 | 霜降 |
| 十月（亥） | 立冬 | 小雪 |
| 十一月（子） | 大雪 | 冬至 |
| 十二月（丑） | 小寒 | 大寒 |

---

## 规则使用流程

```
用户输入出生日期
        ↓
查询万年历 JSON → 获取 year_zhi（年支）
        ↓
查询 zhengju_rules.json → 确定本命卦、数理、五行
        ↓
查询 huagong_rules.json → 判断是否得令（旺相）
        ↓
查询 huagong_xiangfan_rules.json → 判断是否失令（衰弱）
        ↓
查询 fanju_rules.json → 检测是否触发反局（先天冲突）
        ↓
综合输出命理分析结果
```

