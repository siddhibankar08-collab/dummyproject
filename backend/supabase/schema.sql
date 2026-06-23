create table if not exists public.users (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  email text not null unique,
  password_hash text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint users_email_format_chk check (
    email ~* '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$'
  )
);

create index if not exists users_email_idx
  on public.users (lower(email));

create table if not exists public.tasks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  title text not null,
  description text not null default '',
  category text not null default 'General',
  difficulty text not null default 'Normal',
  estimated_minutes integer not null default 30 check (estimated_minutes >= 0),
  target_metric text not null default '',
  success_criteria text not null default '',
  notes text not null default '',
  reward text not null default '',
  rank text not null default 'E' check (rank in ('E', 'D', 'C', 'B', 'A', 'S')),
  due_date date not null default current_date,
  is_complete boolean not null default false,
  completed_at timestamptz,
  locked_at timestamptz not null default now(),
  commitment_version integer not null default 1,
  created_at timestamptz not null default now()
);

create index if not exists tasks_due_date_created_at_idx
  on public.tasks (user_id, due_date, created_at);

create index if not exists tasks_due_date_complete_idx
  on public.tasks (user_id, due_date, is_complete);

create index if not exists tasks_user_completed_idx
  on public.tasks (user_id, completed_at);
