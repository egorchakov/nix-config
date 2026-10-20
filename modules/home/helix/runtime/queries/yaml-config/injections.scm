; inherits: yaml

(block_mapping_pair
  key:
  (flow_node
    (plain_scalar
      (string_scalar)
      @_query))
  value:
  (block_node
    (block_scalar)
    @injection.content)
  (#eq? @_query "query")
  (#set! injection.language "sql"))

(block_mapping_pair
  key:
  (flow_node
    (plain_scalar
      (string_scalar)
      @_query))
  value:
  (flow_node
    (plain_scalar
      (string_scalar)
      @injection.content))
  (#eq? @_query "query")
  (#set! injection.language "sql"))

(block_mapping_pair
  key:
  (flow_node
    (plain_scalar
      (string_scalar)
      @_query))
  value:
  (flow_node
    [(double_quote_scalar) (single_quote_scalar)]
    @injection.content)
  (#eq? @_query "query")
  (#set! injection.language "sql"))

(block_mapping_pair
  key:
  (flow_node
    (plain_scalar
      (string_scalar)
      @_hparams_jq))
  value:
  (block_node
    (block_scalar)
    @injection.content)
  (#eq? @_hparams_jq "hparams_jq")
  (#set! injection.language "jq"))

(block_mapping_pair
  key:
  (flow_node
    (plain_scalar
      (string_scalar)
      @_hparams_jq))
  value:
  (flow_node
    (plain_scalar
      (string_scalar)
      @injection.content))
  (#eq? @_hparams_jq "hparams_jq")
  (#set! injection.language "jq"))

(block_mapping_pair
  key:
  (flow_node
    (plain_scalar
      (string_scalar)
      @_hparams_jq))
  value:
  (flow_node
    [(double_quote_scalar) (single_quote_scalar)]
    @injection.content)
  (#eq? @_hparams_jq "hparams_jq")
  (#set! injection.language "jq"))
