# frozen_string_literal: true

RSpec.describe Janus::DbSwitcher do
  describe 'when JANUS_ENABLED is not set' do
    around do |example|
      original = ENV.fetch('JANUS_ENABLED', nil)
      ENV.delete('JANUS_ENABLED')
      example.run
      ENV['JANUS_ENABLED'] = original
    end

    it 'switch returns nil' do
      expect(described_class.switch).to be_nil
    end

    it 'switch with arg returns nil' do
      expect(described_class.switch('any')).to be_nil
    end

    it 'current returns database name' do
      # rubocop:disable RSpec/VerifiedDoubles
      connection_double = double('Connection')
      # rubocop:enable RSpec/VerifiedDoubles
      allow(ActiveRecord::Base).to receive(:connection).and_return(connection_double)
      allow(connection_double).to receive(:current_database).and_return('db1')
      expect(described_class.current).to eq('db1')
    end

    it 'db_from_redis returns database name' do
      stub_redis_with_namespace_mock
      mock = MockRedis.new
      mock.set('current_db_name', 'db1')
      allow(MockRedis).to receive(:new).and_return(mock)
      expect(described_class.db_from_redis).to eq('db1')
    end
  end

  describe '.switch' do
    context 'when database_name blank' do
      it 'raises SwitchError if database_name is empty string' do
        expect do
          described_class.switch('')
        end.to raise_error(Janus::SwitchError, /Empty database_name/)
      end
    end

    context 'when current equals database_name' do
      it 'does not disconnect' do
        allow(described_class).to receive(:current).and_return('db1')
        # rubocop:disable RSpec/VerifiedDoubles
        pool_spy = spy('ConnectionPool')
        # rubocop:enable RSpec/VerifiedDoubles
        allow(ActiveRecord::Base).to receive(:connection_pool).and_return(pool_spy)
        described_class.switch('db1')
        expect(pool_spy).not_to have_received(:disconnect!)
      end

      it 'returns true' do
        allow(described_class).to receive(:current).and_return('db1')
        expect(described_class.switch('db1')).to be true
      end
    end

    context 'when establish_connection fails' do
      it 'raises SwitchError with original message' do
        allow(described_class).to receive(:current).and_return('other')
        allow(ActiveRecord::Base.connection_pool)
          .to receive(:disconnect!)
          .and_raise(StandardError.new('fail'))
        expect { described_class.switch('db1') }.to raise_error(Janus::SwitchError, /fail/)
      end
    end

    context 'when switch succeeds' do
      let(:sequence) { [] }

      before do
        allow(described_class).to receive(:current) {
          sequence.empty? ? ((sequence << :other) && 'old_db') : 'new_db'
        }
        allow(ActiveRecord::Base.connection_pool).to receive(:disconnect!) {
          sequence << :disconnected
        }
        allow(ActiveRecord::Base).to receive(:establish_connection) { sequence << :established }
      end

      it 'disconnects when switching' do
        described_class.switch('new_db')
        expect(sequence).to include(:disconnected)
      end

      it 'establishes new connection when switching' do
        described_class.switch('new_db')
        expect(sequence).to include(:established)
      end

      it 'returns true' do
        allow(described_class).to receive(:current).and_return('new_db')
        allow(ActiveRecord::Base.connection_pool).to receive(:disconnect!)
        allow(ActiveRecord::Base).to receive(:establish_connection)
        expect(described_class.switch('new_db')).to be true
      end
    end
  end
end
