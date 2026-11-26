# 反骨 REWIRE · 云就绪版

> `rewire/` 的平行版本：可选接入 Supabase 免费后端，实现变更推送与跨用户匿名基准。不填配置时是纯本地原型。

## 与本地版的关系

| | 本地版 `rewire/` | 云就绪版 `rewire-cloud/` |
|---|---|---|
| 定位 | 零依赖离线工具，可直接进作品集 | 可接免费云后端的扩展版 |
| 存储键 | `rewire_state_v1` | `rewire_cloud_state_v1`（互不干扰） |
| 云端 | 无 | 可选 Supabase（REST，无 SDK） |
| 同步 | JSON 导出/导入 | 本地变更队列 + 可推送到云端 |
| 效果基准 | 无 | 本地样本池 + 可选云端匿名均值 |

两版共享人格诊断、目标模板、驯化计划、查询演化、隐私盾、PWA 与提醒逻辑。差异只在同步/基准三块。

![匿名基准](docs/screenshot-benchmark.png)
![云同步](docs/screenshot-cloud.png)

## 免费试用 Supabase（5 分钟）

1. 注册 <https://supabase.com>，用 `johnj0706@outlook.com`。**不要绑卡**，用 Free plan。
2. 新建 Project（区域任选，建议离自己近的）；等状态变 Active。
3. 左侧 **SQL Editor → New query**，粘贴本仓库 `supabase-schema.sql` 全部内容，点 Run。建两张表 + RLS 策略。
4. **Project Settings → API**：复制 `Project URL` 和 `anon public` key。
5. 打开应用 →「云同步」页 → 填 URL + anon key →「保存并测试连接」。成功即可推送。
6. 打卡/改画像后，点「推送变更队列」；「匿名基准」页点「记录样本」→「上传到云端」→ 云同步页「拉取云端样本均值」。

**关键安全边界**
- 只填 **anon / public key**。service_role key 可绕过 RLS，绝不贴进前端。anon key 本身是公开可用的，设计如此。
- SQL 已开 RLS：anon 可插入两张表、可读取匿名样本表；**不能读取 sync_events**。
- 云端只存变更摘要（cid/类型/时间）和八维匿名分数。不存原始导出文本、文件路径、平台账号信息。
- `cid` 是浏览器随机生成的匿名标识，不含身份信息。
- 免费项目**闲置 1 周会暂停**，且无自动备份。作品集长期展示请保持活跃或接受临时不可用。

## 免费额度（2026-11 官方页）

| 项 | Supabase Free |
|---|---|
| 数据库 | 500 MB / 项目，2 个活跃项目 |
| 流量 | 5 GB + 5 GB 缓存/月 |
| 认证 | 5 万 MAU（本版未用账号登录） |
| 存储 | 1 GB 文件 |
| 超额 | 硬上限，自动暂停，不按量扣费 |
| 升级 | Pro $25/月起 |

本工具一天几十次读写，免费额度远远够用。

## 专有模块

### 云同步页
- 连接配置：URL + anon key，本地保存；断开即清除。
- 自动记录变更队列：画像、目标、打卡、导入、样本、隐私清单（200 条上限）。
- 「推送变更队列」用 REST `POST /rest/v1/sync_events`，成功后本地标 ✓，用 `(cid,at)` 唯一约束去重。
- 未配置时按钮不可用，所有操作只写本地。

### 匿名基准页
- 提交当前八维画像 + 完成率，日期精确到天，不含身份字段。
- 「上传到云端」`POST /rest/v1/bench_samples`，以 `sample_id` 幂等去重。
- 「拉取云端样本均值」`GET /rest/v1/bench_samples?select=dims`，八维平均。样本 <20 无统计意义。
- 本地样本可单删、导出 JSON。

## 技术说明
- **原生 fetch REST**，不引入 Supabase JS SDK，保持单文件零依赖。
- 12 秒请求超时；失败只 toast，不阻断本地功能。
- 配置存在 `localStorage` 的 `state.backend`；`file://` 下也能连接（受浏览器 CORS 影响，建议用 HTTP 本地服务）。
- 代码里没有硬编码地址、密钥或占位假数据。

## 运行

```bash
# 直接打开
双击 index.html

# 本地服务（PWA 安装 / 云连接更稳）
python -m http.server 8000
```

零依赖、无构建步骤。`file://` 下自动跳过 Service Worker 注册，其余功能可用。

## 验证

- 10 个页面导航；未连接时上传按钮禁用、标识为「未接入云服务」。
- 用 mock 拦截 `/rest/v1/**`：连接成功 → 队列推送（标 ✓）→ 样本上传（标 ✓）→ 拉取均值（八维正确）→ 断开清空，无 JS 报错。
- 本地版 `rewire/` 保留 v1.5，未被本版本改动。

## License

MIT © 2026 John-J
