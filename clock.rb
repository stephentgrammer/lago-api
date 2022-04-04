# frozen_string_literal: true

require 'clockwork'
require './config/boot'
require './config/environment'

module Clockwork
  handler do |job, time|
    puts "Running #{job} at #{time}"
  end

  error_handler do |error|
    # TODO: plug error handler here
  end

  every(1.day, 'schedule:bill_customers', at: '01:00') do
    Clock::SubscriptionsBillerJob.perform_later
  end
end