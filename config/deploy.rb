# config valid only for current version of Capistrano
lock '3.6.0'

set :application, 'projectr'
set :repo_url, 'git@github.com:activebridge/projectr.git'

set :deploy_to, '/home/deploy/'

set :linked_files, fetch(:linked_files, []).push(
  'config/database.yml',
  'config/secrets.yml'
)

set :linked_dirs, fetch(:linked_dirs, []).push(
  'log',
  'tmp/pids',
  'tmp/cache',
  'tmp/sockets',
  'vendor/bundle',
  'public/system'
)
