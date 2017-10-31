# == Class: druid::broker
#
# Setup a Druid node runing the broker service.
#
# === Parameters
#
# [*host*]
#   Host address for the service to listen on.
#
#   Default value: The `$ipaddress` fact.
#
# [*port*]
#   Port the service listens on.
#
#   Default value: `8082`.
#
# [*service*]
#   The name of the service.
#
#   This is used as a dimension when emitting metrics and alerts.  It is
#   used to differentiate between the various services
#
#   Default value: `'druid/broker'`.
#
# [*balancer_type*]
#   The way connections to historical nodes are balanced.
#
#   Valid values:
#     * `'random'`: Choose randomly.
#     * `'connectionCount'`: Use node with the fewest active connections.
#
#   Default value: `'random'`.
#
# [*cache_expiration*]
#   Memcached expiration time.
#
#   Default value: `2592000` (30 days).
#
# [*cache_hosts*]
#   Array of Memcached hosts (i.e. '<host:port>').
#
#   Default value: `[]`.
#
# [*cache_initial_size*]
#   Initial size of the hashtable backing the cache.
#
#   Default value: `500000`.
#
# [*cache_log_eviction_count*]
#   If non-zero, log cache eviction every logEvictionCount items.
#
#   Default value: `0`.
#
# [*cache_max_object_size*]
#   Maximum object size in bytes for a Memcached object.
#
#   Default value: `52428800` (50 MB).
#
# [*cache_memcached_prefix*]
#   Key prefix for all keys in Memcached.
#
#   Default value: `'druid'`.
#
# [*cache_populate_cache*]
#   Populate the cache on the broker.
#
#   Valid values: `true`, `false`.
#
#   Default value: `false`.
#
# [*cache_size_in_bytes*]
#   Maximum cache size in bytes.
#
#   Zero disables caching.
#
#   Default value: `0`.
#
# [*cache_timeout*]
#   Maximum time in milliseconds to wait for a response from Memcached.
#
#   Default value: `500`.
#
# [*cache_type*]
#   Type of cache to use for queries.
#
#   Valid values:
#     * `'local'`: Use local file cache.
#     * `'memcached'`: Use Memcached.
#
#   Default value: `'local'`.
#
# [*cache_uncacheable*]
#   All query types to not cache.
#
#   Default value: `['groupBy', 'select']`.
#
# [*cache_use_cache*]
#   Enable the cache on the broker.
#
#   Valid values: `true`, `false`.
#
#   Default value: `false`.
#
# [*http_num_connections*]
#   Connection pool size.
#
#   Specifically, this is the number of connections the Broker uses to
#   connect to historical and real-time nodes. If there are more queries
#   than this number that all need to speak to the same node, then they
#   will queue up.
#
#   Default value: `5`.
#
# [*http_read_timeout*]
#   The timeout for data reads.
#
#   Default value: `'PT15M'`.
#
# [*jvm_opts*]
#   Array of options to set for the JVM running the service.
#
#   Default value: [
#     '-server',
#     '-Duser.timezone=UTC',
#     '-Dfile.encoding=UTF-8',
#     '-Djava.io.tmpdir=/tmp',
#     '-Djava.util.logging.manager=org.apache.logging.log4j.jul.LogManager'
#   ]
#
# [*processing_buffer_size_bytes*]
#   Buffer size for the storage of intermediate results.
#
#   The computation engine in both the Historical and Realtime nodes will
#   use a scratch buffer of this size to do all of their intermediate
#   computations off-heap. Larger values allow for more aggregations in a
#   single pass over the data while smaller values can require more passes
#   depending on the query that is being executed.
#
#   Default value: `1073741824` (1GB).
#
# [*processing_column_cache_size_bytes*]
#   Maximum size in bytes for the dimension value lookup cache.
#
#   Any value greater than 0 enables the cache. It is currently disabled by
#   default. Enabling the lookup cache can significantly improve the
#   performance of aggregators operating on dimension values, such as the
#   JavaScript aggregator, or cardinality aggregator, but can slow things
#   down if the cache hit rate is low (i.e. dimensions with few repeating
#   values). Enabling it may also require additional garbage collection
#   tuning to avoid long GC pauses.
#
#   Default value: `0` (disabled).
#
# [*processing_format_string*]
#   Format string to name processing threads.
#
#   Default value: `'processing-%s'`.
#
# [*processing_num_threads*]
#   Number of processing threads available for processing of segments.
#
#   Rule of thumb is num_cores - 1, which means that even under heavy load
#   there will still be one core available to do background tasks like
#   talking with ZooKeeper and pulling down segments. If only one core is
#   available, this property defaults to the value 1.
#
# [*query_group_by_max_intermediate_rows*]
#   Maximum number of intermediate rows.
#
#   Default value: `50000`.
#
# [*query_group_by_max_results*]
#   Maximum number of results.
#
#   Default value: `500000`.
#
# [*query_group_by_single_threaded*]
#   Run single threaded group by queries.
#
#   Valid values: `true`, `false`.
#
#   Default value: `false`.
#
# [*query_search_max_search_limit*]
#   Maximum number of search results to return.
#
#   Default value: `1000`.
#
# [*retry_policy_num_tries*]
#   Number of tries.
#
#   Default value: `1`.
#
# [*select_tier_custom_priorities*]
#   Array of integer priorities to select server tiers with.
#
#   Default value: `[]`.
#
# [*select_tier*]
#   Preference of tier to select based on priority.
#
#   If segments are cross-replicated across tiers in a cluster, you can tell
#   the broker to prefer to select segments in a tier with a certain
#   priority.
#
#   Valid values:
#     * `'highestPriority'`
#     * `'lowestPriority'`
#     * `'custom'`
#
#   Default value: `'highestPriority'`.
#
# [*server_http_max_idle_time*]
#   The Jetty max idle time for a connection.
#
#   Default value: `'PT5m'`.
#
# [*server_http_num_threads*]
#   Number of threads for HTTP requests.
#
#   Default value: `10`.
#
# === Examples
#
#  class { 'druid::broker': }
#
# === Authors
#
# Tyler Yahn <codingalias@gmail.com>
#
class druid::broker (
  $host                                 = $druid::params::broker_host,
  $port                                 = $druid::params::broker_port,
  $service                              = $druid::params::broker_service,
  $balancer_type                        = $druid::params::broker_balancer_type,
  $cache_expiration                     = $druid::params::broker_cache_expiration,
  $cache_hosts                          = $druid::params::broker_cache_hosts,
  $cache_initial_size                   = $druid::params::broker_cache_initial_size,
  $cache_log_eviction_count             = $druid::params::broker_cache_log_eviction_count,
  $cache_max_object_size                = $druid::params::broker_cache_max_object_size,
  $cache_memcached_prefix               = $druid::params::broker_cache_memcached_prefix,
  $cache_populate_cache                 = $druid::params::broker_cache_populate_cache,
  $cache_size_in_bytes                  = $druid::params::broker_cache_size_in_bytes,
  $cache_timeout                        = $druid::params::broker_cache_timeout,
  $cache_type                           = $druid::params::broker_cache_type,
  $cache_uncacheable                    = $druid::params::broker_cache_uncacheable,
  $cache_use_cache                      = $druid::params::broker_cache_use_cache,
  $http_num_connections                 = $druid::params::broker_http_num_connections,
  $http_read_timeout                    = $druid::params::broker_http_read_timeout,
  $jvm_opts                             = $druid::params::broker_jvm_opts,
  $processing_buffer_size_bytes         = $druid::params::broker_processing_buffer_size_bytes,
  $processing_column_cache_size_bytes   = $druid::params::broker_processing_column_cache_size_bytes,
  $processing_format_string             = $druid::params::broker_processing_format_string,
  $processing_num_threads               = $druid::params::broker_processing_num_threads,
  $query_group_by_max_intermediate_rows = $druid::params::broker_query_group_by_max_intermediate_rows,
  $query_group_by_max_results           = $druid::params::broker_query_group_by_max_results,
  $query_group_by_single_threaded       = $druid::params::broker_query_group_by_single_threaded,
  $query_search_max_search_limit        = $druid::params::broker_query_search_max_search_limit,
  $retry_policy_num_tries               = $druid::params::broker_retry_policy_num_tries,
  $select_tier_custom_priorities        = $druid::params::broker_select_tier_custom_priorities,
  $select_tier                          = $druid::params::broker_select_tier,
  $server_http_max_idle_time            = $druid::params::broker_server_http_max_idle_time,
  $server_http_num_threads              = $druid::params::broker_server_http_num_threads,
  $num_merge_buffers                    = $druid::params::broker_num_merge_buffers,
) inherits druid::params {
  require druid

  validate_string(
    $service,
    $balancer_type,
    $cache_memcached_prefix,
    $cache_type,
    $http_read_timeout,
    $processing_format_string,
    $select_tier,
    $server_http_max_idle_time,
  )

  validate_integer($port)
  validate_integer($cache_expiration)
  validate_integer($cache_initial_size)
  validate_integer($cache_log_eviction_count)
  validate_integer($cache_max_object_size)
  validate_integer($cache_size_in_bytes)
  validate_integer($cache_timeout)
  validate_integer($http_num_connections)
  validate_integer($processing_buffer_size_bytes)
  validate_integer($processing_column_cache_size_bytes)
  validate_integer($query_group_by_max_intermediate_rows)
  validate_integer($query_group_by_max_results)
  validate_integer($query_search_max_search_limit)
  validate_integer($retry_policy_num_tries)
  validate_integer($server_http_num_threads)

  if ($processing_num_threads != undef) {
    validate_integer($processing_num_threads)
  }

  validate_bool(
    $cache_populate_cache,
    $cache_use_cache,
    $query_group_by_single_threaded,
  )

  validate_array(
    $cache_hosts,
    $cache_uncacheable,
    $jvm_opts,
    $select_tier_custom_priorities,
  )

  druid::service { 'broker':
    config_content  => template("${module_name}/broker.runtime.properties.erb"),
    service_content => template("${module_name}/druid-broker.service.erb"),
  }
}
