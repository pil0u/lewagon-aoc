# frozen_string_literal: true

namespace :fly do
  task console: :environment do
    sh 'fly ssh console -C "app/bin/rails console"'
  end

  task dbconsole: :environment do
    sh 'fly ssh console -C "app/bin/rails dbconsole"'
  end

  task printenv: :environment do
    sh 'fly ssh console -C "printenv"'
  end

  task ssh: :environment do
    sh "fly ssh console"
  end
end
