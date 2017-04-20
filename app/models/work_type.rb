class WorkType < Base
  attr_reader :id, :title, :container, :updated_at

  def initialize(attributes, options={})
    @id = attributes.fetch("id").underscore.dasherize
    @title = attributes.fetch("title", nil)
    @container = attributes.fetch("container", nil)
    @updated_at = attributes.fetch("timestamp", nil)
  end

  def self.get_data(options = {})
    [
        {
            'id' => 'article',
            'title' => 'Article',
            'timestamp' => '2016-03-21T15:05:02Z'
        },
        {
            'id' => 'bill',
            'title' => 'Bill',
            'timestamp' => '2016-03-21T15:05:02Z'
        },
        {
            'id' => 'post-weblog',
            'title' => 'Blog Post',
            'container' => 'Blog',
            'timestamp' => '2016-03-21T15:05:03Z'
        },
        {
            'id' => 'book',
            'title' => 'Book',
            'timestamp' => '2016-03-21T15:05:02Z'
        },
        {
            'id' => 'review-book',
            'title' => 'Book Review',
            'timestamp' => '2016-03-21T15:05:03Z'
        },
        {
            'id' => 'broadcase',
            'title' => 'Broadcast',
            'timestamp' => '2016-03-21T15:05:03Z'
        },
        {
            'id' => 'chapter',
            'title' => 'Chapter',
            'container' => 'Book',
            'timestamp' => '2016-03-21T15:05:03Z'
        },
        {
            'id' => 'computer_program',
            'title' => 'Computer Program',
            'timestamp' => '2016-03-21T15:05:03Z'
        },
        {
            'id' => 'paper-conference',
            'title' => 'Conference Paper',
            'container' => 'Conference',
            'timestamp' => '2016-03-21T15:05:03Z'
        },
        {
            'id' => 'dataset',
            'title' => 'Dataset',
            'timestamp' => '2016-03-21T15:05:03Z'
        },
        {
            'id' => 'entry-dictionary',
            'title' => 'Dictionary Entry',
            'container' => 'Dictionary',
            'timestamp' => '2016-03-21T15:05:03Z'
        },
        {
            'id' => 'entry-encyclopedia',
            'title' => 'Encyclopedia Entry',
            'container' => 'Encyclopedia',
            'timestamp' => '2016-03-21T15:05:03Z'
        },
        {
            'id' => 'entry',
            'title' => 'Entry',
            'timestamp' => '2016-03-21T15:05:03Z'
        },
        {
            'id' => 'figure',
            'title' => 'Figure',
            'timestamp' => '2016-03-21T15:05:03Z'
        },
        {
            'id' => 'graphic',
            'title' => 'Graphic',
            'timestamp' => '2016-03-21T15:05:03Z'
        },
        {
            'id' => 'interview',
            'title' => 'Interview',
            'timestamp' => '2016-03-21T15:05:03Z'
        },
        {
            'id' => 'article-journal',
            'title' => 'Journal Article',
            'container' => 'Journal',
            'timestamp' => '2016-03-21T15:05:02Z'
        },
        {
            'id' => 'legal_case',
            'title' => 'Legal Case',
            'timestamp' => '2016-03-21T15:05:03Z'
        },
        {
            'id' => 'legislation',
            'title' => 'Legislation',
            'timestamp' => '2016-03-21T15:05:03Z'
        },
        {
            'id' => 'article-magazine',
            'title' => 'Magazine Article',
            'container' => 'Magazine',
            'timestamp' => '2016-03-21T15:05:02Z'
        },
        {
            'id' => 'manuscript',
            'title' => 'Manuscript',
            'timestamp' => '2016-03-21T15:05:03Z'
        },
        {
            'id' => 'map',
            'title' => 'Map',
            'timestamp' => '2016-03-21T15:05:03Z'
        },
        {
            'id' => 'motion_picture',
            'title' => 'Motion Picture',
            'timestamp' => '2016-03-21T15:05:03Z'
        },
        {
            'id' => 'musical_score',
            'title' => 'Musical Score',
            'timestamp' => '2016-03-21T15:05:03Z'
        },
        {
            'id' => 'article-newspaper',
            'title' => 'Newspaper Article',
            'container' => 'Newspaper',
            'timestamp' => '2016-03-21T15:05:02Z'
        },
        {
            'id' => 'pamphlet',
            'title' => 'Pamphlet',
            'timestamp' => '2016-03-21T15:05:03Z'
        },
        {
            'id' => 'patent',
            'title' => 'Patent',
            'timestamp' => '2016-03-21T15:05:03Z'
        },
        {
            'id' => 'personal_communication',
            'title' => 'Personal Communication',
            'timestamp' => '2016-03-21T15:05:03Z'
        },
        {
            'id' => 'post',
            'title' => 'Post',
            'timestamp' => '2016-03-21T15:05:03Z'
        },
        {
            'id' => 'report',
            'title' => 'Report',
            'timestamp' => '2016-03-21T15:05:03Z'
        },
        {
            'id' => 'review',
            'title' => 'Review',
            'timestamp' => '2016-03-21T15:05:03Z'
        },
        {
            'id' => 'song',
            'title' => 'Song',
            'timestamp' => '2016-03-21T15:05:03Z'
        },
        {
            'id' => 'speech',
            'title' => 'Speech',
            'timestamp' => '2016-03-21T15:05:03Z'
        },
        {
            'id' => 'thesis',
            'title' => 'Thesis',
            'timestamp' => '2016-03-21T15:05:03Z'
        },
        {
            'id' => 'treaty',
            'title' => 'Treaty',
            'timestamp' => '2016-03-21T15:05:03Z'
        },
        {
            'id' => 'webpage',
            'title' => 'Webpage',
            'container' => 'Website',
            'timestamp' => '2016-03-21T15:05:03Z'
        }
    ]
  end

  def self.parse_data(items, options={})
    if options[:id]
      item = items.find { |i| i["id"] == options[:id] }
      return nil if item.nil?

      { data: parse_item(item) }
    else
      { data: parse_items(items), meta: { total: items.length } }
    end
  end

  def self.url
    "#{ENV["LAGOTTO_URL"]}/work_types"
  end
end
