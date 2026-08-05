# Supabase — `messages` contract

Contact form submissions. The app inserts with the **anon** key.

## Schema

Apply [`schema/messages.sql`](./schema/messages.sql) to your Supabase project.

| Column       | Type          | Notes               |
| ------------ | ------------- | ------------------- |
| `id`         | `uuid`        | `gen_random_uuid()` |
| `name`       | `text`        | 1–120 chars         |
| `email`      | `text`        | 3–254 chars         |
| `message`    | `text`        | 1–5000 chars        |
| `created_at` | `timestamptz` | UTC                 |

## RLS

| Role            | INSERT | SELECT | UPDATE | DELETE |
| --------------- | ------ | ------ | ------ | ------ |
| `anon`          | ✅     | ❌     | ❌     | ❌     |
| `authenticated` | ❌     | ❌     | ❌     | ❌     |
| `service_role`  | ✅     | ✅     | ✅     | ✅     |

The SQL also `REVOKE`s broad defaults and `GRANT INSERT` to `anon` only.

Do **not** add SELECT policies for `anon`. Read inbox rows in the Dashboard or with `service_role` on the server only — never in `NEXT_PUBLIC_*`.

## Env

```bash
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
```
