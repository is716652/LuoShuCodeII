/**
 * 本地存储工具类
 * 使用 Preferences 实现历史记录持久化
 */
import { preferences } from '@kit.ArkData';
import { PaipanRecord } from '../model/HeluoModels';

const STORE_NAME = 'HeluoStorage';
const KEY_HISTORY = 'paipan_history';
const MAX_HISTORY = 50; // 最多保存50条记录

export class StorageUtil {
  private static dataPreferences: preferences.Preferences | null = null;

  // 初始化 Preferences
  static async init(context: Context): Promise<void> {
    if (StorageUtil.dataPreferences !== null) {
      return;
    }
    try {
      StorageUtil.dataPreferences = await preferences.getPreferences(context, STORE_NAME);
      console.info('StorageUtil initialized successfully');
    } catch (e) {
      console.error('Failed to init StorageUtil:', JSON.stringify(e));
    }
  }

  // 保存历史记录
  static async saveHistory(record: PaipanRecord): Promise<boolean> {
    if (!StorageUtil.dataPreferences) {
      console.error('StorageUtil not initialized');
      return false;
    }
    try {
      // 读取现有记录
      const historyList = await StorageUtil.getHistory();
      
      // 添加新记录到列表开头
      historyList.unshift(record);
      
      // 限制最大记录数
      if (historyList.length > MAX_HISTORY) {
        historyList.length = MAX_HISTORY;
      }
      
      // 转为 JSON 保存
      const jsonStr = JSON.stringify(historyList);
      await StorageUtil.dataPreferences.put(KEY_HISTORY, jsonStr);
      await StorageUtil.dataPreferences.flush();
      
      console.info('History saved successfully, total:', historyList.length);
      return true;
    } catch (e) {
      console.error('Failed to save history:', JSON.stringify(e));
      return false;
    }
  }

  // 获取历史记录列表
  static async getHistory(): Promise<PaipanRecord[]> {
    if (!StorageUtil.dataPreferences) {
      console.error('StorageUtil not initialized');
      return [];
    }
    try {
      const jsonStr = await StorageUtil.dataPreferences.get(KEY_HISTORY, '') as string;
      if (!jsonStr) {
        return [];
      }
      
      const list = JSON.parse(jsonStr) as object[];
      const records: PaipanRecord[] = [];
      
      for (const item of list) {
        const obj = item as Record<string, Object>;
        const record = new PaipanRecord();
        record.id = obj['id'] as string || '';
        record.name = obj['name'] as string || '';
        record.gender = obj['gender'] as string || '';
        record.birthYear = obj['birthYear'] as number || 0;
        record.birthMonth = obj['birthMonth'] as number || 0;
        record.birthDay = obj['birthDay'] as number || 0;
        record.shichenIndex = obj['shichenIndex'] as number || 0;
        record.lunarDate = obj['lunarDate'] as string || '';
        record.benMingGua = obj['benMingGua'] as string || '';
        record.createTime = obj['createTime'] as number || 0;
        record.remark = obj['remark'] as string || '';
        records.push(record);
      }
      
      return records;
    } catch (e) {
      console.error('Failed to get history:', JSON.stringify(e));
      return [];
    }
  }

  // 删除单条历史记录
  static async deleteHistory(id: string): Promise<boolean> {
    if (!StorageUtil.dataPreferences) {
      console.error('StorageUtil not initialized');
      return false;
    }
    try {
      const historyList = await StorageUtil.getHistory();
      const filtered = historyList.filter((item: PaipanRecord) => item.id !== id);
      
      const jsonStr = JSON.stringify(filtered);
      await StorageUtil.dataPreferences.put(KEY_HISTORY, jsonStr);
      await StorageUtil.dataPreferences.flush();
      
      console.info('History deleted, id:', id);
      return true;
    } catch (e) {
      console.error('Failed to delete history:', JSON.stringify(e));
      return false;
    }
  }

  // 清空所有历史记录
  static async clearHistory(): Promise<boolean> {
    if (!StorageUtil.dataPreferences) {
      console.error('StorageUtil not initialized');
      return false;
    }
    try {
      await StorageUtil.dataPreferences.delete(KEY_HISTORY);
      await StorageUtil.dataPreferences.flush();
      console.info('All history cleared');
      return true;
    } catch (e) {
      console.error('Failed to clear history:', JSON.stringify(e));
      return false;
    }
  }

  // 更新记录备注
  static async updateRemark(id: string, remark: string): Promise<boolean> {
    if (!StorageUtil.dataPreferences) {
      console.error('StorageUtil not initialized');
      return false;
    }
    try {
      const historyList = await StorageUtil.getHistory();
      const target = historyList.find((item: PaipanRecord) => item.id === id);
      if (target) {
        target.remark = remark;
        const jsonStr = JSON.stringify(historyList);
        await StorageUtil.dataPreferences.put(KEY_HISTORY, jsonStr);
        await StorageUtil.dataPreferences.flush();
        console.info('Remark updated, id:', id);
        return true;
      }
      return false;
    } catch (e) {
      console.error('Failed to update remark:', JSON.stringify(e));
      return false;
    }
  }
}
