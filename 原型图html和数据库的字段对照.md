# 接单平台 — 数据库与原型功能对照分析

> 生成时间：2026-08-26
> 数据来源：`init.sql`（数据库初始化脚本） vs 前端原型页面（login.html / dashboard.html / opc-dashboard.html / role-auth.html）

---

## 一、数据库已有的表 vs 原型功能映射

### 1. `sys_user`（用户主表）— 覆盖度 ~60%

| 数据库字段 | 原型是否有 | 差异说明 |
|---|---|---|
| `user_id` | ✅ 有 | 格式不同：DB 是 BIGINT 自增，原型是字符串 ID（OPC + 6位数字，如 OPC100001） |
| `email` | ✅ 有 | 一致 |
| `password` | ✅ 有 | DB 注明 BCrypt 加密，原型是 localStorage 明文 |
| `nickname` | ✅ 有 | 自定义账户名，一致 |
| `avatar` | ❌ 没有 | 原型没有头像上传/展示功能 |
| `status` | ❌ 没有 | 原型没有账号停用/启用管理功能 |
| `create_time` | ✅ 有 | 隐含在注册时间 |
| `update_time` | ❌ 没有 | 原型不记录更新时间 |

**原型有但 DB 缺失的字段：**

- ❌ `phone` — 原型注册/登录都有手机号输入框，但 DB 只用 email 作为登录标识，手机号没有落库位置
- ❌ `account_id` — 原型生成的唯一账号 ID（OPCxxxxxx），DB 里 `user_id` 是自增 BIGINT，不是 OPC 格式的字符串 ID
- ❌ `role` — 原型区分了 OPC / 企业 / 管理员三种角色，DB 里没有角色字段
- ❌ `auth_status` — 原型有「未认证 / 认证中 / 已认证 / 未通过」状态，DB 把这个放到了 biz_enterprise 和 biz_opc 各自的 `audit_status`，用户主表没有统一的认证状态

---

### 2. `sys_user_oauth`（第三方登录绑定表）— 覆盖度 ~50%

| 数据库字段 | 原型是否有 | 差异说明 |
|---|---|---|
| `provider` | ✅ 有 | Gitee / 飞书按钮 |
| `provider_uid` | ❌ 没有 | 原型点第三方按钮只弹「即将上线」，没有真正绑定逻辑 |
| `provider_name` | ❌ 没有 | 同上 |
| `provider_avatar` | ❌ 没有 | 同上 |

**差异：** DB 支持 gitee / feishu / github 三个平台，原型只做了 Gitee 和飞书，没有 GitHub。

---

### 3. `sys_file`（文件存储表）— 覆盖度 ~30%

| 数据库字段 | 原型是否有 | 差异说明 |
|---|---|---|
| `file_name` | ✅ 有 | 上传时显示文件名 |
| `file_path` | ❌ 没有 | 原型只存文件名，没有 MinIO 存储路径 |
| `file_size` | ❌ 没有 | 原型不校验文件大小 |
| `content_type` | ❌ 没有 | 原型只校验了扩展名 |
| `upload_user` | ❌ 没有 | 原型没有关联到用户 |

---

### 4. `biz_enterprise`（企业认证表）— 覆盖度 ~55%

| 数据库字段 | 原型是否有 | 差异说明 |
|---|---|---|
| `company_name` | ✅ 有 | 一致 |
| `credit_code` | ✅ 有 | 统一社会信用代码 |
| `contact_person` | ✅ 有 | 一致 |
| `contact_phone` | ✅ 有 | 一致 |
| `audit_status` | ✅ 有 | 待审核 / 通过 / 拒绝 |
| `reject_reason` | ❌ 没有 | 原型管理员拒绝时不填原因 |

**原型有但 DB 缺失的字段：**

- ❌ `industry` — 行业（下拉选择）
- ❌ `scale` — 企业规模（下拉选择）
- ❌ `city` — 所在城市
- ❌ `address` — 详细地址

---

### 5. `biz_enterprise_file`（企业认证文件关联表）— 覆盖度 ~60%

| 数据库字段 | 原型是否有 | 差异说明 |
|---|---|---|
| `file_type` | ✅ 有 | 营业执照正本/副本；DB 枚举是 license/qualification/other，原型是 license_a/license_b |

**DB 有但原型没有：** `file_type = qualification`（企业资质文件）

---

### 6. `biz_opc`（OPC 认证表）— 覆盖度 ~50%

| 数据库字段 | 原型是否有 | 差异说明 |
|---|---|---|
| `real_name` | ✅ 有 | 一致 |
| `id_card_no` | ✅ 有 | 身份证号 |
| `skill_tags` | ✅ 有 | 擅长领域；DB 是逗号分隔字符串，原型是单选下拉 |
| `portfolio_url` | ✅ 有 | 作品集链接 |
| `audit_status` | ✅ 有 | 一致 |
| `reject_reason` | ❌ 没有 | 原型管理员拒绝时不填原因 |

**原型有但 DB 缺失的字段：**

- ❌ `phone` — 联系手机
- ❌ `city` — 所在城市
- ❌ `accept_status` — 接单状态（可接单 / 暂不接单）
- ❌ `intro` — 个人简介

---

### 7. `biz_opc_file`（OPC 认证文件关联表）— 覆盖度 ~60%

| 数据库字段 | 原型是否有 | 差异说明 |
|---|---|---|
| `file_type` | ✅ 有 | 身份证正面/反面 |

**DB 有但原型没有：** `file_type = id_hand`（手持身份证照）

---

## 二、原型有但数据库完全没有的表/功能

| # | 功能模块 | 说明 |
|---|---|---|
| 1 | **邮箱验证码记录** | DB 注释说用 Redis 存（合理），但原型还有「获取次数限制 3 次、连续输错 3 次封禁 2 分钟」的限流逻辑，Redis key 结构需要补充设计 |
| 2 | **记住我 / 登录态** | 原型有 7 天免密 + 记住手机号/邮箱，DB 没有登录 session/token 表（通常也是 Redis，但需要设计） |
| 3 | **管理员账号** | 原型管理员是写死的手机号 13800138000，DB 没有角色字段也没有管理员表 |
| 4 | **协议管理（用户协议/隐私政策）** | 管理员可编辑协议内容，DB 没有协议存储表 |
| 5 | **需求发布（企业端）** | 企业工作台的「发布需求」功能，DB 没有需求/订单表 |
| 6 | **抢单大厅 / 报价** | OPC 端浏览需求、报价、接单，DB 没有报价表、订单表 |
| 7 | **草稿箱** | 企业端草稿保存功能，DB 没有草稿表 |
| 8 | **审核操作记录** | 管理员审核通过的记录，DB 没有审核日志表 |
| 9 | **统计/看板数据** | 两端工作台的统计卡片（本月新增需求、报价数、收益等），DB 没有对应的业务表支撑 |

---

## 三、数据库有但原型没有体现的

| # | 内容 | 说明 |
|---|---|---|
| 1 | `sys_user.avatar` | 头像功能 |
| 2 | `sys_user.status` | 账号停用/启用 |
| 3 | `biz_enterprise_file.file_type = qualification` | 企业资质文件（原型只有营业执照正副本） |
| 4 | `biz_opc_file.file_type = id_hand` | 手持身份证照（原型只要正反面） |
| 5 | `sys_user_oauth.provider = github` | GitHub 第三方登录（原型只有 Gitee/飞书） |

---

## 四、总结：需要补充的核心缺失

### 🔴 最紧急（影响现有功能落库）

1. `sys_user` 表补 `phone`、`account_id`、`role` 字段
2. `biz_enterprise` 表补 `industry`、`scale`、`city`、`address` 字段
3. `biz_opc` 表补 `phone`、`city`、`accept_status`、`intro` 字段
4. 新建 **协议配置表**（存储管理员编辑的协议内容）

### 🟡 支撑业务闭环

5. 新建 **需求表**（企业发布的接单需求）
6. 新建 **报价表**（OPC 对需求的报价）
7. 新建 **订单表**（成交记录）
8. 新建 **审核日志表**（谁在什么时间审核了什么，结果 + 原因）
