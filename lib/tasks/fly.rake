# frozen_string_literal: true

namespace :fly do
  # task build: "assets:precompile"
  # task release: "db:migrate"

  task console: :environment do
    sh 'fly ssh console -C "app/bin/rails console" -a lewagon-aoc'
  end

  task dbconsole: :environment do
    sh 'fly ssh console -C "app/bin/rails dbconsole" -a lewagon-aoc'
  end

  task deploy: :environment do
    sh "fly deploy -a lewagon-aoc"
  end

  task printenv: :environment do
    sh 'fly ssh console -C "printenv" -a lewagon-aoc'
  end

  task ssh: :environment do
    sh "fly ssh console -a lewagon-aoc"
  end

  namespace :pr do
    task console: :environment do
      sh 'fly ssh console -C "app/bin/rails console" -a lewagon-aoc-pr'
    end

    task dbconsole: :environment do
      sh 'fly ssh console -C "app/bin/rails dbconsole" -a lewagon-aoc-pr'
    end

    task deploy: :environment do
      sh "fly deploy -a lewagon-aoc-pr"
    end

    task printenv: :environment do
      sh 'fly ssh console -C "printenv" -a lewagon-aoc-pr'
    end

    task ssh: :environment do
      sh "fly ssh console -a lewagon-aoc-pr"
    end
  end
end
