require 'spec_helper'

describe 'druid::router', :type => 'class' do
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
      should contain_class('druid::router')
      should contain_druid__service('router')
      should contain_file('/etc/druid/router')
      should contain_file('/etc/druid/router/common.runtime.properties')
      should contain_file('/etc/druid/router/runtime.properties')
      should contain_file('/etc/systemd/system/druid-router.service')
      should contain_exec('Reload systemd daemon for new router service config')
      should contain_service('druid-router')
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
          '-Xms1g',
          '-Xmx2g',
          '-Duser.timezone=UTC',
          '-Dfile.encoding=URF-8',
          '-Djava.util.logging.manager=org.apache.logging.log4j.jul.LogManager',
          '-Djava.io.tmpdir=/mnt/tmp',
        ]
      }
    end

      it {
        should contain_file('/etc/systemd/system/druid-router.service')\
          .with_content("[Unit]\nDescription=Druid Router Node\n\n[Service]\nType=simple\nStandardOutput=syslog\nStandardError=syslog\nSyslogFacility=daemon\nWorkingDirectory=/opt/druid/\nExecStart=/usr/bin/java -server -Xms1g -Xmx2g -Duser.timezone=UTC -Dfile.encoding=URF-8 -Djava.util.logging.manager=org.apache.logging.log4j.jul.LogManager -Djava.io.tmpdir=/mnt/tmp -classpath .:/etc/druid/router/:/etc/druid:/opt/druid/lib/* io.druid.cli.Main server router\nSuccessExitStatus=130 143\nRestart=on-failure\n\n[Install]\nWantedBy=multi-user.target\n")
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
        :host                                 => '192.168.0.105',
        :service                              => 'druid-test/router',
      }
    end

      it {
        should contain_file('/etc/druid/router/runtime.properties').with_content("# This file is managed by Puppet\n# MODIFICATION WILL BE OVERWRITTEN\n\n# Node Config\ndruid.host=192.168.0.105\ndruid.plaintextPort=8091\ndruid.service=druid-test/router\n\n# Router Configs\n\ndruid.router.defaultBrokerServiceName=druid/broker\ndruid.router.coordinatorServiceName=druid/coordinator\ndruid.router.defaultRule=_default\ndruid.router.pollPeriod=PT1M\ndruid.router.strategies=[{\"type\":\"timeBoundary\"},{\"type\":\"priority\"}]\ndruid.router.avatica.balancer.type=rendezvousHash\ndruid.router.managementProxy.enabled=false\ndruid.router.tierToBrokerMap={\"_default_tier\":\"\"}\ndruid.router.http.numConnections=5\ndruid.router.http.readTimeout=PT15M\ndruid.router.http.numMaxThreads=10\ndruid.server.http.numThreads=10\n")
      }
  end
end
