WITH RECURSIVE refused_ews_tree AS (
        --Select the fields we want to use from the original table
        SELECT  id,
                ews_id,
                creator_id,
                data_model,
                data_ref,
                spell_activity_id,
                state,
                ARRAY[id] as activity_ids,
                partial_reason,
                ARRAY[partial_reason] as partial_tree,
                id as first_activity_id,
                id as last_activity_id,
                true as refused,
                sequence,
                date_terminated as first_activity_date_terminated,
                date_terminated as last_activity_date_terminated
        FROM ews_activities
        --Make sure we only get EWS
        WHERE partial_reason = 'refused'
        AND state = 'completed'
        --Join the two tables
        UNION ALL
        --Select the same table but join it with parent row (via creator_id)
        SELECT  child_act.id,
                child_act.ews_id,
                child_act.creator_id,
                child_act.data_model,
                child_act.data_ref,
                child_act.spell_activity_id,
                child_act.state,
                array_append(act.activity_ids, child_act.id) AS activity_ids,
                child_act.partial_reason,
                array_append(act.partial_tree, child_act.partial_reason)
                  AS partial_tree,
                activity_ids[1] AS first_activity_id,
                child_act.id AS last_activity_id,
                NOT array_to_string(
                  array_cat(
                    partial_tree,
                    ARRAY[child_act.partial_reason]
                  ), ', ') <> array_to_string(
                  array_cat(
                    partial_tree,
                    ARRAY[child_act.partial_reason]
                  ), ', ', '(null)')
                AS refused,
                act.sequence,
                act.first_activity_date_terminated
                as first_activity_date_terminated,
                child_act.date_terminated as last_activity_date_terminated
        FROM ews_activities as child_act
        INNER JOIN refused_ews_tree as act
        ON (child_act.creator_id = act.id)
        WHERE child_act.state = 'completed'
        OR child_act.state = 'cancelled'
        AND child_act.cancel_reason_id IS NOT NULL
    )

    SELECT *,
    row_number() over(
      partition by spell_activity_id
      ORDER BY spell_activity_id ASC,
      first_activity_id DESC,
      last_activity_id DESC
    ) AS rank
    FROM refused_ews_tree
;