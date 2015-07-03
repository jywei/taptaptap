class Admin::PartitionsController < Admin::ApplicationController
  add_breadcrumb :partitions_manager, :admin_partitions_path

  def index
    @partitions_start_date = SystemData.find_by(name: 'partitions_start_date').try(:value)
  end

  def update
    @partitions_start_date = SystemData.find_or_initialize_by(name: 'partitions_start_date')
    @partitions_start_date.value = params[:partitions_start_date]
    @partitions_start_date.save
    redirect_to admin_partitions_path
  end
end
