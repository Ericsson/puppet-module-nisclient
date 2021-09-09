require 'spec_helper'
describe 'nisclient' do
  describe 'variable type and content validations' do
    # tests should be OS independent, so we only test RedHat
    test_on = {
      supported_os: [
        {
          'operatingsystem'        => 'RedHat',
          'operatingsystemrelease' => ['8'],
        },
      ],
    }
    on_supported_os(test_on).sort.each do |os, os_facts|
      context "on #{os}" do
        let(:facts) { os_facts }

        validations = {
          # FIXME: implemented variable validation
          # 'array / string' => {
          #   name:    ['package_name'],
          #   valid:   [['array'], 'string'],
          #   invalid: [{ 'ha' => 'sh' }, 3, 2.42, true, false],
          #   message: 'is not an array nor a string',
          # },
          'boolean' => {
            name:    ['broadcast'],
            valid:   [true, false, 'true', 'false'],
            invalid: ['string', ['array'], { 'ha' => 'sh' }, 3, 2.42, nil],
            message: '(is not a boolean|Unknown type of boolean given)',
          },
          'string' => {
            name:    ['domainname', 'package_ensure', 'server', 'service_name'],
            valid:   ['string'],
            invalid: [['array'], { 'ha' => 'sh' }, 3, 2.42, true, false],
            message: 'is not a string',
          },
          # FIXME: implemented variable validation
          # 'service_ensure' => {
          #   name:    ['service_ensure'],
          #   valid:   ['running', 'stopped'],
          #   invalid: ['string', ['array'], { 'ha' => 'sh' }, 3, 2.42, true, false],
          #   message: ' may be either running or stopped',
          # },
        }
        validations.sort.each do |type, var|
          var[:name].each do |var_name|
            var[:params] = {} if var[:params].nil?
            var[:valid].each do |valid|
              context "when #{var_name} (#{type}) is set to valid #{valid} (as #{valid.class})" do
                let(:params) { [var[:params], { "#{var_name}": valid, }].reduce(:merge) }

                it { is_expected.to compile }
              end
            end

            var[:invalid].each do |invalid|
              context "when #{var_name} (#{type}) is set to invalid #{invalid} (as #{invalid.class})" do
                let(:params) { [var[:params], { "#{var_name}": invalid, }].reduce(:merge) }

                it 'fail' do
                  expect { is_expected.to contain_class(:subject) }.to raise_error(Puppet::Error, %r{#{var[:message]}})
                end
              end
            end
          end
        end
      end
    end
  end
end
