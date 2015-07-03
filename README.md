# 3taps Posting API

## Overview

3taps built a data exchange that aggregated user-generated data housed on various websites and then made that data available through this API to developers, including [PadMapper](http://www.padmapper.com/) and [Lovely](https://livelovely.com/).

## Requirements

This project requires `Redis` and `MySQL` to be installed. If you are running Linux, you'd need the `libmysql-client-dev` package in order to proceed with `mysql2` gem installation.

## Installing

1. Clone a project
2. Create directories missing: `mkdir log/custom`
3. Change directories' write permissions: `chmod -R a+rw log tmp public`
4. Install all the gems: `bundle install`
5. Create databases and set its credentials in `config/database.yml`
6. Set Redis config in `lib/redis_helper.rb`
7. Initialize database schemas:
  - `rake db:multi:migrate DATABASE=taps`
  - `rake db:multi:migrate DATABASE=taps_payments`
  - `rake db:multi:migrate DATABASE=taps_stat`
8. Create postings converters: `rake db:seed`
9. Fill the database with locations: `rake locations:init_all`

## Running

1. Run an API itself with a Ruby application server of your choice *(you may use developer mode Puma)*: `rails s`
2. Run delayed job supervisor: `sidekiq`
