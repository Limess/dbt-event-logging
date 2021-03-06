with events as (

    select * from {{ ref('stg_dbt_audit_log') }}

),

aggregated as (

    select

        {{ dbt_utils.surrogate_key(
            'event_model',
            'invocation_id'
        ) }} as model_deployment_id,

        invocation_id,
        event_model as model,

        min(case
            when event_name = 'model deployment started' then event_timestamp
        end) as deployment_started_at,

        min(case
            when event_name = 'model deployment completed' then event_timestamp
        end) as deployment_completed_at

    from events

    where event_name ilike '%model%'

    group by 1, 2, 3

)

select * from aggregated
