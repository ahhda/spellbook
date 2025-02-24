{{ config(
        alias = alias('erc20_transfer_source', legacy_model=True),
        materialized='incremental',
        incremental_strategy = 'merge',
        file_format = 'delta',
        unique_key = ['contract_address']
)
}}

 SELECT
  t.contract_address
, max(t.evt_block_time) AS latest_transfer
-- ideally we'd have decimals and symbols here, but these aren't easily accessible onchain
FROM {{ source('erc20_optimism','evt_Transfer') }} t
    {% if is_incremental() %}
       WHERE t.evt_block_time >= date_trunc("day", now() - interval '1 week')
    {% endif %}
GROUP BY 1