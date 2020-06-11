require 'spec_helper'

describe 'druid', :type => 'class' do
  context 'On generic system with defaults for all parameters in Druid 0.9.2' do
    let(:facts) do
      {
        :memorysize      => '10 GB',
        :ipaddress       => '127.0.0.1',
        :osfamily        => 'Darwin',
        :operatingsystem => 'Darwin',
        :architecture    => 'x86_64',
      }
    end
    it {
      should compile.with_all_deps
      should contain_class('druid')
      should contain_archive('/var/tmp/druid-0.9.2-bin.tar.gz').with({
        :ensure          => 'present',
        :extract         => 'true',
        :extract_path    => '/opt',
        :source          => 'http://static.druid.io/artifacts/releases/druid-0.9.2-bin.tar.gz',
        :checksum_verify => 'false',
        :creates         => '/opt/druid-0.9.2',
        :cleanup         => 'true',
      })
      should contain_exec('Remove all default extensions in directory /opt/druid-0.9.2/extensions/').with({
        :path => ['/usr/bin', '/usr/sbin', '/bin'],
        :command => "rm -rf /opt/druid-0.9.2/extensions/*",
        :subscribe => "Archive[/var/tmp/druid-0.9.2-bin.tar.gz]",
        :refreshonly => true,
      })
      should contain_file('/opt/druid').with({
        :ensure => :link,
        :target => '/opt/druid-0.9.2'
      }).that_requires('Archive[/var/tmp/druid-0.9.2-bin.tar.gz]')
      should contain_file('/etc/druid').with({
        :ensure => 'directory'
      })
    }
  end

  context 'On generic system with custom install parameters' do
    let(:facts) do
      {
        :memorysize      => '10 GB',
        :ipaddress       => '127.0.0.1',
        :osfamily        => 'Darwin',
        :operatingsystem => 'Darwin',
        :architecture    => 'x86_64',
      }
    end
    let(:params) do
      {
        :version      => '0.14.2',
        :package_name => 'org.apache.druid',
      }
    end
    it {
      should compile.with_all_deps
      should contain_class('druid')
      should contain_archive('/var/tmp/apache-druid-0.14.2-incubating-bin.tar.gz').with({
        :ensure          => 'present',
        :extract         => 'true',
        :extract_path    => '/opt',
        :source          => 'https://archive.apache.org/dist/incubator/druid/0.14.2-incubating/apache-druid-0.14.2-incubating-bin.tar.gz',
        :checksum_verify => 'false',
        :creates         => '/opt/apache-druid-0.14.2-incubating',
        :cleanup         => 'true',
      })
      should contain_exec('Remove all default extensions in directory /opt/apache-druid-0.14.2-incubating/extensions/').with({
        :path => ['/usr/bin', '/usr/sbin', '/bin'],
        :command => "rm -rf /opt/apache-druid-0.14.2-incubating/extensions/*",
        :subscribe => "Archive[/var/tmp/apache-druid-0.14.2-incubating-bin.tar.gz]",
        :refreshonly => true,
      })
      should contain_file('/opt/druid').with({
        :ensure => :link,
        :target => '/opt/apache-druid-0.14.2-incubating'
      }).that_requires('Archive[/var/tmp/apache-druid-0.14.2-incubating-bin.tar.gz]')
      should contain_file('/etc/druid').with({
        :ensure => 'directory'
      })
    }
  end

  context 'Check that you cannot set org.apache.druid with a version < 0.13.0' do
    let(:facts) do
      {
        :memorysize      => '10 GB',
        :ipaddress       => '127.0.0.1',
        :osfamily        => 'Darwin',
        :operatingsystem => 'Darwin',
        :architecture    => 'x86_64',
      }
    end
    let(:params) do
      {
        :version      => '0.9.2',
        :package_name => 'org.apache.druid',
      }
    end
    it { should compile.and_raise_error(/"org.apache.druid" does not match \["\^io.druid\$"\]/) }
  end

  context 'Check that you cannot set io.druid with a version >= 0.13.0' do
    let(:facts) do
      {
        :memorysize      => '10 GB',
        :ipaddress       => '127.0.0.1',
        :osfamily        => 'Darwin',
        :operatingsystem => 'Darwin',
        :architecture    => 'x86_64',
      }
    end
    let(:params) do
      {
        :version      => '0.14.2',
        :package_name => 'io.druid',
      }
    end
    it { should compile.and_raise_error(/"io.druid" does not match \["\^org.apache.druid\$"\]/) }
  end

  context 'On generic system with custom druid parameters' do

    let(:facts) do
      {
        :memorysize      => '10 GB',
        :ipaddress       => '127.0.0.1',
        :osfamily        => 'Darwin',
        :operatingsystem => 'Darwin',
        :architecture    => 'x86_64',
      }
    end
    let(:params) do
      {
        :extensions_remote_repositories           => ['http://repo1.maven.org/maven2/'],
        :extensions_local_repository              => '~/.m2-test/repository',
        :extensions_coordinates                   => ['groupID;artifactID:version'],
        :extensions_hadoop_deps_dir               => '/opt/druid/hadoop-dependencies',
        :extensions_default_version               => 'test',
        :extensions_search_current_classloader    => false,
        :zk_service_host                          => '192.168.0.150',
        :zk_service_session_timeout_ms            => 30002,
        :curator_compress                         => false,
        :zk_paths_base                            => '/druid',
        :zk_paths_properties_path                 => '/druid/1',
        :zk_paths_announcements_path              => '/druid/2',
        :zk_paths_live_segments_path              => '/druid/3',
        :zk_paths_load_queue_path                 => '/druid/4',
        :zk_paths_coordinator_path                => '/druid/5',
        :zk_paths_indexer_base                    => '/druid/6',
        :zk_paths_indexer_announcements_path      => '/druid/7',
        :zk_paths_indexer_tasks_path              => '/druid/8',
        :zk_paths_indexer_status_path             => '/druid/9',
        :zk_paths_indexer_leader_latch_path       => '/druid/10',
        :discovery_curator_path                   => '/druid-test/discovery',
        :request_logging_type                     => 'file',
        :request_logging_dir                      => '/log/',
        :request_logging_feed                     => 'druid-test',
        :monitoring_emission_period               => 'PT2m',
        :monitoring_monitors                      => ['mode'],
        :emitter                                  => 'logging',
        :emitter_logging_logger_class             => 'ServiceEmitter',
        :emitter_logging_log_level                => 'debug',
        :emitter_http_time_out                    => 'PT6M',
        :emitter_http_flush_millis                => 60001,
        :emitter_http_flush_count                 => 501,
        :emitter_http_recipient_base_url          => '127.0.0.1',
        :metadata_storage_type                    => 'mysql',
        :metadata_storage_connector_uri           => 'jdbc:mysql://127.0.0.1:3306/druid?characterEncoding=UTF-8',
        :metadata_storage_connector_user          => 'druid-test',
        :metadata_storage_connector_password      => 'test_insecure_pass',
        :metadata_storage_connector_create_tables => false,
        :metadata_storage_tables_base             => 'druid-test',
        :metadata_storage_tables_segment_table    => 'druid-test_segments',
        :metadata_storage_tables_rule_table       => 'druid-test_rules',
        :metadata_storage_tables_config_table     => 'druid-test_config',
        :metadata_storage_tables_tasks            => 'druid-test_tasks',
        :metadata_storage_tables_task_log         => 'druid-test_taskLog',
        :metadata_storage_tables_task_lock        => 'druid-test_taskLock',
        :metadata_storage_tables_audit            => 'druid-test_audit',
        :storage_type                             => 's3',
        :storage_directory                        => '/tmp/druid-test/localStorage',
        :s3_access_key                            => 'key3',
        :s3_secret_key                            => 'key2',
        :s3_bucket                                => 'druid',
        :s3_base_key                              => 'key1',
        :storage_disable_acl                      => true,
        :s3_archive_bucket                        => 'druid-archive',
        :s3_archive_base_key                      => 'druid-base-key',
        :hdfs_directory                           => 'druid',
        :cassandra_host                           => '127.0.0.1',
        :cassandra_keyspace                       => 'none',
        :cache_type                               => 'memcached',
        :cache_size_in_bytes                      => 2,
        :cache_initial_size                       => 500002,
        :cache_log_eviction_count                 => 2,
        :cache_expiration                         => 2592002,
        :cache_timeout                            => 501,
        :cache_hosts                              => ['127.0.0.1:1221', '192.168.0.10:1122'],
        :cache_max_object_size                    => 52428802,
        :cache_memcached_prefix                   => 'druid-test',
        :selectors_indexing_service_name          => 'druid-test/overlord',
        :announcer_type                           => 'lecagy',
        :announcer_segments_per_node              => 51,
        :announcer_max_bytes_per_node             => 524289,
      }
    end
    it {
      should contain_file('/etc/druid/log4j2.xml')\
        .with_content("<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<Configuration status=\"WARN\">\n    <Appenders>\n        <Console name=\"Console\" target=\"SYSTEM_OUT\">\n            <PatternLayout pattern=\"%d{ISO8601} %p [%t] %c - %m%n\"/>\n        </Console>\n    </Appenders>\n    <Loggers>\n        <Root level=\"info\">\n            <AppenderRef ref=\"Console\"/>\n        </Root>\n    </Loggers>\n</Configuration>")
    }
    it {
      should contain_file('/etc/druid/common.runtime.properties').with_content("# This file is managed by Puppet\n# MODIFICATION WILL BE OVERWRITTEN\n\n# Extensions\ndruid.extensions.remoteRepositories=[\"http://repo1.maven.org/maven2/\"]\ndruid.extensions.localRepository=~/.m2-test/repository\ndruid.extensions.coordinates=[\"groupID;artifactID:version\"]\ndruid.extensions.defaultVersion=test\ndruid.extensions.searchCurrentClassloader=false\ndruid.extensions.hadoopDependenciesDir=/opt/druid/hadoop-dependencies\n\n# Zookeeper\ndruid.zk.paths.base=/druid\ndruid.zk.service.host=192.168.0.150\ndruid.zk.service.sessionTimeoutMs=30002\ndruid.curator.compress=false\ndruid.zk.paths.propertiesPath=/druid/1\ndruid.zk.paths.announcementsPath=/druid/2\ndruid.zk.paths.liveSegmentsPath=/druid/3\ndruid.zk.paths.loadQueuePath=/druid/4\ndruid.zk.paths.coordinatorPath=/druid/5\ndruid.zk.paths.indexer.base=/druid/6\ndruid.zk.paths.indexer.announcementsPath=/druid/7\ndruid.zk.paths.indexer.tasksPath=/druid/8\ndruid.zk.paths.indexer.statusPath=/druid/9\ndruid.zk.paths.indexer.leaderLatchPath=/druid/10\ndruid.discovery.curator.path=/druid-test/discovery\n\n# Request Logging\ndruid.request.logging.type=file\ndruid.request.logging.dir=/log/\n\n# Enabling Metrics\ndruid.monitoring.emissionPeriod=PT2m\ndruid.monitoring.monitors=[\"mode\"]\n\n# Emitting Metrics\ndruid.emitter=logging\ndruid.emitter.logging.loggerClass=ServiceEmitter\ndruid.emitter.logging.logLevel=debug\n\n# Metadata Storage\ndruid.metadata.storage.type=mysql\ndruid.metadata.storage.connector.connectURI=jdbc:mysql://127.0.0.1:3306/druid?characterEncoding=UTF-8\ndruid.metadata.storage.connector.user=druid-test\ndruid.metadata.storage.connector.password=test_insecure_pass\ndruid.metadata.storage.connector.createTables=false\ndruid.metadata.storage.tables.base=druid-test\ndruid.metadata.storage.tables.segmentTable=druid-test_segments\ndruid.metadata.storage.tables.ruleTable=druid-test_rules\ndruid.metadata.storage.tables.configTable=druid-test_config\ndruid.metadata.storage.tables.tasks=druid-test_tasks\ndruid.metadata.storage.tables.taskLog=druid-test_taskLog\ndruid.metadata.storage.tables.taskLock=druid-test_taskLock\ndruid.metadata.storage.tables.audit=druid-test_audit\n\n# Deep Storage\ndruid.storage.type=s3\ndruid.s3.accessKey=key3\ndruid.s3.secretKey=key2\ndruid.storage.bucket=druid\ndruid.storage.baseKey=key1\ndruid.storage.disableAcl=true\ndruid.storage.archiveBucket=druid-archive\ndruid.storage.archiveBaseKey=druid-base-key\n\n# Caching\ndruid.cache.type=memcached\ndruid.cache.expiration=2592002\ndruid.cache.timeout=501\ndruid.cache.hosts=127.0.0.1:1221,192.168.0.10:1122\ndruid.cache.maxObjectSize=52428802\ndruid.cache.memcachedPrefix=druid-test\n\n# Indexing Service Discovery\ndruid.selectors.indexing.serviceName=druid-test/overlord\n\n# Coordinator Service Discovery\ndruid.selectors.coordinator.serviceName=druid/coordinator\n\n# Logging\n# #\n#\n# # Log all runtime properties on startup. Disable to avoid logging properties on startup:\n\ndruid.startup.logging.logProperties=true\n#\n# Announcing Segments\ndruid.announcer.type=lecagy\n# Task Logging\ndruid.indexer.logs.type=file\ndruid.indexer.logs.directory=/var/log\n")
    }
  end

  context 'On base system with local as cache' do
    let(:facts) do
      {
        :memorysize      => '10 GB',
        :ipaddress       => '127.0.0.1',
        :osfamily        => 'Darwin',
        :operatingsystem => 'Darwin',
        :architecture    => 'x86_64',
      }
    end

    let(:params) do
      {
        :cache_size_in_bytes                     => 7065,
        :cache_initial_size                      => 6355,
        :cache_log_eviction_count                => 69,
        :cache_type                              => 'local',
      }
    end

    it {
      should contain_file('/etc/druid/common.runtime.properties').with_content("# This file is managed by Puppet\n# MODIFICATION WILL BE OVERWRITTEN\n\n# Extensions\ndruid.extensions.remoteRepositories=[\"http://repo1.maven.org/maven2/\", \"https://metamx.artifactoryonline.com/metamx/pub-libs-releases-local\"]\ndruid.extensions.localRepository=~/.m2/repository\ndruid.extensions.coordinates=[]\ndruid.extensions.searchCurrentClassloader=true\ndruid.extensions.hadoopDependenciesDir=/opt/druid/hadoop-dependencies\n\n# Zookeeper\ndruid.zk.paths.base=/druid\ndruid.zk.service.host=localhost\ndruid.zk.service.sessionTimeoutMs=30000\ndruid.curator.compress=true\ndruid.discovery.curator.path=/druid/discovery\n\n# Request Logging\ndruid.request.logging.type=noop\n\n# Enabling Metrics\ndruid.monitoring.emissionPeriod=PT1m\n\n# Emitting Metrics\ndruid.emitter=logging\ndruid.emitter.logging.loggerClass=LoggingEmitter\ndruid.emitter.logging.logLevel=info\n\n# Metadata Storage\ndruid.metadata.storage.type=mysql\ndruid.metadata.storage.connector.connectURI=jdbc:mysql://localhost:3306/druid?characterEncoding=UTF-8\ndruid.metadata.storage.connector.user=druid\ndruid.metadata.storage.connector.password=insecure_pass\ndruid.metadata.storage.connector.createTables=true\ndruid.metadata.storage.tables.base=druid\ndruid.metadata.storage.tables.segmentTable=druid_segments\ndruid.metadata.storage.tables.ruleTable=druid_rules\ndruid.metadata.storage.tables.configTable=druid_config\ndruid.metadata.storage.tables.tasks=druid_tasks\ndruid.metadata.storage.tables.taskLog=druid_taskLog\ndruid.metadata.storage.tables.taskLock=druid_taskLock\ndruid.metadata.storage.tables.audit=druid_audit\n\n# Deep Storage\ndruid.storage.type=local\ndruid.storage.storageDirectory=/tmp/druid/localStorage\n\n# Caching\ndruid.cache.type=local\ndruid.cache.sizeInBytes=7065\ndruid.cache.initialSize=6355\ndruid.cache.logEvictionCount=69\n\n# Indexing Service Discovery\ndruid.selectors.indexing.serviceName=druid/overlord\n\n# Coordinator Service Discovery\ndruid.selectors.coordinator.serviceName=druid/coordinator\n\n# Logging\n# #\n#\n# # Log all runtime properties on startup. Disable to avoid logging properties on startup:\n\ndruid.startup.logging.logProperties=true\n#\n# Announcing Segments\ndruid.announcer.type=batch\ndruid.announcer.segmentsPerNode=50\ndruid.announcer.maxBytesPerNode=524288\n# Task Logging\ndruid.indexer.logs.type=file\ndruid.indexer.logs.directory=/var/log\n")
    }
  end

  context 'On base system with memcached as cache' do
    let(:facts) do
      {
        :memorysize      => '10 GB',
        :ipaddress       => '127.0.0.1',
        :osfamily        => 'Darwin',
        :operatingsystem => 'Darwin',
        :architecture    => 'x86_64',
      }
    end

    let(:params) do
      {
        :cache_expiration                     => 4184004,
        :cache_timeout                        => 500,
        :cache_hosts                          => ['127.0.0.1:1223'],
        :cache_max_object_size                => 52428802,
        :cache_memcached_prefix               => 'druid',
        :cache_type                           => 'memcached',
      }
    end

    it {
      should contain_file('/etc/druid/common.runtime.properties').with_content("# This file is managed by Puppet\n# MODIFICATION WILL BE OVERWRITTEN\n\n# Extensions\ndruid.extensions.remoteRepositories=[\"http://repo1.maven.org/maven2/\", \"https://metamx.artifactoryonline.com/metamx/pub-libs-releases-local\"]\ndruid.extensions.localRepository=~/.m2/repository\ndruid.extensions.coordinates=[]\ndruid.extensions.searchCurrentClassloader=true\ndruid.extensions.hadoopDependenciesDir=/opt/druid/hadoop-dependencies\n\n# Zookeeper\ndruid.zk.paths.base=/druid\ndruid.zk.service.host=localhost\ndruid.zk.service.sessionTimeoutMs=30000\ndruid.curator.compress=true\ndruid.discovery.curator.path=/druid/discovery\n\n# Request Logging\ndruid.request.logging.type=noop\n\n# Enabling Metrics\ndruid.monitoring.emissionPeriod=PT1m\n\n# Emitting Metrics\ndruid.emitter=logging\ndruid.emitter.logging.loggerClass=LoggingEmitter\ndruid.emitter.logging.logLevel=info\n\n# Metadata Storage\ndruid.metadata.storage.type=mysql\ndruid.metadata.storage.connector.connectURI=jdbc:mysql://localhost:3306/druid?characterEncoding=UTF-8\ndruid.metadata.storage.connector.user=druid\ndruid.metadata.storage.connector.password=insecure_pass\ndruid.metadata.storage.connector.createTables=true\ndruid.metadata.storage.tables.base=druid\ndruid.metadata.storage.tables.segmentTable=druid_segments\ndruid.metadata.storage.tables.ruleTable=druid_rules\ndruid.metadata.storage.tables.configTable=druid_config\ndruid.metadata.storage.tables.tasks=druid_tasks\ndruid.metadata.storage.tables.taskLog=druid_taskLog\ndruid.metadata.storage.tables.taskLock=druid_taskLock\ndruid.metadata.storage.tables.audit=druid_audit\n\n# Deep Storage\ndruid.storage.type=local\ndruid.storage.storageDirectory=/tmp/druid/localStorage\n\n# Caching\ndruid.cache.type=memcached\ndruid.cache.expiration=4184004\ndruid.cache.timeout=500\ndruid.cache.hosts=127.0.0.1:1223\ndruid.cache.maxObjectSize=52428802\ndruid.cache.memcachedPrefix=druid\n\n# Indexing Service Discovery\ndruid.selectors.indexing.serviceName=druid/overlord\n\n# Coordinator Service Discovery\ndruid.selectors.coordinator.serviceName=druid/coordinator\n\n# Logging\n# #\n#\n# # Log all runtime properties on startup. Disable to avoid logging properties on startup:\n\ndruid.startup.logging.logProperties=true\n#\n# Announcing Segments\ndruid.announcer.type=batch\ndruid.announcer.segmentsPerNode=50\ndruid.announcer.maxBytesPerNode=524288\n# Task Logging\ndruid.indexer.logs.type=file\ndruid.indexer.logs.directory=/var/log\n")
    }
  end

  context 'On base system with caffeine as cache' do
    let(:facts) do
      {
        :memorysize      => '10 GB',
        :ipaddress       => '127.0.0.1',
        :osfamily        => 'Darwin',
        :operatingsystem => 'Darwin',
        :architecture    => 'x86_64',
      }
    end

    let(:params) do
      {
        :version                              => '0.14.2',
        :package_name                         => 'org.apache.druid',
        :cache_size_in_bytes                  => 2048,
        :cache_expire_after                   => 300,
        :cache_type                           => 'caffeine',
      }
    end

    it {
      should contain_file('/etc/druid/common.runtime.properties').with_content("# This file is managed by Puppet\n# MODIFICATION WILL BE OVERWRITTEN\n\n# Extensions\ndruid.extensions.remoteRepositories=[\"http://repo1.maven.org/maven2/\", \"https://metamx.artifactoryonline.com/metamx/pub-libs-releases-local\"]\ndruid.extensions.localRepository=~/.m2/repository\ndruid.extensions.coordinates=[]\ndruid.extensions.searchCurrentClassloader=true\ndruid.extensions.hadoopDependenciesDir=/opt/druid/hadoop-dependencies\n\n# Zookeeper\ndruid.zk.paths.base=/druid\ndruid.zk.service.host=localhost\ndruid.zk.service.sessionTimeoutMs=30000\ndruid.curator.compress=true\ndruid.discovery.curator.path=/druid/discovery\n\n# Request Logging\ndruid.request.logging.type=noop\n\n# Enabling Metrics\ndruid.monitoring.emissionPeriod=PT1m\n\n# Emitting Metrics\ndruid.emitter=logging\ndruid.emitter.logging.loggerClass=LoggingEmitter\ndruid.emitter.logging.logLevel=info\n\n# Metadata Storage\ndruid.metadata.storage.type=mysql\ndruid.metadata.storage.connector.connectURI=jdbc:mysql://localhost:3306/druid?characterEncoding=UTF-8\ndruid.metadata.storage.connector.user=druid\ndruid.metadata.storage.connector.password=insecure_pass\ndruid.metadata.storage.connector.createTables=true\ndruid.metadata.storage.tables.base=druid\ndruid.metadata.storage.tables.segmentTable=druid_segments\ndruid.metadata.storage.tables.ruleTable=druid_rules\ndruid.metadata.storage.tables.configTable=druid_config\ndruid.metadata.storage.tables.tasks=druid_tasks\ndruid.metadata.storage.tables.taskLog=druid_taskLog\ndruid.metadata.storage.tables.taskLock=druid_taskLock\ndruid.metadata.storage.tables.audit=druid_audit\n\n# Deep Storage\ndruid.storage.type=local\ndruid.storage.storageDirectory=/tmp/druid/localStorage\n\n# Caching\ndruid.cache.type=caffeine\ndruid.cache.sizeInBytes=2048\ndruid.cache.expireAfter=300\n\n# Indexing Service Discovery\ndruid.selectors.indexing.serviceName=druid/overlord\n\n# Coordinator Service Discovery\ndruid.selectors.coordinator.serviceName=druid/coordinator\n\n# Logging\n# #\n#\n# # Log all runtime properties on startup. Disable to avoid logging properties on startup:\n\ndruid.startup.logging.logProperties=true\n#\n# Announcing Segments\ndruid.announcer.type=batch\ndruid.announcer.segmentsPerNode=50\ndruid.announcer.maxBytesPerNode=524288\n# Task Logging\ndruid.indexer.logs.type=file\ndruid.indexer.logs.directory=/var/log\n")
    }
  end

  context 'On base system with filtered as request logging type' do
    let(:facts) do
      {
        :memorysize      => '10 GB',
        :ipaddress       => '127.0.0.1',
        :osfamily        => 'Darwin',
        :operatingsystem => 'Darwin',
        :architecture    => 'x86_64',
      }
    end

    let(:params) do
      {
        :version                                      => '0.14.2',
        :package_name                                 => 'org.apache.druid',
        :request_logging_type                         => 'filtered',
        :request_logging_query_time_threshold_ms      => 1000,
        :request_logging_sql_query_time_threshold_ms  => 1000,
        :request_logging_delegate_type                => { 'type' => 'slf4j' },
      }
    end

    it {
      should contain_file('/etc/druid/common.runtime.properties').with_content("# This file is managed by Puppet\n# MODIFICATION WILL BE OVERWRITTEN\n\n# Extensions\ndruid.extensions.remoteRepositories=[\"http://repo1.maven.org/maven2/\", \"https://metamx.artifactoryonline.com/metamx/pub-libs-releases-local\"]\ndruid.extensions.localRepository=~/.m2/repository\ndruid.extensions.coordinates=[]\ndruid.extensions.searchCurrentClassloader=true\ndruid.extensions.hadoopDependenciesDir=/opt/druid/hadoop-dependencies\n\n# Zookeeper\ndruid.zk.paths.base=/druid\ndruid.zk.service.host=localhost\ndruid.zk.service.sessionTimeoutMs=30000\ndruid.curator.compress=true\ndruid.discovery.curator.path=/druid/discovery\n\n# Request Logging\ndruid.request.logging.type=filtered\ndruid.request.logging.queryTimeThresholdMs=1000\ndruid.request.logging.sqlQueryTimeThresholdMs=1000\ndruid.request.logging.delegate={\"type\":\"slf4j\"}\n\n# Enabling Metrics\ndruid.monitoring.emissionPeriod=PT1m\n\n# Emitting Metrics\ndruid.emitter=logging\ndruid.emitter.logging.loggerClass=LoggingEmitter\ndruid.emitter.logging.logLevel=info\n\n# Metadata Storage\ndruid.metadata.storage.type=mysql\ndruid.metadata.storage.connector.connectURI=jdbc:mysql://localhost:3306/druid?characterEncoding=UTF-8\ndruid.metadata.storage.connector.user=druid\ndruid.metadata.storage.connector.password=insecure_pass\ndruid.metadata.storage.connector.createTables=true\ndruid.metadata.storage.tables.base=druid\ndruid.metadata.storage.tables.segmentTable=druid_segments\ndruid.metadata.storage.tables.ruleTable=druid_rules\ndruid.metadata.storage.tables.configTable=druid_config\ndruid.metadata.storage.tables.tasks=druid_tasks\ndruid.metadata.storage.tables.taskLog=druid_taskLog\ndruid.metadata.storage.tables.taskLock=druid_taskLock\ndruid.metadata.storage.tables.audit=druid_audit\n\n# Deep Storage\ndruid.storage.type=local\ndruid.storage.storageDirectory=/tmp/druid/localStorage\n\n# Caching\ndruid.cache.type=local\ndruid.cache.sizeInBytes=0\ndruid.cache.initialSize=500000\ndruid.cache.logEvictionCount=0\n\n# Indexing Service Discovery\ndruid.selectors.indexing.serviceName=druid/overlord\n\n# Coordinator Service Discovery\ndruid.selectors.coordinator.serviceName=druid/coordinator\n\n# Logging\n# #\n#\n# # Log all runtime properties on startup. Disable to avoid logging properties on startup:\n\ndruid.startup.logging.logProperties=true\n#\n# Announcing Segments\ndruid.announcer.type=batch\ndruid.announcer.segmentsPerNode=50\ndruid.announcer.maxBytesPerNode=524288\n# Task Logging\ndruid.indexer.logs.type=file\ndruid.indexer.logs.directory=/var/log\n")
    }
  end

  context 'On base system with graphite as emitter' do
    let(:facts) do
      {
        :memorysize      => '10 GB',
        :ipaddress       => '127.0.0.1',
        :osfamily        => 'Darwin',
        :operatingsystem => 'Darwin',
        :architecture    => 'x86_64',
      }
    end

    let(:params) do
      {
        :emitter                                      => 'graphite',
        :emitter_graphite_hostname                    => 'graphitehost.com',
        :emitter_graphite_port                        => 2004,
        :emitter_graphite_batchSize                   => 200,
        :emitter_graphite_eventConverter              => { 'type' => 'whiteList', 'namespacePrefix' => 'someprefix', 'ignoreHostname' => false, 'ignoreServiceName' => false, 'mapPath' => '/somefile.json' },
        :emitter_graphite_flushPeriod                 => 120000,
      }
    end

    it {
      should contain_file('/etc/druid/common.runtime.properties').with_content("# This file is managed by Puppet\n# MODIFICATION WILL BE OVERWRITTEN\n\n# Extensions\ndruid.extensions.remoteRepositories=[\"http://repo1.maven.org/maven2/\", \"https://metamx.artifactoryonline.com/metamx/pub-libs-releases-local\"]\ndruid.extensions.localRepository=~/.m2/repository\ndruid.extensions.coordinates=[]\ndruid.extensions.searchCurrentClassloader=true\ndruid.extensions.hadoopDependenciesDir=/opt/druid/hadoop-dependencies\n\n# Zookeeper\ndruid.zk.paths.base=/druid\ndruid.zk.service.host=localhost\ndruid.zk.service.sessionTimeoutMs=30000\ndruid.curator.compress=true\ndruid.discovery.curator.path=/druid/discovery\n\n# Request Logging\ndruid.request.logging.type=noop\n\n# Enabling Metrics\ndruid.monitoring.emissionPeriod=PT1m\n\n# Emitting Metrics\ndruid.emitter=graphite\ndruid.emitter.graphite.hostname=graphitehost.com\ndruid.emitter.graphite.port=2004\ndruid.emitter.graphite.batchSize=200\ndruid.emitter.graphite.eventConverter={\"type\":\"whiteList\",\"namespacePrefix\":\"someprefix\",\"ignoreHostname\":false,\"ignoreServiceName\":false,\"mapPath\":\"/somefile.json\"}\ndruid.emitter.graphite.flushPeriod=120000\n\n# Metadata Storage\ndruid.metadata.storage.type=mysql\ndruid.metadata.storage.connector.connectURI=jdbc:mysql://localhost:3306/druid?characterEncoding=UTF-8\ndruid.metadata.storage.connector.user=druid\ndruid.metadata.storage.connector.password=insecure_pass\ndruid.metadata.storage.connector.createTables=true\ndruid.metadata.storage.tables.base=druid\ndruid.metadata.storage.tables.segmentTable=druid_segments\ndruid.metadata.storage.tables.ruleTable=druid_rules\ndruid.metadata.storage.tables.configTable=druid_config\ndruid.metadata.storage.tables.tasks=druid_tasks\ndruid.metadata.storage.tables.taskLog=druid_taskLog\ndruid.metadata.storage.tables.taskLock=druid_taskLock\ndruid.metadata.storage.tables.audit=druid_audit\n\n# Deep Storage\ndruid.storage.type=local\ndruid.storage.storageDirectory=/tmp/druid/localStorage\n\n# Caching\ndruid.cache.type=local\ndruid.cache.sizeInBytes=0\ndruid.cache.initialSize=500000\ndruid.cache.logEvictionCount=0\n\n# Indexing Service Discovery\ndruid.selectors.indexing.serviceName=druid/overlord\n\n# Coordinator Service Discovery\ndruid.selectors.coordinator.serviceName=druid/coordinator\n\n# Logging\n# #\n#\n# # Log all runtime properties on startup. Disable to avoid logging properties on startup:\n\ndruid.startup.logging.logProperties=true\n#\n# Announcing Segments\ndruid.announcer.type=batch\ndruid.announcer.segmentsPerNode=50\ndruid.announcer.maxBytesPerNode=524288\n# Task Logging\ndruid.indexer.logs.type=file\ndruid.indexer.logs.directory=/var/log\n")
    }
  end

end
