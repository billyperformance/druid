# == Class: druid::indexing
#
# Private class used to setup Druid nodes runing an indexing service.
#
# === Parameters
#
# [*azure_logs_container*]
#   The Azure Blob Store container to store logs at. 
#
# [*azure_logs_prefix*]
#   The path to prepend to logs for Azure storage. 
#
# [*hdfs_logs_directory*]
#   The HDFS directory to store logs. 
#
# [*local_logs_directory*]
#   Local filesystem path to store logs. 
#
#   Default value: `'/var/log'`
#
# [*logs_type*]
#   Where to store task logs. 
#
#   Valid values: `'noop'`, `'s3'`, `'azure'`, `'hdfs'`, `'file'`. 
#
#   Default value: `'file'`. 
#
# [*s3_logs_bucket*]
#   S3 bucket name to store logs at. 
#
# [*s3_logs_prefix*]
#   S3 key prefix. 
#
# === Authors
#
# Tyler Yahn <codingalias@gmail.com>
#

class druid::indexing (
  $azure_logs_container = $druid::params::indexing_azure_logs_container,
  $azure_logs_prefix    = $druid::params::indexing_azure_logs_prefix,
  $hdfs_logs_directory  = $druid::params::indexing_hdfs_logs_directory,
  $local_logs_directory = $druid::params::indexing_local_logs_directory,
  $logs_type            = $druid::params::indexing_logs_type,
  $s3_logs_bucket       = $druid::params::indexing_s3_logs_bucket,
  $s3_logs_prefix       = $druid::params::indexing_s3_logs_prefix,
) inherits druid::params {
  require druid

  validate_re($logs_type, ['^noop$', '^s3$', '^azure$', '^hdfs$', '^file$'])
  validate_string(
    $azure_logs_container,
    $azure_logs_prefix,
    $hdfs_logs_directory,
    $local_logs_directory,
    $s3_logs_bucket,
    $s3_logs_prefix,
  )
}
