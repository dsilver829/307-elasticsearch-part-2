require 'elasticsearch/model'
require 'jbuilder'

class Article < ActiveRecord::Base
  belongs_to :author
  has_many :comments

  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  def self.search(params)
    query = Jbuilder.encode do |json|
      if params[:query].present?
        json.query do
          json.multi_match do
            json.query params[:query]
            json.fields do
              json.array! ["name", "content"]
            end
          end
        end
      end
      json.filter do
        json.range do
          json.published_at do
            json.lte Date.today.to_s
          end
        end
      end
    end
    __elasticsearch__.search(query).records
  end
end