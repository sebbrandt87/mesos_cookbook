require_relative '../../../kitchen/data/spec_helper'

# mesos slave service
describe file('/etc/default/mesos') do
  it { should be_file }
end

describe file('/etc/default/mesos-slave') do
  it { should be_file }
end

describe file('/etc/mesos/zk') do
  it { should be_file }
end

describe 'mesos slave service' do
  it 'should be running' do
    case RSpec.configuration.os
    when 'Debian'
      expect(service 'mesos-slave').to be_running
    end
  end
end

describe port(5051) do
  it { should be_listening }
end

describe command('curl -sD - http://localhost:5051/health -o /dev/null') do
  its(:stdout) { should match(/200 OK/) }
end

describe file('/var/log/mesos/mesos-slave.INFO') do
  its(:content) { should match(/INFO level logging started/) }
  its(:content) { should match(/Slave started on/) }
  its(:content) { should match(/connected to ZooKeeper/) }
  its(:content) { should match(/New master detected/) }
end

describe command('curl -sD - http://localhost:5051/state.json') do
  its(:stdout) { should match(/"logging_level":"INFO"/) }
  its(:stdout) { should match(/"gc_delay":"1days"/) }
  its(:stdout) { should match(/"checkpoint":"true"/) }
  its(:stdout) { should match(/"switch_user":"true"/) }
end
