require 'foodcritic'
require 'rake/clean'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'kitchen/rake_tasks'

CLEAN.include %w(.kitchen/ coverage/)
CLOBBER.include %w(Berksfile.lock Gemfile.lock)

namespace :style do
  desc 'Run Rubocop style checks'
  RuboCop::RakeTask.new(:ruby)

  desc 'Run Foodcritic style checks'
  FoodCritic::Rake::LintTask.new(:chef) do |t|
    t.options = {
      cookbook_paths: '.',
      fail_tags: ['any']
    }
  end
end

desc 'Run all style checks'
task style: ['style:chef', 'style:ruby']

# Haven't configured KitchenCI yet.
# desc 'Run Kitchen CI tests'
# Kitchen::RakeTasks.new
