begin;

create extension if not exists pgtap with schema extensions;

select plan(6);

-- ---------------------------------------------------------------------------
-- 1. Setup isolated test fixtures (runs as postgres superuser inside transaction)
-- ---------------------------------------------------------------------------
insert into auth.users (id, email)
values
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'tenant_a@test.local'),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'tenant_b@test.local');

insert into public.workspaces (id, name, slug)
values
  ('10000000-0000-0000-0000-000000000001', 'Alpha Corp', 'alpha-corp'),
  ('20000000-0000-0000-0000-000000000002', 'Beta Labs', 'beta-labs');

insert into public.workspace_members (workspace_id, user_id, role)
values
  ('10000000-0000-0000-0000-000000000001', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'owner'),
  ('20000000-0000-0000-0000-000000000002', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'owner');

insert into public.projects (id, workspace_id, name, created_by)
values
  ('30000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', 'Alpha Launch', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'),
  ('40000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000002', 'Beta Secret', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb');

insert into public.tasks (id, workspace_id, project_id, title, status, priority, position, created_by)
values
  ('50000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001', 'Alpha Task 1', 'todo', 'high', 0, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'),
  ('60000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000002', '40000000-0000-0000-0000-000000000002', 'Beta Task 1', 'todo', 'medium', 0, 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb');

-- ---------------------------------------------------------------------------
-- 2. Test as Tenant A (Alpha Corp)
-- ---------------------------------------------------------------------------
set local role authenticated;
set local request.jwt.claim.sub = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';

-- Test 1: Tenant A only sees their own workspace
select results_eq(
  'select count(*) from public.workspaces',
  array[1::bigint],
  'Tenant A sees only 1 workspace'
);

-- Test 2: Tenant A only sees their own tasks
select results_eq(
  'select title from public.tasks',
  array['Alpha Task 1'::text],
  'Tenant A sees only Alpha Corp tasks'
);

-- Test 3: Tenant A can insert a task into their own workspace
select results_eq(
  $$insert into public.tasks (workspace_id, project_id, title, status, priority, position, created_by)
    values ('10000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001', 'Alpha Task 2', 'in_progress', 'low', 1, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa')
    returning title$$,
  array['Alpha Task 2'::text],
  'Tenant A can create a task in their own workspace'
);

-- ---------------------------------------------------------------------------
-- 3. Test Cross-Tenant Isolation as Tenant B (Beta Labs)
-- ---------------------------------------------------------------------------
set local request.jwt.claim.sub = 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';

-- Test 4: Tenant B cannot read Tenant A tasks
select results_eq(
  'select count(*) from public.tasks where workspace_id = ''10000000-0000-0000-0000-000000000001''',
  array[0::bigint],
  'Tenant B cannot read Tenant A tasks'
);

-- Test 5: Tenant B cannot update Tenant A tasks
select is_empty(
  $$update public.tasks
    set title = 'Hijacked'
    where id = '50000000-0000-0000-0000-000000000001'
    returning id$$,
  'Tenant B cannot update Tenant A tasks'
);

-- Test 6: Tenant B cannot insert a task into Tenant A workspace
select throws_ok(
  $$insert into public.tasks (workspace_id, project_id, title, status, priority, position, created_by)
    values ('10000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001', 'Injected Task', 'todo', 'urgent', 99, 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb')$$,
  '42501',
  null,
  'Tenant B is blocked from inserting into Tenant A workspace (RLS WITH CHECK)'
);

select * from finish();
rollback;
