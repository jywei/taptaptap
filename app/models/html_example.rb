class HtmlExample < ActiveRecord::Base
	include AASM
	validates :name,:html, presence: true

	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :committer, presence: true, format: { with: VALID_EMAIL_REGEX }
  
  VALID_URL_REGEX = /(http|https):\/\/|[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,6}(:[0-9]{1,5})?(\/.*)?/ix
  validates :url, presence: true, format: { with: VALID_URL_REGEX }

  after_create :send_email_administrator

  aasm :column => :status do
    state :new, :initial => true
    state :accepted
    state :rejected
    state :ready

    event :accept do
      transitions :from => :new, :to => :accepted
    end

    event :reject, after: :send_rejected_email do
      transitions :from => :new, :to => :rejected
    end

    event :ready, after: :send_ready_email do
      transitions :from => :accepted, :to => :ready
    end
  end

private
  def send_email_administrator
    NotificationMailer.notice("Added new postings html example in table html_eamples!").deliver!
  end

  def send_rejected_email
    NotificationMailer.notice("Sorry, but #{name} page you have provided can't be parsed!", "Page can't be parsed", committer).deliver!
  end

  def send_ready_email
    NotificationMailer.notice("#{name} page you have provided is ready!", 'Page is ready', committer).deliver!
  end
end
