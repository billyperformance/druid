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
# [*plaintext_port*]
#   Port the service listens on.
#
#   Default value: `8888`.
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
#
# ToDo document the remaining params
#
#


class druid::router (
  $host                                 = $druid::params::router_host,
  $plaintext_port                       = $druid::params::router_plaintext_port,
  $service                              = $druid::params::router_service,
  $jvm_opts                             = $druid::params::router_jvm_opts,
  # Service discovery
  $default_broker_service_name          = $druid::params::router_default_broker_service_name,
  $coordinator_service_name             = $druid::params::router_coordinator_service_name,
  $default_rule                         = $druid::params::router_default_rule,
  $poll_period                          = $druid::params::router_poll_period,
  $strategies                           = $druid::params::router_strategies,
  $avatica_balancer_type                = $druid::params::router_avatica_balancer_type,
  # Management proxy to coordinator / overlord: required for unified web console.
  $management_proxy_enabled             = $druid::params::router_management_proxy_enabled,
  $tier_to_broker_map                   = $druid::params::router_tier_to_broker_map,
  # HTTP proxy
  $http_num_connections                 = $druid::params::router_http_num_connections,
  $http_read_timeout                    = $druid::params::router_http_read_timeout,
  $http_num_max_threads                 = $druid::params::router_http_num_max_threads,
  $server_http_num_threads              = $druid::params::router_server_http_num_threads,
) inherits druid::params {
  require druid

  validate_string(
    $host,
    $service,
    $default_broker_service_name,
    $coordinator_service_name,
    $default_rule,
    $poll_period,
    $avatica_balancer_type,
    $http_read_timeout,
  )
  validate_bool($management_proxy_enabled)

  validate_integer($plaintext_port)
  validate_integer($http_num_connections)
  validate_integer($http_num_max_threads)
  validate_integer($server_http_num_threads)

  validate_array(
    $jvm_opts,
    $strategies,
  )

  validate_hash($router_tier_to_broker_map)

  druid::service { 'router':
    config_content  => template("${module_name}/router.runtime.properties.erb"),
    service_content => template("${module_name}/druid-router.service.erb"),
  }
}
