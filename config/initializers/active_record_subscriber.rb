unless Rails.env.test?
  ActiveSupport::Notifications.subscribe "sql.active_record" do |name, start, finish, id, payload|
    if payload[:sql].match "INSERT"
      duration = finish - start
      # Statistics::Tracker.add(Statistics::POSTING_INSERT, duration)
    end
  end
end
