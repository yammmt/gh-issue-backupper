# frozen_string_literal: true

require 'json'
require 'octokit'
require 'pry'

# constants
JSON_FILE_PATH           = './json/'
REPOSITORY_LIST_FILENAME = 'repository_list.txt'
TOKEN_FILENAME           = 'my_token.txt'

STDOUT.sync = true

# read OAuth token
# TODO: error processing for File.open
oauth_token = ''
File.open(TOKEN_FILENAME, 'r') do |f|
  oauth_token = f.read.chomp
end
if oauth_token.empty?
  puts "write your OAuth token to #{TOKEN_FILENAME}"
  exit
end

# read target repository list
# TODO: error processing for File.open
repo_list = []
File.open(REPOSITORY_LIST_FILENAME, 'r') do |f|
  f.each_line do |l|
    repo_list.push(l.chomp)
  end
end
if repo_list.empty?
  puts "write target repository name to #{REPOSITORY_LIST_FILENAME}"
  exit
end

# use user info with OAuth token
client = Octokit::Client.new(access_token: oauth_token)
client.auto_paginate = true

# get all issues (includes pull requests) per repository
repo_list.each do |repo_name|
  # create directory per repositories
  directory_name = repo_name[%r{\/(\w|-|_)*}].delete('/')
  directory_path = "#{JSON_FILE_PATH}#{directory_name}/"
  puts "make directory #{directory_path}..."
  Dir.mkdir(directory_path) unless FileTest.exist?(directory_path)

  # get issues
  issues = client.issues(repo_name, state: 'all')
  puts "#{issues.size} issue & pull requests found"
  issue_digit = issues.size.to_s.length
  issues.each do |i|
    issue_id_formatted = format("%0#{issue_digit}d", i.number)
    json_basename = "#{issue_id_formatted}_#{i.title}".gsub(%r{\/| }, '-')
    json_basepath = "#{directory_path}#{json_basename}"
    filepath = "#{json_basepath}.json"
    puts "saving #{filepath}..."
    File.open(filepath, 'w') do |f|
      f.write(i.to_attrs.to_json)
    end

    # get comments
    next unless i.comments.positive?
    comments = client.issue_comments(repo_name, i.number)
    comments.each_with_index do |c, num|
      filepath = "#{json_basepath}_comment#{num + 1}.json"
      puts "    saving #{filepath}..."
      File.open(filepath, 'w') do |f|
        f.write(c.to_attrs.to_json)
      end
    end
  end
  puts ''
end

puts 'complete!'
