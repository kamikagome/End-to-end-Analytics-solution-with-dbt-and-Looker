{% macro generate_schema_name(custom_schema_name, node) -%}

    {#
        This macro routes models to the correct schema based on their layer.

        Dev target:  dev_bronze, dev_silver, dev_gold
        Prod target: bronze, silver, gold

        The custom_schema_name comes from the +schema config in dbt_project.yml
    #}

    {%- set default_schema = target.schema -%}

    {%- if custom_schema_name is none -%}
        {{ default_schema }}

    {%- elif target.name == 'prod' -%}
        {# Production: use schema name directly (bronze, silver, gold) #}
        {{ custom_schema_name | trim }}

    {%- else -%}
        {# Dev/other: prefix with 'dev_' (dev_bronze, dev_silver, dev_gold) #}
        dev_{{ custom_schema_name | trim }}

    {%- endif -%}

{%- endmacro %}
