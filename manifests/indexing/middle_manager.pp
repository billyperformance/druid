# == Class: druid::indexing::middle_manager
#
# Setup a Druid node runing the indexing middleManager service.
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
#   Default value: `8080`.
#
# [*service*]
#   The name of the service.
#
#   This is used as a dimension when emitting metrics and alerts.  It is
#   used to differentiate between the various services
#
#   Default value: `'druid/middlemanager'`.
#
# [*fork_properties*]
#   Hash of explicit child peon config options.
#
#   Peons inherit the configurations of their parent middle managers, but if
#   this is undesired for certain config options they can be explicitly
#   passed here.
#
#   These key value pairs are expected in Druid config format and are
#   unvalidated.  The keys should NOT include
#   `'druid.indexer.fork.property'` as a prefix.
#
#   Example for druid >= 0.13.0:
#
#   ```puppet
#     {
#       "druid.monitoring.monitors" => "[\"org.apache.druid.java.util.metrics.JvmMonitor\"]",
#       "druid.processing.numThreads" => 2,
#     }
#   ```#   Example for druid version older than 0.13:
#
#   ```puppet
#     {
#       "druid.monitoring.monitors" => "[\"com.metamx.metrics.JvmMonitor\"]",
#       "druid.processing.numThreads" => 2,
#     }
#   ```
#   Default value: `{}`
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
# [*peon_mode*]
#   Mode peons are run in.
#
#   Valid values:
#     * `'local'`: Standalone mode (Not recommended).
#     * `'remote'`: Pooled.
#
#   Default value: `'remote'`.
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
# [*processing_num_threads*]
#   Number of processing threads available for processing of segments.
#
#   Rule of thumb is num_cores - 1, which means that even under heavy load
#   there will still be one core available to do background tasks like
#   talking with ZooKeeper and pulling down segments. If only one core is
#   available, this property defaults to the value 1.
#
# [*remote_peon_max_retry_count*]
#   Max retries a remote peon makes communicating with the overlord.
#
#   Default value: `10`.
#
# [*remote_peon_max_wait*]
#   Max retry time a remote peon makes communicating with the overlord.
#
#   Default value: `'PT10M'`.
#
# [*remote_peon_min_wait*]
#   Min retry time a remote peon makes communicating with the overlord.
#
#   Default value: `'PT1M'`.
#
# [*runner_allowed_prefixes*]
#   Array of prefixes of configs that are passed down to peons.
#
#   Default value: `['com.metamx', 'druid', 'io.druid', 'org.apache.druid.java.util.metrics', 'org.apache.druid', 'user.timezone', 'file.encoding']`.
#
# [*runner_classpath*]
#   Java classpath for the peons.
#
# [*runner_compress_znodes*]
#   Specify if Znodes are compressed.
#
#   Default value: `true`.
#
# [*runner_java_command*]
#   Command for peons to use to execute java.
#
#   Default value: `'java'`.
#
# [*runner_java_opts*]
#   Java "-X" options for the peon to use in its own JVM.
#
# [*runner_max_znode_bytes*]
#   Maximum Znode size in bytes that can be created in Zookeeper.
#
#   Default value: `524288`.
#
# [*runner_start_port*]
#   Port peons begin running on.
#
#   Default value: `8100`.
#
# [*task_base_dir*]
#   Base temporary working directory.
#
#   Default value: `'/tmp'`.
#
# [*task_base_task_dir*]
#   Base temporary working directory for tasks.
#
#   Default value: `'/tmp/persistent/tasks'`.
#
# [*task_chat_handler_type*]
#   Specify service discovery type.
#
#   Certain tasks will use service discovery to announce an HTTP endpoint
#   that events can be posted to.
#
#   Valid values: `'noop'` or `'announce'`.
#
#   Default value: `'noop'`.
#
# [*task_default_hadoop_coordinates*]
#   Array of default Hadoop versions to use.
#
#   This is used with HadoopIndexTasks that do not request a particular
#   version.
#
#   Default value: `['org.apache.hadoop:hadoop-client:2.3.0']`.
#
# [*task_default_row_flush_boundary*]
#   Highest row count before persisting to disk.
#
#   Used for indexing generating tasks.
#
#   Default value: `50000`.
#
# [*task_hadoop_working_path*]
#   Temporary working directory for Hadoop tasks.
#
#   Default value: `'/tmp/druid-indexing'`.
#
# [*worker_capacity*]
#   Maximum number of tasks to accept.
#
# [*worker_ip*]
#   The IP of the worker.
#
#   Default value: `'localhost'`.
#
# [*worker_version*]
#   Version identifier for the middle manager.
#
#   Default value: `'0'`.
#
# [*num_merge_buffers*]
#   Number of merge buffers (needs to be > 0 for groupBy v2 engine).
#
#   Default value: `undef`.
#
# [*server_http_num_threads*]
#   Number of threads for HTTP requests.
#
#   Default value: `10`.
#
# === Authors
#
# Tyler Yahn <codingalias@gmail.com>
#

class druid::indexing::middle_manager (
  $host                            = $druid::params::middle_manager_host,
  $port                            = $druid::params::middle_manager_port,
  $service                         = $druid::params::middle_manager_service,
  $fork_properties                 = $druid::params::middle_manager_fork_properties,
  $jvm_opts                        = $druid::params::middle_manager_jvm_opts,
  $peon_mode                       = $druid::params::middle_manager_peon_mode,
  $processing_buffer_size_bytes    = $druid::params::middle_manager_processing_buffer_size_bytes,
  $processing_num_threads          = $druid::params::middle_manager_processing_num_threads,
  $remote_peon_max_retry_count     = $druid::params::middle_manager_remote_peon_max_retry_count,
  $remote_peon_max_wait            = $druid::params::middle_manager_remote_peon_max_wait,
  $remote_peon_min_wait            = $druid::params::middle_manager_remote_peon_min_wait,
  $runner_allowed_prefixes         = $druid::params::middle_manager_runner_allowed_prefixes,
  $runner_classpath                = $druid::params::middle_manager_runner_classpath,
  $runner_compress_znodes          = $druid::params::middle_manager_runner_compress_znodes,
  $runner_java_command             = $druid::params::middle_manager_runner_java_command,
  $runner_java_opts                = $druid::params::middle_manager_runner_java_opts,
  $runner_max_znode_bytes          = $druid::params::middle_manager_runner_max_znode_bytes,
  $runner_start_port               = $druid::params::middle_manager_runner_start_port,
  $task_base_dir                   = $druid::params::middle_manager_task_base_dir,
  $task_base_task_dir              = $druid::params::middle_manager_task_base_task_dir,
  $task_chat_handler_type          = $druid::params::middle_manager_task_chat_handler_type,
  $task_default_hadoop_coordinates = $druid::params::middle_manager_task_default_hadoop_coordinates,
  $task_default_row_flush_boundary = $druid::params::middle_manager_task_default_row_flush_boundary,
  $task_hadoop_working_path        = $druid::params::middle_manager_task_hadoop_working_path,
  $worker_capacity                 = $druid::params::middle_manager_worker_capacity,
  $worker_ip                       = $druid::params::middle_manager_worker_ip,
  $worker_version                  = $druid::params::middle_manager_worker_version,
  $num_merge_buffers               = $druid::params::middle_manager_num_merge_buffers,
  $server_http_num_threads         = $druid::params::middle_manager_server_http_num_threads,
) inherits druid::params {
  require druid

  validate_re($peon_mode, ['^local$', '^remote$'])
  validate_re($task_chat_handler_type, ['^noop$', '^announce$'])

  validate_string(
    $host,
    $service,
    $remote_peon_max_wait,
    $remote_peon_min_wait,
    $runner_classpath,
    $runner_java_command,
    $runner_java_opts,
    $worker_ip,
    $worker_version,
  )

  validate_integer($port)
  validate_integer($processing_buffer_size_bytes)
  if ($processing_num_threads != undef) {
    validate_integer($processing_num_threads)
  }
  validate_integer($remote_peon_max_retry_count)
  validate_integer($runner_max_znode_bytes)
  validate_integer($runner_start_port)
  validate_integer($task_default_row_flush_boundary)
  if $worker_capacity {
    validate_integer($worker_capacity)
  }
  if ($num_merge_buffers != undef) {
    validate_integer($num_merge_buffers)
  }
  validate_integer($server_http_num_threads)

  validate_hash($fork_properties)

  validate_array($runner_allowed_prefixes)
  validate_array($jvm_opts)
  validate_array($task_default_hadoop_coordinates)

  validate_bool($runner_compress_znodes)

  validate_absolute_path($task_base_dir)
  validate_absolute_path($task_base_task_dir)
  validate_absolute_path($task_hadoop_working_path)

  exec { "Create task base task directory with tmp":
    # this tmp directory can be used as the java.io.tmpdir for runner_java_opts if task_base_task_dir is in a separate partition with plenty of space
    command     => "mkdir -p ${task_base_task_dir}/tmp",
    creates     => "${task_base_task_dir}/tmp",
    before      => Service['druid-middle_manager'],
  }

  druid::service { 'middle_manager':
    config_content  => template("${module_name}/middle_manager.runtime.properties.erb"),
    service_content => template("${module_name}/druid-middle_manager.service.erb"),
  }
}
