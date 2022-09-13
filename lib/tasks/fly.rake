# frozen_string_literal: true

namespace :fly do
  # BUILD step:
  #  - changes to the filesystem made here DO get deployed
  #  - NO access to secrets, volumes, databases
  #  - Failures here prevent deployment
  task build: "assets:precompile"

  # RELEASE step:
  #  - changes to the filesystem made here are DISCARDED
  #  - full access to secrets, databases
  #  - failures here prevent deployment
  task release: "db:migrate"

  # SERVER step:
  #  - changes to the filesystem made here are deployed
  #  - full access to secrets, databases
  #  - failures here result in VM being stated, shutdown, and rolled back
  #    to last successful deploy (if any).
  task server: :environment do
    sh "bin/rails server"
  end

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

  task seed: :environment do
    sh 'fly ssh console -C "app/bin/rails db:seed" -a lewagon-aoc'
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

    task seed: :environment do
      sh 'fly ssh console -C "app/bin/rails db:seed" -a lewagon-aoc-pr'
    end

    task ssh: :environment do
      sh "fly ssh console -a lewagon-aoc-pr"
    end
  end
end
