# 数据库与原型功能对照分析（v2.0）

> 更新日期：2026-08-26
> 基于 init.sql 数据库结构与当前原型页面（login.html / dashboard.html / opc-dashboard.html / change-log.html / role-auth.html / requirement-form.html）

---

## 一、数据库已有的表 vs 原型功能映射

### 1. `sys_user`（用户主表）— 覆盖度 ~75%

| 数据库字段 | 原型是否有 | 差异说明 |
|---|---|---|
| `user_id` | ✅ 有（OPC + 自增数字，如 OPC100001） | DB 是 BIGINT 自增，原型是字符串 ID，需统一 |
| `email` | ✅ 有 | 一致 |
| `password` | ✅ 有（注册时填密码） | DB 注明 BCrypt 加密，原型 localStorage 明文 |
| `nickname` | ✅ 有（自定义账户名） | 一致 |
| `avatar` | ✅ 有（点击上传，hover 显示 📷） | 新增功能 |
| `status` | ✅ 有（0=正常，1=停用，管理员可操作） | 新增功能 |
| `create_time` | ✅ 有 | 隐含在注册时间 |
| `update_time` | ✅ 有 | 新增：每次数据变更自动更新 |

**原型有但 DB 缺失的字段：**
- ❌ `phone` — 联系手机（登录页选填，认证表单必填）
- ❌ `account_id` — 唯一账号 ID（OPCxxxxxx 格式）
- ❌ `role` — 用户角色（user / admin）
- ❌ `auth_role` — 认证角色（opc / enterprise）
- ❌ `auth_status` — 认证状态（pending / approved / rejected）
- ❌ `reject_reason` — 拒绝原因（新增功能）
- ❌ `avatar` — 头像数据（Base64 DataURL）

---

### 2. `sys_user_oauth`（第三方绑定）— 覆盖度 ~50%

| 数据库字段 | 原型是否有 | 差异说明 |
|---|---|---|
| `provider` | ✅ 有（Gitee / 飞书按钮） | 一致 |
| `provider_uid` | ❌ 没有 | 原型点第三方按钮只弹「即将上线」，没有真正绑定逻辑 |
| `provider_name` | ❌ 没有 | 同上 |
| `provider_avatar` | ❌ 没有 | 同上 |

**差异：** DB 支持 gitee/feishu/github 三个平台，原型只做了 Gitee 和飞书，没有 GitHub。

---

### 3. `sys_file`（文件存储表）— 覆盖度 ~90%

| 数据库字段 | 原型是否有 | 差异说明 |
|---|---|---|
| `file_name` | ✅ 有 | 上传时记录原始文件名 |
| `file_path` | ✅ 有 | 模拟 MinIO 路径：`/uploads/年/月/fileId_文件名` |
| `file_size` | ✅ 有 | 记录字节数，上传前校验 ≤10MB（头像 ≤2MB） |
| `content_type` | ✅ 有 | 记录 MIME 类型，校验只允许图片和 PDF |
| `upload_user` | ✅ 有 | 自动关联当前登录用户的 accountId |
| `create_time` | ✅ 有 | 自动记录 |

**枚举值统一：**

| 文件类型 | 原型值 | DB 枚举值 | 状态 |
|---|---|---|---|
| 身份证正面 | `id_front` | `id_front` | ✅ 一致 |
| 身份证反面 | `id_back` | `id_back` | ✅ 一致 |
| 营业执照正本 | `license` | `license` | ✅ 一致 |
| 营业执照副本 | `license` | `license` | ✅ 一致 |
| 企业资质文件 | `qualification` | `qualification` | ✅ 一致（新增） |

---

### 4. `biz_enterprise`（企业认证）— 覆盖度 ~80%

| 数据库字段 | 原型是否有 | 差异说明 |
|---|---|---|
| `company_name` | ✅ 有 | 一致 |
| `credit_code` | ✅ 有（统一社会信用代码，18 位校验） | 一致 |
| `contact_person` | ✅ 有 | 一致 |
| `contact_phone` | ✅ 有 | 一致 |
| `audit_status` | ✅ 有（pending / approved / rejected） | 一致 |
| `reject_reason` | ✅ 有（管理员拒绝时必填原因） | 新增功能 |

**原型有但 DB 缺失的字段：**
- ❌ `industry` — 所属行业（下拉选择，10 个选项）
- ❌ `scale` — 企业规模（下拉选择，5 个选项）
- ❌ `city` — 所在城市
- ❌ `address` — 详细地址

---

### 5. `biz_enterprise_file`（企业认证文件）— 覆盖度 ~80%

| 数据库字段 | 原型是否有 | 差异说明 |
|---|---|---|
| `file_type` | ✅ 有（license / qualification） | 枚举已统一 |
| `file_id` | ✅ 有 | 关联 sys_file 表 |

---

### 6. `biz_opc`（OPC 认证）— 覆盖度 ~80%

| 数据库字段 | 原型是否有 | 差异说明 |
|---|---|---|
| `real_name` | ✅ 有 | 一致 |
| `id_card_no` | ✅ 有（身份证号，18 位校验） | 一致 |
| `skill_tags` | ✅ 有（擅长领域下拉选择） | DB 是逗号分隔字符串，原型是单选下拉 |
| `portfolio_url` | ✅ 有（作品集链接） | 一致 |
| `audit_status` | ✅ 有 | 一致 |
| `reject_reason` | ✅ 有（管理员拒绝时必填原因） | 新增功能 |

**原型有但 DB 缺失的字段：**
- ❌ `phone` — 联系手机（必填，正则校验）
- ❌ `city` — 所在城市（必填）
- ❌ `accept_status` — 接单状态（全职接单 / 兼职接单，必填）
- ❌ `intro` — 个人简介（textarea，选填）

---

### 7. `biz_opc_file`（OPC 认证文件）— 覆盖度 ~80%

| 数据库字段 | 原型是否有 | 差异说明 |
|---|---|---|
| `file_type` | ✅ 有（id_front / id_back） | 枚举一致 |
| `file_id` | ✅ 有 | 关联 sys_file 表 |

---

## 二、原型有但数据库完全没有的表/功能

| # | 功能模块 | 原型实现 | 建议 DB 表 |
|---|---|---|---|
| 1 | **邮箱验证码记录** | 获取限制 3 次、连续输错 3 次封禁 2 分钟 | Redis key 结构即可，无需建表 |
| 2 | **记住我 / 登录态** | 7 天免密 + 记住手机号/邮箱 | Redis session，无需建表 |
| 3 | **管理员账号** | 写死 admin@opc.com | `sys_user` 加 `role` 字段即可 |
| 4 | **协议管理** | 管理员可编辑《用户协议》《隐私政策》 | `sys_config` 或 `sys_agreement` 表 |
| 5 | **需求发布（企业端）** | 企业工作台的「发布需求」功能 | `biz_requirement` 表 |
| 6 | **抢单大厅（OPC 端）** | OPC 浏览需求、报价、接单 | `biz_order` + `biz_quote` 表 |
| 7 | **草稿箱** | 企业端草稿保存 | `biz_requirement_draft` 表 |
| 8 | **变更日志** | 独立页面 change-log.html，记录所有数据变更 | `sys_change_log` 表 |
| 9 | **审核操作记录** | 管理员审核通过/拒绝 + 原因 | `biz_audit_log` 表 |
| 10 | **统计/看板数据** | 两端工作台的统计卡片 | 基于业务表聚合查询 |
| 11 | **文件存储** | localStorage.opc_files 模拟 sys_file | 已有 `sys_file` 表 |

---

## 三、数据库有但原型没有体现的

| # | 内容 | 说明 |
|---|---|---|
| 1 | `sys_user_oauth.provider = github` | GitHub 第三方登录（原型只有 Gitee/飞书） |
| 2 | `biz_opc_file.file_type = id_hand` | 手持身份证照（原型只要正反面） |
| 3 | `biz_enterprise_file.file_type = other` | 其他文件类型（原型有 license + qualification） |

---

## 四、需要修改数据库的建议

### 🔴 最紧急（影响现有功能落库）

| # | 修改内容 | 建议 SQL |
|---|---|---|
| 1 | `sys_user` 补 `phone` | `ALTER TABLE sys_user ADD COLUMN phone VARCHAR(20) NULL COMMENT '联系手机';` |
| 2 | `sys_user` 补 `account_id` | `ALTER TABLE sys_user ADD COLUMN account_id VARCHAR(20) UNIQUE COMMENT '唯一账号ID（OPC+自增）';` |
| 3 | `sys_user` 补 `role` | `ALTER TABLE sys_user ADD COLUMN role VARCHAR(20) DEFAULT 'user' COMMENT '角色：user/admin';` |
| 4 | `sys_user` 补 `auth_role` | `ALTER TABLE sys_user ADD COLUMN auth_role VARCHAR(20) NULL COMMENT '认证角色：opc/enterprise';` |
| 5 | `sys_user` 补 `auth_status` | `ALTER TABLE sys_user ADD COLUMN auth_status VARCHAR(20) DEFAULT 'unauth' COMMENT '认证状态：unauth/pending/approved/rejected';` |
| 6 | `sys_user` 补 `reject_reason` | `ALTER TABLE sys_user ADD COLUMN reject_reason VARCHAR(500) NULL COMMENT '认证拒绝原因';` |
| 7 | `biz_enterprise` 补 `industry` | `ALTER TABLE biz_enterprise ADD COLUMN industry VARCHAR(50) NULL COMMENT '所属行业';` |
| 8 | `biz_enterprise` 补 `scale` | `ALTER TABLE biz_enterprise ADD COLUMN scale VARCHAR(20) NULL COMMENT '企业规模';` |
| 9 | `biz_enterprise` 补 `city` | `ALTER TABLE biz_enterprise ADD COLUMN city VARCHAR(50) NULL COMMENT '所在城市';` |
| 10 | `biz_enterprise` 补 `address` | `ALTER TABLE biz_enterprise ADD COLUMN address VARCHAR(200) NULL COMMENT '详细地址';` |
| 11 | `biz_opc` 补 `phone` | `ALTER TABLE biz_opc ADD COLUMN phone VARCHAR(20) NULL COMMENT '联系手机';` |
| 12 | `biz_opc` 补 `city` | `ALTER TABLE biz_opc ADD COLUMN city VARCHAR(50) NULL COMMENT '所在城市';` |
| 13 | `biz_opc` 补 `accept_status` | `ALTER TABLE biz_opc ADD COLUMN accept_status VARCHAR(20) NULL COMMENT '接单状态：全职接单/兼职接单';` |
| 14 | `biz_opc` 补 `intro` | `ALTER TABLE biz_opc ADD COLUMN intro TEXT NULL COMMENT '个人简介';` |

### 🟡 支撑业务闭环（建议后续迭代）

| # | 修改内容 | 建议 |
|---|---|---|
| 15 | 新建 `sys_agreement` 表 | 存储管理员编辑的协议内容（user_agreement / privacy_policy） |
| 16 | 新建 `sys_change_log` 表 | 存储数据变更日志（time / user_id / user_name / type / field / desc） |
| 17 | 新建 `biz_requirement` 表 | 存储企业发布的接单需求 |
| 18 | 新建 `biz_quote` 表 | 存储 OPC 对需求的报价 |
| 19 | 新建 `biz_order` 表 | 存储成交订单 |
| 20 | 新建 `biz_audit_log` 表 | 存储审核操作记录（审核人 / 时间 / 结果 / 原因） |

---

## 五、总结

### 已完成的对齐项

- ✅ `sys_file` 5 个字段全部补齐（file_path / file_size / content_type / upload_user）
- ✅ 文件类型枚举统一（id_front / id_back / license / qualification）
- ✅ `reject_reason` 管理员拒绝时必填原因，用户端展示
- ✅ `avatar` 头像上传功能（两端工作台）
- ✅ `status` 账号停用/启用（管理员审核列表中操作）
- ✅ `update_time` 每次数据变更自动更新
- ✅ 账号 ID 自增（OPC100001 开始）
- ✅ 认证状态实时同步（每 3 秒 + 页面聚焦时）
- ✅ 变更日志独立页面（change-log.html）
- ✅ 企业资质文件上传（qualification 类型）

### 仍需数据库补充的字段

- `sys_user`：phone、account_id、role、auth_role、auth_status、reject_reason
- `biz_enterprise`：industry、scale、city、address
- `biz_opc`：phone、city、accept_status、intro

### 仍需新建的数据库表

- `sys_agreement`（协议管理）
- `sys_change_log`（变更日志）
- `biz_requirement`（需求发布）
- `biz_quote`（报价管理）
- `biz_order`（订单管理）
- `biz_audit_log`（审核日志）
