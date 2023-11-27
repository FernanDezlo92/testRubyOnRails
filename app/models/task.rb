# == Schema Information
#
# Table name: tasks
#
#  id          :bigint           not null, primary key
#  name        :string
#  descripcion :text
#  due_date    :date
#  category_id :bigint           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  owner_id    :bigint           not null
#  code        :string
#
class Task < ApplicationRecord
  belongs_to :category
  belongs_to :owner, class_name: "User"
  has_many :participating_user, class_name: "Participant"
  has_many :participants, through: :participating_user, source: :user
  has_many :notes
  
  validates :name, :descripcion,  presence: true
  validates :name, uniqueness: { case_sensitive: false}
  validate :due_date_validity
  validates :participating_user, presence: true

  after_create :send_email_to_participants

  before_create :create_code

  accepts_nested_attributes_for :participating_user, allow_destroy: true


  def due_date_validity
    return if due_date.blank?
    if due_date < Date.today
      errors.add(:due_date, "can't be in the past")
    end
  end

  def create_code
    self.code = "#{owner_id}#{SecureRandom.hex(4)}"
  end

  def send_email_to_participants
    participants.each do |participant|
      ParticipantMailer.with(user: participant, task: self).new_task_email.deliver_later
    end
  end

end
