SELECT  (
            with reasons (reason) as (
                select unnest(partial_tree)
            )
            select count(*)
            from reasons
            where reason = 'refused'
        ) as count,
        first_activity_id as activity_id,
        spell_activity_id,
        first_activity_date_terminated
FROM (
    SELECT *,
    row_number() over(
        partition by last_activity_id
        ORDER BY
        last_activity_id DESC,
        first_activity_id ASC
    ) AS last_activity_rank,
    row_number() over(
        partition by first_activity_id
        ORDER BY
        last_activity_id DESC,
        first_activity_id ASC
    ) AS first_activity_rank
    FROM refused_ews_activities
    WHERE NOT array_to_string(partial_tree, ',', 'null') LIKE '%null%'
) AS refused_ews
WHERE last_activity_rank = 1
AND first_activity_rank = 1
;