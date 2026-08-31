-- ============================================================
-- 接单平台数据库初始化脚本
-- ============================================================

-- 创建数据库
CREATE DATABASE IF NOT EXISTS `order_platform` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

USE `order_platform`;

-- ============================================================
-- 1. 用户主表（所有登录方式共用，只管账号信息）
-- ============================================================
CREATE TABLE sys_user (
    user_id       BIGINT PRIMARY KEY AUTO_INCREMENT  COMMENT '用户ID',
    email         VARCHAR(128) DEFAULT NULL           COMMENT '邮箱（登录标识）',
    password      VARCHAR(200) DEFAULT NULL           COMMENT '密码（BCrypt加密，邮箱+密码登录用）',
    nickname      VARCHAR(64)  DEFAULT NULL           COMMENT '昵称（展示用）',
    avatar        VARCHAR(500) DEFAULT NULL           COMMENT '头像地址',
    status        TINYINT DEFAULT 0                   COMMENT '账号状态（0正常 1停用）',
    create_time   DATETIME DEFAULT CURRENT_TIMESTAMP  COMMENT '注册时间',
    update_time   DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',

    UNIQUE KEY uk_email (email) COMMENT '邮箱唯一'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';


-- ============================================================
-- 2. 第三方登录绑定表（一个用户可绑定多个平台）
-- ============================================================
CREATE TABLE sys_user_oauth (
    id              BIGINT PRIMARY KEY AUTO_INCREMENT  COMMENT '主键ID',
    user_id         BIGINT NOT NULL                    COMMENT '用户ID（关联sys_user）',
    provider        VARCHAR(20) NOT NULL               COMMENT '第三方平台（gitee/feishu/github）',
    provider_uid    VARCHAR(128) NOT NULL              COMMENT '第三方平台用户唯一标识',
    provider_name   VARCHAR(64)  DEFAULT NULL          COMMENT '第三方平台昵称',
    provider_avatar VARCHAR(500) DEFAULT NULL          COMMENT '第三方平台头像',
    create_time     DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '绑定时间',

    UNIQUE KEY uk_provider_uid (provider, provider_uid) COMMENT '同一平台用户唯一',
    INDEX idx_user_id (user_id)                         COMMENT '按用户查询绑定列表'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='第三方登录绑定表';


-- ============================================================
-- 3. 文件存储表（上传的图片、证件照等统一管理）
-- ============================================================
CREATE TABLE sys_file (
    file_id       BIGINT PRIMARY KEY AUTO_INCREMENT  COMMENT '文件ID',
    file_name     VARCHAR(255) NOT NULL              COMMENT '原始文件名',
    file_path     VARCHAR(500) NOT NULL              COMMENT '存储路径（MinIO地址）',
    file_size     BIGINT DEFAULT 0                   COMMENT '文件大小（字节）',
    content_type  VARCHAR(100) DEFAULT NULL          COMMENT '文件类型（image/png等）',
    upload_user   BIGINT DEFAULT NULL                COMMENT '上传用户ID',
    create_time   DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '上传时间',

    INDEX idx_upload_user (upload_user)              COMMENT '按用户查询上传记录'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='文件存储表';


-- ============================================================
-- 4. 企业认证表
-- ============================================================
CREATE TABLE biz_enterprise (
    enterprise_id   BIGINT PRIMARY KEY AUTO_INCREMENT  COMMENT '企业认证ID',
    user_id         BIGINT NOT NULL                    COMMENT '用户ID（关联sys_user）',
    company_name    VARCHAR(128) NOT NULL              COMMENT '企业名称',
    credit_code     VARCHAR(64)  NOT NULL              COMMENT '统一社会信用代码',
    contact_person  VARCHAR(64)  NOT NULL              COMMENT '企业联系人',
    contact_phone   VARCHAR(20)  NOT NULL              COMMENT '联系电话',
    audit_status    TINYINT DEFAULT 0                  COMMENT '审核状态（0待审核 1通过 2拒绝）',
    reject_reason   VARCHAR(500) DEFAULT NULL          COMMENT '拒绝原因',
    create_time     DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '申请时间',
    update_time     DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',

    UNIQUE KEY uk_user_id (user_id)                    COMMENT '一个用户只能有一个企业认证',
    INDEX idx_audit_status (audit_status)              COMMENT '按审核状态查询'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='企业认证表';


-- ============================================================
-- 5. 企业认证-文件关联表
-- ============================================================
CREATE TABLE biz_enterprise_file (
    id            BIGINT PRIMARY KEY AUTO_INCREMENT  COMMENT '主键ID',
    enterprise_id BIGINT NOT NULL                    COMMENT '企业认证ID（关联biz_enterprise）',
    file_id       BIGINT NOT NULL                    COMMENT '文件ID（关联sys_file）',
    file_type     VARCHAR(20) NOT NULL               COMMENT '文件用途（license/qualification/other）',
    create_time   DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '关联时间',

    INDEX idx_enterprise_id (enterprise_id)          COMMENT '按企业认证ID查询关联文件'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='企业认证文件关联表';


-- ============================================================
-- 6. OPC认证表
-- ============================================================
CREATE TABLE biz_opc (
    opc_id        BIGINT PRIMARY KEY AUTO_INCREMENT  COMMENT 'OPC认证ID',
    user_id       BIGINT NOT NULL                    COMMENT '用户ID（关联sys_user）',
    real_name     VARCHAR(64)  NOT NULL              COMMENT '真实姓名',
    id_card_no    VARCHAR(64)  NOT NULL              COMMENT '身份证号',
    skill_tags    VARCHAR(500) DEFAULT NULL          COMMENT '技能标签（逗号分隔）',
    portfolio_url VARCHAR(500) DEFAULT NULL          COMMENT '作品集链接',
    audit_status  TINYINT DEFAULT 0                  COMMENT '审核状态（0待审核 1通过 2拒绝）',
    reject_reason VARCHAR(500) DEFAULT NULL          COMMENT '拒绝原因',
    create_time   DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '申请时间',
    update_time   DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',

    UNIQUE KEY uk_user_id (user_id)                  COMMENT '一个用户只能有一个OPC认证',
    INDEX idx_audit_status (audit_status)            COMMENT '按审核状态查询'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='OPC认证表';


-- ============================================================
-- 7. OPC认证-文件关联表
-- ============================================================
CREATE TABLE biz_opc_file (
    id            BIGINT PRIMARY KEY AUTO_INCREMENT  COMMENT '主键ID',
    opc_id        BIGINT NOT NULL                    COMMENT 'OPC认证ID（关联biz_opc）',
    file_id       BIGINT NOT NULL                    COMMENT '文件ID（关联sys_file）',
    file_type     VARCHAR(20) NOT NULL               COMMENT '文件用途（id_front/id_back/id_hand/other）',
    create_time   DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '关联时间',

    INDEX idx_opc_id (opc_id)                        COMMENT '按OPC认证ID查询关联文件'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='OPC认证文件关联表';


-- ============================================================
-- 8. 邮箱验证码（Redis存储，不建表）
-- ============================================================
-- key:   email:code:xxx@qq.com
-- value: 123456
-- TTL:   300秒（5分钟）


-- ============================================================
-- 表关系总览
-- ============================================================
-- sys_user（登录账号）
--   ├── sys_user_oauth（第三方绑定，一对多）
--   ├── biz_enterprise（企业认证，一对一）
--   │     └── biz_enterprise_file（关联图片，一对多）→ sys_file
--   └── biz_opc（OPC认证，一对一）
--         └── biz_opc_file（关联图片，一对多）→ sys_file
--
-- Redis 存邮箱验证码，不落库
