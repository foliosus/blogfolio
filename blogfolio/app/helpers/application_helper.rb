# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def format_date(date)
    date.to_s(:short)
  end
  
  def humanize_date(date)
    current = Date.today
    case
      when (3..6).include?(date.yday - current.yday)
        date.strftime("This %A")
      when date.yday == (current.yday + 2)
        "In two days"
      when date.yday == (current.yday + 1)
        "Tomorrow"
      when date.yday == current.yday
        "Today"
      when date.yday == (current.yday - 1)
        "Yesterday"
      when date.yday == (current.yday - 2)
        "Two days ago"
      when (3..6).include?((current.yday - date.yday).abs)
        date.strftime("%A")
      when date.year != current.year
        date.strftime("%m/%d/%Y")
      when date.cweek == (current.cweek + 2)
        date.strftime("%A in two weeks")
      when date.cweek == (current.cweek + 1)
        date.strftime("Next %A")
      when date.cweek == (current.cweek - 1)
        date.strftime("Last %A")
      when date.cweek == (current.cweek - 2)
        date.strftime("%A two weeks ago")
      else
        date.strftime("%b %d")
    end
  end
  
  def humanize_time(time)
    humanize_date(time.to_date) + (time.to_date.cweek == Date.today.cweek ? " at " + time.strftime("%l:%M %p") : "")
  end

  # Enable sortable tables by default
  def sort_tables(default_column = 0)
    content_for :head do
      "<script type=\"text/javascript\">
      $(document).ready(function() 
          { 
              $('table').tablesorter({widgets: ['zebra'], sortList: [[#{default_column}, 0]]}); 
          } 
      );
      </script>"
    end
  end

end
