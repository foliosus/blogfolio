module BlogFolio
  module Date
    def humanize
      current = Date.today
      case
        when (3..6).include?(self.yday - current.yday)
          strftime("This %A")
        when self.yday == (current.yday + 2)
          "In two days"
        when self.yday == (current.yday + 1)
          "Tomorrow"
        when self.yday == current.yday
          "Today"
        when self.yday == (current.yday - 1)
          "Yesterday"
        when self.yday == (current.yday - 2)
          "Two days ago"
        when (3..6).include?(abs(current.yday - self.yday))
          strftime("%A")
        when self.year != current.year
          strftime("%m/%d/%Y")
        when self.cweek == (current.cweek + 2)
          strftime("%A in two weeks")
        when self.cweek == (current.cweek + 1)
          strftime("Next %A")
        when self.cweek == (current.cweek - 1)
          strftime("Last %A")
        when self.cweek == (current.cweek - 2)
          strftime("%A two weeks ago")
        else
          strftime("%b %d")
      end
    end
  end

  module Time
    def humanize
      self.to_date.humanize + (self.to_date.cweek == Date.today.cweek ? " at " + strftime("%l:%M %p") : "")
    end
  end
end

Time.class_eval do
  include BlogFolio::Time
end