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
        :memorysize => '10 GB',
        :ipaddress => '127.0.0.1',
        :osfamily => 'Darwin',
        :operatingsystem => 'Darwin',
        :architecture => 'x86_64',
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
    it { should compile.and_raise_error(/"org.apache.druid" does not match \["io.druid"\]/) }
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
    it { should compile.and_raise_error(/"io.druid" does not match \["org.apache.druid"\]/) }
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
    it {
      should contain_file('/etc/druid/log4j2.xml')\
        .with_content("<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<Configuration status=\"WARN\">\n    <Appenders>\n        <Console name=\"Console\" target=\"SYSTEM_OUT\">\n            <PatternLayout pattern=\"%d{ISO8601} %p [%t] %c - %m%n\"/>\n        </Console>\n    </Appenders>\n    <Loggers>\n        <Root level=\"info\">\n            <AppenderRef ref=\"Console\"/>\n        </Root>\n    </Loggers>\n</Configuration>")
    }
  end

  context 'On base system with local as cache' do
    let(:facts) do
      {
        :memorysize => '10 GB',
        :ipaddress => '127.0.0.1',
        :osfamily => 'Darwin',
        :operatingsystem => 'Darwin',
        :architecture => 'x86_64',
      }
    end

    let(:params) do
      {
        :cache_size_in_bytes                     => 0,
        :cache_initial_size                      => 0,
        :cache_log_eviction_count                => 100,
        :cache_type                              => 'local',
      }
    end

    it {
      should contain_file('/etc/druid/common.runtime.properties').with_content("# This file is managed by Puppet\n# MODIFICATION WILL BE OVERWRITTEN\n\n# Extensions\ndruid.extensions.remoteRepositories=[\"http://repo1.maven.org/maven2/\", \"https://metamx.artifactoryonline.com/metamx/pub-libs-releases-local\"]\ndruid.extensions.localRepository=~/.m2/repository\ndruid.extensions.coordinates=[]\ndruid.extensions.searchCurrentClassloader=true\ndruid.extensions.hadoopDependenciesDir=/opt/druid/hadoop-dependencies\n\n# Zookeeper\ndruid.zk.paths.base=/druid\ndruid.zk.service.host=localhost\ndruid.zk.service.sessionTimeoutMs=30000\ndruid.curator.compress=true\ndruid.discovery.curator.path=/druid/discovery\n\n# Request Logging\ndruid.request.logging.type=noop\n\n# Enabling Metrics\ndruid.monitoring.emissionPeriod=PT1m\n\n# Emitting Metrics\ndruid.emitter=logging\ndruid.emitter.logging.loggerClass=LoggingEmitter\ndruid.emitter.logging.logLevel=info\n\n# Metadata Storage\ndruid.metadata.storage.type=mysql\ndruid.metadata.storage.connector.connectURI=jdbc:mysql://localhost:3306/druid?characterEncoding=UTF-8\ndruid.metadata.storage.connector.user=druid\ndruid.metadata.storage.connector.password=insecure_pass\ndruid.metadata.storage.connector.createTables=true\ndruid.metadata.storage.tables.base=druid\ndruid.metadata.storage.tables.segmentTable=druid_segments\ndruid.metadata.storage.tables.ruleTable=druid_rules\ndruid.metadata.storage.tables.configTable=druid_config\ndruid.metadata.storage.tables.tasks=druid_tasks\ndruid.metadata.storage.tables.taskLog=druid_taskLog\ndruid.metadata.storage.tables.taskLock=druid_taskLock\ndruid.metadata.storage.tables.audit=druid_audit\n\n# Deep Storage\ndruid.storage.type=local\ndruid.storage.storageDirectory=/tmp/druid/localStorage\n\n# Caching\ndruid.cache.type=local\ndruid.cache.sizeInBytes=0\ndruid.cache.initialSize=0\ndruid.cache.logEvictionCount=100\n\n# Indexing Service Discovery\ndruid.selectors.indexing.serviceName=druid/overlord\n\n# Coordinator Service Discovery\ndruid.selectors.coordinator.serviceName=druid/coordinator\n\n# Logging\n# #\n#\n# # Log all runtime properties on startup. Disable to avoid logging properties on startup:\n\ndruid.startup.logging.logProperties=true\n#\n# Announcing Segments\ndruid.announcer.type=batch\ndruid.announcer.segmentsPerNode=50\ndruid.announcer.maxBytesPerNode=524288\n# Task Logging\ndruid.indexer.logs.type=file\ndruid.indexer.logs.directory=/var/log\n")
    }
  end

  context 'On base system with memcached as cache' do
    let(:facts) do
      {
        :memorysize => '10 GB',
        :ipaddress => '127.0.0.1',
        :osfamily => 'Darwin',
        :operatingsystem => 'Darwin',
        :architecture => 'x86_64',
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
        :memorysize => '10 GB',
        :ipaddress => '127.0.0.1',
        :osfamily => 'Darwin',
        :operatingsystem => 'Darwin',
        :architecture => 'x86_64',
      }
    end

    let(:params) do
      {
        :cache_size_in_bytes                  => 0,
        :cache_expire_after                   => 0,
        :cache_type                           => 'caffeine',
      }
    end

    it {
      should contain_file('/etc/druid/common.runtime.properties').with_content("# This file is managed by Puppet\n# MODIFICATION WILL BE OVERWRITTEN\n\n# Extensions\ndruid.extensions.remoteRepositories=[\"http://repo1.maven.org/maven2/\", \"https://metamx.artifactoryonline.com/metamx/pub-libs-releases-local\"]\ndruid.extensions.localRepository=~/.m2/repository\ndruid.extensions.coordinates=[]\ndruid.extensions.searchCurrentClassloader=true\ndruid.extensions.hadoopDependenciesDir=/opt/druid/hadoop-dependencies\n\n# Zookeeper\ndruid.zk.paths.base=/druid\ndruid.zk.service.host=localhost\ndruid.zk.service.sessionTimeoutMs=30000\ndruid.curator.compress=true\ndruid.discovery.curator.path=/druid/discovery\n\n# Request Logging\ndruid.request.logging.type=noop\n\n# Enabling Metrics\ndruid.monitoring.emissionPeriod=PT1m\n\n# Emitting Metrics\ndruid.emitter=logging\ndruid.emitter.logging.loggerClass=LoggingEmitter\ndruid.emitter.logging.logLevel=info\n\n# Metadata Storage\ndruid.metadata.storage.type=mysql\ndruid.metadata.storage.connector.connectURI=jdbc:mysql://localhost:3306/druid?characterEncoding=UTF-8\ndruid.metadata.storage.connector.user=druid\ndruid.metadata.storage.connector.password=insecure_pass\ndruid.metadata.storage.connector.createTables=true\ndruid.metadata.storage.tables.base=druid\ndruid.metadata.storage.tables.segmentTable=druid_segments\ndruid.metadata.storage.tables.ruleTable=druid_rules\ndruid.metadata.storage.tables.configTable=druid_config\ndruid.metadata.storage.tables.tasks=druid_tasks\ndruid.metadata.storage.tables.taskLog=druid_taskLog\ndruid.metadata.storage.tables.taskLock=druid_taskLock\ndruid.metadata.storage.tables.audit=druid_audit\n\n# Deep Storage\ndruid.storage.type=local\ndruid.storage.storageDirectory=/tmp/druid/localStorage\n\n# Caching\ndruid.cache.type=caffeine\ndruid.cache.sizeInBytes=0\ndruid.cache.expireAfter=0\n\n# Indexing Service Discovery\ndruid.selectors.indexing.serviceName=druid/overlord\n\n# Coordinator Service Discovery\ndruid.selectors.coordinator.serviceName=druid/coordinator\n\n# Logging\n# #\n#\n# # Log all runtime properties on startup. Disable to avoid logging properties on startup:\n\ndruid.startup.logging.logProperties=true\n#\n# Announcing Segments\ndruid.announcer.type=batch\ndruid.announcer.segmentsPerNode=50\ndruid.announcer.maxBytesPerNode=524288\n# Task Logging\ndruid.indexer.logs.type=file\ndruid.indexer.logs.directory=/var/log\n")
    }
  end

end
