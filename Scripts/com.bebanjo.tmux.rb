#!/usr/bin/env ruby
#
require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem 'patryn', path: '~/Projects/patryn'
  gem 'tmuxinator'
end

LOGFILE_PATH = File.expand_path '~/Library/Logs/com.bebanjo.tmuxworkflow.out'

class TmuxWorkflow < Patryn::Base
  logger_options device: File.open(LOGFILE_PATH, 'w'), level: :info

  def shoot
    create_tmux_sessions
    create_log
  end

  private

  def create_tmux_sessions
    @results = projects.map { |project| system("tmuxinator start #{project}") }
  end

  def create_log
    projects.zip(@results).each do |project, result|
      if result
        logger.info "Created a new session with name #{project}"
      else
        logger.error "Unable to create a new session with name #{project}"
      end
    end
  end

  def projects
    @projects ||= ARGV.map { |value| "bebanjo_#{value}" }
  end
end

TmuxWorkflow.new.run