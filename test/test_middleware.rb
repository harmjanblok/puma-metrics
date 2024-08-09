# frozen_string_literal: true

require 'minitest/autorun'
require 'puma/metrics/middleware'

class TestMiddleware < Minitest::Test
  def setup
    @app = ->(env) { [200, {}, ['OK']] }
    @logger = Minitest::Mock.new
    @puma_stats_parser = Minitest::Mock.new
    @middleware = Puma::Metrics::Middleware.new(@app, logger: @logger, parser: @puma_stats_parser)
  end

  def test_call_with_http_success
    mock_http_response = Minitest::Mock.new
    mock_http_response.expect(:is_a?, true, [Net::HTTPSuccess])
    mock_http_response.expect(:body, '{}')
    @puma_stats_parser.expect(:parse, nil, [{}])

    Net::HTTP.stub(:get_response, mock_http_response) do
      @middleware.call({})
    end

    mock_http_response.verify
    @puma_stats_parser.verify
  end

  def test_call_without_http_success
    mock_http_response = Minitest::Mock.new
    mock_http_response.expect(:is_a?, false, [Net::HTTPSuccess])
    mock_http_response.expect(:message, 'error')
    @logger.expect(:error, nil, ['Error fetching Puma stats: error'])
    @puma_stats_parser.expect(:parse, nil, [{}])

    Net::HTTP.stub(:get_response, mock_http_response) do
      @middleware.call({})
    end

    mock_http_response.verify
    @logger.verify
    @puma_stats_parser.verify
  end

  def test_call_with_exception
    @logger.expect(:error, nil, ['Error fetching Puma stats: error'])
    @puma_stats_parser.expect(:parse, nil, [{}])

    @middleware.stub(:fetch_stats, -> { raise 'error' }) do
      @middleware.call({})
    end

    @logger.verify
    @puma_stats_parser.verify
  end
end
