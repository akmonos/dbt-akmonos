<!-- ACTION ITEM -->
> [!WARNING]
> Double-check PII and secrets!
> - [ ] I have checked for PII on all models touched in this PR
> - [ ] No keys, passwords, `.env` files, or data files are committed

## Overview
<!-- What changed and why. -->

-

**Type of change**
- [ ] New model(s)
- [ ] Change to existing model(s)
- [ ] Macro, config, or `dbt_project.yml`
- [ ] CI/CD or workflow
- [ ] Snowflake setup script (numbered scripts)
- [ ] Docs or README only

**Related links**
<!-- Related PRs, issues, or roadmap item. -->

-

## Validation

1. **Development run**
   - [ ] `dbt build -s <models>+` passed in my `DBT_<USERNAME>_*` schemas
   - [ ] Every model ran in under 2 minutes (explain any that took longer)

2. **Dev vs prod comparison (existing models)**
   - [ ] No existing models modified
   - [ ] No differences
   - [ ] Differences found (details below)

   - **Model:** [model name]
   - **Change type:** [Expected / Unexpected / Breaking]
   - **Description:** [what changed]

   - [ ] Comparison query included:
     ```sql
     -- row counts: prod first, then dev
     select 'prod' as env, count(*) as row_count from prod_transformed.<schema>.<model>
     union all
     select 'dev' as env, count(*) as row_count from dev.dbt_<username>_<schema>.<model>;
     ```

3. **New models**
   - [ ] No new models created
   - [ ] Grain proven in Snowflake before building (key is unique)
   - [ ] Compared row counts to upstream models
   - [ ] Dropped records or fan out: [None / Identified, explain if expected]

4. **Code quality**
   - [ ] pre-commit passed on commit (SQLFluff fix and lint, yaml, whitespace, private key)
   - [ ] Import CTEs at the top, explicit column list in the final select (no `select *`)
   - [ ] Every `.sql` change has a matching `.yml` update

5. **CI**
   - [ ] Slim CI passed and built the models I expected
   - [ ] Alerts or warnings: [None / Yes, explain]

6. **Documentation**
   - [ ] Every new or changed model and column has a description that references a doc block in `_<folder>__docs.md`
   - [ ] Checked with `dbt docs generate` and `dbt docs serve`
   - [ ] README updated if setup, workflow, or conventions changed

## Sensitive Data Review

> [!IMPORTANT]
> If the only change to a model is adding `masking_policy` to a column, also make a build-triggering change (edit the model's header comment or a yml description). Slim CI only builds changed models, so without it the masking is never tested in CI.

- [ ] No sensitive columns added or changed
- [ ] Every new or changed sensitive column has `data_classification` and `masking_policy` under `config.meta`
- [ ] Any new masking policy has a macro in `macros/snow-mask-ddl/` named `mp__<classification>__<domain>__<type>_v<n>`
- [ ] Checked as the `reporter` role that masked columns return NULL

## Snowflake Changes

- [ ] No Snowflake setup changes
- [ ] Setup SQL added to the right numbered script (not `scratch.sql`), with a one-line header comment
- [ ] Grants follow least privilege (dbt runs as `transformer`, BI and AI read as `reporter`)

## Approval and Merge

- [ ] At least 1 approval received
- [ ] All review comments addressed
- [ ] All checks above are done and CI is green
- [ ] After merge: deploy workflow finished green
