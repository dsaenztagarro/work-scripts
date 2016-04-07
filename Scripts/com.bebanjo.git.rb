#!/usr/bin/env ruby

gem 'octokit'
gem 'patryn'

require 'patryn'
require 'octokit'
require 'yaml'
require 'byebug'

LOGFILE_PATH = File.expand_path '~/Library/Logs/com.bebanjo.gitworkflow.out'

class GitWorkflow < Patryn::Base
  logger_options device: File.open(LOGFILE_PATH, 'w'), level: :debug

  def shoot
    log_environment

    repositories
    begin
      debugger
      client.user
    rescue
      debugger
    end

    client.create_authorization \
      :scopes => ["user"],
      :note => "bebanjo.macbookair.script",
      :headers => { "X-GitHub-OTP" => "8ed979a23d90aaeec45b458566df0955394118df" }

    puts client
  end

  private

  def log_environment
    logger.warn "*******************************"
    logger.warn " RUBY VERSION: #{`ruby --version`.delete("\n")}"
    logger.warn " ARGS: #{ARGV}"
    logger.warn "*******************************"
  end

  def client
    @client ||= Octokit::Client.new :access_token => credentials[:access_token]
    # '8ed979a23d90aaeec45b458566df0955394118df'
  end

  def credentials
    @credentials ||= YAML.load_file(File.expand_path '~/.github.yml')
  end

  def repositories
    client.org_repos('Bebanjo', type: 'all', per_page: 100)
  end
end

GitWorkflow.new.shoot
