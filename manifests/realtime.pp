# == Class: druid::realtime
#
# Setup a Druid node runing the realtime service.
#
# === Parameters
#
# [*host*]
#   Host address the service listens on.
#
#   Default value: The `$ipaddress` fact.
#
# [*port*]
#   Port the service listens on.
#
#   Default value: `8084`.
#
# [*service*]
#   The name of the service.
#
#   This is used as a dimension when emitting metrics and alerts.  It is
#   used to differentiate between the various services
#
#   Default value: `'druid/realtime'`.
#
# [*jvm_opts*]
#   Array of options to set for the JVM running the service.
#
#   Default value: `[
#     '-server',
#     '-Duser.timezone=UTC',
#     '-Dfile.encoding=UTF-8',
#     '-Djava.io.tmpdir=/tmp',
#     '-Djava.util.logging.manager=org.apache.logging.log4j.jul.LogManager'
#   ]`
#
# [*processing_buffer_size_bytes*]
#   Buffer size for the storage of intermediate results.
#
#   The computation engine uses a scratch buffer of this size to do all
#   intermediate computations off-heap. Larger values allow for more
#   aggregations in a single pass over the data while smaller values can
#   require more passes depending on the query that is being executed.
#
#   Default value: `1073741824` (1GB).
#
# [*processing_column_cache_size_bytes*]
#   Maximum size in bytes for the dimension value lookup cache.
#
#   Any value greater than `0` enables the cache. Enabling the lookup cache
#   can significantly improve the performance of aggregators operating on
#   dimension values, such as the JavaScript aggregator, or cardinality
#   aggregator, but can slow things down if the cache hit rate is low (i.e.
#   dimensions with few repeating values). Enabling it may also require
#   additional garbage collection tuning to avoid long GC pauses.
#
#   Default value: `0` (disabled).
#
# [*processing_format_string*]
#   Format string to name processing threads.
#
#   Default value: `'processing-%s'`.
#
# [*processing_num_threads*]
#   Number of processing threads for processing of segments.
#
#   Rule of thumb is num_cores - 1, which means that even under heavy load
#   there will still be one core available to do background tasks like
#   talking with ZooKeeper and pulling down segments.
#
# [*publish_type*]
#   Where to publish segments.
#
#   Valid values: `'noop'` or `'metadata'`.
#
#   Default value: `'metadata'`.
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
#   Run single threaded `groupBy` queries.
#
#   Default value: `false`.
#
# [*query_search_max_search_limit*]
#   Maximum number of search results to return.
#
#   Default value: `1000`.
#
# [*segment_cache_locations*]
#   Where intermediate segments are stored.
#
# [*spec_file*]
#   File location of realtime specFile.
#
# [*spec_file_content*]
#   Content to ensure in spec_file.
#
# === Authors
#
# Tyler Yahn <codingalias@gmail.com>
#

class druid::realtime (
  $host                                 = $druid::params::realtime_host,
  $port                                 = $druid::params::realtime_port,
  $service                              = $druid::params::realtime_service,
  $jvm_opts                             = $druid::params::realtime_jvm_opts,
  $processing_buffer_size_bytes         = $druid::params::realtime_processing_buffer_size_bytes,
  $processing_column_cache_size_bytes   = $druid::params::realtime_processing_column_cache_size_bytes,
  $processing_format_string             = $druid::params::realtime_processing_format_string,
  $processing_num_threads               = $druid::params::realtime_processing_num_threads,
  $publish_type                         = $druid::params::realtime_publish_type,
  $query_group_by_max_intermediate_rows = $druid::params::realtime_query_group_by_max_intermediate_rows,
  $query_group_by_max_results           = $druid::params::realtime_query_group_by_max_results,
  $query_group_by_single_threaded       = $druid::params::realtime_query_group_by_single_threaded,
  $query_search_max_search_limit        = $druid::params::realtime_query_search_max_search_limit,
  $segment_cache_locations              = $druid::params::realtime_segment_cache_locations,
  $spec_file                            = $druid::params::realtime_spec_file,
  $spec_file_content                    = $druid::params::realtime_spec_file_content,
) inherits druid::params {
  require druid

  validate_string(
    $host,
    $service,
    $processing_format_string,
    $spec_file_content,
  )

  validate_re($publish_type, ['^noop$', '^metadata$'])

  validate_integer($port)
  validate_integer($processing_buffer_size_bytes)
  validate_integer($processing_column_cache_size_bytes)
  if $processing_num_threads {
    validate_integer($processing_num_threads)
  }
  validate_integer($query_group_by_max_intermediate_rows)
  validate_integer($query_group_by_max_results)
  validate_integer($query_search_max_search_limit)

  validate_bool($query_group_by_single_threaded)

  validate_array($jvm_opts)

  if $segment_cache_locations {
    validate_absolute_path($segment_cache_locations)
  }

  if $spec_file {
    validate_absolute_path($spec_file)

    file { $spec_file :
      ensure  => file,
      content => $spec_file_content,
      before  => Service['druid-realtime'],
    }
  }

  druid::service { 'realtime':
    config_content  => template("${module_name}/realtime.runtime.properties.erb"),
    service_content => template("${module_name}/druid-realtime.service.erb"),
  }
}
