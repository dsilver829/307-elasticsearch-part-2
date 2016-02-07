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
          json.query_string do
            json.query params[:query]
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
      if params[:query].blank?
        json.sort do
          json.published_at do
            json.order "desc"
          end
        end
      end
    end
    __elasticsearch__.search(query)
  end

  def as_indexed_json(options = {})
    as_json methods: [:author_name, :comment_count]
  end

  def author_name
    author.name
  end

  def comment_count
    comments.size
  end
end