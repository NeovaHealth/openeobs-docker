drop view if exists wdb_ward_locations cascade;
        drop view if exists wdb_ews_ranked cascade;
        drop view if exists wdb_ews cascade;
        drop view if exists nh_eobs_ward_dashboard cascade;
        drop view if exists loc_waiting_patients cascade;
        drop view if exists loc_availability cascade;
        drop view if exists loc_users cascade;
        drop view if exists child_loc_users cascade;
        drop view if exists loc_patients_by_risk cascade;
        drop view if exists loc_risk_patients_count cascade;
        drop view if exists ward_beds cascade;

        create or replace view
        wdb_ward_locations as(
            with recursive ward_loc(id, parent_id, path, ward_id) as (
                select lc.id, lc.parent_id, ARRAY[lc.id] as path,
                lc.id as ward_id
                from nh_clinical_location as lc
                where lc.usage = 'ward'
                union all
                select l.id, l.parent_id,
                w.path || ARRAY[l.id] as path, w.path[1]
                    as ward_id
                from ward_loc as w, nh_clinical_location as l
                where l.parent_id = w.id)
            select * from ward_loc
        );

        create or replace view
        -- ews per spell, data_model, state
        wdb_ews_ranked as(
            select *
            from (
                select
                    spell.id as spell_id,
                    activity.*,
                    split_part(activity.data_ref, ',', 2)::int as data_id,
                    rank() over (partition by spell.id, activity.data_model,
                        activity.state order by activity.sequence desc)
            from nh_clinical_spell spell
            inner join nh_activity activity
                on activity.spell_activity_id = spell.activity_id
                and activity.data_model = 'nh.clinical.patient.observation.ews'
            left join nh_clinical_patient_observation_ews ews
                on ews.activity_id = activity.id
            where activity.state = 'scheduled'
            or (activity.state != 'scheduled'
                and ews.clinical_risk != 'Unknown')) sub_query
            where rank < 3
        );

        create or replace view
        wdb_ews as(
            select
                activity.parent_id as spell_activity_id,
                activity.patient_id,
                activity.spell_id,
                activity.state,
                activity.date_scheduled,
                activity.date_terminated,
                ews.id,
                ews.score,
                ews.frequency,
                ews.clinical_risk,
                case when activity.date_scheduled < now() at time zone 'UTC'
                    then 'overdue: ' else '' end as next_diff_polarity,
                case activity.date_scheduled is null
                    when false then justify_hours(greatest(now() at time zone
                    'UTC',activity.date_scheduled) - least(now() at time zone
                    'UTC', activity.date_scheduled))
                    else interval '0s'
                end as next_diff_interval,
                activity.rank
            from wdb_ews_ranked activity
            inner join nh_clinical_patient_observation_ews ews
                on activity.data_id = ews.id
            where activity.rank = 1 and activity.state = 'completed'
        );

        create or replace view loc_patients_by_risk as (
            select
                wl.ward_id as location_id,
                case
                    when e1.clinical_risk is null then 'NoScore'
                    else e1.clinical_risk
                end as clinical_risk,
                count(spell.id) as patients
            from nh_clinical_spell spell
            inner join nh_activity activity
            on activity.id = spell.activity_id and activity.state = 'started'
            inner join nh_clinical_location location
            on location.id = spell.location_id and location.usage = 'bed'
            inner join wdb_ward_locations wl on wl.id = location.id
            left join wdb_ews e1 on e1.spell_activity_id = activity.id
            group by wl.ward_id, e1.clinical_risk
        );

        create or replace view loc_risk_patients_count as (
            select
                location.id as location_id,
                high.patients as high_risk_patients,
                med.patients as med_risk_patients,
                low.patients as low_risk_patients,
                no.patients as no_risk_patients,
                nos.patients as noscore_patients
            from nh_clinical_location location
            left join loc_patients_by_risk high
            on high.location_id = location.id and high.clinical_risk = 'High'
            left join loc_patients_by_risk med
            on med.location_id = location.id and med.clinical_risk = 'Medium'
            left join loc_patients_by_risk low
            on low.location_id = location.id and low.clinical_risk = 'Low'
            left join loc_patients_by_risk no
            on no.location_id = location.id and no.clinical_risk = 'None'
            left join loc_patients_by_risk nos
            on nos.location_id = location.id and nos.clinical_risk = 'NoScore'
        );

        create or replace view loc_availability as (
            select
                wl.ward_id as location_id,
                count(spell.id) as patients_in_bed,
                count(location.id) - count(spell.id) as free_beds
            from nh_clinical_location location
            inner join wdb_ward_locations wl on wl.id = location.id
            left join nh_clinical_spell spell
            on spell.location_id = location.id
            left join nh_activity activity
            on activity.id = spell.activity_id and activity.state = 'started'
            where location.usage = 'bed' and location.active = true
            group by wl.ward_id
        );

        create or replace view loc_waiting_patients as (
            select
                placement.location_id as location_id,
                count(distinct placement.patient_id) as waiting_patients,
                array_agg(distinct placement.patient_id)
                as patients_waiting_ids
            from nh_clinical_placement placement
            inner join nh_activity activity on activity.id = placement.id
            inner join nh_activity spell_activity
            on spell_activity.id = activity.parent_id
            where spell_activity.state = 'started'
            group by placement.location_id
        );

        create or replace view loc_users as (
            select
                location.id as location_id,
                groups.name as group_name,
                array_agg(distinct users.id) as user_ids
            from res_groups groups
            left join res_groups_users_rel gurel on gurel.gid = groups.id
            left join res_users users on users.id = gurel.uid
            left join user_location_rel ulrel on ulrel.user_id = users.id
            left join nh_clinical_location location
            on location.id = ulrel.location_id
            group by location.id, groups.name
        );

        create or replace view child_loc_users as (
            select
                wl.ward_id as location_id,
                groups.name as group_name,
                array_agg(distinct users.id) as user_ids,
                count(distinct users.id) as related_users
            from res_groups groups
            left join res_groups_users_rel gurel on gurel.gid = groups.id
            left join res_users users on users.id = gurel.uid
            left join user_location_rel ulrel on ulrel.user_id = users.id
            left join nh_clinical_location location
            on location.id = ulrel.location_id
            left join wdb_ward_locations wl on wl.id = location.id
            group by wl.ward_id, groups.name
        );

        create or replace view ward_beds as (
            select
                wl.ward_id as location_id,
                array_agg(distinct location.id) as bed_ids
            from nh_clinical_location location
            inner join wdb_ward_locations wl on wl.id = location.id
            where location.usage = 'bed'
            group by wl.ward_id
        );

        create or replace view nh_eobs_ward_dashboard as (
            select
                location.id as id,
                location.id as location_id,
                lwp.waiting_patients,
                avail.patients_in_bed,
                avail.free_beds,
                clu1.related_users as related_hcas,
                clu2.related_users as related_nurses,
                clu3.related_users as related_doctors,
                rpc.high_risk_patients,
                rpc.med_risk_patients,
                rpc.low_risk_patients,
                rpc.no_risk_patients,
                rpc.noscore_patients,
                case
                    when rpc.high_risk_patients > 0 then 2
                    when rpc.med_risk_patients > 0 then 3
                    when rpc.low_risk_patients > 0 then 4
                    when rpc.no_risk_patients > 0 then 0
                    when rpc.noscore_patients > 0 then 7
                    else 7
                end as kanban_color
            from nh_clinical_location location
            left join loc_waiting_patients lwp on lwp.location_id = location.id
            left join loc_availability avail on avail.location_id = location.id
            left join child_loc_users clu1 on clu1.location_id = location.id
                and clu1.group_name = 'NH Clinical HCA Group'
            left join child_loc_users clu2 on clu2.location_id = location.id
                and clu2.group_name = 'NH Clinical Nurse Group'
            left join child_loc_users clu3 on clu3.location_id = location.id
                and clu3.group_name = 'NH Clinical Doctor Group'
            left join loc_risk_patients_count rpc
                on rpc.location_id = location.id
            where location.usage = 'ward'
        )
;