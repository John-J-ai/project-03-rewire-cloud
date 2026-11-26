-- REWIRE Cloud · Supabase 建表脚本
-- 用法：Supabase 控制台 → SQL Editor → New query → 粘贴 → Run
-- 只存变更摘要与匿名八维分数；不存原始导出文本、文件路径、账号信息。

create table if not exists public.sync_events (
  id bigint generated always as identity primary key,
  cid text not null,
  kind text not null,
  at timestamptz not null,
  constraint sync_events_cid_at_key unique (cid, at)
);

create table if not exists public.bench_samples (
  id bigint generated always as identity primary key,
  sample_id text not null unique,
  cid text not null,
  sample_date date not null,
  dims jsonb not null,
  progress int not null check (progress between 0 and 100),
  at timestamptz not null
);

-- 表级权限：anon 角色必须有 GRANT 才能走 REST（RLS 只做行级过滤）
grant usage on schema public to anon;
grant select, insert on public.sync_events to anon;
grant select, insert on public.bench_samples to anon;
grant usage, select on sequence public.sync_events_id_seq to anon;
grant usage, select on sequence public.bench_samples_id_seq to anon;

alter table public.sync_events enable row level security;
alter table public.bench_samples enable row level security;

-- anon 可插入，不能读取 sync_events（摘要无读取价值）
drop policy if exists "anon insert sync" on public.sync_events;
create policy "anon insert sync" on public.sync_events
  for insert to anon with check (true);

-- anon 可插入匿名样本，可读取用于计算均值
drop policy if exists "anon insert bench" on public.bench_samples;
create policy "anon insert bench" on public.bench_samples
  for insert to anon with check (true);
drop policy if exists "anon read bench" on public.bench_samples;
create policy "anon read bench" on public.bench_samples
  for select to anon using (true);

-- 索引：按日期拉取基准样本
create index if not exists bench_samples_date_idx on public.bench_samples (sample_date desc);
