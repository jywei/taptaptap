class TransferedDataWorker
  include Sidekiq::Worker

  def perform(postings, remote_ip, auth_token)
    postings.group_by { |posting| posting['source'] }.each do |source, postings_group|
      postings_by_category = {}

      postings_group.each do |posting|
        category = posting['category']

        data_size = posting.to_json.bytesize

        if postings_by_category.has_key? category
          postings_by_category[category][:amount] += 1
          postings_by_category[category][:data_size] += data_size
        else
          postings_by_category[category] = {
              amount: 1,
              data_size: data_size
          }
        end
      end

      postings_by_category.each do |category, group|
        StatisticByTransferedData.track({ direction: :out, ip: remote_ip, auth_token: auth_token, source: source, category: category, amount: group[:amount], data_size: group[:data_size] })
      end
    end
  end
end