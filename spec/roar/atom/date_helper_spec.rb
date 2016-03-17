require 'spec_helper'

describe Roar::Atom::DateHelper do
  subject                          { described_class }
  let(:date_instance)              { Date.today }
  let(:datetime_instance)          { DateTime.now }
  let(:time_instance)              { Time.now }
  let(:rfc3339_date)               { '2016-02-09T00:05:24Z' }
  let(:rfc3339_date_with_timezone) { '2016-02-09T00:05:24+00:00' }

  describe '.is_rfc3339_format?' do
    context 'with a RFC 3339 date-time (String) with timezone' do
      it do
        expect(subject.is_rfc3339_format?(rfc3339_date_with_timezone))
          .to be_truthy
      end
    end

    context 'with a RFC 3339 date-time (String) without timezone' do
      it do
        expect(subject.is_rfc3339_format?(rfc3339_date))
          .to be_truthy
      end
    end

    context 'with a regular String instance' do
      it { expect(subject.is_rfc3339_format?('DateTime.now')).to be_falsey }
    end

    context 'with an instance of class different from String' do
      it { expect(subject.is_rfc3339_format?(date_instance)).to be_falsey }
    end
  end

  describe '.format_date_element' do
    context 'with a value already RFC 3339 formatted' do
      it do
        expect(subject.format_date_element(rfc3339_date_with_timezone))
          .to eq(rfc3339_date_with_timezone)
      end
    end

    context 'with an unformatted value' do
      it do
        expect(subject.format_date_element(date_instance))
          .to eq(date_instance.rfc3339)
      end
    end
  end
end
