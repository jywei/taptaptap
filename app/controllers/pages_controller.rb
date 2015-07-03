class PagesController < ApplicationController
  def health
    errors = []

    anchor = RecentAnchor.first.anchor
    volume = (anchor.to_i-1) / 1_000_000
    Posting.table_name = "postings#{volume}"
    Posting.primary_key = 'id'
    last = Posting.last

    posting = Posting.find anchor

    t = Time.now
    Time.zone = 'UTC'
    t = Time.zone.parse t.to_s.split(' ')[0..-2].join(' ')

    if t - posting.created_at > 30.minutes
      errors << "Last posting anchor more than 30 minutes ago"
      statuses = Posting.select('geolocation_status').where("id > #{anchor}").collect(&:geolocation_status)
      counts = Hash[statuses.uniq.map { |status| [ status, statuses.count(status) ] }]
      errors << "statuses: #{counts}"
    end

    posting = Posting.last

    errors << "Last posting more than 30 minutes ago" if t - posting.created_at > 30.minutes

    str = `mysql -uroot -ptaptaptap taps_production -A -e 'show processlist;' | grep replica`
    errors << "replicator died" unless str.match /replica/

    errors << "Difference between last_volume and current_volume <=5" if RedisHelper.get_redis.get("little_volume") == 1

    if errors.empty?
      render status: 200, text: 'ok'
    else
      render status: 500, text: errors.join('\n')
    end
  end
end
