require 'github/markdown'
require 'rouge'

module ApplicationHelper
  def icon(icon, text = nil, html_options = {})
    text, html_options = nil, text if text.is_a?(Hash)

    content_class = "fa fa-#{icon}"
    content_class << " #{html_options[:class]}" if html_options.key?(:class)
    html_options[:class] = content_class

    html = content_tag(:i, nil, html_options)
    html << ' ' << text.to_s unless text.blank?
    html
  end

  def markdown(text)
    text = GitHub::Markdown.render_gfm(text)
    syntax_highlighter(text).html_safe
  end

  def syntax_highlighter(html)
    formatter = Rouge::Formatters::HTML.new(:css_class => 'hll')
    lexer = Rouge::Lexers::Shell.new

    doc = Nokogiri::HTML::DocumentFragment.parse(html)
    doc.search("//pre").each { |pre| pre.replace formatter.format(lexer.lex(pre.text)) }
    doc.to_s
  end

  def formatted_class_name(string)
    return string if string.length < 25

    string.split("::", 2).last
  end

  def states
     %w(waiting working failed done)
  end

  def number_hiding_zero(number)
    (number.nil? || number == 0 ? "" : number_with_delimiter(number))
  end

  def sources
    Source.order("group_id, title")
  end

  def data_centers
    DataCenters.active.order("name")
  end

  def contributors
    Person.order("family_name")
  end

  def people
    Person.order("family_name")
  end

  def author_format(author)
    author = [author] if author.is_a?(Hash)
    authors = Array(author).map do |a|
      if a.is_a?(Hash)
        name = [a.fetch("given", nil), a.fetch("family", nil)].compact.join(' ')
        if a["ORCID"].present?
          pid_short = CGI.escape(a["ORCID"].gsub(/(http|https):\/+(\w+)/, '\2'))
          "<a href=\"/people/#{pid_short}\">#{name}</a>"
        else
          name
        end
      else
        nil
      end
    end.compact

    fa = case authors.length
         when 0..2 then authors.join(" & ")
         when 3..20 then authors[0..-2].join(", ") + " & " + authors.last
         else authors[0..19].join(", ") + " … & " + authors.last
         end
    fa.html_safe
  end

  def date_format(work)
    if work.day
      :long
    elsif work.month
      :month
    else
      :year
    end
  end

  def settings
    Settings[ENV['MODE']]
  end
end
