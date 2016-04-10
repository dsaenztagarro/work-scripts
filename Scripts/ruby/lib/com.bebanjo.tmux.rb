#!/usr/bin/env ruby

gem 'patryn'

require 'patryn'
require 'ostruct'
require 'byebug'

LOGFILE_PATH = File.expand_path '~/Library/Logs/com.bebanjo.tmuxworkflow.out'

# Base abstract command
class Command
  def initialize(session)
    @session = session
  end

  def run
    Thread.new do
      system shell_script
    end
  end

  def to_s
    shell_script
  end
end

# Represents a 'tmuxinator start [PROJECT]' command
class NewSessionCommand < Command
  def shell_script
    "tmuxinator start #{@session}"
  end
end

# Represents a 'tmux kill-session [-t target-session]' command
class KillSessionCommand < Command
  def shell_script
    "tmux kill-session -t #{@session}"
  end
end

# Batch runner for tmuxinator
class TmuxWorkflow < Patryn::Base
  logger_options device: File.open(LOGFILE_PATH, 'w'), level: :info

  attr_reader :commands

  def shoot
    generate_commands
    run_commands
    log_execution
  end

  private

  def generate_commands
    @commands = projects.map do |project|
      action = (self.class.current_sessions.include? project)? 'Kill' : 'New'
      Object.const_get("#{action}SessionCommand").new(project)
    end
  end

  def run_commands
    @threads = commands.map { |command| command.run }.each(&:join)
  end

  def log_execution
    @threads.zip(commands).each do |thread, command|
      if thread.value
        logger.info command
      else
        logger.error "FAIL: #{command}"
      end
    end
  end

  def projects
    options.projects.map { |project| "#{@options.prefix}#{project}" }
  end

  def opt_parser
    OptionParser.new do |parser|
      parser.on('-pPREFIX', '--prefix=PREFIX', 'Prefix of sessions name') do |prefix|
        options.prefix = prefix
      end
      parser.on('-sPROJECTS', '--projects=PROJECTS', 'Tmuxinator project names') do |projects|
        options.projects = projects.split(' ')
      end
    end
  end

  def self.current_sessions
    `tmux list-sessions -F '\#{session_name}'`.split("\n")
  end

  def self.default_options
    OpenStruct.new.tap do |options|
      options.prefix = ''
      options.projects = []
    end
  end
end

TmuxWorkflow.new().run
