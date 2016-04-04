#!/usr/bin/env ruby

gem 'patryn'

require 'patryn'

LOGFILE_PATH = File.expand_path '~/Library/Logs/com.bebanjo.tmuxworkflow.out'

class TmuxWorkflow < Patryn::Base
  logger_options device: File.open(LOGFILE_PATH, 'w'), level: :debug

  def shoot
    log_environment
    create_tmux_sessions
    log_results
  end

  private

  def log_environment
    logger.warn "*******************************"
    logger.warn " RUBY VERSION: #{`ruby --version`.delete("\n")}"
    logger.warn " ARGS: #{ARGV}"
    logger.warn "*******************************"
  end

  def create_tmux_sessions
    @results = projects.map do |project|
      system("touch #{project}")
      system("tmuxinator start #{project}")
    end
  end

  def log_results
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

TmuxWorkflow.new.shoot