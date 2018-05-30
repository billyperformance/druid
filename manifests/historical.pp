# == Class: druid::historical
#
# Setup a historical druid node.
#
# === Parameters
#
# [*host*]
#   The host for the current node.
#
#   Defaults to the facter defined `$ipaddress`.
#
# [*port*]
#  This is the port to actually listen on; unless port mapping is used, this
#  will be the same port as is on druid.host
#
#  Defaults to 8083.
#
# [*service*]
#  The name of the service. This is used as a dimension when emitting metrics
#  and alerts to differentiate between the various services
#
#  Defaults to 'druid/historical'.
#
# [*server_max_size*]
#  The maximum number of bytes-worth of segments that the node wants assigned
#  to it. This is not a limit that Historical nodes actually enforces, just a
#  value published to the Coordinator node so it can plan accordingly.
#
#  Defaults to 0.
#
# [*server_tier*]
#  A string to name the distribution tier that the storage node belongs to.
#  Many of the rules Coordinator nodes use to manage segments can be keyed on
#  tiers.
#
#  Defaults to '_default_tier'.
#
# [*server_priority*]
#  In a tiered architecture, the priority of the tier, thus allowing control
#  over which nodes are queried. Higher numbers mean higher priority. The
#  default (no priority) works for architecture with no cross replication
#  (tiers that have no data-storage overlap). Data centers typically have
#  equal priority.
#
#  Defaults to 0.
#
# [*segment_cache_locations*]
#  Segments assigned to a Historical node are first stored on the local file
#  system (in a disk cache) and then served by the Historical node. These
#  locations define where that local cache resides.
#
#  Valid values are 'none' (also `undef`) or an absolute file path.
#
# [*segment_cache_delete_on_remove*]
#  Delete segment files from cache once a node is no longer serving a segment.
#
#  Defaults to true.
#
# [*segment_cache_drop_segment_delay_millis*]
#  How long a node delays before completely dropping segment.
#
#  Defaults to 30000 (30 seconds).
#
# [*segment_cache_info_dir*]
#  Historical nodes keep track of the segments they are serving so that when
#  the process is restarted they can reload the same segments without waiting
#  for the Coordinator to reassign. This path defines where this metadata is
#  kept. Directory will be created if needed.
#
# [*segment_cache_announce_interval_millis*]
#  How frequently to announce segments while segments are loading from cache.
#  Set this value to zero to wait for all segments to be loaded before
#  announcing.
#
#  Defaults to 5000 (5 seconds).
#
# [*segment_cache_num_loading_threads*]
#  How many segments to load concurrently from from deep storage.
#
#  Defaults to 1.
#
# [*server_http_num_threads*]
#  Number of threads for HTTP requests.
#
#  Defaults to 10.
#
# [*server_http_max_idle_time*]
#  The Jetty max idle time for a connection.
#
#  Defaults to 'PT5m'.
#
# [*processing_buffer_size_bytes*]
#  This specifies a buffer size for the storage of intermediate results. The
#  computation engine in both the Historical and Realtime nodes will use a
#  scratch buffer of this size to do all of their intermediate computations
#  off-heap. Larger values allow for more aggregations in a single pass over
#  the data while smaller values can require more passes depending on the
#  query that is being executed.
#
#  Defaults to 1073741824 (1GB).
#
# [*processing_format_string*]
#  Realtime and historical nodes use this format string to name their processing threads.
#
#  Defaults to 'processing-%s'.
#
# [*processing_num_threads*]
#  Number of processing threads available for processing of segments.
#
#  Rule of thumb is num_cores - 1, which means that even under heavy load
#  there will still be one core available to do background tasks like
#  talking with ZooKeeper and pulling down segments. If only one core is
#  available, this property defaults to the value 1.
#
# [*processing_column_cache_size_bytes*]
#  Maximum size in bytes for the dimension value lookup cache. Any value
#  greater than 0 enables the cache. It is currently disabled by default.
#  Enabling the lookup cache can significantly improve the performance of
#  aggregators operating on dimension values, such as the JavaScript
#  aggregator, or cardinality aggregator, but can slow things down if
#  the cache hit rate is low (i.e. dimensions with few repeating values).
#  Enabling it may also require additional garbage collection tuning to avoid
#  long GC pauses.
#
#  Defaults to 0 (disabled).
#
# [*query_groupBy_single_threaded*]
#  Run single threaded group By queries.
#
#  Defaults to false.
#
# [*query_groupBy_max_intermediate_rows*]
#  Maximum number of intermediate rows.
#
#  Defaults to 50000.
#
# [*query_groupBy_max_results*]
#  Maximum number of results.
#
#  Defaults to 500000.
#
# [*query_search_max_search_limit*]
#  Maximum number of search results to return.
#
#  Defaults to 1000.
#
# [*use_cache*]
#  Enable the cache on the historical.
#
#  Defaults to false.
#
# [*populate_cache*]
#  Populate the cache on the historical.
#
#  Defaults to false.
#
# [*uncacheable*]
#  All query types to not cache.
#
#  Defaults to ["groupBy", "select"].
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
# [*num_merge_buffers*]
#   Number of merge buffers (needs to be > 0 for groupBy v2 engine).
#
#   Default value: `undef`.
#
# === Examples
#
#  class { 'druid::historical': }
#
# === Authors
#
# Tyler Yahn <codingalias@gmail.com>
#
class druid::historical (
  $host                                    = $druid::params::historical_host,
  $port                                    = $druid::params::historical_port,
  $service                                 = $druid::params::historical_service,
  $server_max_size                         = $druid::params::historical_server_max_size,
  $server_tier                             = $druid::params::historical_server_tier,
  $server_priority                         = $druid::params::historical_server_priority,
  $segment_cache_locations                 = $druid::params::historical_segment_cache_locations,
  $segment_cache_delete_on_remove          = $druid::params::historical_segment_cache_delete_on_remove,
  $segment_cache_drop_segment_delay_millis = $druid::params::historical_segment_cache_drop_segment_delay_millis,
  $segment_cache_info_dir                  = $druid::params::historical_segment_cache_info_dir,
  $segment_cache_announce_interval_millis  = $druid::params::historical_segment_cache_announce_interval_millis,
  $segment_cache_num_loading_threads       = $druid::params::historical_segment_cache_num_loading_threads,
  $server_http_num_threads                 = $druid::params::historical_server_http_num_threads,
  $server_http_max_idle_time               = $druid::params::historical_server_http_max_idle_time,
  $processing_buffer_size_bytes            = $druid::params::historical_processing_buffer_size_bytes,
  $processing_format_string                = $druid::params::historical_processing_format_string,
  $processing_num_threads                  = $druid::params::historical_processing_num_threads,
  $processing_column_cache_size_bytes      = $druid::params::historical_processing_column_cache_size_bytes,
  $query_group_by_single_threaded          = $druid::params::historical_query_group_by_single_threaded,
  $query_group_by_max_intermediate_rows    = $druid::params::historical_query_group_by_max_intermediate_rows,
  $query_group_by_max_results              = $druid::params::historical_query_group_by_max_results,
  $query_search_max_search_limit           = $druid::params::historical_query_search_max_search_limit,
  $use_cache                               = $druid::params::historical_use_cache,
  $populate_cache                          = $druid::params::historical_populate_cache,
  $uncacheable                             = $druid::params::historical_uncacheable,
  $jvm_opts                                = $druid::params::historical_jvm_opts,
  $num_merge_buffers                       = $druid::params::historical_num_merge_buffers,
) inherits druid::params {
  require druid

  validate_string(
    $service,
    $server_tier,
    $server_http_max_idle_time,
    $processing_format_string,
  )

  validate_integer($port)
  validate_integer($server_max_size)
  validate_integer($server_priority)
  validate_integer($segment_cache_drop_segment_delay_millis)
  validate_integer($segment_cache_announce_interval_millis)
  validate_integer($segment_cache_num_loading_threads)
  validate_integer($server_http_num_threads)
  validate_integer($processing_column_cache_size_bytes)
  validate_integer($processing_buffer_size_bytes)
  validate_integer($query_group_by_max_intermediate_rows)
  validate_integer($query_group_by_max_results)
  validate_integer($query_search_max_search_limit)

  if ($processing_num_threads != undef) {
    validate_integer($processing_num_threads)
  }

  if ($num_merge_buffers != undef) {
    validate_integer($num_merge_buffers)
  }

  validate_bool(
    $segment_cache_delete_on_remove,
    $query_group_by_single_threaded,
    $use_cache,
    $populate_cache
  )

  validate_array($uncacheable)
  validate_array($jvm_opts)

  if ($segment_cache_locations != undef) {
    validate_array($segment_cache_locations)
    if ($segment_cache_info_dir != undef) {
      validate_absolute_path($segment_cache_info_dir)
    }
  }

  druid::service { 'historical':
    config_content  => template("${module_name}/historical.runtime.properties.erb"),
    service_content => template("${module_name}/druid-historical.service.erb"),
  }
}
