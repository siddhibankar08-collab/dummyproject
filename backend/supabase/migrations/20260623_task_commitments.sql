alter table public.tasks
  add column if not exists user_id uuid references public.users(id) on delete cascade,
  add column if not exists description text not null default '',
  add column if not exists category text not null default 'General',
  add column if not exists difficulty text not null default 'Normal',
  add column if not exists estimated_minutes integer not null default 30,
  add column if not exists target_metric text not null default '',
  add column if not exists success_criteria text not null default '',
  add column if not exists notes text not null default '',
  add column if not exists completed_at timestamptz,
  add column if not exists locked_at timestamptz not null default now(),
  add column if not exists commitment_version integer not null default 1;

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'tasks_estimated_minutes_nonnegative_chk'
      and conrelid = 'public.tasks'::regclass
  ) then
    alter table public.tasks
      add constraint tasks_estimated_minutes_nonnegative_chk
      check (estimated_minutes >= 0) not valid;
  end if;
end $$;

alter table public.tasks
  validate constraint tasks_estimated_minutes_nonnegative_chk;

create index if not exists tasks_due_date_created_at_idx
  on public.tasks (user_id, due_date, created_at);

create index if not exists tasks_due_date_complete_idx
  on public.tasks (user_id, due_date, is_complete);

create index if not exists tasks_user_completed_idx
  on public.tasks (user_id, completed_at);
