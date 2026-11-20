# Desktop Phase 4 Hardening — 任务

## 当前工作

- [x] Spec 095 + 索引 / 085 交叉引用
- [x] Table：`TTableCellEdited` / `TTableDragSort` + TokenScope
- [x] Table：`maxHeight` 表体 `ListView.builder`
- [x] Select：选项面板 `ListView.builder`
- [x] desktop 全量 test + gallery analyze

## 当前工作（第二批）

- [x] Token codegen 补语义色并重新生成
- [x] Select/Date/Time/Tree/Cascader/TreeSelect/Input 硬编码色迁 Token
- [x] desktop 去掉 core re-export；gallery + 测试双 import
- [x] desktop / gallery analyze + desktop test

## 当前工作（第三批）

- [x] 反馈 / 导航硬编码色迁 Token（Dialog、Dropdown、Popover、Menu、Tabs、Pagination、Breadcrumb）
- [x] desktop analyze + menu / tabs / pagination test

## 当前工作（第四批）

- [x] Tag / Link / Badge / Table / Divider / 表单控件硬编码色迁 Token
- [x] desktop analyze + test

## 未决设计与缺失证据

- [ ] 无帧耗时基准；本阶段只验 builder 路径可交互
- [x] Tooltip 用 `grayColor14` / `textColorAnti`；遮罩用 `maskActive`；浮层阴影用 `shadow1`，Dialog 用 `shadow2`
- [ ] Button 填充态 hover/pressed 仍是黑白 lerp，不是 Token
