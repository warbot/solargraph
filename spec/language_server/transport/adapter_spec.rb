class AdapterTester
  include Solargraph::LanguageServer::Transport::Adapter
  attr_reader :host

  def write data
    @buffer = data
  end

  def flush
    tmp = @buffer
    @buffer.clear
    tmp
  end
end

describe Solargraph::LanguageServer::Transport::Adapter do
  it "creates a host on open" do
    tester = AdapterTester.new
    tester.opening
    expect(tester.host).to be_a(Solargraph::LanguageServer::Host)
    expect(tester.host).not_to be_stopped
  end

  it "stops a host on close" do
    tester = AdapterTester.new
    tester.opening
    tester.closing
    expect(tester.host).to be_stopped
  end

  it "stops Backport when the host stops" do
    tester = AdapterTester.new
    Backport.run do
      tester.opening
      Backport.prepare_interval 0.1 do
        tester.host.stop
      end
    end
    expect(tester.host).to be_stopped
  end

  it "processes sent data" do
    tester = AdapterTester.new
    tester.opening
    expect {
      tester.sending "Content-length: 2\r\n\r\n{}"
    }.not_to raise_error
  end
end
