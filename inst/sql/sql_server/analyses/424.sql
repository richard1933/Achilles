-- 424
-- For each condition concept, compute the top 15 co-occurring condition concepts.
--

-- create unique person_id,condition_concept_id pairs for people with at least 2 different (mapped) conditions.

--HINT DISTRIBUTE_ON_KEY(condition_concept_id)
with ctePairs
as
(
  SELECT distinct person_id,condition_concept_id
  FROM @cdmDatabaseSchema.condition_occurrence
  where condition_concept_id != 0
),
cteSingles
as
(
  select person_id, count(distinct condition_concept_id) AS count_of_condition_concept_id
   from @cdmDatabaseSchema.condition_occurrence
   where condition_concept_id != 0
   group by person_id
   having count_of_condition_concept_id = 1
)
select distinct A.person_id, A.condition_concept_id
  into #unique_pairs_424
  from ctePairs A 
  left join cteSingles B on A.person_id = B.person_id
where B.person_id is null
;
    


-- Create ordered pairs of concept_ids, then count and rank them (condition pairs must have at least 1000 distinct people)

 --HINT DISTRIBUTE_ON_KEY(stratum_1)
select 424 as analysis_id,
       cast(concept_id_1 as varchar(255)) as stratum_1,
	   cast(concept_id_2 as varchar(255)) as stratum_2,
	   cast(ranking      as varchar(255)) as stratum_3,
	   cast(null         as varchar(255)) as stratum_4,
       cast(null         as varchar(255)) as stratum_5,
	   num_people        as count_value		
  into @scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_424
  from (
select concept_id_1, concept_id_2, num_people,
       row_number()over(partition by concept_id_1 order by num_people desc) ranking
  from (
select t1.condition_concept_id concept_id_1,
       t2.condition_concept_id concept_id_2,
       count(distinct t1.person_id) num_people
  from #unique_pairs_424 t1,
       #unique_pairs_424 t2
 where t1.person_id             = t2.person_id
   and t1.condition_concept_id != t2.condition_concept_id
 group by t1.condition_concept_id,t2.condition_concept_id
having count(distinct t1.person_id) >= 1000 
       ) tmp
       ) tmp
 where ranking <= 15;

truncate table #unique_pairs_424;
drop table #unique_pairs_424;