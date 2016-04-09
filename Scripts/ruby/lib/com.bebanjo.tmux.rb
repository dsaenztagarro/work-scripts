#!/usr/bin/env ruby

gem 'patryn'

require 'patryn'
require 'byebug'

LOGFILE_PATH = File.expand_path '~/Library/Logs/com.bebanjo.tmuxworkflow.out'

class Command
  def initialize(session)
    @session = session
  end

  def run
    system shell_script
  end

  def to_s
    shell_script
  end
end

class NewSessionCommand < Command
  def shell_script
    "tmuxinator start #{@session}"
  end
end

class KillSessionCommand < Command
  def shell_script
    "tmux kill-session -t #{@session}"
  end
end

class TmuxWorkflow < Patryn::Base
  logger_options device: File.open(LOGFILE_PATH, 'w'), level: :debug

  def opt_parser_options
    lambda do |parser|
      # parser.on
    end
  end

  def shoot
    logger.debug { "Current tmux sessions: #{current_sessions.join "\n"}" }
    commands.each do |command|
      if command.run
        logger.info command
      else
        logger.error "FAIL: #{command}"
      end
    end
  end

  private

  def commands
    projects.map do |project|
      action = (current_sessions.include? project)? 'Kill' : 'New'
      Object.const_get("#{action}SessionCommand").new(project)
    end
  end

  def current_sessions
    @current_sessions =
      `tmux list-sessions -F '\#{session_name}'`
      .split("\n")
  end

  def projects
    @projects ||= ARGV
  end
end

TmuxWorkflow.new.run
