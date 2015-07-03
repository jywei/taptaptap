class Admin::AnnotationsController < Admin::ApplicationController
  
  def index
    @annotations = Annotation.all
    add_breadcrumb "index", admin_annotations_path
  end

  def new
    @annotation = Annotation.new
    add_breadcrumb "New"
  end

  def edit
    @annotation = Annotation.find params[:id]
    add_breadcrumb "Edit"
  end

  def create
    @annotation = Annotation.new(annotation_params)

    if @annotation.save
      redirect_to admin_annotations_path
    else
      render :new
    end
  end

  def update
    @annotation = Annotation.find params[:id]

    if @annotation.update_attributes annotation_params
      redirect_to admin_annotations_path
    else
      render :edit
    end
  end

  def csv_export
    annotations = Annotation.all

    data = CSV.generate do |csv|
      csv << [ 'name', 'sources', 'categories', 'control type', 'is public' ]

      annotations.each do |annotation|
        csv << [
          annotation.name,
          annotation.sources.join('|'),
          annotation.categories.join('|'),
          annotation.control_type,
          annotation.public?
        ]
      end
    end

    filename = "annotations.#{ DateTime.now.strftime('%H-%M.%d-%m-%Y') }.csv"

    send_data data, :type => 'text/csv; charset=utf-8; header=present', :filename => filename
  end

  private

  def annotation_params
    params.require(:annotation).permit!

    params[:annotation][:sources].reject! { |source| source.blank? }

    params[:annotation]
  end
end
