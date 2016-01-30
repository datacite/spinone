require 'spec_helper'

describe "queue:all[orcid]", vcr: true do
  include_context "rake"

  ENV['FROM_DATE'] = "2013-09-04"
  ENV['UNTIL_DATE'] = "2013-09-05"

  let(:output) { "Queueing for works published from 2013-09-04 to 2013-09-05.\n0 works for agent ORCID have been queued.\n0 contributors for agent ORCID Auto-Update have been queued.\n1 works for agent Related Identifier have been queued.\n" }

  it "should run" do
    expect(capture_stdout { subject.invoke }).to eq(output)
  end
end

describe "queue:all[related_identifier]", vcr: true do
  include_context "rake"

  ENV['FROM_DATE'] = "2013-09-04"
  ENV['UNTIL_DATE'] = "2013-09-05"

  let(:output) { "Queueing for works published from 2013-09-04 to 2013-09-05.\n0 works for agent ORCID have been queued.\n0 contributors for agent ORCID Auto-Update have been queued.\n1 works for agent Related Identifier have been queued.\n" }

  it "should run" do
    expect(capture_stdout { subject.invoke }).to eq(output)
  end
end

describe "queue:all", vcr: true do
  include_context "rake"

  ENV['FROM_DATE'] = "2013-09-04"
  ENV['UNTIL_DATE'] = "2013-09-05"

  let(:output) { "Queueing for works published from 2013-09-04 to 2013-09-05.\n0 works for agent ORCID have been queued.\n0 contributors for agent ORCID Auto-Update have been queued.\n1 works for agent Related Identifier have been queued.\n" }

  it "should run" do
    expect(capture_stdout { subject.invoke }).to eq(output)
  end
end
