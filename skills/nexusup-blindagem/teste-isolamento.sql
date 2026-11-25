-- NexusUp Blindagem · teste de isolamento entre clientes (IDOR) no Supabase.
-- Somente leitura, dentro de transação desfeita. Troque PREFIXO_ pelas tabelas do app.
-- Rode cada bloco separado (execute_sql devolve o resultado do último SELECT).

-- 1) Usuário logado que não pertence a nenhuma empresa: tudo deve dar 0.
begin;
set local role authenticated;
select set_config('request.jwt.claims','{"sub":"11111111-2222-3333-4444-555555555555","role":"authenticated"}', true);
select 'PREFIXO_empresas' t, count(*) n from public.PREFIXO_empresas
union all select 'PREFIXO_leads', count(*) from public.PREFIXO_leads;
rollback;

-- 2) Visitante anônimo: deve dar "permission denied" ou 0.
begin;
set local role anon;
select set_config('request.jwt.claims','{"role":"anon"}', true);
select (select count(*) from public.PREFIXO_empresas) n;
rollback;

-- 3) Membro da empresa A tentando ver a empresa B (troque os UUIDs): deve dar 0.
begin;
set local role authenticated;
select set_config('request.jwt.claims','{"sub":"UUID_USUARIO_DA_EMPRESA_A","role":"authenticated"}', true);
select count(*) from public.PREFIXO_leads where empresa_id = 'UUID_EMPRESA_B';
rollback;

-- 4) Políticas que mudam dados e gatilhos de proteção (para o teste de fraude de lógica).
select tablename, policyname, cmd, qual, with_check from pg_policies
 where schemaname='public' and tablename like 'PREFIXO_%' and cmd in ('UPDATE','INSERT','ALL','DELETE');
select c.relname, t.tgname from pg_trigger t join pg_class c on c.oid=t.tgrelid
 where not t.tgisinternal and c.relname like 'PREFIXO_%';
