require 'spec_helper'

describe 'druid::coordinator', :type => 'class' do
  context 'On system with 10 GB RAM and defaults for all parameters' do
    let(:facts) do
      {
        :memorysize => '10 GB',
        :ipaddress => '127.0.0.1',
        :osfamily => 'Darwin',
        :operatingsystem => 'Darwin',
        :architecture => 'x86_64',
      }
    end

    it {
      should compile.with_all_deps
      should contain_class('druid::coordinator')
      should contain_druid__service('coordinator')
      should contain_file('/etc/druid/coordinator')
      should contain_file('/etc/druid/coordinator/common.runtime.properties')
      should contain_file('/etc/druid/coordinator/runtime.properties')
      should contain_file('/etc/systemd/system/druid-coordinator.service')
      should contain_exec('Reload systemd daemon for new coordinator service config')
      should contain_service('druid-coordinator')
    }
  end

  context 'On base system with custom JVM parameters ' do
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
        :jvm_opts => [
          '-server',
          '-Xmx25g',
          '-Xms25g',
          '-XX:NewSize=6g',
          '-XX:MaxNewSize=6g',
          '-XX:MaxDirectMemorySize=64g',
          '-Duser.timezone=PDT',
          '-Dfile.encoding=latin-1',
          '-Djava.util.logging.manager=custom.LogManager',
          '-Djava.io.tmpdir=/mnt/tmp',
        ]
      }
    end

      it {
        should contain_file('/etc/systemd/system/druid-coordinator.service')\
          .with_content("[Unit]\nDescription=Druid Coordinator Node\n\n[Service]\nType=simple\nStandardOutput=syslog\nStandardError=syslog\nSyslogFacility=daemon\nWorkingDirectory=/opt/druid/\nExecStart=/usr/bin/java -server -Xmx25g -Xms25g -XX:NewSize=6g -XX:MaxNewSize=6g -XX:MaxDirectMemorySize=64g -Duser.timezone=PDT -Dfile.encoding=latin-1 -Djava.util.logging.manager=custom.LogManager -Djava.io.tmpdir=/mnt/tmp -classpath .:/etc/druid/coordinator/:/etc/druid:/opt/druid/lib/* io.druid.cli.Main server coordinator\nSuccessExitStatus=130 143\nRestart=on-failure\n\n[Install]\nWantedBy=multi-user.target\n")
      }
  end

  context 'On system with 10 GB RAM and custom druid configs' do
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
        :host                          => '127.0.0.1',
        :port                          => 8091,
        :service                       => 'druid-test/coordinator',
        :conversion_on                 => true,
        :load_timeout                  => 'PT17M',
        :manager_config_poll_duration  => 'PT2M',
        :manager_rules_alert_threshold => 'PT12M',
        :manager_rules_default_tier    => '_test_default',
        :manager_rules_poll_duration   => 'PT3M',
        :manager_segment_poll_duration => 'PT5M',
        :merge_on                      => true,
        :period                        => 'PT62S',
        :period_indexing_period        => 'PT1803S',
        :start_delay                   => 'PT302S',
      }
    end

      it {
        should contain_file('/etc/druid/coordinator/runtime.properties').with_content("# This file is managed by Puppet\n# MODIFICATION WILL BE OVERWRITTEN\n\n# Node Config\ndruid.host=127.0.0.1\ndruid.port=8091\ndruid.service=druid-test/coordinator\n\n# Coordinator Operation\ndruid.coordinator.period=PT62S\ndruid.coordinator.period.indexingPeriod=PT1803S\ndruid.coordinator.startDelay=PT302S\ndruid.coordinator.merge.on=true\ndruid.coordinator.conversion.on=true\ndruid.coordinator.load.timeout=PT17M\n\n# Metadata Retrieval\ndruid.manager.config.pollDuration=PT2M\ndruid.manager.segment.pollDuration=PT5M\ndruid.manager.rules.pollDuration=PT3M\ndruid.manager.rules.defaultTier=_test_default\ndruid.manager.rules.alertThreshold=PT12M\n")
      }
  end
end
