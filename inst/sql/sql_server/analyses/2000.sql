-- 2000	patients with at least 1 Dx and 1 Rx


select 2000 as analysis_id,  
	cast(null as varchar(255)) as stratum_1, cast(null as varchar(255)) as stratum_2, cast(null as varchar(255)) as stratum_3, cast(null as varchar(255)) as stratum_4, cast(null as varchar(255)) as stratum_5,
--gender_concept_id as stratum_1, COUNT_BIG(distinct person_id) as count_value
        CAST(a.cnt AS BIGINT) AS count_value
	into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2000
    FROM (
                select COUNT_BIG(*) cnt from (
                    select distinct person_id from @cdmDatabaseSchema.condition_occurrence
                    intersect
                    select distinct person_id from @cdmDatabaseSchema.drug_exposure
                ) b
         ) a
         ;
