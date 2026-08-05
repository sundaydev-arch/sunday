# Agent skills

Project skills live here (source of truth). Cursor discovers the same skills via symlinks under `.cursor/skills/`.

| Skill                               | Use when                                        |
| ----------------------------------- | ----------------------------------------------- |
| [`seo-audit`](./seo-audit/SKILL.md) | SEO / GEO audit, meta tags, ranking diagnostics |

Add new skills under `.agents/skills/<name>/`, then:

```bash
ln -s ../../.agents/skills/<name> .cursor/skills/<name>
```
